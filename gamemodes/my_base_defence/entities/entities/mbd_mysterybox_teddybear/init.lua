AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-------------------------------
----------------
-- Initialize --
----------------
function ENT:Initialize()
	self:SetName("mbd_ent")
	
	self:SetModel("models/mysterybox_bo3/teddybear/mysterybox_bo3_teddybear_standalone.mdl")
	self:ResetSequence("teddybear_still")

	local _parentEnt = self:GetParentBoxEntity()
	if _parentEnt and _parentEnt:IsValid() then self:SetAngles(_parentEnt:GetAngles()) end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end
------------
-- On USE --
------------
function ENT:Use(activator, caller, useType, value)
	return false
end
-----------
-- Think --
-----------
function ENT:Think()
	local _parentEnt = self:GetParentBoxEntity()
	if not _parentEnt or not _parentEnt:IsValid() then
		if self and self:IsValid() then
			self:Remove()
			
			return
		end
	end

	-- Move Up
	local __amountUp = self:GetAmountUp()

	-- Start Position
	local extraZ = self:GetExtraZ()

	-- Move Weapon UP... . --
	local __zPos = math.max(self:GetPrevWepEntityPos().z, _parentEnt:GetPos().z)
	-- Position
	self:SetPos(
		Vector(
			_parentEnt:GetPos().x,
			_parentEnt:GetPos().y,
			__zPos + extraZ
		)
	)
	self:SetAngles(_parentEnt:GetAngles())

	local _newVal = extraZ + __amountUp

	-- Increase
	self:SetExtraZ(_newVal)

	-- Maybe remove self...
	if (
		not self:GetIsDone() and
		(self:GetPos().z - __zPos) >= 350 -- Pretty good
	) then
		self:SetIsDone(true)

		local __scaleTime = 1

		self:SetModelScale(0, __scaleTime)
		
		timer.Simple(__scaleTime + 0.15, function()
			if not self or not self:IsValid() then return end

			self:Remove()
		end)
	end

	self:NextThink(CurTime())
	return true
end