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

	self:NetworkVar("Float", 0, "CycleLastSecond")
	self:NetworkVar("Float", 1, "CycleNextSecond")
	self:NetworkVar("Float", 2, "AmountUp")
	self:NetworkVar("Float", 3, "AmountDown")
	self:NetworkVar("Float", 4, "UpperLimit")
	self:NetworkVar("Float", 5, "LowerLimit")
	self:NetworkVar("Float", 6, "TeddybearRisk")
	self:NetworkVar("Float", 7, "ExtraZ")

	self:NetworkVar("Entity", 0, "OwnerPlayer")
	self:NetworkVar("Entity", 1, "ParentBoxEntity")

	if SERVER then
		--- Set First Time
		self:SetMoveWeaponUp(true)
		self:SetStartingToDissapear(false)

		self:SetCurrentWeaponClassSwitch("")

		self:SetCycleLastSecond(4)
		self:SetCycleNextSecond(0.16)
		self:SetAmountUp(0.3)
		self:SetAmountDown(0.0005)
		self:SetUpperLimit(43)
		self:SetLowerLimit(5)
		self:SetTeddybearRisk( GetConVar("mbd_mysterybox_bo3_ravo_teddybearGetChance"):GetFloat() )
		self:SetExtraZ(-13) -- Juster??

		self:SetOwnerPlayer(nil)
		self:SetParentBoxEntity(nil)
	end
end

function DisablePhysgunning(ply, ent)
	if ent:GetClass():lower() == "mbd_mysterybox_weapon" then
		return false
	end
end
hook.Add("PhysgunPickup", "mbd:DisableTakingTheWeaponInTheMysteryBox", DisablePhysgunning)