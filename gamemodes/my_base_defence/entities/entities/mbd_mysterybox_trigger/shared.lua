ENT.Type                    = "anim"
ENT.Base                    = "base_anim"
ENT.PrintName               = "Trigger for Mystery Box"
ENT.Author                  = "ravo Norway"
ENT.Purpose                 = "Trigger for opening the Mystery Box"
ENT.Instructions            = "Spawn it together with the Mystery Box."
ENT.Spawnable               = false
ENT.AdminSpawnable          = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "ParentBoxEntity")
    
    if SERVER then
        --- Set First Time
        self:SetParentBoxEntity(nil)
    end
end