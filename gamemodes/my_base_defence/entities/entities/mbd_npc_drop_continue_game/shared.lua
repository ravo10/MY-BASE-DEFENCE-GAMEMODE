-- .Base og .Type er veldig viktig for korleis animasjonen skal oppføre seg uten "hacks"....

ENT.Base            = "base_entity"  --garrysmod\gamemodes\base\entities\entities
ENT.Type            = "anim"
ENT.ClassName       = "mbd_npc_drop_continue_game"
ENT.Category        = "M.B.D."
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.PrintName		= "NPC Continue Game Drop"
ENT.Author			= "ravo (Norway)"
ENT.Contact			= "N/A"
ENT.Purpose			= "To be dropped by random NPC's half way through the game, so the player can pick it up. If there are any of these at round/wave end, the game will end."
ENT.Instructions	= "Spawn it on random enemy NPC alive."

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "StartNewAnimationSequence")
    
    if SERVER then
        --- Set First Time
        self:SetStartNewAnimationSequence(true)
    end
end