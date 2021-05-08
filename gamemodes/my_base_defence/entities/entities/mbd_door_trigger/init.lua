AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	-- Physics stuff
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetNotSolid(true)
	self:DrawShadow(false)

	-- Init physics only on server, so it doesn't mess up physgun beam
	if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end

	-- Make prop to fall on spawn
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then phys:Wake() end

	self:SetNWString("allPlayersAllowedUniqueID", self:GetOwner():UniqueID().." ")
end
function ENT:GravGunPickupAllowed(pl)
	return false
end
----------------------------
--- ON TOUCH >>>
-----
function ENT:Touch(ent)
	if !ent or !ent:IsValid() or !ent:IsPlayer() then return false end

	local _PlayerUniqueID = ent:UniqueID()

	local _AllowedPlayers = self:GetNWString("allPlayersAllowedUniqueID", nil)
	if _AllowedPlayers then _AllowedPlayers = string.Split(_AllowedPlayers, " ") else return false end

	for k,v in pairs(_AllowedPlayers) do
		if tonumber(v) == tonumber(_PlayerUniqueID) then
			-- Found an Allowed Player...>>

			-- Make the Prop No-Collidable for Players >>
			--
			_Parent = self:GetParent()
			if !_Parent or !_Parent:IsValid() then return false end

			--
			--_Parent:SetNotSolid(true)
			_Parent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

			return true
		end

		if k == #_AllowedPlayers then return false end
	end
end
function ENT:EndTouch(ent)
	if !ent or !ent:IsValid() or !ent:IsPlayer() then return false end

	-- Make solid again >>
	-- --
	_Parent = self:GetParent()
	if !_Parent or !_Parent:IsValid() then return false end
	
	--
	--_Parent:SetNotSolid(false)
	_Parent:SetCollisionGroup(COLLISION_GROUP_BREAKABLE_GLASS)

	return true
end