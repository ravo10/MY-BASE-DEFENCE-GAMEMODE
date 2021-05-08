if CLIENT then
	--
	  -- Toolgun-UI-tekst
	--
	language.Add("tool.mbd_door.name", "Door")
	language.Add("tool.mbd_door.desc", "Make a door from a prop to your base")
	
	language.Add("tool.mbd_door.left", "Apply a door")
	language.Add("tool.mbd_door.right", "Add another Player to the door")
	language.Add("tool.mbd_door.reload", "Remove the door/a targeted Player's access to all doors")
	--
	TOOL.Author		= "ravo Norway"
	TOOL.Category   = "Interior"
	TOOL.Name	    = "#tool.mbd_door.name"

	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" }
	}

	-- Variables >>

	TOOL.ClientConVar["Door1"] = nil
	TOOL.ClientConVar["Door2"] = nil

	function TOOL.BuildCPanel(CPanel)
		CPanel:SetName("Door Tool | v2.0")

		-- --->>
		--
		CPanel:Help("")
		CPanel:Help("This tool is for the M.B.D. Gamemode.")
		CPanel:ControlHelp("Made by: ravo (Norway)")
		CPanel:Help("")
	end
end
-- -
-- The shoot effect
function TOOL:DoShootEffect(hitpos, hitnormal, entity, physbone, bFirstTimePredicted)
	self.Weapon:EmitSound(self.Weapon.ShootSound)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- View model animation

	-- There's a bug with the model that's causing a muzzle to
	-- appear on everyone's screen when we fire this animation.
	self.Weapon.Owner:SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation

	if ( !bFirstTimePredicted ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetNormal( hitnormal )
	effectdata:SetEntity( entity )
	effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetStart( self.Weapon.Owner:GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )
end
-- - - ---- Action >>>
function TOOL:Deploy()
	if SERVER then
		-- This is needed when dropping the weapon... Because then
		-- the tool will have no owner and we can't access "self" as here...
		self.SWEP:SetNWEntity("Owner", self:GetOwner())
	end
end
local sendLocalMessageToPlayer = function(message, owner)
	net.Start("TellNotificationError")
		net.WriteString(message)
	net.Send(owner)
end
--
-- Left Click
function TOOL:LeftClick(tr)
	if CLIENT then return true end

	local _Owner = self:GetOwner()

	if self.Door1 and !self.Door1:IsValid() then self.Door1 = nil end
	if self.Door2 and !self.Door2:IsValid() then self.Door2 = nil end

	if self.Door1 and self.Door2 then
		sendLocalMessageToPlayer("You can only have Two Doors!", _Owner)

		return false
	end

	if !tr.Entity or !tr.Entity:IsValid() then return false end
	if SERVER then tr.Entity = GetCorrectEntForProps(tr.Entity) end
	local ent = tr.Entity

	-- Don't allow these Props under any circumstances...
	local _entClass = ent:GetClass()
	if (
		ent:GetNWBool("hasAMBDDoor", false) or
		_entClass == "mbd_npc_spawner_all" or
		_entClass == "mbd_buybox"
	) then return end

	-- Only allow a few things...
	if !ent or !ent:IsValid() then return end
	if ent:IsPlayer() or ent:IsNPC() or ent:IsWorld() then return end
	
	local _Children 		= ent:GetChildren()
	local _ChildrenLength 	= #_Children
	for k, v in pairs(_Children) do
		if v:GetClass() == "mbd_door_trigger" then return false end
	end
	--
	--- --- >>>
	-- INSERT A TRIGGER BOUNDING BOX (RADIUS) FOR DOOR...>>>
	ent:SetNWBool("hasAMBDDoor", true)

	local ent_door_trigger = ents.Create("mbd_door_trigger")
	ent_door_trigger:SetCollisionGroup(COLLISION_GROUP_BREAKABLE_GLASS)

	ent_door_trigger:SetPos(ent:GetPos())
	ent_door_trigger:SetAngles(ent:GetAngles())

	ent_door_trigger:SetParent(ent)
	ent_door_trigger:SetName("mbd_prop_door_trigger")
	ent_door_trigger:SetOwner(_Owner)

	ent_door_trigger:SetModel(ent:GetModel())
	ent_door_trigger:SetModelScale(1, 0)

	ent_door_trigger:Spawn()
	ent_door_trigger:Activate()
	--
	ent_door_trigger:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent_door_trigger:SetColor(
		Color(
			0,
			0,
			0,
			0
		)
	)

	-- Very important to set it here after spawn...
	ent_door_trigger:UseTriggerBounds(true, 3)
	ent_door_trigger:SetTrigger(true)

	ent_door_trigger:SetNotSolid(true)

	timer.Simple(0.2, function()
		ent:SetRenderMode(RENDERMODE_TRANSALPHA)
		local _CurrColor = ent:GetColor()
		ent:SetNWString("OriginalColor", _CurrColor.r..",".._CurrColor.g..",".._CurrColor.b)
		ent:SetColor(
			Color(255, 255, 255, 230)
		)

		-- Save the Door
		if !self.Door1 then self.Door1 = ent
		elseif !self.Door2 then self.Door2 = ent end
	end)

	-- Everything OK
	-- Notify
	if SERVER then
		net.Start("NotificationReceivedFromServer")
			net.WriteTable({
				Text 	= "You made a NEW DOOR!",
				Type	= NOTIFY_GENERIC,
				Time	= 2.3
			})
		net.Send(_Owner)
	end

	self:DoShootEffect(tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted())
	
	return true
end
--
-- Right Click
-- Look in the shared.lua

--
-- Reload
function TOOL:Reload(tr)
	if CLIENT then return true end
	
	if !tr.Entity or !tr.Entity:IsValid() then return false end

	local _Owner = self:GetOwner()

	if SERVER then tr.Entity = GetCorrectEntForProps(tr.Entity) end
	local ent = tr.Entity
	if !ent or !ent:IsValid() then return false end
	
	if !ent:IsNPC() then
		local _Children 		= ent:GetChildren()
		local _ChildrenLength 	= #_Children
		for k, v in pairs(_Children) do
			if v:GetClass() == "mbd_door_trigger" then
				v:Remove()

				timer.Simple(0.1, function()
					if !ent or !ent:IsValid() then return end

					ent:SetRenderMode(RENDERMODE_NORMAL)
					local OriginalColor = string.Split(ent:GetNWString("OriginalColor"), ",")
					OriginalColor = {
						r = tonumber(OriginalColor[1]),
						g = tonumber(OriginalColor[2]),
						b = tonumber(OriginalColor[3])
					}
					ent:SetColor(
						Color(
							OriginalColor.r,
							OriginalColor.g,
							OriginalColor.b,
							255
						)
					)
					ent:SetNWString("OriginalColor", "") -- Reset

					ent:SetNotSolid(false)

					--
					--- - 
					if ent == self.Door1 then self.Door1 = nil
					elseif ent == self.Door2 then self.Door2 = nil end
				end)

				-- Everything OK
				ent:SetNWBool("hasAMBDDoor", false)

				-- Notify
				if SERVER then
					net.Start("NotificationReceivedFromServer")
						net.WriteTable({
							Text 	= "You REMOVED a DOOR!",
							Type	= NOTIFY_ERROR,
							Time	= 2.3
						})
					net.Send(_Owner)
				end

				self:DoShootEffect(tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted())
				
				return true
			end

			if k == _ChildrenLength then return false end
		end
	else
		-- It is a Player => Remove it from the array
		--
		local function UpdateDoorAllowedPlayers(DoorTypeString, player)
			if !self[DoorTypeString] then return end

			-- Fetch the door entity.. .
			local doorEntity = nil
			for _,v in pairs(self[DoorTypeString]:GetChildren()) do
				if v:GetClass() == "mbd_door_trigger" then doorEntity = v break end
			end

			local _AllowedPlayers = doorEntity:GetNWString("allPlayersAllowedUniqueID", nil)
			if !_AllowedPlayers then return false end

			local Door_Players = string.Split(_AllowedPlayers, " ")

			for k,v in pairs(Door_Players) do
				if v and #v > 0 then
					local uniqueID = tonumber(v)

					if player.GetByUniqueID(uniqueID) == player then
						-- Found the Player to remove...
						local newTable = Door_Players
						table.remove(newTable, k)

						if SERVER then
							-- Update =>
							doorEntity:SetNWString("allPlayersAllowedUniqueID", table.concat(newTable, " "))

							-- Notify
							local text000 = "'"
							local plyNick = string.Trim(self:GetOwner():Nick())
							if string.Split(plyNick, "")[#plyNick] != "s" then text000 = text000 + "s" end
							net.Start("NotificationReceivedFromServer")
								net.WriteTable({
									Text 	= "You got REMOVED from "..self:GetOwner():Nick()..""..text000.." DOORS",
									Type	= NOTIFY_GENERIC,
									Time	= 4
								})
							net.Send(v)

						-- Notify Owner
							net.Start("NotificationReceivedFromServer")
								net.WriteTable({
									Text 	= "You REMOVED "..v:Nick().." from DOOR",
									Type	= NOTIFY_GENERIC,
									Time	= 2.3
								})
							net.Send(_Owner)
						end
					end
				end
			end
		end

		UpdateDoorAllowedPlayers("Door1", ent)
		UpdateDoorAllowedPlayers("Door2", ent)

		self:DoShootEffect(tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone, IsFirstTimePredicted())

		return true
	end
end
local _Insert = function(_table, x, y)
	table.insert(_table, {
		x = x, y = y
	})
end
local figure = {}

local basePosX = 100
local basePosY = 0

local _iX = 0
local _iY = 0
for i = 0, 360 do
	if i <= 90 then
		-- X will increase and Y will decrease
		_Insert(figure, basePosX + _iX, basePosY - _iY)

		if i == 90 then basePosX = (basePosX + _iX) _iX = 0 end
	elseif i > 90 and i <= 180 then
		-- X will decrease and Y will decrease
		_Insert(figure, basePosX - _iX, basePosY - _iY)

		if i == 180 then basePosY = (basePosY + _iY) _iY = 0 end
	elseif i > 180 and i <= 270 then
		-- X will decrease and Y will increase
		_Insert(figure, basePosX - _iX, basePosY + _iY)

		if i == 270 then basePosX = (basePosX + _iX) _iX = 0 end
	else
		-- X will increase and Y will increase
		_Insert(figure, basePosX + _iX, basePosY + _iY)
	end

	if i == 360 then
		_Insert(figure, 100, 100)
	end

	_iX = (_iX + 1)
	_iY = (_iY + 1)
end
function TOOL:DrawToolScreen(width, height)
	-- - -
	-- Draw background
	surface.SetDrawColor(Color(17, 24, 33))
	surface.DrawRect(0, 0, width, height)

	-- Draw a figure
	surface.SetDrawColor(Color(20, 20, 20))
	surface.DrawPoly(figure)
	-- -
	-- Draw text
	draw.SimpleText(
		"MAKE DOORZ",
		"TOOLGunScreen001",
		(
			width / 2
		),
		(
			height / 2.4
		),
		Color(200, 200, 200),
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	)
end

--OnDrop => Look in shared.lua
--OnRemove => Look in shared.lua
