AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
----------- --------------------
--- By: ravo Norway
--------------------
local defaultDivisionValueGetChance = 3.92307

timer.Create( "mbd_bo3RavoMysteryBoxInit", 0.3, 0, function()
	
	if mbd_allowedWeaponsMysteryBox then

		timer.Remove( "mbd_bo3RavoMysteryBoxInit" )
		
		if not ConVarExists( "mbd_mysterybox_bo3_ravo_teddybearGetChance" ) then
			CreateConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance", ( ( table.Count( mbd_allowedWeaponsMysteryBox ) / defaultDivisionValueGetChance ) * -1), bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "How likley it is to get a Teddybear. Lower = Higher risk." )
		end
		if not ConVarExists( "mbd_mysterybox_bo3_ravo_teddybearGetChance_TotallyCustomValueAllowed" ) then
			CreateConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance_TotallyCustomValueAllowed", 0, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "If the system will allow totally Custom Teddy Bear Get Chance Value (it doesn't matter how many times you have used the box)." )
		end

	end
	
end )
----------------------
-- Spawn Function --
--------------------
function ENT:SpawnFunction(pl, tr)
	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 25

	local ent = ents.Create("mbd_mysterybox_weapon")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end
----------------
-- Initialize --
----------------
function ENT:Initialize()
	self:SetName("mbd_ent")

	if GetConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance_TotallyCustomValueAllowed" ):GetInt() == 0 then

		local chance = math.Round( ( ( table.Count( bo3_ravo_mysterybox_allowedWeapons ) / defaultDivisionValueGetChance ) * -1 ), 3 )
	
		if not ConVarExists( "mbd_mysterybox_bo3_ravo_teddybearGetChance" ) then
			CreateConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance", chance, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "How likley it is to get a Teddybear. Lower = Higher risk.")
		else
			-- Reset to normal settings
			GetConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance" ):SetFloat( chance )
		end

	end

	self:MaybeAdjustTheChanceToGetATeddybear()

	self:SetModel("models/weapons/w_Pistol.mdl") -- Fallback model
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_FLY)
	self:SetNotSolid(true) -- I can add a USE-hook, but don't care about it right now
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:SetAngles(self:GetAngles() - Angle(0, -90, 0))
	
	self:CycleWeapons()
	self:DrawShadow(false)
end
--------------------
-- Cycle Weapons ---
--------------------
function ENT:MaybeAdjustTheChanceToGetATeddybear()
	-- Adjust the chance to get a teddybear after the amount of uses
	-- -
	local currentAmountOfUses = self:GetParentBoxEntity():GetAmountOfUses()
	local newTeddybearRisk = GetConVar("mbd_mysterybox_bo3_ravo_teddybearGetChance"):GetFloat()
	
	if GetConVar("mbd_mysterybox_bo3_ravo_teddybearGetChance_TotallyCustomValueAllowed"):GetInt() == 0 then
	
		if (
			currentAmountOfUses >= 0 and
			currentAmountOfUses <= 4
		) then
			newTeddybearRisk = 1
		elseif (
			currentAmountOfUses > 4 and
			currentAmountOfUses <= 8
		) then
			if newTeddybearRisk == 1 then
				newTeddybearRisk = GetConVar("mbd_mysterybox_bo3_ravo_teddybearGetChance"):GetFloat()
			end

			newTeddybearRisk = (newTeddybearRisk * 1.15)
		elseif (
			currentAmountOfUses > 8 and
			currentAmountOfUses <= 12
		) then
			if newTeddybearRisk == 1 then
				newTeddybearRisk = GetConVar("mbd_mysterybox_bo3_ravo_teddybearGetChance"):GetFloat()
			end

			newTeddybearRisk = (newTeddybearRisk * 1.3)
		else
			if newTeddybearRisk == 1 then
				newTeddybearRisk = GetConVar("mbd_mysterybox_bo3_ravo_teddybearGetChance"):GetFloat()
			end

			newTeddybearRisk = (newTeddybearRisk * 1.5)
		end

	end

	self:SetTeddybearRisk( newTeddybearRisk )
