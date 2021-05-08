local strictSetting = 1
if GetConVar("mbd_enableStrictMode"):GetInt() then
	strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
end

-- Variables that are used on both client and server

SWEP.PrintName		= "Tool Gun"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModel		= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel		= "models/weapons/w_toolgun.mdl"

SWEP.UseHands		= true
SWEP.Spawnable		= true

-- Be nice, precache the models
util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

-- Todo, make/find a better sound.
SWEP.ShootSound = Sound( "Airboat.FireGunRevDown" )

SWEP.Tool = {}

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.CanHolster = true
SWEP.CanDeploy = true

local sendLocalMessageToPlayer = function(message, owner)
	net.Start("TellNotificationError")
		net.WriteString(message)
	net.Send(owner)
end

function SWEP:SetupDataTables()

	self:NetworkVar( "Entity", 0, "TargetEntity1" )
	self:NetworkVar( "Entity", 1, "TargetEntity2" )
	self:NetworkVar( "Entity", 2, "TargetEntity3" )
	self:NetworkVar( "Entity", 3, "TargetEntity4" )

	-- CUSTOM
	self:NetworkVar("Entity", 4, "RightClickEnt1")
	self:NetworkVar("Entity", 5, "RightClickEnt2")
	
	self:NetworkVar("Bool", 1, "ToolThatIsInUseIsBlacklisted")
	
	if SERVER then
		self:SetRightClickEnt1(nil)
		self:SetRightClickEnt2(nil)
		self:SetToolThatIsInUseIsBlacklisted(false)
	end

end

function SWEP:NotifyThatTheToolIsBlackListed()
	local owner = self.Owner

	-- Tell
	net.Start("NotificationReceivedFromServer")
		net.WriteTable({
			Text 	= "Blacklisted tool!",
			Type	= NOTIFY_ERROR,
			Time	= 2
		})
	net.Send(owner)
	timer.Simple(0.3, function()
		net.Start("NotificationReceivedFromServer")
			net.WriteTable({
				Text 	= "Choose another tool.",
				Type	= NOTIFY_ERROR,
				Time	= 3
			})
		net.Send(owner)
	end)
end

function SWEP:InitializeTools()

	local temp = {}

	for k,v in pairs( self.Tool ) do

		temp[k] = table.Copy( v )
		temp[k].SWEP = self
		temp[k].Owner = self.Owner
		temp[k].Weapon = self.Weapon
		temp[k]:Init()

	end

	self.Tool = temp

end


-- Convenience function to check object limits
function SWEP:CheckLimit( str )
	return self:GetOwner():CheckLimit( str )
end

function SWEP:Initialize()

	self:SetHoldType( "revolver" )

	self:InitializeTools()

	-- We create these here. The problem is that these are meant to be constant values.
	-- in the toolmode they're not because some tools can be automatic while some tools aren't.
	-- Since this is a global table it's shared between all instances of the gun.
	-- By creating new tables here we're making it so each tool has its own instance of the table
	-- So changing it won't affect the other tools.

	self.Primary = {
		ClipSize = -1,
		DefaultClip = -1,
		Automatic = false,
		Ammo = "none"
	}

	self.Secondary = {
		ClipSize = -1,
		DefaultClip = -1,
		Automatic = false,
		Ammo = "none"
	}

end

function SWEP:OnRestore()

	self:InitializeTools()

end

function SWEP:Precache()

	util.PrecacheSound( self.ShootSound )

end

function SWEP:Reload()

	if strictSetting == 1 and self:GetToolThatIsInUseIsBlacklisted() then
		self:NotifyThatTheToolIsBlackListed()

		return false
	end

	-- This makes the reload a semi-automatic thing rather than a continuous thing
	if ( !self.Owner:KeyPressed( IN_RELOAD ) ) then return end

	local mode = self:GetMode()
	local trace = self.Owner:GetEyeTrace()
	if ( !trace.Hit ) then return end

	local tool = self:GetToolObject()
	if ( !tool ) then return end

	tool:CheckObjects()

	-- Does the server setting say it's ok?
	if ( !tool:Allowed() ) then return end

	-- Ask the gamemode if it's ok to do this
	if ( !gamemode.Call( "CanTool", self.Owner, trace, mode ) ) then return end

	if ( !tool:Reload( trace ) ) then return end

	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

