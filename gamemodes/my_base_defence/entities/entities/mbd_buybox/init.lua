AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:SpawnFunction(pl, tr)
	if not tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal

	local ent = ents.Create("mbd_buybox")
	ent:SetPos(SpawnPos + Vector(0, 0, 50))
	ent:SetAngles(
		Angle(180, pl:EyeAngles().y, -180)
	)

	ent:Spawn()
	ent:Activate()

	return ent
end
function ENT:Initialize()
	self:SetName("mbd_ent")
	
	-- Sets what model to use
	self:SetUseType(ONOFF_USE)
	self:SetModel("models/buybox/buybox.mdl")
	
	-- Sets what color to use
	-- self:SetColor(Color(22, 166, 236, 255)) -- blue

	-- Physics stuff
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	-- Init physics only on server, so it doesn't mess up physgun beam
	if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end

	-- Make prop to fall on spawn
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then phys:Wake() end
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
function ENT:SetAndCountDownToNextAnimationPlay(sec)
	timer.Remove("mbd:CountDownToAnimationDone"..self:EntIndex())
	
	self:SetStartNewAnimationSequence(false)
	self:ResetSequence("active")

	timer.Create("mbd:CountDownToAnimationDone"..self:EntIndex(), sec, 1, function()
		self:SetStartNewAnimationSequence(true)
	end)
end
--
--
function ENT:Use(activator, caller, useType, value)
	if (
		caller and
		caller:IsValid() and
		caller:IsPlayer() and
		!caller:GetNWBool("isSpectating", false)
	) then
		if useType == USE_ON then
			--
			net.Start("OpenBuyBoxMenu")
			net.Send(caller)
		elseif useType == USE_OFF then
			--
			net.Start("CloseBuyBoxMenu")
			net.Send(caller)
		end
	end

	return true
end
-- On remove...
function ENT:OnRemove()
	timer.Remove("mbd:CountDownToAnimationDone"..self:EntIndex())
end
function ENT:Think()
	if self:GetStartNewAnimationSequence() then
		self:SetAndCountDownToNextAnimationPlay(8 --[[ <-- base time for whole animation ]] + 3)
	end

	if (SERVER) then
		self:NextThink(CurTime())
		return true
	end
end