AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	local _parent = self:GetParent()

	self:SetModel(_parent:GetModel())
	self:SetModelScale(0.7)
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
function ENT:GravGunPickupAllowed(pl) return false end
----------------------------
--- ON TOUCH >>>
-----
function ENT:StartTouch(ent)
	if (
		not ent or
		not ent:IsValid() or
		not ent:IsPlayer()
	) then return end

	local currentAllowedPlayers = self:GetNWString("allowedPlayersHealProp", "")
	-- Add the Player to string-table, to be allowed to heal the Prop
	if currentAllowedPlayers == "" then currentAllowedPlayers = {} else
		currentAllowedPlayers = string.Split(currentAllowedPlayers, ",")
	end

	if ent.UniqueID and not table.HasValue(currentAllowedPlayers, ent:UniqueID()) then
		-- Insert to table
		table.insert(currentAllowedPlayers, ent:UniqueID())

		-- Save
		self:SetNWString("allowedPlayersHealProp", table.concat(currentAllowedPlayers, ","))
	end
end
function ENT:EndTouch(ent)
	if (
		not ent
		or not ent:IsValid()
		or not ent:IsPlayer()
	) then return end

	local currentAllowedPlayers = self:GetNWString("allowedPlayersHealProp", "")
	if currentAllowedPlayers == "" then currentAllowedPlayers = {} else
		currentAllowedPlayers = string.Split(currentAllowedPlayers, ",")
	end

	local uniqueId = "-1"
	if not ent:IsValid() then return else
		if ent.UniqueID then uniqueId = tostring(ent:UniqueID()) end
	end

	if uniqueId ~= "-1" and table.HasValue(currentAllowedPlayers, uniqueId) then
		-- Remove from Table
		table.RemoveByValue(currentAllowedPlayers, uniqueId)

		-- Save
		self:SetNWString("allowedPlayersHealProp", table.concat(currentAllowedPlayers, ","))
	end
end