end

-- Returns the mode we're in
function SWEP:GetMode()

	return self.Mode

end

-- Think does stuff every frame
function SWEP:Think()

	self.Mode = self.Owner:GetInfo( "gmod_toolmode" )

	local tool = self:GetToolObject()
	if ( !tool ) then return end

	tool:CheckObjects()

	self.last_mode = self.current_mode
	self.current_mode = self.Mode

	-- Release ghost entities if we're not allowed to use this new mode?
	if ( !tool:Allowed() ) then
		self:GetToolObject( self.last_mode ):ReleaseGhostEntity()
		return
	end

	if ( self.last_mode != self.current_mode ) then

		if ( !self:GetToolObject( self.last_mode ) ) then return end

		-- We want to release the ghost entity just in case
		self:GetToolObject( self.last_mode ):Holster()

	end

	self.Primary.Automatic = tool.LeftClickAutomatic or false
	self.Secondary.Automatic = tool.RightClickAutomatic or false
	self.RequiresTraceHit = tool.RequiresTraceHit or true

	tool:Think()

end

-- The shoot effect
function SWEP:DoShootEffect( hitpos, hitnormal, entity, physbone, bFirstTimePredicted )

	self:EmitSound( self.ShootSound )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) -- View model animation

	-- There's a bug with the model that's causing a muzzle to
	-- appear on everyone's screen when we fire this animation.
	self.Owner:SetAnimation( PLAYER_ATTACK1 ) -- 3rd Person Animation

	if ( !bFirstTimePredicted ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetNormal( hitnormal )
	effectdata:SetEntity( entity )
	effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetStart( self.Owner:GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self )
	util.Effect( "ToolTracer", effectdata )

end

-- Trace a line then send the result to a mode function
function SWEP:PrimaryAttack()

	if strictSetting == 1 and self:GetToolThatIsInUseIsBlacklisted() then
		self:NotifyThatTheToolIsBlackListed()

		return false
	end

	local mode = self:GetMode()
	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end

	local tool = self:GetToolObject()
	if ( !tool ) then return end

	tool:CheckObjects()

	-- Does the server setting say it's ok?
	if ( !tool:Allowed() ) then return end

	-- Ask the gamemode if it's ok to do this
	if ( !gamemode.Call( "CanTool", self.Owner, trace, mode ) ) then return end

	if ( !tool:LeftClick( trace ) ) then return end

	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

end

function SWEP:SecondaryAttack()
	if strictSetting == 1 and self:GetToolThatIsInUseIsBlacklisted() then
		self:NotifyThatTheToolIsBlackListed()

		return false
	end

	--- - -- CUSTOM
	--- -
	local currentMode = self:GetTable()["current_mode"]
	--
	if currentMode == "mbd_door" then
		if CLIENT then return false end

		--[[ 
			Since:
			self:GetRightClickEnt1() and
			self:GetRightClickEnt2() is an Entity, it will always be that, but can be a null entity.
		]]

		-- Play a small sound...
		
		local _Owner    = self.Owner
		local _Weapon   = self.Weapon
		_Weapon:SetNextSecondaryFire(CurTime() + 0.15)

		local trace = _Owner:GetEyeTrace()
		local _TraceEntity    = trace.Entity
		
		if !_TraceEntity or !_TraceEntity:IsValid() or _TraceEntity:IsVehicle() then return false end
		local ent = GetCorrectEntForProps(_TraceEntity)

		-- Reset
		if self:GetRightClickEnt1():IsValid() and self:GetRightClickEnt2():IsValid() then
			self:SetRightClickEnt1(nil)
			self:SetRightClickEnt2(nil)
		end

		local invalidSelection = function()
			self:SetRightClickEnt1(nil)
			self:SetRightClickEnt2(nil)

			sendLocalMessageToPlayer("Select a DOOR and one PLAYER!", _Owner)
		end

		local checkIfThePropHasADoor = function(_Entity)
			-- -
			-- Find the custom Door entity placed in the prop (maybe)
			local theDoor = nil
			if !ent:IsPlayer() then
				for _,v in pairs(_Entity:GetChildren()) do
					if v:GetClass() == "mbd_door_trigger" then theDoor = v break end
				end
		
				--- -
				-- Check if the prop actually has a Door...
				if !theDoor then
					-- Check if Ent nr. 1 is a Door and Ent nr. 2 also...
					if
						self:GetRightClickEnt1():IsValid() and
						!self:GetRightClickEnt1():IsPlayer() and
						self:GetRightClickEnt2():IsValid() and
						!self:GetRightClickEnt2():IsPlayer()
					then
						invalidSelection()
					elseif
						_TraceEntity:IsValid() and
						!_TraceEntity:IsPlayer() and
						!_TraceEntity:IsNPC()
					then
						sendLocalMessageToPlayer("The Prop has NO DOOR yet!", _Owner)
					else return end
				end
			end

			return theDoor
		end
		-- - -
		-- Add; maybe
		if !self:GetRightClickEnt1():IsValid() then
			local theDoorEnt = checkIfThePropHasADoor(ent)
			
			if theDoorEnt or ent:IsPlayer() then
				self:SetRightClickEnt1(theDoorEnt or ent)

				-- - -
				-- Tell the Player whats going on...
				local message = "Entity 1 chosen - Now choose a "
				if ent:IsPlayer() then message = message.."DOOR" else message = message.."PLAYER" end

				net.Start("NotificationReceivedFromServer")
					net.WriteTable({
						Text 	= message,
						Type	= NOTIFY_GENERIC,
						Time	= 4
					})
				net.Send(_Owner)

				self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
			end

			return true
		elseif !self:GetRightClickEnt2():IsValid() then
			local theDoorEnt = checkIfThePropHasADoor(ent)

			if theDoorEnt or ent:IsPlayer() then
				self:SetRightClickEnt2(theDoorEnt or ent)

				-- - -
				-- Tell the Player whats going on...
				local message = "Entity 2 chosen - Checking..."

				net.Start("NotificationReceivedFromServer")
					net.WriteTable({
						Text 	= message,
						Type	= NOTIFY_GENERIC,
						Time	= 4
					})
				net.Send(_Owner)

				self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )
			end
			-- -- -
			--- -
			-- Correct the entity order
			local Ent1ShouldBeProp = nil -- Should be Prop
			local Ent2ShouldBePlayer = nil -- Should be Player
			if !self:GetRightClickEnt1():IsPlayer() then
				Ent1ShouldBeProp = self:GetRightClickEnt1()
				Ent2ShouldBePlayer = self:GetRightClickEnt2()
			else
				-- Switch
				Ent1ShouldBeProp = self:GetRightClickEnt2()
				Ent2ShouldBePlayer = self:GetRightClickEnt1()
			end
			-- Save
			self:SetRightClickEnt1(Ent1ShouldBeProp)
			self:SetRightClickEnt2(Ent2ShouldBePlayer)

			-- - -
			-- -- Check that there is one valid Prop and One Player (for now..)
			if Ent1ShouldBeProp:IsPlayer() or !Ent2ShouldBePlayer:IsPlayer() then
				timer.Simple(0.9, function()
					invalidSelection()
				end)

				return false
			end

			-- -
			--
			-- -
			-- -- Everything OK =>>
			timer.Simple(0.6, function()
				if self:GetRightClickEnt1():IsValid() and self:GetRightClickEnt2():IsValid() then
					local _DoorTrigger 		= self:GetRightClickEnt1()
					local _PlayerUniqueID 	= self:GetRightClickEnt2():UniqueID()
	
					local _AllowedPlayers 	= _DoorTrigger:GetNWString("allPlayersAllowedUniqueID", nil)
					if _AllowedPlayers then _AllowedPlayers = (_AllowedPlayers.." ".._PlayerUniqueID) else return false end
					
					-- Update =>>
					_DoorTrigger:SetNWString("allPlayersAllowedUniqueID", _AllowedPlayers)
	
					-- - -
					-- Tell the Player whats going on...
					local message = "Added new PLAYER ("..self:GetRightClickEnt2():Nick()..") to DOOR!"
	
					net.Start("NotificationReceivedFromServer")
						net.WriteTable({
							Text 	= message,
							Type	= NOTIFY_GENERIC,
							Time	= 4
						})
					net.Send(_Owner)

					-- Reset
					self:SetRightClickEnt1(nil)
					self:SetRightClickEnt2(nil)
				end
			end)
		end

		return true
	else
		local mode = self:GetMode()
		local tr = util.GetPlayerTrace(self.Owner)
		tr.mask = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX)
		local trace = util.TraceLine(tr)
		if !trace.Hit then return end

		local tool = self:GetToolObject()
		if !tool then return end

		tool:CheckObjects()

		-- Ask the gamemode if it's ok to do this
		if !tool:Allowed() then return end
		if !gamemode.Call("CanTool", self.Owner, trace, mode) then return end

		if !tool:RightClick(trace) then return end

		self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
	end
	
