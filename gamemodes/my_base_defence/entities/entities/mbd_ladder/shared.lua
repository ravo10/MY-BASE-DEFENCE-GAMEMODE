util.PrecacheModel("models/mbd_props/mbd_ladder.mdl")

ENT.Base            = "base_entity"  --garrysmod\gamemodes\base\entities\entities
ENT.Type            = "anim"
ENT.ClassName       = "mbd_ladder"
ENT.Category        = "M.B.D."
ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.PrintName		= "Ladder (M.B.D.)"
ENT.Author			= "ravo (Norway)"
ENT.Contact			= "N/A"
ENT.Purpose			= "To transport Players to a higher plane of existance."
ENT.Instructions	= "Place and walk on to go up or down."

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "OwnerOfLadder")
end