end
function ENT:SwitchWeaponModel(weaponWModel, weaponClass)
	if weaponClass then self:SetCurrentWeaponClassSwitch(weaponClass) end

	if (
		weaponWModel and
		self:IsValid()
	) then
		-- Set model (could be teddybear)
		self:SetModel(weaponWModel)
	end
end
function ENT:CycleWeapons()
	local cycleLastSecond = self:GetCycleLastSecond()
	local cycleNextSecond = self:GetCycleNextSecond()

	local totalAmountOfReps = math.Round(((1 - cycleNextSecond) / cycleLastSecond) * 100)

	local parentEnt = nil
	--
	-- Cycle Creator
	local tableCountAllowedWeapons = table.Count( mbd_allowedWeaponsMysteryBox )

	-- Make the switch slower...
	timer.Simple((cycleLastSecond / 1.5), function()
		cycleNextSecond = cycleNextSecond * (1 + 0.9) -- Decrease by an percentage
	end)
	
	local function _swithWeapons(self)
		if not self:IsValid() then return end

		local randomWeaponIndex = math.ceil( math.random( self:GetTeddybearRisk(), tableCountAllowedWeapons ) )
		if randomWeaponIndex > tableCountAllowedWeapons then randomWeaponIndex = tableCountAllowedWeapons end
		local theWeaponsTable = mbd_allowedWeaponsMysteryBox[randomWeaponIndex]

		local _WModel

		-- -- -
		-- Cycle
		if self:IsValid() then
			parentEnt = self:GetParentBoxEntity()

			if randomWeaponIndex <= 0 then
				self:SwitchWeaponModel("models/mysterybox_bo3/teddybear/mysterybox_bo3_teddybear_standalone.mdl", nil)

				self:ResetSequence("teddybear_still")
			elseif theWeaponsTable then
				_WModel = theWeaponsTable.WModel
				if not _WModel then _WModel = theWeaponsTable.VModel end
				if not _WModel then _WModel = "models/weapons/w_crowbar.mdl" end

				self:SwitchWeaponModel(_WModel, theWeaponsTable.ClassName)

				self:ResetSequence("idle")
			else return end
		end

		--- *************************** ---
		-- Finished with Cycling Weapons
		-- --
		if (
			self:IsValid() and
			totalAmountOfReps == 0 and
			randomWeaponIndex > 0
		) then
			--- - -
			-- The Player got this Weapon! He can take it if he wants...
			if not parentEnt or not parentEnt:IsValid() then return end

			-- For saftey, set here and on client side also...
			self:SetModel(_WModel)
			
			net.Start("setClientModleMysteryBoxRavo")
				net.WriteTable({
					Weapon = self,
					WModel = _WModel
				})
			net.Send(self:GetOwnerPlayer())
			
			parentEnt:SetCanTakeWeapon(true)
		elseif (
			self:IsValid() and
			totalAmountOfReps == 0 and
			randomWeaponIndex <= 0
		) then
			------------- -- ------
			-- Someone got the Teddybear! Remove itself...
			------------ ------------------------------------
			self:GetParentBoxEntity():TeddybearIncoming()

			-- Remove Self from every Player
			for _,_Player in pairs(player.GetAll()) do
				if _Player and _Player:IsValid() then
					local allCurrentIDs = string.Split(_Player:GetNWString("CanActivateMysteryboxMBD"), ";")
					local _newT = {}
					for k,v in pairs(allCurrentIDs) do
						if v ~= "" then
							local tableEntIndex = tonumber(v)
							local tableEnt = ents.GetByIndex(tableEntIndex)
							-- Not equal to Self (tha box)
							if (
								tableEntIndex ~= self:EntIndex() and (
									tableEnt and
									tableEnt:IsValid() and
									tableEnt:GetClass() == "mbd_mysterybox"
								)
							) then
								-- Add
								table.insert(_newT, v)
							end
						end

						if k == #allCurrentIDs then
							-- Save
							_Player:SetNWString("CanActivateMysteryboxMBD", table.concat(_newT, ";"))
						end
					end
				end
			end

			-- Just wait a little...
			timer.Simple(2.3, function()
				if not self or not self:IsValid() then return end

				local teddyent = ents.Create("mbd_mysterybox_teddybear")
				teddyent:SetPos(self:GetPos())

				teddyent:SetParentBoxEntity(self:GetParentBoxEntity())
				teddyent:SetPrevWepEntityPos(self:GetPos())

				teddyent:Spawn()
				
				-- Remove Self
				if self and self:IsValid() then self:Remove() end
			end)
		end
		
		if not self:IsValid() then return end

		-- Start next loop
		totalAmountOfReps = (totalAmountOfReps - 1)

		if totalAmountOfReps >= 0 then
			timer.Simple(cycleNextSecond, function()
				_swithWeapons(self)
			end)
		end
	end

	-- Wait for self to be valid before kick start
	local timerID = "switchWeaponMysterybox"..self:EntIndex()
	timer.Create(timerID, 0.15, (10 / 0.15), function()
		if self and self:IsValid() then
			timer.Remove(timerID)

			_swithWeapons(self)
		end
	end)
