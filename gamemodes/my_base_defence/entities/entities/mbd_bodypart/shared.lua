ENT.Base            = "base_entity"  --garrysmod\gamemodes\base\entities\entities
ENT.Type            = "anim"
ENT.ClassName       = "mbd_bodypart"
ENT.Category        = "M.B.D."
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.PrintName		= ""
ENT.Author			= "ravo (Norway)"
ENT.Contact			= "N/A"
ENT.Purpose			= "To make a bodypart."
ENT.Instructions	= "Spawn it where you want"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "OwnerOfLadder")
end
