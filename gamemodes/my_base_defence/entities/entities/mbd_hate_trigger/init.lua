AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	local _parent = self:GetParent()
	self:SetModel(_parent:GetModel())
	self:SetModelScale(_parent:GetModelScale())
	self:Activate()

	self:SetPos(_parent:GetPos())
	self:SetAngles(_parent:GetAngles())
	
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(
		255,
		255,
		255,
		0
	))
	
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetSolid(SOLID_OBB)
	self:DrawShadow(false)
end
function ENT:GravGunPickupAllowed(pl)
	if (
		self:GetOwner() == pl
	) then
		return true
	end
end
----------------------------
--- ON TOUCH >>>
-----
local __PriorityAmount = 99
function ENT:IsEntityValidToHateNeatural(ent)
	if (
		ent and
		ent:IsValid() and
		ent:IsNPC() and
		MBD_CheckIfNotBullseyeEntity(ent:GetClass())
	) then
		return true
	else
		return false
	end
end
function ENT:FindNPCBullseyeEntity(entParent)
	if entParent:IsValid() then
		local _npc_bullseye = entParent:GetNWEntity("mbd_npc_bullseye_child", nil)

		if _npc_bullseye then return _npc_bullseye:GetChildren()[1] end
	else return nil end
end
function ENT:HateNPCBullseye(entParent, _npc)
	if (
		!entParent or
		!entParent:IsValid() or
		!_npc or
		!_npc:IsValid()
	) then return end
	--
	local _self = self
	timer.Simple(0.15, function()
		if _self and _self:IsValid() and _self.FindNPCBullseyeEntity then
			local hitboxEntity = _self:FindNPCBullseyeEntity(entParent)
			if (
				hitboxEntity and
				hitboxEntity:IsValid() and
				_npc:IsValid() and
				_npc:Disposition(hitboxEntity) != D_HT and
				hitboxEntity:GetNWInt("AmountOfEnemiesHating", -1) < 3 -- A "prop"/hitbox can only have a maximum of 3 enemies at the same time
			) then
				--
				-- HATE
				hitboxEntity:SetNWInt("AmountOfEnemiesHating", (hitboxEntity:GetNWInt("AmountOfEnemiesHating", 0) + 1))
				_npc:AddEntityRelationship(hitboxEntity, D_HT, __PriorityAmount)
			end
		end
	end)
end
function ENT:NeautralNPCBullseye(entParent, _npc)
	if (
		!entParent or
		!entParent:IsValid() or
		!_npc or
		!_npc:IsValid()
	) then return end
	--
	local _self = self
	timer.Simple(1, function()
		if _self and _self:IsValid() and _self.FindNPCBullseyeEntity then
			local hitboxEntity = _self:FindNPCBullseyeEntity(entParent)
			if (
				hitboxEntity and
				hitboxEntity:IsValid() and
				_npc and
				_npc:IsValid() and
				_npc.Disposition and
				_npc:Disposition(hitboxEntity) != D_NU
			) then
				--
				-- NEAUTRAL
				if (_npc:Disposition(hitboxEntity) == D_HT) then
					hitboxEntity:SetNWInt("AmountOfEnemiesHating", (hitboxEntity:GetNWInt("AmountOfEnemiesHating", 0) - 1))
				end
				_npc:AddEntityRelationship(hitboxEntity, D_NU, __PriorityAmount)
			end
		end
	end)
end
function ENT:Touch(ent)
	-- Get Parent
	local entParent = self:GetParent()
	if !ent or !ent:IsValid() then return end

	local _Pitch = ent:GetAngles().pitch
	if (_Pitch < 0) then _Pitch = (_Pitch * -1) end
	if (
		_Pitch > 70 and
		_Pitch < 110 -- Laying flat...
	) then
		if !self:IsValid() or !ent or !ent:IsValid() or !ent:IsNPC() then return end
		self:NeautralNPCBullseye(entParent, ent)

		-- Clear memory
		local _Enemy = ent:GetEnemy()
		if _Enemy and !MBD_CheckIfNotBullseyeEntity(_Enemy:GetClass()) then
			ent:ClearEnemyMemory()
		end
	end

	if self:IsEntityValidToHateNeatural(ent) then
		--
		--- HATE
		if !self:IsValid() then return end
		self:HateNPCBullseye(entParent, ent)
	end
end
function ENT:EndTouch(ent)
	local entParent = self:GetParent()

	if !ent or !ent:IsValid() then return end
	
	if self:IsEntityValidToHateNeatural(ent) then
		--
		--- NEAUTRAL
		if !self:IsValid() then return end
		self:NeautralNPCBullseye(entParent, ent)
	end
end
