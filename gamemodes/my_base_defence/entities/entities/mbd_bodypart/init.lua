AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	-- Physics stuff
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NPC)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end
function ENT:GravGunPickupAllowed(pl)
	return true
end
function ENT:Use(activator, caller, useType, value)
	if (self:IsPlayerHolding()) then
		return
	end

	activator:PickupObject(self)
end

function ENT:OnTakeDamage(dmginfo)
	fleshBodyPartPlayARandomSound(self)

	local attackerEnt = dmginfo:GetAttacker()

	local pos = dmginfo:GetDamagePosition()
	local ang = attackerEnt:EyeAngles()

	spawnBodyBodyPartParticles(self, pos, ang)
end