end

function SWEP:Holster()

	-- Just do what the SWEP wants to do if there's no tool
	if ( !self:GetToolObject() ) then return self.CanHolster end

	local CanHolster = self:GetToolObject():Holster()
	if ( CanHolster ~= nil ) then return CanHolster end

	return self.CanHolster

end

-- Delete ghosts here in case the weapon gets deleted all of a sudden somehow
function SWEP:OnRemove()
	--- - -- CUSTOM
	--- -
	local currentMode = self:GetTable()["current_mode"]
	--
	if currentMode == "mbd_door" then
		if SERVER then
			self:GetOwner():MBDRemoveAllRelatedDoors()
		end
	else
		if ( !self:GetToolObject() ) then return end

		self:GetToolObject():ReleaseGhostEntity()
	end
end
function SWEP:OnDrop()
	--- - -- CUSTOM
	--- -
	local currentMode = self:GetTable()["current_mode"]
	--
	if currentMode == "mbd_door" then
		local _Owner = self:GetNWEntity("Owner", nil)

		if !_Owner or !_Owner:IsValid() then return end
		_Owner:MBDRemoveAllRelatedDoors()

		--- Clear table
		if SERVER then
			self:SetRightClickEnt1(nil)
			self:SetRightClickEnt2(nil)
		end
	end