end
-----------
-- Think --
-----------
function ENT:Think()
	local _parentEnt = self:GetParentBoxEntity()
	local timerID = "MBDThink"..self:EntIndex()

	if not _parentEnt or not _parentEnt:IsValid() then
		if self and self:IsValid() then
			self:Remove()
			
			return
		end
	end

	local __amountUp = self:GetAmountUp()
	local __amountDown = self:GetAmountDown()
	local __UpperLimit = self:GetUpperLimit()
	local __LowerLimit = self:GetLowerLimit()
	

	-- Start Position
	local extraZ = self:GetExtraZ()

	-- Move Weapon UP... . --
	-- Position
	self:SetPos(
		Vector(
			_parentEnt:GetPos().x,
			_parentEnt:GetPos().y,
			(_parentEnt:GetPos().z + __LowerLimit + extraZ)
		)
	)
	-- - Angle
	if self:GetModel() == "models/mysterybox_bo3/teddybear/mysterybox_bo3_teddybear_standalone.mdl" then
		self:SetAngles(_parentEnt:GetAngles())
	else
		self:SetAngles(_parentEnt:GetAngles() + Angle(0, 270, 0))
	end

	-- Set Z Position
	if self:IsValid() then
		-- Start moving down...
		if (
			extraZ >= __UpperLimit and
			self:GetMoveWeaponUp()
		) then
			self:SetMoveWeaponUp(false)
		end
		-- -- --     ----------
		--- -- - Movement -- -
		------------ -- -------
		if self:GetMoveWeaponUp() then
			local _newVal = extraZ + __amountUp
			
			-- Increase
			self:SetExtraZ(_newVal)
		else
			local percentage = extraZ / (extraZ + __amountUp)

			-- Maybe need to componsate (depends one the up value)
			percentage = (percentage - 0.0016)

			--- -- --- -
			-- Move faster...
			if percentage <= 0.99148 then self:SetAmountDown(0.01) end
			if percentage <= 0.9912 then self:SetAmountDown(0.02) end
			if percentage <= 0.9905 then self:SetAmountDown(0.05) end
			if percentage <= 0.98814 then self:SetAmountDown(0.072) end

			local _newVal = extraZ - __amountDown

			-- The model is will start to dissapear
			if (
				not self:GetStartingToDissapear() and
				_newVal <= __LowerLimit * 4.75
			) then
				self:SetStartingToDissapear(true)

				if not self or not self:IsValid() then return end

				self:SetModelScale(0, (__amountDown * (__LowerLimit * 9.8)))
			end

			-- Decrease
			if _newVal > __LowerLimit then self:SetExtraZ(_newVal) elseif _newVal <= __LowerLimit then
				self:GetParentBoxEntity():WeaponExpired()

				-- Remove Weapon (finished)
				self:Remove()
			end
		end
	end

	self:NextThink(CurTime())
	return true
end