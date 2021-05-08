if engine.ActiveGamemode() == "my_base_defence" then
	AddCSLuaFile()
	
	local LIFETIME = math.random(0.2, 0.3)

	----------------
	-- Initialize --
	----------------
	function EFFECT:Init(data)
		self.StartPos 	= data:GetStart()	
		self.EndPos 	= data:GetOrigin()
		self.Dir 		= self.EndPos - self.StartPos
		self:SetRenderBoundsWS( self.StartPos, self.EndPos )
		self.DieTime = CurTime() + LIFETIME
		
		local emitter = ParticleEmitter(self.StartPos)
		for i=1, math.random(4) do
			local particle = emitter:Add("sprites/light_glow02_add",self.StartPos)
			if particle then
				particle:SetColor(255,255,153,25)
	--			particle:SetVelocity(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)):GetNormal() * 20)
	--			timer.Simple(0.25, function()
	--				particle:SetVelocity(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)):GetNormal() * 20)
	--			end)
				particle:SetDieTime(11)
				particle:SetLifeTime(0)
				particle:SetStartSize(50)
				particle:SetEndSize(50)
			end
		end
		emitter:Finish()
	end

	------------------
	-- Effect Think --
	------------------
	function EFFECT:Think()
		return false -- Return true if you want to have
					-- this effect emit particles for
					-- more than just one frame.
	end


	-------------------
	-- Render Effect --
	-------------------
	function EFFECT:Render()

	end
end
