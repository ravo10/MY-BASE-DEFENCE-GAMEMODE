AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	-- Physics stuff
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	-- Init physics only on server, so it doesn't mess up physgun beam
	if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end

	-- Make prop to fall on spawn
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:Wake()

		phys:SetVelocity(Vector(math.random(-3, 3), math.random(-3, 3), math.random(100, 350)))
	end

	local timerIDOnRemoveLoader = "mbd:NPCDropGiverRemoveSelfLoader001"..self:EntIndex()
	local timerIDOnRemove = ""
	timer.Create(timerIDOnRemoveLoader, 0.15, (10 / 0.15), function()
		if self and self:IsValid() then
			timer.Remove(timerIDOnRemoveLoader)
			timerIDOnRemove = "mbd:NPCDropGiverRemoveSelf001"..self:EntIndex()

			self:UseTriggerBounds(true, 27.5)
			self:SetTrigger(true)

			timer.Create(timerIDOnRemove, 32.5, 1, function()
				if self and self:IsValid() then
					self:Remove()
				end
			end)
		end
	end)
	self:CallOnRemove("RemoveTimers", function(_ent)
		if _ent and _ent:IsValid() then
			timer.Remove(timerIDOnRemove)
		end
	end)
end
--
function ENT:GravGunPickupAllowed(pl)
	if (
		pl:MBDIsAnAdmin(true)
	) then
		--
		return true
	else
		return false
	end
end
--
--
function ENT:Touch(ent)
	if (
		ent:IsValid() and
		ent:IsPlayer() and
		not ent:GetNWBool("isSpectating", false)
	) then
		local removeSelf = function()
			if self and self:IsValid() then
				self:Remove()
			end
		end
		local givePlayer = function(_giveDataTable)
			local type = _giveDataTable.type
			local amount = _giveDataTable.amount
			local __sound = _giveDataTable.sound

			ent:SetNWInt(type, (ent:GetNWInt(type, 0) + amount))
			if type == "money" then
				SendLocalSoundToAPlayer("game_money_collected", ent)
			elseif type == "buildPoints" then
				SendLocalSoundToAPlayer("game_buildpoints_collected", ent)
			end

			removeSelf()
		end

		-- Give the Player the money/build points
		-- -
		givePlayer({
			type = self:GetTypeToGive(),
			amount = self:GetAmountToGive()
		})
	end

	return true
end