include("shared.lua")

function ENT:Draw()
	if not self or not self:IsValid() then
		return
	end

	self:DrawModel()

	-- Emit some lights above (gold)
	-- -- -
	local lightAbove = DynamicLight(self:EntIndex())
	if lightAbove then
		lightAbove.pos = self:LocalToWorld(self:OBBCenter()) + Vector(0, 0, 20)

		local __color = Color(105, 3, 252, 255)

		lightAbove.r = __color.r
		lightAbove.g = __color.g
		lightAbove.b = __color.b

		lightAbove.brightness = 4.5
		lightAbove.Decay = 10
		lightAbove.Size = 380
		lightAbove.DieTime = CurTime() + 0.15
	end
end