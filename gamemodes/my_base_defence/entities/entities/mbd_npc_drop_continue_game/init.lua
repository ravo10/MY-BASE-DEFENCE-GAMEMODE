AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	-- Physics stuff
	self:SetModel("models/lightball/lightball.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local timerIDOnRemoveLoader = "mbd:NPCDropContinueGameSelfLoader001"..self:EntIndex()
	local timerIDOnRemove = ""
	timer.Create(timerIDOnRemoveLoader, 0.15, (10 / 0.15), function()
		if self and self:IsValid() then
			timer.Remove(timerIDOnRemoveLoader)
			timerIDOnRemove = "mbd:NPCDropContinueGameSelfLoader001"..self:EntIndex()

			self:UseTriggerBounds(true, 27.5)
			self:SetTrigger(true)
		end
	end)
	self:CallOnRemove("RemoveTimers", function(_ent)
		if _ent and _ent:IsValid() then
			timer.Remove(timerIDOnRemove)
		end
	end)

	-- Delete
	if GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt() >= GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() then
		if self and self:IsValid() then self:Remove() end
	end -- Overkill to put it here also, but what ever
end
--
function ENT:GravGunPickupAllowed(pl)
	if (pl:MBDIsAnAdmin(true)) then
		--
		return true
	else
		return false
	end
end
--
--
function ENT:Touch(ent)
	if !GameStarted then return end

	if (ent:IsValid() and ent:IsPlayer() and not ent:GetNWBool("isSpectating", false)) then
		local removeSelf = function()
			if self and self:IsValid() then
				self:Remove()
			end
		end

		removeSelf()
		SendLocalSoundToAPlayer("game_pyramid_drop_pickup", ent)
		
		-- Notify all Players that the drop was picked up, and how many needed that are left
		local howManyDropItemsPickedUpByPlayers = GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt()
		if howManyDropItemsPickedUpByPlayers >= GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() then return end -- Overkill to put it here also, but what ever
		GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):SetInt(howManyDropItemsPickedUpByPlayers + 1)

		-- print("Picked up a pyramid. Now => (", GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt(), ")")

		local string0 = "A PYRAMID was picked up by "..ent:Nick().."!"
		local amountMax = GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt()
		local status = GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt().."/"..amountMax
		if amountMax < 3 then status = "N/A" end
		net.Start("NotificationReceivedFromServer")
			net.WriteTable({
				Text 	= string0,
				Type	= NOTIFY_GENERIC,
				Time	= 4
			})
		net.Broadcast()
		--
		net.Start("PyramidStatus")
			net.WriteString(status)
		net.Broadcast()

		-- Give Player some B.P. and £B.D.
		ent:SetNWInt("buildPoints", (ent:GetNWInt("buildPoints", 0) + 1200))
		ent:SetNWInt("money", (ent:GetNWInt("money", 0) + 600))
	end

	return true
end
function ENT:OnRemove()
	timer.Remove("mbd:NPCDropContinueGameSelfLoader001"..self:EntIndex())
	timer.Remove("mbd:CountDownToAnimationDone"..self:EntIndex())
end
function ENT:Think()
	self:ResetSequence("idle")

	self:NextThink(CurTime())
	return true
end
