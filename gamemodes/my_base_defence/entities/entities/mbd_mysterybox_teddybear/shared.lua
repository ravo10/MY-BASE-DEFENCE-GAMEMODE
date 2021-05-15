util.PrecacheModel("models/mysterybox_bo3/teddybear/mysterybox_bo3_teddybear_standalone.mdl")

ENT.Type            = "anim"
ENT.Base            = "base_entity"
ENT.PrintName       = "Mysterybox BO3 Teddy Bear"
ENT.Author          = "ravo Norway"
ENT.Purpose 		= "Show the Teddy Bear floating upwards."
ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "PrevWepEntityPos")

	self:NetworkVar("Entity", 0, "ParentBoxEntity")

	self:NetworkVar("Bool", 0, "IsDone")

	self:NetworkVar("Float", 0, "ExtraZ")
    self:NetworkVar("Float", 1, "AmountUp")
    
    if SERVER then
        --- Set First Time
        self:SetPrevWepEntityPos(Vector(0, 0, 0 ))

        self:SetParentBoxEntity(nil)

        self:SetIsDone(false)

        self:SetExtraZ(0)
        self:SetAmountUp(0.7)
    end
end
