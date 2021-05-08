AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetName("mbd_ent")
	
	-- Physics stuff
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModel("models/props_phx/construct/metal_plate2x2.mdl")
	--

	-- Init physics only on server, so it doesn't mess up physgun beam
	if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end

	-- Make prop to fall on spawn
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then phys:Wake() end
end
function ENT:GravGunPickupAllowed(pl)
	if (
		pl:MBDIsAnAdmin(true)
	) then return true else return false end
end
----------------------------
--- ON TOUCH >>>
-----
local isUnactive = false
function __PushPlayerBackwards(_self, pl)
	local PlayerIsAdmin = false
	if (
		pl:MBDIsAnAdmin(true)
	) then PlayerIsAdmin = true end
	----
	--
	local __WorldPosPlayer = pl:GetPos()
	local __LocalAnglePlayer = pl:GetAngles()
	
	if !pl:GetNWBool("IsBeingTazed", false) then
		if PlayerIsAdmin then
			--
			-- Admin (push through)
			local __Yaw = __LocalAnglePlayer.yaw
			if 		(__Yaw >= 0 	and __Yaw <= 	90	) 	then -- Framom
				__WorldPosPlayer.x = (__WorldPosPlayer.x + 100)
				__WorldPosPlayer.z = (__WorldPosPlayer.z + 10)
			elseif 	(__Yaw >= 90 	and __Yaw <= 	180	) 	then -- Høgre
				__WorldPosPlayer.y = (__WorldPosPlayer.y + 100)
				__WorldPosPlayer.z = (__WorldPosPlayer.z + 10)
			elseif 	(__Yaw < 0 		and __Yaw <= 	-90	) 	then -- Bakom
				__WorldPosPlayer.x = (__WorldPosPlayer.x - 100)
				__WorldPosPlayer.z = (__WorldPosPlayer.z + 10)
			elseif 	(__Yaw < 0 		and __Yaw > 	-90	) 	then -- Venstre
				__WorldPosPlayer.y = (__WorldPosPlayer.y - 100)
				__WorldPosPlayer.z = (__WorldPosPlayer.z + 10)
			end
		end
	end
	--- 
	-----
	if !PlayerIsAdmin then
		if SERVER then
			MBDSetSoundAndEntity(
				ent
				"blocker/short_circut.wav",
				"110, 210" -- Max 255
			)
		end

		pl:TakeDamage(0.1, _self, _self)
	end

	-- -- Only do this one time..:>>
	if !PlayerIsAdmin then
		if !pl:GetNWBool("IsBeingTazed", false) then
			pl:Freeze(true)
			ClientPrintAddTextMessage(pl, {Color(0, 46, 254), "You just got tazed... Be careful."})

			timer.Simple(1, function()
				isUnactive = true
				pl:SetNWBool("IsBeingTazed", false)
				pl:Freeze(false)

				timer.Simple(2, function()
					isUnactive = false
				end)
			end)
		end

		pl:SetNWBool("IsBeingTazed", true)
	else
		-- Admin
		pl:SetPos(__WorldPosPlayer)
	end
end
function ENT:Touch(ent)
	if (
		ent:IsValid() and
		ent:IsPlayer() and
		!isUnactive
	) then
		-- Repell the Player in negative axis..>>
		--
		__PushPlayerBackwards(self, ent)
	end
end
