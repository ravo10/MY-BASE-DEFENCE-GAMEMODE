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
	self:SetUseType(SIMPLE_USE)

	self:SetName("mbd_ent")

	if GetConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance_TotallyCustomValueAllowed" ):GetInt() == 0 then

		local chance = math.Round( ( ( table.Count( mbd_allowedWeaponsMysteryBox ) / defaultDivisionValueGetChance ) * -1 ), 3 )
	
		if not ConVarExists( "mbd_mysterybox_bo3_ravo_teddybearGetChance" ) then
			CreateConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance", chance, bit.bor( FCVAR_PROTECTED, FCVAR_ARCHIVE ), "How likley it is to get a Teddybear. Lower = Higher risk.")
		else
			-- Reset to normal settings
			GetConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance" ):SetFloat( chance )
		end

	end

	self:MaybeAdjustTheChanceToGetATeddybear()

	self:SetModel( "models/maxofs2d/logo_gmod_b.mdl" )
	self:SetModelScale( 0.15 )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_FLY )
	self:SetSolidFlags( FSOLID_NOT_STANDABLE )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	self:CycleWeapons()
	self:DrawShadow( false )
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
	local CycleDurationScalar = self:GetCycleDurationScalar()
	local CycleUntilNextWepInSecond = self:GetCycleUntilNextWepInSecond()

	local totalAmountOfReps = math.Round( ( (1 - CycleUntilNextWepInSecond ) / CycleDurationScalar ) * 100 )

	local parentEnt = nil
	--
	-- Cycle Creator
	local tableCountAllowedWeapons = table.Count( mbd_allowedWeaponsMysteryBox )
	
	-- Make the switch slower...
	timer.Simple( ( CycleDurationScalar / 1.5 ), function()
		CycleUntilNextWepInSecond = CycleUntilNextWepInSecond * ( 1 + 0.9 ) -- Decrease by an percentage
	end )

	local function _switchWeapons(self)
		if not self:IsValid() then return end

		local randomWeaponIndex = math.ceil( math.random( self:GetTeddybearRisk(), tableCountAllowedWeapons ) )
		if randomWeaponIndex > tableCountAllowedWeapons then randomWeaponIndex = tableCountAllowedWeapons end
		local theWeaponsTable = mbd_allowedWeaponsMysteryBox[ randomWeaponIndex ]

		local _WModel

		-- -- -
		-- Cycle
		if self:IsValid() then
			parentEnt = self:GetParentBoxEntity()
			-- --
			-- If lower or equal to 0, then spawn a Teddy bear
			if randomWeaponIndex <= 0 then
				self:SwitchWeaponModel( "models/mysterybox_bo3/teddybear/mysterybox_bo3_teddybear_standalone.mdl", nil )

				self:ResetSequence("teddybear_still")
			elseif theWeaponsTable then
				_WModel = theWeaponsTable.WModel
				if not _WModel then _WModel = theWeaponsTable.VModel end
				if not _WModel then _WModel = "models/maxofs2d/logo_gmod_b.mdl" end -- Likely never to happend

				self:SwitchWeaponModel( _WModel, theWeaponsTable.ClassName )

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

		-- Slow down the cycle a bit
		if totalAmountOfReps == 7 then CycleUntilNextWepInSecond = CycleUntilNextWepInSecond * 2 end
		if totalAmountOfReps == 3 then CycleUntilNextWepInSecond = CycleUntilNextWepInSecond * 1.3 end

		if totalAmountOfReps >= 0 then
			timer.Simple(CycleUntilNextWepInSecond, function()
				_switchWeapons(self)
			end)
		end
	end

	-- Wait for self to be valid before kick start
	local timerID = "switchWeaponMysterybox"..self:EntIndex()
	timer.Create(timerID, 0.15, (10 / 0.15), function()
		if self and self:IsValid() then
			timer.Remove(timerID)

			_switchWeapons(self)
		end
	end)
