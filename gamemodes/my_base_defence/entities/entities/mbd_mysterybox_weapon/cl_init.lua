include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local localMaxs = self:OBBMaxs()

	local pos = self:GetPos() + Vector(0, 0, localMaxs.z + 4)
	local ang = self:GetAngles() + Angle(0, 0, 90)
	
	--- Get Data
	if not self.GetCurrentWeaponClassSwitch then return end

	local _weaponClass = self:GetCurrentWeaponClassSwitch()
	if not _weaponClass then return end
	_weaponClass = string.lower(_weaponClass)

	local _parentBox = self:GetParentBoxEntity()
	local _CanTakeWeapon = _parentBox:GetCanTakeWeapon()

	-- -
	if _CanTakeWeapon then
		if not __NAME_Weapons then
			mbd_bo3_ravo_getNiceWeaponNames()
		end

		-- Text
		local textTitle = "N/A"
		if __NAME_Weapons then textTitle = __NAME_Weapons[_weaponClass] end
		if not __NAME_Weapons or not textTitle or textTitle == "" then textTitle = _weaponClass end
		if not textTitle or textTitle == "" then textTitle = "N/A" end
		-- Color
		local textColor = self:GetColor()
		textColor = Color(255, 215, 0, 240) -- Gold

		local __Text = textTitle
		
		-- Draw front (kind of back)
		drawSpecialPropText(pos, ang, 0.3, __Text, textColor, false)
		-- Draw back (kind of front)
		drawSpecialPropText(pos, ang, 0.3, __Text, textColor, true)
	end

	-- Emit some lights for seeing weapons in the dark (center)
	-- -- -
	local lightCenter = DynamicLight(self:EntIndex())
	if lightCenter then
		lightCenter.pos = self:LocalToWorld(self:OBBCenter()) + Vector(0, 0, 0)

		lightCenter.r 	= 33
		lightCenter.g 	= 217
		lightCenter.b 	= 242
		
		lightCenter.brightness 	= 3
		lightCenter.Decay 		= 0.1
		lightCenter.Size 		= 100
		lightCenter.DieTime 	= CurTime()
	end
end