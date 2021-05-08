include("shared.lua")
 
function ENT:Draw()
	if not self or not self:IsValid() then return end

	self:DrawModel()

	local localMaxs = self:OBBMaxs()

	local pos = self:GetPos() + Vector(0, 0, localMaxs.z + 22)
	local ang = Angle(0, (RealTime() * ((6.5 * 10) % 360)), 90)

	local textTitle = "BuyBox Station"
	local textColor = Color(255, 210, 4)
	textColor = Color(textColor.r, textColor.g, textColor.b, 240)
	
	-- Draw front
	drawSpecialPropText(pos, ang, 0.65, textTitle, textColor, false)
	-- Draw back
	drawSpecialPropText(pos, ang, 0.65, textTitle, textColor, true)
	--- -
end