end


-- This will remove any ghosts when a player dies and drops the weapon
function SWEP:OwnerChanged()

	if ( !self:GetToolObject() ) then return end

	self:GetToolObject():ReleaseGhostEntity()

end

-- Deploy
function SWEP:Deploy()
	
	-- Just do what the SWEP wants to do if there is no tool
	if ( !self:GetToolObject() ) then return self.CanDeploy end

	self:GetToolObject():UpdateData()

	local CanDeploy = self:GetToolObject():Deploy()
	if ( CanDeploy ~= nil ) then return CanDeploy end

	return self.CanDeploy

end
function SWEP:GetToolObject( tool )

	local mode = tool or self:GetMode()

	if SERVER then
		-- MBD:: Control what is possible to use in strict mode
		if mode and strictSetting == 1 then
			local owner = self:GetOwner()
			if owner and owner:IsValid() then
				-- Case Sensitive
				if !table.HasValue(MBDToolgunAndSettingsWhiteListOnlyModelNames, mode) then
					if !self:GetToolThatIsInUseIsBlacklisted() then
						-- Tell
						net.Start("NotificationReceivedFromServer")
							net.WriteTable({
								Text 	= "Blacklisted tool! \""..mode.."\"",
								Type	= NOTIFY_ERROR,
								Time	= 2
							})
						net.Send(owner)
						timer.Simple(0.3, function()
							net.Start("NotificationReceivedFromServer")
								net.WriteTable({
									Text 	= "Choose another tool.",
									Type	= NOTIFY_ERROR,
									Time	= 3
								})
							net.Send(owner)
						end)
					end
					self:SetToolThatIsInUseIsBlacklisted(true)

					return false
				else
					-- OK
					self:SetToolThatIsInUseIsBlacklisted(false)
				end
			end
		end
		if self:GetToolThatIsInUseIsBlacklisted() then return false end
	end

	if ( !self.Tool[ mode ] ) then return false end

	return self.Tool[ mode ]

end

function SWEP:FireAnimationEvent( pos, ang, event, options )

	-- Disables animation based muzzle event
	if ( event == 21 ) then return true end
	-- Disable thirdperson muzzle flash
	if ( event == 5003 ) then return true end

end

include( "stool.lua" )
