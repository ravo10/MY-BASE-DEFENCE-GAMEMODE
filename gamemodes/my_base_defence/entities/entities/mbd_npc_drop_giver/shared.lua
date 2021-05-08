ENT.Base            = "base_entity"
ENT.Type            = "anim"
ENT.ClassName       = "mbd_npc_drop_giver"
ENT.Category        = "M.B.D."
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.PrintName		= "NPC Drop Giver"
ENT.Author			= "ravo (Norway)"
ENT.Contact			= "N/A"
ENT.Purpose			= "To give Players £B.D. or B.P. in the gamemode M.B.D."
ENT.Instructions	= "Spawn it on enemy NPC death."

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "DropGiverModel")
    self:NetworkVar("String", 1, "TypeToGive")
    
    self:NetworkVar("Float", 0, "AmountToGive")
    
    if SERVER then
        self:SetDropGiverModel("")
        self:SetTypeToGive("")

        self:SetAmountToGive(0)
    end
end