end
-----------
-- Think --
-----------
function ENT:Think()

	local MysteryBox = self:GetParentBoxEntity()
	local timerID = "MBDThink"..self:EntIndex()

	if not MysteryBox or not MysteryBox:IsValid() then
		if self and self:IsValid() then
			self:Remove()
			
			return
		end
	end

	-- Start Position
	-- Move Weapon UP... . --
	local modelSize = 0.15

	local ParentPosition = MysteryBox:GetPos()

	local ChangingWeaponZPosValueCounter = self:GetChangingWeaponZPosValueCounter()
	local extraZWeapon = ( ParentPosition.z + self:GetStartPositionZPos() + ChangingWeaponZPosValueCounter )

	if self:GetModel() == "models/mysterybox_bo3/teddybear/mysterybox_bo3_teddybear_standalone.mdl" then

		modelSize = 1

		local newpos, newang = LocalToWorld( Vector( 0, 0, 0 ), Angle( 0, 0, 0 ), Vector( ParentPosition.x, ParentPosition.y, extraZWeapon ), MysteryBox:GetAngles() )

		self:SetAngles( newang )
		self:SetPos( newpos )
		
		self:SetAngles( MysteryBox:GetAngles() )

	else

		local addAngles = Angle( 0, 0, 0 )
		local fallbackModelIsActive = self:GetModel() == "models/maxofs2d/logo_gmod_b.mdl"

		if not fallbackModelIsActive then addAngles = Angle( 0, 90, 0 ) modelSize = 1 end

		local newpos, newang = LocalToWorld(

			Vector( 0, 0, 0 ), addAngles,
			Vector( ParentPosition.x, ParentPosition.y, extraZWeapon ), MysteryBox:GetAngles()
		)

		self:SetAngles( newang )
		self:SetPos( newpos )

	end

	-- Set Z Position
	if self:IsValid() then

		self:SetModelScale( modelSize )
		
		if self:GetChangingWeaponZPosValueCounterLerpTime() < 0 then self:SetChangingWeaponZPosValueCounterLerpTime( CurTime() ) end

		-- -- --     ----------
		--- -- - Movement -- -
		------------ -- -------
		if self:GetMoveWeaponUp() then

			local newZPositionValueCounterGoingUp = Lerp(

				( CurTime() - self:GetChangingWeaponZPosValueCounterLerpTime() ),
				ChangingWeaponZPosValueCounter,
				ChangingWeaponZPosValueCounter + self:GetAmountUp()

			)

			-- Increase ( Set next Z-Position )
			self:SetChangingWeaponZPosValueCounter( newZPositionValueCounterGoingUp )

			-- Start moving down instead...
			if ChangingWeaponZPosValueCounter >= self:GetEndPositionTopCounter() then
				
				self:SetMoveWeaponUp( false )
				self:SetEndPositionTopGoReallySlowSecondsLastCount( CurTime() )

			end

		else

			local limit = 0.93

			local percetage = 0.999995 -- Lower = Lower Speed
			local amountDownDivision = ( self:GetAmountDown() / self:GetAmountDownOriginalValue() )

			-- Move faster
			if self:GetEndPositionTopGoReallySlowSecondsLastCount() >= 0 then

				local currentSecondsOn = ( CurTime() - self:GetEndPositionTopGoReallySlowSecondsLastCount() )

				-- Make it go slower...
				percetage = 0.005
				local scalar = 2

				-- Higest to lowest
				if currentSecondsOn >= ( self:GetEndPositionTopGoReallySlowSeconds() / 2 ) then scalar = 100
				elseif currentSecondsOn >= ( self:GetEndPositionTopGoReallySlowSeconds() / 3 ) then scalar = 50
				elseif currentSecondsOn >= ( self:GetEndPositionTopGoReallySlowSeconds() / 4 ) then scalar = 30
				elseif currentSecondsOn >= ( self:GetEndPositionTopGoReallySlowSeconds() / 5 ) then scalar = 10 end

				percetage = percetage * scalar

				-- Finished
				if currentSecondsOn >= self:GetEndPositionTopGoReallySlowSeconds() then

					self:SetEndPositionTopGoReallySlowSecondsLastCount( -1 )

				end

			else

				-- Go even faster down
				if ChangingWeaponZPosValueCounter > 0 and ( self:GetEndPositionBottomCounter() / ChangingWeaponZPosValueCounter ) <= -1.83 then percetage = 1.5
				elseif ChangingWeaponZPosValueCounter < 0 then percetage = 2 end

			end

			local newZPositionValueCounterGoingDown = Lerp(

				( CurTime() - self:GetChangingWeaponZPosValueCounterLerpTime() ),
				ChangingWeaponZPosValueCounter,
				( ChangingWeaponZPosValueCounter - self:GetAmountDown() * percetage )

			)

			-- Decrease
			if newZPositionValueCounterGoingDown > self:GetEndPositionBottomCounter() then

				-- Decrease ( Set next Z-Position )
				self:SetChangingWeaponZPosValueCounter( newZPositionValueCounterGoingDown )
			
			else

				self:GetParentBoxEntity():WeaponExpired()

				-- Remove Weapon (finished)
				self:Remove()

			end

		end

	end

	if ( CurTime() - self:GetChangingWeaponZPosValueCounterLerpTime() ) > 0.05 then self:SetChangingWeaponZPosValueCounterLerpTime( CurTime() ) end

	self:NextThink( CurTime() + 0.002 )
	return true

end

function ENT:Use( activator, caller, useType, value )

	local MysteryBox = self:GetParentBoxEntity()

	if not MysteryBox and ( _parentBox and not MysteryBox:IsValid() ) and not _parentBox.GetWeaponEntity then return end

	-- The Weapon can be close to activator... Then allow also to click "use" key
	local weaponChild = MysteryBox:GetWeaponEntity()
	local weaponIsCloseEnough = false

	if weaponChild and weaponChild:IsValid() then
		weaponChild:MaybeAdjustTheChanceToGetATeddybear()

		if activator:GetPos():Distance(weaponChild:GetPos()) <= 85 then
			weaponIsCloseEnough = true
		end
	end

	if not Bo3RavoMBDIsPlayerAllowedToActivate( MysteryBox, activator, weaponIsCloseEnough ) then return end
	Bo3RavoMBDMysteryBoxTakeWeapon( MysteryBox, activator, weaponChild )

	return true

end
