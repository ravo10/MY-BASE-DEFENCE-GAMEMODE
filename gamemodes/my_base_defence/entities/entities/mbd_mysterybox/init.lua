AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

if not ConVarExists("mbd_mysterybox_bo3_ravo_exchangeWeapons") then
	CreateConVar("mbd_mysterybox_bo3_ravo_exchangeWeapons", 1, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "If set to higher than 0, the Player will get his weapon exchanged with the one in the Mystery Box.")
end
if not ConVarExists("mbd_mysterybox_bo3_ravo_MysteryBoxTotalHealth") then
	CreateConVar("mbd_mysterybox_bo3_ravo_MysteryBoxTotalHealth", 1500, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "If set to lower than or equal to 0, the Mystery Box will have an infinite value as health.")
end
if not ConVarExists("mbd_mysterybox_bo3_ravo_hideAllNotificationsFromMysteryBox") then
	CreateConVar("mbd_mysterybox_bo3_ravo_hideAllNotificationsFromMysteryBox", 0, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "If set to lower than or equal to 0, the Mystery Box will not create notifications of any kind.")
end
if not ConVarExists("mbd_mysterybox_bo3_ravo_disableAllParticlesEffects") then
	CreateConVar("mbd_mysterybox_bo3_ravo_disableAllParticlesEffects", 0, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "If set to higher than 0, the Mystery Box will not create any particle effects (good for performance).")
end

util.AddNetworkString("setClientModleMysteryBoxRavo")
util.AddNetworkString("mbd:cheatCode_MysteryboxRavo001")

local function ShowMysteryBoxNotification()
	if GetConVar("mbd_mysterybox_bo3_ravo_hideAllNotificationsFromMysteryBox"):GetInt() <= 0 then
		return true
	else
		return false
	end
end
--
--- --
-- Originally for the Gamemode M.B.D. by: ravo Norway
-- -- -
--------------------
-- Spawn Function --
--------------------
function ENT:SpawnFunction(pl, tr)
	if not tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal

	local ent = ents.Create("mbd_mysterybox")
	ent:SetPos(SpawnPos)
	ent:SetAngles(
		Angle(180, pl:EyeAngles().y, -180)
	)
	ent:SetVirtualOwner(pl)

	ent:Spawn()
	ent:Activate()

	-- Add a special trigger
	local ent_trigger = ents.Create("mbd_mysterybox_trigger")
	if (
		ent and
		ent:IsValid() and
		ent_trigger and
		ent_trigger:IsValid()
	) then
		ent_trigger:SetParentBoxEntity(ent)

		ent_trigger:Spawn()
		ent_trigger:Activate()
	else
		print("Start of error--")
		print("Error: Could not set Trigger for Mystery Box (BO3)... Something was not valid.")
		print("ent:", ent)
		print("ent_trigger:", ent_trigger)
		print("--End of error")

		if ent and ent:IsValid() then ent:Remove() end
		return nil
	end
	--

	return ent
