include("shared.lua")
 
function ENT:Draw()
	if not self or not self:IsValid() then return end

	self:DrawModel()

	-- Emit some lights above (gold)
	-- -- -
	local lightAbove = DynamicLight(self:EntIndex())
	if lightAbove then
		lightAbove.pos = self:LocalToWorld(self:OBBCenter()) + Vector(0, 0, 2)

		local __color = Color(255, 255, 255, 255)
		if self:GetTypeToGive() == "money" then
			__color = Color(249, 204, 22, 255)
		elseif self:GetTypeToGive() == "buildPoints" then
			__color = Color(43, 212, 255, 255)
		end
		lightAbove.r = __color.r
		lightAbove.g = __color.g
		lightAbove.b = __color.b
		
		lightAbove.brightness	= 3
		lightAbove.Decay 		= 5
		lightAbove.Size 		= 53
		lightAbove.DieTime 		= CurTime() + 0.15
	end
end
