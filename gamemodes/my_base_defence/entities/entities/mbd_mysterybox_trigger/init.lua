AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
----------- --------------------
--- By: ravo Norway (04.05.2019)
--------------------
--------------------
-- Spawn Function --
--------------------
function ENT:SpawnFunction(pl, tr)
	if not tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal

	local ent = ents.Create("mysterybox_bo3_ravo")
	ent:SetPos(SpawnPos)
	ent:SetAngles(
		Angle(180, pl:EyeAngles().y, -180)
	)
	ent:SetVirtualOwner(pl)

	ent:Spawn()
	ent:Activate()

	-- Add a special trigger
	local ent_trigger = ents.Create("mysterybox_bo3_trigger_ravo")
	if (
		ent and
		ent:IsValid() and
		ent_trigger and
		ent_trigger:IsValid()
	) then
		ent_trigger:SetParentBoxEntity(ent)

		ent_trigger:Spawn()
		ent_trigger:Activate()
	else
		print("Start of error--")
		print("Error: Could not set Trigger for Mystery Box (BO3)... Something was not valid.")
		print("ent:", ent)
		print("ent_trigger:", ent_trigger)
		print("--End of error")

		if ent and ent:IsValid() then ent:Remove() end
		return nil
	end
	--

	return ent
end
----------------
-- Initialize --
----------------
function ENT:Initialize()
	self:SetName("mbd_ent")
	
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:SetModelScale(0.1)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BSP)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	local _ParentEntity = self:GetParentBoxEntity()
	self:SetPos(_ParentEntity:GetPos() + Vector(0, 0, 9))
	self:SetAngles(_ParentEntity:GetAngles())

	self:SetParent(_ParentEntity, MOVETYPE_NONE)
	self:SetOwner(_ParentEntity:GetVirtualOwner())

	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Sleep()
	end

	-- Set trigger area.
	-- *This will define when the Player is allowed to use the box
	self:UseTriggerBounds(true, 53 * 1.4)
	self:SetTrigger(true)

	local timerID = "mbd_makeTriggerInvisible001"..self:EntIndex()
	timer.Create(timerID, 0.15, 5, function()
		if not self or not self:IsValid() then timer.Remove(timerID) return end

		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetColor(Color(
			255,
			255,
			255,
			0
		))
	end)
end
-----------
-- TOUCH --
-----------
function ENT:Touch(ent)
	local _ParentEntity = self:GetParentBoxEntity()
	if not _ParentEntity or not _ParentEntity:IsValid() then return end

	local allCurrentIDs = string.Split(ent:GetNWString("CanActivateMysteryboxMBD"), ";")
	local PlayerHasTheParentID = false
	for k,v in pairs(allCurrentIDs) do
		if (
			v and
			v ~= ""
		) then
			local tableEntIndex = tonumber(v)

			if tableEntIndex == _ParentEntity:EntIndex() then
				PlayerHasTheParentID = true

				break
			end
		end
	end
	if not PlayerHasTheParentID then
		-- Add
		table.insert(allCurrentIDs, _ParentEntity:EntIndex())

		-- Save
		ent:SetNWString("CanActivateMysteryboxMBD", table.concat(allCurrentIDs, ";"))
	end
end
function ENT:EndTouch(ent)
	local _ParentEntity = self:GetParentBoxEntity()
	if not _ParentEntity or not _ParentEntity:IsValid() then return end

	local allCurrentIDs = string.Split(ent:GetNWString("CanActivateMysteryboxMBD"), ";")
	local _newT = {}
	for k,v in pairs(allCurrentIDs) do
		if v ~= "" then
			local tableEntIndex = tonumber(v)
			local tableEnt = ents.GetByIndex(tableEntIndex)
			-- Not equal to Self (tha box)
			if (
				tableEntIndex ~= _ParentEntity:EntIndex() and (
					tableEnt and
					tableEnt:IsValid() and
					tableEnt:GetClass() == "mysterybox_bo3_ravo"
				)
			) then
				-- Add
				table.insert(_newT, v)
			end
		end

		if k == #allCurrentIDs then
			-- Save
			ent:SetNWString("CanActivateMysteryboxMBD", table.concat(_newT, ";"))
		end
	end
end
function ENT:Think()
	local _ParentEntity = self:GetParentBoxEntity()
	if not _ParentEntity or not _ParentEntity:IsValid() then
		self:Remove()

		return false
	end

	self:NextThink(CurTime() + 0.2)
	return true
end