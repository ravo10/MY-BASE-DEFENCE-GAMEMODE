util.PrecacheModel("models/buybox/buybox.mdl")

ENT.Base            = "base_entity"  --garrysmod\gamemodes\base\entities\entities
ENT.Type            = "anim"
ENT.ClassName       = "mbd_buybox"
ENT.Category        = "M.B.D."
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.Base            = "base_entity"  --garrysmod\gamemodes\base\entities\entities
ENT.Type            = "anim"
ENT.PrintName		= "BuyBox (M.B.D.)"
ENT.Author			= "ravo (Norway)"
ENT.Contact			= "N/A"
ENT.Purpose			= "To make Players be able to buy weapons and ammo in the gamemode M.B.D."
ENT.Instructions	= "Place it wherever you want Players to have their BuyBox-station."

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "StartNewAnimationSequence")
    
    if SERVER then
        --- Set First Time
        self:SetStartNewAnimationSequence(true)
    end
end