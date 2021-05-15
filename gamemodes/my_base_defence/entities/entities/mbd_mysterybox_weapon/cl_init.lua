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

	local MysteryBox = self:GetParentBoxEntity()
	local _CanTakeWeapon = MysteryBox:GetCanTakeWeapon()

	-- -
	if _CanTakeWeapon then
		if not MBDbo3RavoNiceWeaponNamesGame then MBDbo3RavoGetNiceWeaponNames() end

		-- Text
		local textTitle = "Name N/A"

		-- Nice name... Maybe
		if MBDbo3RavoNiceWeaponNamesGame and MBDbo3RavoNiceWeaponNamesGame[ _weaponClass ] then textTitle = MBDbo3RavoNiceWeaponNamesGame[ _weaponClass ] end

		-- -- --- -
		-- Color
		local textColor = self:GetColor()
		textColor = Color( 251, 255, 0, 240) -- Yellow

		local __Text = textTitle

		-- Draw front
		drawSpecialPropText( pos, ang, 0.3, __Text, textColor, false )
		-- Draw back
		drawSpecialPropText( pos, ang, 0.3, __Text, textColor, true )
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

hook.Add("HUDPaint", "bo3Ravo:mysteryboxSWEPHUD001", function()
	local playerTraceEntity = LocalPlayer():GetEyeTrace().Entity

	local ent = playerTraceEntity -- Should be the swep
	if (
		ent and
		ent:IsValid() and
		ent:GetClass() == "mbd_mysterybox_weapon"
	) then
		local MysteryBox = ent:GetParentBoxEntity()

		if not MysteryBox.GetCanUseBox then return end
		
		local canUseBox = MysteryBox:GetCanUseBox()

		local maybePlayerCanActivateThisMysterybox = string.Split(LocalPlayer():GetNWString("CanActivateMysteryboxMBD"), ";")
		local PlayerCanActivateThisBox = table.HasValue(maybePlayerCanActivateThisMysterybox, tostring(MysteryBox:EntIndex()))

		if (
			PlayerCanActivateThisBox and
			MysteryBox and
			MysteryBox:IsValid()
		) then
			local _OwnerOfWeapon = MysteryBox:GetWeaponEntity()
			if _OwnerOfWeapon and _OwnerOfWeapon:IsValid() then
				_OwnerOfWeapon = _OwnerOfWeapon:GetOwnerPlayer()
			end

			if (
				MysteryBox:GetCanTakeWeapon() and
				_OwnerOfWeapon == LocalPlayer()
			) then
				local text0, text1, text2 = "Press ", "E ", "for Weapon"
				
				local baseWidthPos = ScrW() / 2
				local width0, width1, width2 = _MBDBo3RavoNorwayMysteryBoxGetTextWidth(text0), _MBDBo3RavoNorwayMysteryBoxGetTextWidth(text1), _MBDBo3RavoNorwayMysteryBoxGetTextWidth(text2)

				-- Draw
				__MBDBo3RavoNorwayMysteryBoxDrawText(text0, (baseWidthPos - width0))
				__MBDBo3RavoNorwayMysteryBoxDrawText(text1, (baseWidthPos - width1), Color(255, 226, 96, 250))
				__MBDBo3RavoNorwayMysteryBoxDrawText(text2, (baseWidthPos + width2 - (width0 + 3)))
			end
		end
	end
end)
