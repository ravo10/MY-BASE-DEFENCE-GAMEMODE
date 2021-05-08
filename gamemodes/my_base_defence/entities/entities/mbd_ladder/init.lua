AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/mbd_props/mbd_ladder.mdl")
		self:SetColor(Color(255, 0, 0, 255))

		local owner = self:GetCreator()
		self:SetOwnerOfLadder(owner)

		ClientPrintAddTextMessage(owner, {Color(254, 208, 0), "Trying to get you a ladder... Please wait..."})

		local playerLastTimeSpawnedALadder = os.time() - owner:GetNWInt("lastTimeSpawnedLadder", 0)
		local limit = GetConVar("mbd_ladderLimit"):GetInt()
		-- -
		timer.Remove("mbd:ladderPropCreationDelay" .. self:EntIndex())
		timer.Create(
			"mbd:ladderPropCreationDelay" .. self:EntIndex(),
			6,
			1,
			function()
				local amountOfLaddersSpawned = owner:GetNWInt("amountOfLaddersSpawned", 0)

				if self and self:IsValid() then
					--self:SetUseType(ONOFF_USE)

					owner:SetNWInt("amountOfLaddersSpawned", amountOfLaddersSpawned + 1)
					if amountOfLaddersSpawned > limit and owner:MBDIsNotAnAdmin(true) then
						if self and self:IsValid() then
							self:Remove()
						end

						ClientPrintAddTextMessage(
							owner,
							{Color(254, 81, 0), "You have reached the ladder limit (", Color(254, 208, 0), limit, Color(254, 81, 0), ")"}
						)

						return
					else
						if playerLastTimeSpawnedALadder <= 5 then
							if self and self:IsValid() then
								self:Remove()
							end

							ClientPrintAddTextMessage(owner, {Color(254, 208, 0), "Wait a little and try again..."})

							return
						else
							owner:SetNWInt("lastTimeSpawnedLadder", os.time())
							-- OK
							-- --
							-- -
							-- Physics stuff
							self:SetColor(Color(255, 255, 255, 255))
							self:Activate()
							self:SetMoveType(MOVETYPE_VPHYSICS)
							self:SetNotSolid(false)
							self:DrawShadow(true)
							-- Init physics only on server, so it doesn't mess up physgun beam
							if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end

							-- Make prop to fall on spawn
							local phys = self:GetPhysicsObject()
							if (IsValid(phys)) then
								phys:Wake()
							end

							ClientPrintAddTextMessage(owner, {Color(254, 208, 0), "There you go."})
							if amountOfLaddersSpawned > limit then
								ClientPrintAddTextMessage(owner, {Color(254, 208, 0), "...The ladder limit is reached, but you're an Admin."})
							end
						end
					end
				end
			end
		)
	end
end
function ENT:OnRemove()
	if SERVER then
		timer.Remove("mbd:ladderPropCreationDelay" .. self:EntIndex())
		local owner = self:GetOwnerOfLadder()

		local amountOfLaddersSpawned = owner:GetNWInt("amountOfLaddersSpawned", 0)
		if amountOfLaddersSpawned > 1 then
			owner:SetNWInt("amountOfLaddersSpawned", amountOfLaddersSpawned - 1)
		end
	end
end
function ENT:GravGunPickupAllowed(pl)
	if (pl:MBDIsAnAdmin(true) and pl == self:GetOwnerOfLadder()) then
		--
		return true
	else
		return false
	end
end
function ENT:Use(activator, caller, useType, value)
	if (self:IsPlayerHolding()) then
		return
	end

	activator:PickupObject(self)
end
