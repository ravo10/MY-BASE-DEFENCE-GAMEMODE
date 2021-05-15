ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.PrintName 		= "Mysterybox BO3 Weapon Entity"
ENT.Author 			= "ravo Norway"
ENT.Purpose 		= "Show the model of weapons in the mysterybox."
ENT.Spawnable 		= false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	
	self:NetworkVar("Bool", 0, "MoveWeaponUp")
	self:NetworkVar("Bool", 1, "StartingToDissapear")

	self:NetworkVar("String", 0, "CurrentWeaponClassSwitch")

	self:NetworkVar("Float", 0, "CycleDurationScalar")
	self:NetworkVar("Float", 1, "CycleUntilNextWepInSecond")
	self:NetworkVar("Float", 2, "AmountUp")
	self:NetworkVar("Float", 3, "AmountDown")
	self:NetworkVar("Float", 4, "AmountDownOriginalValue")
	self:NetworkVar("Float", 5, "StartPositionZPos")
	self:NetworkVar("Float", 6, "EndPositionTopCounter")
	self:NetworkVar("Float", 7, "EndPositionTopGoReallySlowSeconds")
	self:NetworkVar("Float", 8, "EndPositionTopGoReallySlowSecondsLastCount")
	self:NetworkVar("Float", 9, "EndPositionBottomCounter")
	self:NetworkVar("Float", 10, "ChangingWeaponZPosValueCounter")
	self:NetworkVar("Float", 11, "ChangingWeaponZPosValueCounterLerpTime")
	self:NetworkVar("Float", 12, "TeddybearRisk")

	self:NetworkVar("Entity", 0, "OwnerPlayer")
	self:NetworkVar("Entity", 1, "ParentBoxEntity")

	if SERVER then

		--- Set First Time
		self:SetMoveWeaponUp( true )
		self:SetStartingToDissapear( false )

		self:SetCurrentWeaponClassSwitch( "" )

		self:SetCycleDurationScalar( 4 ) -- Higher = Faster
		self:SetCycleUntilNextWepInSecond( 0.1 ) -- Lower = Faster

		self:SetAmountUp( 2.3 ) -- Speed; Higher = Faster
		self:SetAmountDown( 1.68 ) -- Speed; Higher = Faster
		self:SetAmountDownOriginalValue( self:GetAmountDown() ) -- Static

		self:SetStartPositionZPos( 33 ) -- Static
		self:SetEndPositionTopCounter( 23 ) -- Static
		self:SetEndPositionTopGoReallySlowSeconds( 5 ) -- Static
		self:SetEndPositionBottomCounter( -20 ) -- Static
		self:SetChangingWeaponZPosValueCounterLerpTime( -1 ) -- Dynamic
		
		self:SetTeddybearRisk( GetConVar( "mbd_mysterybox_bo3_ravo_teddybearGetChance" ):GetFloat() )

		self:SetOwnerPlayer( nil )
		self:SetParentBoxEntity( nil )

	end

end

function DisablePhysgunning(ply, ent)
	if ent:GetClass():lower() == "mbd_mysterybox_weapon" then
		return false
	end
end
hook.Add("PhysgunPickup", "mbd:DisableTakingTheWeaponInTheMysteryBox", DisablePhysgunning)