end
----------------
-- Initialize --
----------------
function Bo3RavoMBDIsPlayerAllowedToActivate( self, activator, weaponIsCloseEnough )

	local canUseBox = self:GetCanUseBox()

	-- ** Cancle
	-- Check if Player is allowed to activate this (is within it's bound area/trigger area)
	local maybePlayerCanActivateThisMysterybox = string.Split(activator:GetNWString("CanActivateMysteryboxMBD"), ";")
	local PlayerCanActivateThisBox = table.HasValue(maybePlayerCanActivateThisMysterybox, tostring(self:EntIndex()))
	if (
		not PlayerCanActivateThisBox or (
			not self:GetCanTakeWeapon() and
			not self:GetCanUseBox()
		) or (
			activator:GetEyeTrace().Entity ~= self and
			not weaponIsCloseEnough
		)
	) then
		if (
			self:GetModelScale() > 0 and (
				(
					not canUseBox and
					not PlayerCanActivateThisBox
				) or (
					self:GetDeactivated()
				)
			 )
		) then
			-- Push "back"
			activator:SetVelocity(Vector(200, 200, 0))

			self:EmitSound("mysterybox_bo3/chains_locked.wav")

			if ShowMysteryBoxNotification() then
				activator:SendLua( [[notification.AddLegacy( "Don't touch me! ｡゜(｀Д´)゜｡", NOTIFY_ERROR, 2 )]] )
			end
		end

		return false
	end

	return true

end
function Bo3RavoMBDMysteryBoxTakeWeapon( self, activator, weaponChild )

	-- Only the one who "bought" the weapon can take it
	local _OwnerOfWeapon = weaponChild:GetOwnerPlayer()
	if (
		(
			_OwnerOfWeapon or
			_OwnerOfWeapon:IsValid()
		) and (
			_OwnerOfWeapon ~= activator
		)
	) then
		if ShowMysteryBoxNotification() then
			activator:SendLua( [[notification.AddLegacy("Don't try and steal others weapon ┌(▀Ĺ̯▀)┐", NOTIFY_ERROR, 2)]] )
		end
		
		return
	end

	----------------- -- --------------
	-- Give the weapon in the box -----
	----------------- -- ---------------
	local WeaponClassFromBox = weaponChild:GetCurrentWeaponClassSwitch()
	if not WeaponClassFromBox then return end

	if not MBDbo3RavoNiceWeaponNamesGame then bo3RavoGetNiceWeaponNames() end

	local PlayerActiveWeaponClass = activator:GetActiveWeapon():GetClass()
	local PlayerHasTheCurrentWeaponEquiped = WeaponClassFromBox == PlayerActiveWeaponClass
	local PlayerHasTheCurrentWeaponInHisArsenal = false

	local PlayerHasStockWeaponEquiped = false

	local notAllowedToExhangeSWEPs = {
		"gmod_tool",
		"gmod_camera",
		"weapon_physgun",
		"weapon_physcannon",
		"swep_prop_repair",
		"swep_vehicle_repair"
	}

	-- Check if Player has any other Weapons that is not any of The Basics...
	local PlayersWeapons = activator:GetWeapons()
	local playerWeaponsCount = #PlayersWeapons

	local PlayerHasStockWeaponEquiped = table.HasValue( notAllowedToExhangeSWEPs, PlayerActiveWeaponClass )

	-- Count how many of the Players weapons are stock weapons
	local stockWeaponsCounter = 0 for _,Weapon in pairs( PlayersWeapons ) do

		local class = Weapon:GetClass()

		if table.HasValue( notAllowedToExhangeSWEPs, class ) then stockWeaponsCounter = stockWeaponsCounter + 1 end
		if class == WeaponClassFromBox then PlayerHasTheCurrentWeaponInHisArsenal = true end

	end
	-- If true, just give it to the Player
	local allWeaponsAreStockWeapons = stockWeaponsCounter == playerWeaponsCount

	-- Take away the weapon (if set)
	if GetConVar("mbd_mysterybox_bo3_ravo_exchangeWeapons"):GetInt() > 0 then

		-- Remove all SWEP ammo ( balance )
		if not PlayerHasTheCurrentWeaponInHisArsenal and not PlayerHasTheCurrentWeaponEquiped then

			local currentActiveWeaponBeforeChange = activator:GetActiveWeapon()

			activator:RemoveAmmo( activator:GetAmmoCount( currentActiveWeaponBeforeChange:GetPrimaryAmmoType() ), currentActiveWeaponBeforeChange:GetPrimaryAmmoType() )
			activator:RemoveAmmo( activator:GetAmmoCount( currentActiveWeaponBeforeChange:GetSecondaryAmmoType() ), currentActiveWeaponBeforeChange:GetSecondaryAmmoType() )

		end

		-- Player has a non-stock weapon equiped
		if not PlayerHasTheCurrentWeaponInHisArsenal and not allWeaponsAreStockWeapons then activator:StripWeapon( PlayerActiveWeaponClass ) end

	end

	-- Select the new SWEP
	self:SetCanTakeWeapon( false )

	-- Give SWEP
	activator:Give( WeaponClassFromBox )

	if not PlayerHasTheCurrentWeaponEquiped and ShowMysteryBoxNotification() then

		activator:SendLua( [[notification.AddLegacy( "You picked up: ]] .. MBDbo3RavoNiceWeaponNamesGame[ WeaponClassFromBox ] .. [[", NOTIFY_GENERIC, 4 )]] )

	end

	-- Give ammo if Player got Zero nil nadda
	local playersActiveWeapon = activator:GetActiveWeapon()

	local WasNilPrimaryAmmo = false
	local WasNilSecondaryAmmo = false

	local primaryAmmoType = playersActiveWeapon:GetPrimaryAmmoType() if primaryAmmoType < 0 then
		-- Probably not necaserry...
		if playersActiveWeapon.Primary then
			local __PrimAmmoStringFromTable = playersActiveWeapon.Primary.Ammo
			if __PrimAmmoStringFromTable then
				-- Found the string-ID for it
				primaryAmmoType = __PrimAmmoStringFromTable
			else
				primaryAmmoType = false
			end
		else
			primaryAmmoType = false
		end
	end

	local secondaryAmmoType = playersActiveWeapon:GetSecondaryAmmoType() if secondaryAmmoType < 0 then
		-- Probably not necaserry...
		if playersActiveWeapon.Secondary then
			local __SecAmmoStringFromTable = playersActiveWeapon.Secondary.Ammo
			if __SecAmmoStringFromTable then
				-- Found the string-ID for it
				secondaryAmmoType = __SecAmmoStringFromTable
			else
				secondaryAmmoType = false
			end
		else
			secondaryAmmoType = false
		end
	end

	-- Give
	if PlayerHasTheCurrentWeaponInHisArsenal then

		local NewWeaponEnt for _, Weapon in pairs( activator:GetWeapons() ) do if Weapon:GetClass() == WeaponClassFromBox then NewWeaponEnt = Weapon break end end

		local primaryAmmo = NewWeaponEnt:GetPrimaryAmmoType()
		local secondaryAmmo = NewWeaponEnt:GetSecondaryAmmoType()

		activator:GiveAmmo( 25, primaryAmmo, false )
		activator:GiveAmmo( 3, secondaryAmmo, false )

		local ThereIsActuallyAmmoAvailable = ( primaryAmmo >= 0 or secondaryAmmo >= 0 )

		-- If the Player already got the SWEP, just give ammo
		if PlayerHasTheCurrentWeaponEquiped and ShowMysteryBoxNotification() then

			if ThereIsActuallyAmmoAvailable then
			
				activator:SendLua( [[notification.AddLegacy( "You already have: ]] .. MBDbo3RavoNiceWeaponNamesGame[ WeaponClassFromBox ] .. [[; gave ammo", NOTIFY_GENERIC, 4 )]] )

			else
				
				activator:SendLua( [[notification.AddLegacy( "You already have: ]] .. MBDbo3RavoNiceWeaponNamesGame[ WeaponClassFromBox ] .. [[", NOTIFY_GENERIC, 4 )]] )

			end

		end

	end

	-- Select SWEP
	timer.Simple( 0, function() activator:SelectWeapon( WeaponClassFromBox ) end )

	weaponChild:SetRenderMode( RENDERMODE_TRANSALPHA )
	weaponChild:SetColor( Color(0, 0, 0, 0) )
	weaponChild:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

	-- Delete "Weapon" as it is now taken by the Player
	timer.Simple( 0.3, function()

		if weaponChild:IsValid() and weaponChild:GetParentBoxEntity():IsValid() then

			weaponChild:GetParentBoxEntity():WeaponTaken()
			weaponChild:Remove()

		end

	end )

end

function ENT:Initialize()
	self:SetName("mbd_ent")
	
	self:SetUseType(SIMPLE_USE)
	
	self:SetModel("models/mysterybox_bo3/mysterybox_bo3.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	if GetConVar("mbd_mysterybox_bo3_ravo_disableAllParticlesEffects"):GetInt() <= 0 then
		self:ResetSequence("idle_box")
	end
end
------------
-- Damage --
------------
function ENT:OnTakeDamage(dmginfo)
	local damageAmount = dmginfo:GetDamage()

	local currHealth = self:GetMysteryboxHealth()
	if GetConVar("mbd_mysterybox_bo3_ravo_MysteryBoxTotalHealth"):GetInt() <= 0 then currHealth = nil end

	local newHealth = ( ( currHealth or 0 ) - damageAmount )
	------ -- -
	-- Set health
	if newHealth > 0 then self:SetMysteryboxHealth( newHealth ) elseif currHealth then
		-- Destroy
		self:Remove()
		mbd_Bo3Ravo_SpawnKillmodelProps( self, { "models/hunter/blocks/cube025x025x025.mdl", "models/hunter/blocks/cube025x025x025.mdl", "models/hunter/blocks/cube025x025x025.mdl" }, 0 )
	end
end
----------
-- USE --
----------
function ENT:Use(activator, caller, useType, value)

	if not activator or not activator:IsValid() or not activator:IsPlayer() then return end

	-- The Weapon can be close to activator... Then allow also to click "use" key
	local weaponChild = self:GetWeaponEntity()
	local weaponIsCloseEnough = false

	if weaponChild and weaponChild:IsValid() then

		weaponChild:MaybeAdjustTheChanceToGetATeddybear()

		if activator:GetPos():Distance(weaponChild:GetPos()) <= 85 then weaponIsCloseEnough = true end

	end

	local canUseBox = self:GetCanUseBox()

	if not Bo3RavoMBDIsPlayerAllowedToActivate( self, activator, weaponIsCloseEnough ) then return end

	if canUseBox and self:GetHasValidAngles() then

		-- Open the box and Spawn the "Weapons" entity
		self:SetCanUseBox( false )
		self:PlayerBoughtAWeapon()

		local MysteryBoxSWEP = ents.Create( "mbd_mysterybox_weapon" )

		------- -
		-- Save the relationship between the two
		--          -----------
		self:SetWeaponEntity( MysteryBoxSWEP )
		MysteryBoxSWEP:SetParentBoxEntity( self )
		MysteryBoxSWEP:SetOwnerPlayer( activator )

		MysteryBoxSWEP:Spawn()

		-- Add to the amount of uses
		self:SetAmountOfUses( self:GetAmountOfUses() + 1 )

	elseif not canUseBox and weaponChild and weaponChild:IsValid() then Bo3RavoMBDMysteryBoxTakeWeapon( self, activator, weaponChild ) end

	return true

end
-----------
-- SOUND --
-----------
-- These IDs are defined in the .QC file for the model (when to fire etc.)
local soundTable = {
	basePath = "mysterybox_bo3/",
	mysterybox_bo3 = {
		latch = {
			open = "open.wav",
			close = "close.wav",
			music_box = "music_box.wav",
		},
		latch_wep_taken = {
			purchase = "purchase.wav",
			close = "close.wav"
		},
		teddybear = {
			child = "child.wav",
			bye_bye = "bye_bye.wav",
			disappear = "disappear.wav",
			whoosh = "whoosh.wav",
			poof = "poof.wav",
			land = "land.wav",
			rich = "rich.wav"
		}
	}
}

local allPossibleSounds = {

	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "latch" ][ "open" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "latch" ][ "close" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "latch" ][ "music_box" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "latch_wep_taken" ][ "purchase" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "latch_wep_taken" ][ "close" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "teddybear" ][ "child" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "teddybear" ][ "bye_bye" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "teddybear" ][ "disappear" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "teddybear" ][ "whoosh" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "teddybear" ][ "poof" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "teddybear" ][ "land" ],
	soundTable[ "basePath" ] .. soundTable[ "mysterybox_bo3" ][ "teddybear" ][ "rich" ]

}

function ENT:HandleAnimEvent(event, eventTime, cycle, type, options)
	if (
		event == 32 and
		GetConVar("mbd_mysterybox_bo3_ravo_disableAllParticlesEffects"):GetInt() > 0
	) then
		-- Must do this to be sure...
		local timerID = "mbd_mysteryboxStopParticleEffect001"..self:EntIndex()
		timer.Remove(timerID)
		timer.Create(timerID, 0.3, (6 / 0.3), function()
			if self and self:IsValid() then
				self:StopParticles()
			else timer.Remove(timerID) end
		end)
	end

	local soundPath = options
	local soundTablePath = {}

	-- Filename
	for k,v in pairs(string.Split(soundPath, ".")) do
		table.insert(soundTablePath, v)
	end
	if not soundTable or not soundTablePath[1] or not soundTablePath[2] or not soundTablePath[3] then return end
	local __soundFileName = soundTable[soundTablePath[1]][soundTablePath[2]][soundTablePath[3]]

	-- Extra >>
	if soundTablePath[3] == "poof" then
		if not self or not self:IsValid() then return end

		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		self:SetModelScale(0, 0.3)

		-- Wait a little before reappearing
		timer.Simple(math.random(5, 20), function()
			if not self or not self:IsValid() then return end

			self:SetModelScale(1, 0.3)
			
			self:IdleTeddybear()
		end)
	elseif soundTablePath[3] == "rich" then
		if not self or not self:IsValid() then return end

		-- If a Player is very close (when it falls down), take allot of damage...
		local timerID = "mbd:MysteryBoxPushUpPlayer001"..self:EntIndex()
		local punishedPlayers = {}
		timer.Create(timerID, 0.15, math.Round((4.8 --[[ sec. (punisher lasts this long) ]] / 0.15)), function()
			for _,_Player in pairs(player.GetAll()) do
				if (
					_Player and
					_Player:IsValid() and
					self and
					self:IsValid() and
					_Player:GetPos():Distance(self:GetPos()) <= 100 -- Pretty close all around; like on the landing spot almost
				) then
					_Player:SetNotSolid(true)
					
					_Player:SetVelocity(Vector(0, 0, 2400))

					if not table.HasValue(punishedPlayers, _Player) then
						table.insert(punishedPlayers, _Player)

						SendLocalSoundToAPlayer("mysterybox_bo3_nani", _Player)
						if ShowMysteryBoxNotification() then
							ClientPrintAddTextMessage(_Player, {Color(254, 81, 0), "To close bruh; wait 5 sec. ( ͡° ͜ʖ ͡°)"})
						end

						timer.Simple(4, function()
							if _Player and _Player:IsValid() then
								_Player:SetVelocity(Vector(0, 0, -10000 * 5))

								timerID0 = nil
								timerID1 = nil

								timerID0 = "mbd:MysteryBoxPushUpPlayer001DamagerChecker"..math.random(-1000, 1000).._Player:UniqueID()
								timer.Create(timerID0, 0.15, (6 / 0.15), function()
									if _Player and _Player:IsValid() then
										if not _Player:Alive() then timer.Remove(timerID1) end
									end
								end)
	
								timerID1 = "mbd:MysteryBoxPushUpPlayer001Damager"..math.random(-1000, 1000).._Player:UniqueID()
								timer.Create(timerID1, 0.75, 3, function()
									if _Player and _Player:IsValid() then
										if not _Player:Alive() then timer.Remove(timerID1) end

										_Player:SetNotSolid(false)

										_Player:TakeDamage(7, game.GetWorld(), self)
									end
								end)
							end
						end)
					end
				end
			end
		end)

		-- Just wait a little...
		timer.Simple(1, function()
			if not self or not self:IsValid() then return end

			self:SetSolid(SOLID_VPHYSICS)
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
			self:SetMoveType(MOVETYPE_VPHYSICS)
		end)
	end

	-- Emit
	self:EmitSound(soundTable.basePath..__soundFileName)
end
function ENT:Think()
	local _Angles = self:GetAngles()
	local _PitchAng = math.Round(_Angles.p)
	if _PitchAng < 0 then _PitchAng = _PitchAng * -1 end
	local _RollAng = math.Round(_Angles.r)
	if _RollAng < 0 then _RollAng = _RollAng * -1 end

	if (
		_PitchAng > 17 or
		_RollAng > 24
	) then
		-- Can not use
		if self:GetHasValidAngles() then self:SetHasValidAngles(false) end
	else
		if not self:GetHasValidAngles() then self:SetHasValidAngles(true) end
	end

	self:NextThink(CurTime() + 0.1)
	return true
end
--- - -
function ENT:PlayerBoughtAWeapon()
	if not self or not self:IsValid() then return end

	self:ResetSequence("latch_open")
end
function ENT:WeaponExpired()
	if not self or not self:IsValid() then return end

	self:ResetSequence("latch_close")

	timer.Simple(1.75, function()
		if not self:IsValid() then return end

		self:SetCanUseBox(true)
		self:SetCanTakeWeapon(false)
	end)
end
function ENT:WeaponTaken()
	if not self or not self:IsValid() then return end

	self:ResetSequence("latch_close_wep_taken")

	timer.Simple(0.6, function()
		if not self:IsValid() then return end

		self:SetCanUseBox(true)
		self:SetCanTakeWeapon(false)
	end)
end
function ENT:TeddybearIncoming()
	if not self or not self:IsValid() then return end

	self:SetCanUseBox(false)
	self:SetAmountOfUses(0)

	self:SetMoveType(MOVETYPE_NONE)

	self:ResetSequence(self:LookupSequence("teddybear_box_away"))
end
function ENT:PutTeddyBearSittingOnTopChains()
	if not self or not self:IsValid() then return end
	
	-- Put the Teddybear on top (sub.-model)
	local teddybear = self:FindBodygroupByName("teddybear")
	self:SetBodygroup(teddybear, 1)
	-- Add the Chains (sub.-model)
	local chains = self:FindBodygroupByName("chains_locked")
	self:SetBodygroup(chains, 1)
end
function ENT:RemoveTeddyBearSittingOnTopChains()
	if not self or not self:IsValid() then return end
	
	-- Remove the Teddybear on top (sub.-model)
	local teddybear = self:FindBodygroupByName("teddybear")
	self:SetBodygroup(teddybear, 0)
	-- Remove the Chains (sub.-model)
	local chains = self:FindBodygroupByName("chains_locked")
	self:SetBodygroup(chains, 0)

	self:ResetSequence("idle_box")
end
function ENT:IdleTeddybear()
	if not self or not self:IsValid() then return end

	self:PutTeddyBearSittingOnTopChains()

	self:ResetSequence("teddybear_idle")
	self:SetDeactivated(true)

	-- OK to use again after this timer >>>
	timer.Create(self:GetRemoveIdleTimerID(), (60 * math.random(5, 35) / 10), 1, function()
		if not self or not self:IsValid() or self.RemoveTeddyBearSittingOnTopChains then return end

		self:RemoveTeddyBearSittingOnTopChains()

		self:SetCanUseBox(true)
		self:SetDeactivated(false)
	end)
end
--- -- -
-- - Cheatss
function ENT:CheatCode001()
	-- Active box again
	timer.Remove(self:GetRemoveIdleTimerID())

	self:RemoveTeddyBearSittingOnTopChains()

	self:SetCanUseBox(true)
	self:SetDeactivated(false)
end
net.Receive("mbd:cheatCode_MysteryboxRavo001", function(len, pl)
	local cheatCodeActivated = net.ReadTable()

	if pl:MBDIsNotAnAdmin(true) then return end

	local type 			= cheatCodeActivated.type
	local mysteryboxEnt = cheatCodeActivated.mysteryboxEnt

	if type == "001" then
		mysteryboxEnt:CheatCode001()
	end

	if pl and pl:IsValid() then
		if ShowMysteryBoxNotification() then
			pl:SendLua([[notification.AddLegacy("You: ( ° ͜ʖ͡°)╭∩╮, entered a cheat code for a Mystery box.", NOTIFY_GENERIC, 5)]])
		end
	end
end)

function ENT:OnRemove()

	-- Stop all sounds
	for _, sound in pairs( allPossibleSounds ) do self:StopSound( sound ) end

end
