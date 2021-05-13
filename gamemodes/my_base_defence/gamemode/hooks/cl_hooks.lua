function draw.Circle(x, y, radius, seg)
	local cir = {}

	table.insert(
		cir,
		{
			x = x,
			y = y,
			u = 0.5,
			v = 0.5
		}
	)
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(
			cir,
			{
				x = x + math.sin(a) * radius,
				y = y + math.cos(a) * radius,
				u = math.sin(a) / 2 + 0.5,
				v = math.cos(a) / 2 + 0.5
			}
		)
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(
		cir,
		{
			x = x + math.sin(a) * radius,
			y = y + math.cos(a) * radius,
			u = math.sin(a) / 2 + 0.5,
			v = math.cos(a) / 2 + 0.5
		}
	)

	surface.DrawPoly(cir)
end

function draw.FadingBorder(width, height, xPos, yPos, heightShadowBox, opacity, oppositDirection)
	local maxAmountOfBars = (height - 1) / heightShadowBox * opacity

	for i=0,maxAmountOfBars do
		local alpha
		if oppositDirection then
			-- Gradient from bottom => top
			alpha = math.ceil(( (255 / maxAmountOfBars) * i))
		else
			-- Gradient from top => bottom
			alpha = math.floor(255 - ( (255 / maxAmountOfBars) * i))
		end
		-- -
		local currDrawColor = surface.GetDrawColor()
		surface.SetDrawColor(currDrawColor.r, currDrawColor.g, currDrawColor.b, alpha)
		-- -
		surface.DrawRect(
			0 + xPos,
			0 + yPos + i * heightShadowBox,
			width,
			heightShadowBox
		)
	end
end

local cursorMaterial = Material("vgui/mbd_cursor", "smooth")

function draw.CustomCursor(panel, material)
	if panel and panel:IsValid() then
		local mat = material or cursorMaterial

		-- Make the default cursor disappear
		panel:SetCursor("blank")

		-- Paint the custom cursor
		local cursorX, cursorY = panel:LocalCursorPos()

		surface.SetDrawColor(255, 255, 255, 240)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(cursorX, cursorY, 25, 25)
	end
end
--
--
--
-- -- -- =>> HOOKS ran at start...
--
local function GetAnimationCurrentTimeHUD() return SysTime() end
local function GetAnimationCurrentTimeFPS() return RealTime() end
-- - Control the default HUD
-- https://wiki.facepunch.com/gmod/HUD_Element_List Can also hide the health, suit battery etc.
hook.Add("HUDShouldDraw", "mbd:HUDShouldDraw001", function(name)
	local isPlayerSpectating = LocalPlayer():GetNWBool("isSpectaing", false)

	-- When Player is in slow motion
	if ( slowMotionGameIsActivatedByPlayerSinglePlayer or slowMotionKeyIsDown ) and name == "CHudWeaponSelection" then return false end
	-- When Player is spectating
	if isPlayerSpectating and ( name == "CHudHealth" or name == "CHudBattery" or name == "CHudWeaponSelection" ) then return false end
	-- When Game is not started yet
	if not gameStarted and ( name == "CHudHealth" or name == "CHudBattery" ) then return false end
	-- When in third person
	if ( checkIfPlayerIsInTopView() or currentCameraView == 3 or currentCameraView == 2 ) and ( name == "CHudCrosshair" ) then return false end
end)
-- -
hook.Add("CalcView", "mbd:CalcView001", function(pl, pos, angles, fov, znear, zfar)
	local view = {}
	local isPlayerSpectating = LocalPlayer():GetNWBool("isSpectating", false)

	if !isPlayerSpectating and checkIfPlayerIsInTopView() then
		-- Top View
		local playerHeight = 0
		local newPos = LocalPlayer():LocalToWorld((LocalPlayer():WorldToLocal(pos) + Vector(-200, 630, 150)))
		view.origin = newPos - Vector(0, 0, 50)
		view.angles = angles + Angle(55, 0, 0)
		view.drawviewer = true
		local scale = 700
		view.ortho = {
			left = 0,
			right = scale * 2 - scale / 3,
			top = 0,
			bottom = scale
		}
	elseif !isPlayerSpectating and currentCameraView == 3 then
		-- Third person
		local newPos = LocalPlayer():LocalToWorld((LocalPlayer():WorldToLocal(pos) + Vector(0, -0, 33)))
		view.origin = newPos - angles:Forward() * 100
		view.angles = angles - Angle(6, -6, 3.7)
		view.fov = fov
		view.drawviewer = true
	elseif !isPlayerSpectating and currentCameraView == 2 then
		--- Side
		local newPos = LocalPlayer():LocalToWorld((LocalPlayer():WorldToLocal(pos) + Vector(1, 16, -3)))
		view.origin = newPos - angles:Forward() * 3
		view.angles = angles - Angle(0, 10, -6)
		view.fov = fov
		view.drawviewer = true
	elseif !isPlayerSpectating and currentCameraView == 1 then
		-- Cool view
		view.origin = pos
		view.angles = angles
		view.fov = fov + 9
		view.drawviewer = false
		view.znear = znear
		view.zfar = zfar
	else
		-- Normal
		view.origin = pos
		view.angles = angles
		view.fov = fov
		view.drawviewer = false
		view.znear = znear
		view.zfar = zfar
	end

	return view
end)
local tiltForPlayerTimeDifference = GetAnimationCurrentTimeHUD()
-- Settings:: : Higher = Faster animation
local tilForPlayerAnimationLimitOriginal = 0.006 * 1.25
local tilForPlayerAnimationLimit = tilForPlayerAnimationLimitOriginal
-- - -
local currentTilForPlayerAnimationLimit = tilForPlayerAnimationLimit
local currentTilForPlayer = 0
--
local realTimeViewAngleOtherWise = GetAnimationCurrentTimeHUD()
local currentViewAngleOtherWiseAnimationLimit = 0.1 * 1.25
local currentPlayerViewAngles = nil
--
local function createTiltForPlayer(ccmd, x, sensitivity, clampValuesTable)
	-- Add some tilt ( Pretty good )
	local targetValue = x + ccmd:GetMouseX() / sensitivity -- Lower equals more sensitivity
	targetValue = math.Clamp(targetValue, clampValuesTable["clamp"][1], clampValuesTable["clamp"][2])

	local tiltForPlayerTimeDifferenceResult = GetAnimationCurrentTimeHUD() - tiltForPlayerTimeDifference
	-- When there is less than 30 % left to 0, make the animaion time faster by 300 %
	local compareValue = targetValue
	if compareValue < 0 then compareValue = compareValue * -1 end
	if compareValue <= 13 then tiltForPlayerTimeDifferenceResult = tiltForPlayerTimeDifferenceResult * 3.5 end

	-- Animate
	local newValue = MBDLerp(tiltForPlayerTimeDifferenceResult, currentTilForPlayer, targetValue)
	currentTilForPlayer = newValue -- Save

	return newValue
end
local function adjustAnimationSpeed(gameCurrentTimeScale, playerIsSpectating)
	-- -
	-- Set animation speed
	if playerIsSpectating then
		-- Make it go faster when running
		currentTilForPlayerAnimationLimit = currentTilForPlayerAnimationLimit - 0.1
	elseif playerIsRunning then
		-- Make it go faster when running
		currentTilForPlayerAnimationLimit = 0.012 * ( gameCurrentTimeScale )
	else
		-- Normal
		currentTilForPlayerAnimationLimit = tilForPlayerAnimationLimitOriginal * ( gameCurrentTimeScale )
	end
end
local function maybeAdjusTimeDifference0() if GetAnimationCurrentTimeHUD() - tiltForPlayerTimeDifference > currentTilForPlayerAnimationLimit then tiltForPlayerTimeDifference = GetAnimationCurrentTimeHUD() end end
local function maybeAdjusTimeDifference1() if GetAnimationCurrentTimeHUD() - realTimeViewAngleOtherWise > currentViewAngleOtherWiseAnimationLimit then realTimeViewAngleOtherWise = GetAnimationCurrentTimeHUD() end end
hook.Add("InputMouseApply", "mbd:InputMouseApply_Tilt001", function(ccmd, x, y, angle)
	maybeAdjusTimeDifference0() -- Important, so the view doesn't spinn crazy if the user pauses the screen...

	if !currentPlayerViewAngles then currentPlayerViewAngles = { angle[1], angle[2], angle[3] } end
	
	local gameCurrentTimeScale = game.GetTimeScale()
	if gameCurrentTimeScale > 3 then gameCurrentTimeScale = 3 end

	local playerIsRunning = LocalPlayer():GetNWBool("mbd:PlayerIsCurrentlyRunning", false)
	local playerIsSpectating = LocalPlayer():GetNWBool("isSpectating", false)

	local newAngle1
	local newAngle2
	local newAngle3
	
	if !playerIsSpectating and checkIfPlayerIsInTopView() then
		-- Top View
		local speed1 = 250 -- Lower = Higher sensitivity
		local speed2 = 100 -- Lower = Higher sensitivity
		newAngle1 = angle[1] + y / speed1
		newAngle2 = angle[2] + (x * -1) / speed2
		
		angle[1] = math.Clamp(newAngle1, 5.88, 32.52)
		angle[2] = math.Clamp(newAngle2, -360, 360)
		angle[3] = createTiltForPlayer(ccmd, x, 110, { clamp = {-3.3, 3.3} })
	elseif GetConVar("mbd_disablePlayerTilt"):GetInt() <= 0 then
		-- Normal ( with tilt )
		local speed = 60 -- Lower = Higher sensitivity ( to high = laggy screen... )
		newAngle1 = angle[1] + y / speed
		newAngle2 = angle[2] + (x * -1) / speed

		angle[1] = math.Clamp(newAngle1, -89, 89)
		angle[2] = math.Clamp(newAngle2, -361, 361)
		angle[3] = createTiltForPlayer(ccmd, x, 180, { clamp = {-43, 37} })
	else
		-- Normal ( without tilt )
		local speed = 60 -- Lower = Higher sensitivity
		newAngle1 = angle[1] + y / speed
		newAngle2 = angle[2] + (x * -1) / speed

		angle[1] = math.Clamp(newAngle1, -89, 89)
		angle[2] = math.Clamp(newAngle2, -361, 361)
		angle[3] = 0
	end currentPlayerViewAngles = { angle[1], angle[2], angle[3] }
	ccmd:SetViewAngles(angle)

	adjustAnimationSpeed(gameCurrentTimeScale, playerIsSpectating)
	maybeAdjusTimeDifference0()
	maybeAdjusTimeDifference1()

	return true
end)
-- -
-- Draw motion blur
local function veryTierdSound(startOrStop)
	local staminaSoundIsPlaying = LocalPlayer():GetNWInt("mbd:PlayerStaminaSoundPlaying", false)

	if startOrStop and !staminaSoundIsPlaying then
		LocalPlayer():SetNWInt("mbd:PlayerStaminaSoundPlaying", true)

		LocalPlayer():EmitSound("game_slow_breathing")
		timer.Create("mbd:PlayerStaminaSoundPlayingTimer", 10, 1, function()
			LocalPlayer():SetNWInt("mbd:PlayerStaminaSoundPlaying", false)
			LocalPlayer():StopSound("game_slow_breathing")
		end)
	end
end

local OriginalTab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.019,
	["$pp_colour_addb"] = 0.023,
	["$pp_colour_brightness"] = 0.02,
	["$pp_colour_contrast"] = 0.9,
	["$pp_colour_colour"] = 1.4,
	["$pp_colour_mulr"] = 0.2,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 9,
	bloomStrength = 1,
	bloomRed = 1,
	toyBox0 = 3,
	toyBox1 = ScrH() / 3.2
}
-- Important to do it likes this ( do not add a pure copy of the OriginalTab )
local newTab = {
	["$pp_colour_addr"] = OriginalTab["$pp_colour_addr"],
	["$pp_colour_addg"] = OriginalTab["$pp_colour_addg"],
	["$pp_colour_addb"] = OriginalTab["$pp_colour_addb"],
	["$pp_colour_brightness"] = OriginalTab["$pp_colour_brightness"],
	["$pp_colour_contrast"] = OriginalTab["$pp_colour_contrast"],
	["$pp_colour_colour"] = OriginalTab["$pp_colour_colour"],
	["$pp_colour_mulr"] = OriginalTab["$pp_colour_mulr"],
	["$pp_colour_mulg"] = OriginalTab["$pp_colour_mulg"],
	["$pp_colour_mulb"] = OriginalTab["$pp_colour_mulb"],
	bloomStrength = OriginalTab["bloomStrength"],
	bloomRed = OriginalTab["bloomRed"],
	toyBox0 = OriginalTab["toyBox0"],
	toyBox1 = OriginalTab["toyBox1"]
}

local realTimeDifference0 = GetAnimationCurrentTimeFPS()
local realTimeDifference1 = GetAnimationCurrentTimeFPS()
local realTimeDifference2 = GetAnimationCurrentTimeFPS()
local realTimeDifference3 = GetAnimationCurrentTimeFPS()
local realTimeDifference4 = GetAnimationCurrentTimeFPS()
local realTimeDifference5 = GetAnimationCurrentTimeHUD()

local currentColorModifyTable
local function animations_BrightnessMulrAddr(targetBrightnessTable, targetMulrTable, targetAddrTable, amountOfExtraRedOnScreen, isPlayerSpectating)
	local brightness = MBDLerp(targetBrightnessTable[1], newTab["$pp_colour_brightness"], targetBrightnessTable[2])
	local mulr = MBDLerp(targetMulrTable[1], newTab["$pp_colour_mulr"], targetMulrTable[2])
	local addr = MBDLerp(targetAddrTable[1], newTab["$pp_colour_addr"], targetAddrTable[2])

	local decreaseEffectWhenInTopView = 1
	if !isPlayerSpectating and checkIfPlayerIsInTopView() then decreaseEffectWhenInTopView = 0.2 end

	newTab["$pp_colour_brightness"] = ( brightness - amountOfExtraRedOnScreen[3] ) * decreaseEffectWhenInTopView
	newTab["$pp_colour_mulr"] = ( mulr + amountOfExtraRedOnScreen[1] ) * decreaseEffectWhenInTopView
	newTab["$pp_colour_addr"] = ( addr + amountOfExtraRedOnScreen[2] ) * decreaseEffectWhenInTopView

	currentColorModifyTable = newTab
end
local function animations_bloomStrengthBloomRed(targetBloomStrengthTable, targetBloomRedTable, targetAddr, isPlayerSpectating)
	local bloomStrength = MBDLerp(targetBloomStrengthTable[1], newTab["bloomStrength"], targetBloomStrengthTable[2])
	local bloomRed = MBDLerp(targetBloomRedTable[1], newTab["bloomRed"], targetBloomRedTable[2])

	local decreaseEffectWhenInTopView = 1
	if !isPlayerSpectating and checkIfPlayerIsInTopView() then decreaseEffectWhenInTopView = 1.3 end

	newTab["bloomStrength"] = ( bloomStrength ) * decreaseEffectWhenInTopView
	newTab["bloomRed"] = ( bloomRed ) * decreaseEffectWhenInTopView
end
local function GETMaybeDrawMotionBlur(IsInVehicle, overrideUserSettings, a, b, c)
	local mbd_disablePlayerBlurEffect = GetConVar("mbd_disablePlayerBlurEffect"):GetInt() > 0


	if mbd_disablePlayerBlurEffect and gameIsSingleplayer then
		return DrawMotionBlur(a / 0.7, b * 0.15, c * 0.15)
	elseif mbd_disablePlayerBlurEffect and !overrideUserSettings and gameIsSingleplayer then -- The game settings can be overidden when in multiplayer
		if IsInVehicle then DrawMotionBlur(a, b, c) else return nil end
	else
		return DrawMotionBlur(a, b, c)
	end
end
local function GETMaybeDrawToyBoxMotionBlurValue(lerpTime, from, to)
	local mbd_disablePlayerToyTownBlurEffect = GetConVar("mbd_disablePlayerToyTownBlurEffect"):GetInt() > 0
	if mbd_disablePlayerToyTownBlurEffect then return 0 else return MBDLerp(lerpTime, from, to) end
end

local prevColorEnhancerState = GetConVar("mbd_PlayerColorEnhancerState"):GetInt()
function GM:RenderScreenspaceEffects()
	local mbd_PlayerColorEnhancerState = GetConVar("mbd_PlayerColorEnhancerState"):GetInt()
	if mbd_PlayerColorEnhancerState != prevColorEnhancerState then
		prevColorEnhancerState = mbd_PlayerColorEnhancerState

		if mbd_PlayerColorEnhancerState <= 0 then
			-- Color enhancer
			OriginalTab = {
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0.019,
				["$pp_colour_addb"] = 0.023,
				["$pp_colour_brightness"] = 0.02,
				["$pp_colour_contrast"] = 0.9,
				["$pp_colour_colour"] = 1.4,
				["$pp_colour_mulr"] = 0.2,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 9,
				bloomStrength = 1,
				bloomRed = 1,
				toyBox0 = 3,
				toyBox1 = ScrH() / 3.2
			}
			newTab = OriginalTab
		elseif mbd_PlayerColorEnhancerState == 1 then
			-- A small amount of color enhancer added
			OriginalTab = {
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = 0,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = 1.3,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0,
				bloomStrength = 1,
				bloomRed = 1,
				toyBox0 = 3,
				toyBox1 = ScrH() / 3.2
			}
			newTab = OriginalTab
		elseif mbd_PlayerColorEnhancerState >= 2 then
			-- No color enhancer
			OriginalTab = {
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = 0,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = 1,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0,
				bloomStrength = 1,
				bloomRed = 1,
				toyBox0 = 3,
				toyBox1 = ScrH() / 3.2
			}
			newTab = OriginalTab
		end
	end

	local playerStaminaRun = LocalPlayer():GetNWInt("mbd:PlayerCurrentStaminaRun", 100)
	local playerVehicleBlurAmount = string.Split(LocalPlayer():GetNWString("mbd:blurAmountForPlayerVehicle", "0,0,0"), ",")

	local playerisSpectating = LocalPlayer():GetNWBool("isSpectating", false)
	local playerCurrClass = LocalPlayer():GetNWInt("classInt", -1)

	local playerIsAiming = LocalPlayer():GetNWBool("playerIsAiming", false)

	local gameCurrentTimeScale = game.GetTimeScale()
	if gameCurrentTimeScale > 1 then gameCurrentTimeScale = 1 end
	
	-- If Player really hurt
	local currPlayerHealth = LocalPlayer():Health()
	local amountOfExtraRedOnScreen = { 0, 0, 0 }

	local realTimeDifferenceResult0 = GetAnimationCurrentTimeFPS() - realTimeDifference0
	local realTimeDifferenceResult1 = GetAnimationCurrentTimeFPS() - realTimeDifference1
	local realTimeDifferenceResult2 = GetAnimationCurrentTimeFPS() - realTimeDifference2
	local realTimeDifferenceResult3 = GetAnimationCurrentTimeFPS() - realTimeDifference3
	local realTimeDifferenceResult4 = GetAnimationCurrentTimeFPS() - realTimeDifference4
	local realTimeDifferenceResult5 = GetAnimationCurrentTimeHUD() - realTimeDifference5

	-- Adjust effects to if player is spectating
	if gameStarted then
		if !playerisSpectating and ( ( LocalPlayer():MBDIsNotAnAdmin(true) ) or ( LocalPlayer():MBDIsAnAdmin(true) and playerCurrClass > -1 ) ) then
			if currPlayerHealth <= 60 then
				amountOfExtraRedOnScreen[1] = 0.023 amountOfExtraRedOnScreen[2] = 0.0014 amountOfExtraRedOnScreen[3] = 0.021
			elseif currPlayerHealth <= 120 then
				amountOfExtraRedOnScreen[1] = 0.023 amountOfExtraRedOnScreen[2] = 0.0013 amountOfExtraRedOnScreen[3] = 0.017
			end
		elseif playerisSpectating then
			amountOfExtraRedOnScreen[1] = -0.023 amountOfExtraRedOnScreen[2] = -0.0012 amountOfExtraRedOnScreen[3] = -0.012
		end
	end

	-- Percentage
	local stagesOfTired = {
		70,
		50,
		20,
		2
	}

	-- Just for motion blur
	if playerStaminaRun < stagesOfTired[2] then
		if playerStaminaRun <= stagesOfTired[4] then
			-- Very very tired
			GETMaybeDrawMotionBlur(false, true, 0.05 * gameCurrentTimeScale, 1.78 / gameCurrentTimeScale, 0.008)
		elseif playerStaminaRun < stagesOfTired[3] then
			-- Very Tired
			GETMaybeDrawMotionBlur(false, true, 0.06 * gameCurrentTimeScale, 3.5 / gameCurrentTimeScale, 0.007)

			veryTierdSound(true)
		elseif playerStaminaRun < stagesOfTired[2] then
			-- A little Tired
			GETMaybeDrawMotionBlur(false, true, 0.2 * gameCurrentTimeScale, 1.75 / gameCurrentTimeScale, 0.00005)
		end
	else
		if LocalPlayer():InVehicle() then
			GETMaybeDrawMotionBlur(true, true, tonumber(playerVehicleBlurAmount[1]), tonumber(playerVehicleBlurAmount[2]), tonumber(playerVehicleBlurAmount[3]))
		else
			-- Normal State
			GETMaybeDrawMotionBlur(true, false, 0.515 * gameCurrentTimeScale, 1.3 / gameCurrentTimeScale, 0.00002)
		end
	end

	if playerStaminaRun <= stagesOfTired[4] then
		-- Most tired
		local addr = MBDLerp(realTimeDifferenceResult4, newTab["$pp_colour_addr"], 0.32)
		newTab["$pp_colour_addr"] = addr
		currentColorModifyTable = newTab

		animations_bloomStrengthBloomRed(
			{ realTimeDifferenceResult1 , 0.7 },
			{ realTimeDifferenceResult1 , 4 }
		) DrawBloom(newTab["bloomStrength"], 2, 9, 9, 1, 1, newTab["bloomRed"], 1, 1)
	elseif playerStaminaRun <= stagesOfTired[3] then
		animations_BrightnessMulrAddr(
			{ realTimeDifferenceResult1, -0.7 },
			{ realTimeDifferenceResult1, 3.3 },
			{ realTimeDifferenceResult1, 0.12 },
			amountOfExtraRedOnScreen,
			playerisSpectating
		)

		animations_bloomStrengthBloomRed(
			{ realTimeDifferenceResult1 , 0.9 },
			{ realTimeDifferenceResult1 , 2 },
			playerisSpectating
		) DrawBloom(newTab["bloomStrength"], 2, 9, 9, 1, 1, newTab["bloomRed"], 1, 1)
	elseif playerStaminaRun <= stagesOfTired[2] then
		animations_BrightnessMulrAddr(
			{ realTimeDifferenceResult2, -0.1 },
			{ realTimeDifferenceResult0, 1.3 },
			{ realTimeDifferenceResult1, 0.03 },
			amountOfExtraRedOnScreen,
			playerisSpectating
		)
	elseif playerStaminaRun <= stagesOfTired[1] then
		animations_BrightnessMulrAddr(
			{ realTimeDifferenceResult3, OriginalTab["$pp_colour_brightness"] },
			{ realTimeDifferenceResult1, OriginalTab["$pp_colour_mulr"] },
			{ realTimeDifferenceResult1, OriginalTab["$pp_colour_addr"] },
			amountOfExtraRedOnScreen,
			playerisSpectating
		)
	else
		-- Normal
		animations_BrightnessMulrAddr(
			{ realTimeDifferenceResult3, OriginalTab["$pp_colour_brightness"] },
			{ realTimeDifferenceResult1, OriginalTab["$pp_colour_mulr"] },
			{ realTimeDifferenceResult1, OriginalTab["$pp_colour_addr"] },
			amountOfExtraRedOnScreen,
			playerisSpectating
		)
	end if !currentColorModifyTable then currentColorModifyTable = OriginalTab end

	-- -
	--Draws Color Modify effect
	DrawColorModify(currentColorModifyTable)

	-- Pretty good
	DrawSunbeams(0.1, 0.013, 0.14, 0.2, 0.6)
	DrawSharpen(0.3, 0.3)

	local toybox0
	local toybox1
	if playerisSpectating then
		DrawMaterialOverlay("models/props_c17/fisheyelens", -0.09)

		toybox0 = MBDLerp(realTimeDifferenceResult5, newTab["toyBox0"], 1.1)
		toybox1 = MBDLerp(realTimeDifferenceResult5, newTab["toyBox1"], ScrH() / 1)
	elseif playerIsAiming then
		-- This feature is supported by FA:S 2 at least fro now ... .
		if checkIfPlayerIsInTopView() then
			toybox0 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox0"], 3.3)
			toybox1 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox1"], ScrH() / 1.62)
		elseif ( currentCameraView == 0 or currentCameraView == 1 ) then
			toybox0 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox0"], 5)
			toybox1 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox1"], ScrH() / 1.65)
		elseif ( currentCameraView == 2 ) then
			toybox0 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox0"], 5)
			toybox1 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox1"], ScrH() / 1.63)
		elseif ( currentCameraView == 3 ) then
			toybox0 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox0"], 5)
			toybox1 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox1"], ScrH() / 1.8)
		end
	else
		-- Normal
		toybox0 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox0"], OriginalTab["toyBox0"])
		toybox1 = GETMaybeDrawToyBoxMotionBlurValue(realTimeDifferenceResult5, newTab["toyBox1"], OriginalTab["toyBox1"])
	end
	newTab["toyBox0"] = toybox0
	newTab["toyBox1"] = toybox1
	DrawToyTown(toybox0, toybox1)

	if GetAnimationCurrentTimeFPS() - realTimeDifference0 > 0.008 then
		realTimeDifference0 = GetAnimationCurrentTimeFPS()
	end
	if GetAnimationCurrentTimeFPS() - realTimeDifference1 > 0.01 then
		realTimeDifference1 = GetAnimationCurrentTimeFPS()
	end
	if GetAnimationCurrentTimeFPS() - realTimeDifference2 > 0.015 then
		realTimeDifference2 = GetAnimationCurrentTimeFPS()
	end
	if GetAnimationCurrentTimeFPS() - realTimeDifference3 > 0.03 then
		realTimeDifference3 = GetAnimationCurrentTimeFPS()
	end
	if GetAnimationCurrentTimeFPS() - realTimeDifference4 > 0.04 then
		realTimeDifference4 = GetAnimationCurrentTimeFPS()
	end
	if GetAnimationCurrentTimeHUD() - realTimeDifference5 > 0.04 * 1.25 then
		realTimeDifference5 = GetAnimationCurrentTimeHUD()
	end
end
--
-- Wait a little before allowed... For loading
hook.Add("SpawnMenuOpen", "mbd:SpawnMenuWhitelist001", function()
	if not firstLoadComplete or LocalPlayer():GetNWBool("isSpectating", false) then return false end
end)
--
-- - For first time Player join
hook.Add("HUDPaint", "mbd:LoadingScreenFirstTime", function()
	-- LOADING SCREEN FOR CLIENT
	if GameIsNotLoadedYetForClient and GameLoadingTimeLobbyScreenColor then
		surface.SetDrawColor(GameLoadingTimeLobbyScreenColor[1], GameLoadingTimeLobbyScreenColor[2], GameLoadingTimeLobbyScreenColor[3], GameLoadingTimeLobbyScreenColor[4])
		surface.DrawRect(0, 0, ScrW(), ScrH())
		
		local percentageLoaded = ((GameLoadingTimeStartClient - timer.TimeLeft("mbd:gameIsLoadingForClient")) / GameLoadingTimeStartClient)
		local text = "M.B.D. IS LOADING..."
		local widthOfLoadingBar = 300
		local heightOfLoadingBar = 15
		local paddingBakgroundLoadingBar = 6
		-- Backgrond
		draw.RoundedBox(8 + paddingBakgroundLoadingBar - 3,
			(ScrW() / 2 - (widthOfLoadingBar + paddingBakgroundLoadingBar) / 2),
			(ScrH() / 2 - (heightOfLoadingBar + paddingBakgroundLoadingBar) / 2 + 100),
			widthOfLoadingBar + paddingBakgroundLoadingBar,
			(heightOfLoadingBar + paddingBakgroundLoadingBar
		), Color(50, 50, 50, 255)) -- lightBlack Gray
		-- Bar
		local widthLoadingBarDynamic = (widthOfLoadingBar * percentageLoaded)
		if widthLoadingBarDynamic > widthOfLoadingBar then widthLoadingBarDynamic = widthOfLoadingBar end
		draw.RoundedBox(8,
			(ScrW() / 2 - widthOfLoadingBar / 2),
			(ScrH() / 2 - heightOfLoadingBar / 2 + 100),
			widthLoadingBarDynamic,
			(heightOfLoadingBar
		), Color(252, 216, 3, 255)) -- White

		local extra_width, extra_height = getTextWidthAndHeight("HUD_buildPoints", text)

		local colorText = Color(3, 164, 252, 255) -- lightBlue
		draw.DrawText(
			text,
			"HUD_buildPoints",
			(ScrW() / 2 - extra_width / 2),
			(ScrH() / 2 - extra_height / 2),
			colorText,
			TEXT_ALIGN_LEFT
		)
	end
end)
--- -
--
hook.Add("HUDPaint", "mbd_door_trigger:ShowIfItIsADoor", function()
	-- Tell the player if a prop is a door..
	if LocalPlayer() then
		local playerTrace = LocalPlayer():GetEyeTrace()
		local playerTraceEnt = playerTrace.Entity

		if playerTraceEnt and playerTraceEnt:IsValid() then
			local hasADoorChild = false
			for _,child in pairs(playerTraceEnt:GetChildren()) do
				if child:GetClass() == "mbd_door_trigger" then hasADoorChild = true break end
			end

			if (
				playerTraceEnt:GetClass() == "mbd_door_trigger" or
				hasADoorChild
			) then
				-- Show
				local text = "DOOR"

				local extra_width, extra_height = getTextWidthAndHeight("Default", text)

				local pos_center = (playerTraceEnt:LocalToWorld(playerTraceEnt:OBBCenter())):ToScreen()
				local pos_min = (playerTraceEnt:LocalToWorld(playerTraceEnt:OBBMins())):ToScreen()

				local padding = 10
				local zoomSizeDownReducer = LocalPlayer():GetPos():Distance(playerTraceEnt:GetPos()) / 100
				if zoomSizeDownReducer < 1 then zoomSizeDownReducer = 1 end

				if zoomSizeDownReducer >= 6.6439 then return end

				local rectWidth = (extra_width + padding * 2)
				local rectHeight = (extra_height + padding * 2)

				local posX = (pos_center.x - rectWidth / 2)
				local posY = (pos_min.y - rectHeight / 2)
				local posXText = (pos_center.x - extra_width / 2)
				local posYText = (pos_min.y - extra_height / 2)

				local alpha = 400 - zoomSizeDownReducer * 100

				--
				-- BACKGROUND
				surface.SetDrawColor(254, 234, 0, alpha)
				surface.DrawRect(posX, posY, rectWidth, rectHeight)
				--
				draw.DrawText(
					text,
					"Default",
					posXText,
					posYText,
					Color(0, 0, 0, alpha),
					TEXT_ALIGN_LEFT
				)
			end
		end
	end
end)
hook.Add("HUDPaint", "mbd_roof:ShowIfItIsARoof", function()
	-- Tell the player if a prop is a roof..
	if LocalPlayer() then
		local playerTrace = LocalPlayer():GetEyeTrace()
		local playerTraceEnt = playerTrace.Entity

		if playerTraceEnt and playerTraceEnt:IsValid() then
			if playerTraceEnt:GetNWString("originalColorRoof", "") != "" then
				-- Show
				local text = "ROOFING"

				local extra_width, extra_height = getTextWidthAndHeight("Default", text)

				local pos_center = (playerTraceEnt:LocalToWorld(playerTraceEnt:OBBCenter())):ToScreen()

				local padding = 10
				local zoomSizeDownReducer = LocalPlayer():GetPos():Distance(playerTraceEnt:GetPos()) / 100
				if zoomSizeDownReducer < 1 then zoomSizeDownReducer = 1 end

				if zoomSizeDownReducer >= 6.6439 then return end

				local rectWidth = (extra_width + padding * 2)
				local rectHeight = (extra_height + padding * 2)

				local posX = (pos_center.x - rectWidth / 2)
				local posY = (pos_center.y - rectHeight / 2)
				local posXText = (pos_center.x - extra_width / 2)
				local posYText = (pos_center.y - extra_height / 2)

				local alpha = 400 - zoomSizeDownReducer * 100

				--
				-- BACKGROUND
				surface.SetDrawColor(0, 53, 254, alpha)
				surface.DrawRect(posX, posY, rectWidth, rectHeight)
				--
				draw.DrawText(
					text,
					"Default",
					posXText,
					posYText,
					Color(255, 255, 255, alpha),
					TEXT_ALIGN_LEFT
				)
			end
		end
	end
end)
hook.Add("HUDPaint", "mbd_roof:ShowIfLadder", function()
	-- Tell the player if a prop is a roof..
	if LocalPlayer() then
		local playerTrace = LocalPlayer():GetEyeTrace()
		local playerTraceEnt = playerTrace.Entity

		if playerTraceEnt and playerTraceEnt:IsValid() and playerTraceEnt:GetClass() == "mbd_ladder" and !LocalPlayer():KeyPressed(IN_USE) then
			-- Show
			local text = "Pick me up with 'E'"

			local extra_width, extra_height = getTextWidthAndHeight("Default", text)

			local pos_center = (playerTraceEnt:LocalToWorld(playerTraceEnt:OBBCenter())):ToScreen()
			local pos_bottom = (playerTraceEnt:LocalToWorld(playerTraceEnt:OBBCenter())):ToScreen()

			local padding = 10
			local zoomSizeDownReducer = LocalPlayer():GetPos():Distance(playerTraceEnt:GetPos()) / 100
			if zoomSizeDownReducer < 1 then zoomSizeDownReducer = 1 end

			if zoomSizeDownReducer <= 1.3 or zoomSizeDownReducer >= 6.6439 then return end

			local rectWidth = (extra_width + padding * 2)
			local rectHeight = (extra_height + padding * 2)

			local posX = (pos_center.x - rectWidth / 2)
			local posY = (pos_center.y - rectHeight / 2)
			local posXText = (pos_center.x - extra_width / 2)
			local posYText = (pos_center.y - extra_height / 2)

			local alpha = 500 - zoomSizeDownReducer * 100

			--
			-- BACKGROUND
			surface.SetDrawColor(254, 208, 0, alpha)
			surface.DrawRect(posX, posY, rectWidth, rectHeight)
			--
			draw.DrawText(
				text,
				"Default",
				posXText,
				posYText,
				Color(5, 5, 5, alpha),
				TEXT_ALIGN_LEFT
			)
		end
	end
end)
-- FOR BUYBOX
hook.Add("HUDPaint", "mbd_buybox:EntWhat001", function()
	local pl 	= LocalPlayer()
	local ent 	= pl:GetEyeTrace().Entity
	--
	if (
		!pl:IsValid() or
		!ent:IsValid() or
		ent:GetClass() != "mbd_buybox"
	) then return nil end
	--
	--
	local position  = (ent:LocalToWorld(ent:OBBCenter())):ToScreen()
	local w			= 130
	local h			= 40
	--
	-- TEXT
	local buyBoxText = "Open Box ( \"E\" )"

	local extra_widthBUYBOX, extra_heightBUYBOX = getTextWidthAndHeight("ScoreboardDefault", buyBoxText)

	--
	-- BACKGROUND
	draw.RoundedBox(
		20,
		(position.x - 10 / 2),
		(position.y),
		(extra_widthBUYBOX + 10 * 2),
		h,
		Color(255, 215, 30, 195) -- orange
	)

	--
	draw.DrawText(
		buyBoxText,
		"ScoreboardDefault",
		(position.x + (extra_widthBUYBOX / 2 - (extra_widthBUYBOX / 2)) + (10 / 2)),
		(position.y + (h / 2 - (extra_heightBUYBOX / 2)) - 1),
		Color(0, 0, 0, 225),
		TEXT_ALIGN_LEFT
	)
end)
--
--
--- -- --> WHEN A PLAYER open's the menu with a written command
--
function HOOK_OnPlayerChat001()
    hook.Add("OnPlayerChat", "mbd_OnPlayerChat001", function(pl, strText, bTeam, bDead)
        if (pl != LocalPlayer()) then return end
    
        strText = string.lower(strText)
    
		-- Show Admin panel
		if (
			strText == "!a" or
			strText == "!!"
		) then
			if (
				pl:MBDIsAnAdmin(true)
			) then
				showAdminPanel()
			else ClientPrintAddTextMessage(pl, {Color(208, 0, 254), "U no Admin... (-.-)"}) end
		elseif (
			strText == "!bd" or
			strText == "!"
		) then
			-- Open Lobby
			viewBuyBox = nil

			openLobby()
		elseif (string.match(strText, "!bl")) then
			--
			--- Spawn A BLOCKER
			local __Block = string.Split(strText, " ")
			if (
				(
					pl:MBDIsAnAdmin(true)
				) and #__Block == 3
			) then
				--
				net.Start("SpawnBlockerBlock")
					net.WriteString(strText)
				net.SendToServer()
			end
		elseif (string.match(strText, "!bv")) then
			-- Mechanic wants to buy a vehicle...
			local __Vehicle = string.Split(strText, " ")[2]
			if (
				__Vehicle and
				(
					__Vehicle == "jeep" or
					__Vehicle == "airboat" or
					__Vehicle == "jalopy"
				)
			) then
				--
				--- Make e.g. jeep => Jeep
				__Vehicle = string.Split(__Vehicle, "")
				local __FirstLetter = string.upper(__Vehicle[1])
				table.remove(__Vehicle, 1)
				__Vehicle = __FirstLetter..table.concat(__Vehicle, "")

				--
				net.Start("MechanicWantsToBuyVehicle")
					net.WriteString(__Vehicle)
				net.SendToServer()
			else
				ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "Not a valid vehicle... Use:", Color(254, 187, 0), " \"jeep (7000 £B.D.)\",", Color(254, 166, 0), " \"airboat (7000 £B.D.)\"", Color(254, 208, 0), " or ", Color(254, 145, 0), "\"jalopy (8000 £B.D.)\"", Color(254, 208, 0), "."})
			end
		elseif (
			strText == "!h" or
			strText == "!help"
		) then
			-- Open Help/Commands Panel
			-- --
			createCommandsHelpPanel()
		elseif (
			strText == "!drop" or
			strText == "!d"
		) then
			-- DROP the Players current weapon..>
			--
			if CLIENT then
				net.Start("DropCurrentPlayerWeapon")
				net.SendToServer()
			end
		elseif (
			string.match(strText, "!give") or
			string.match(strText, "!g")
		) then
			local t 		=  string.Split(strText, " ")
			local _amount 	= nil
			local _Player 	= nil

			local function getPlayer(string)
				local name = string.Split(string, ":")[2]

				for k,v in pairs(player.GetAll()) do
					local CurrentLoopPlayer = string.lower(v:GetName())
					local _Name 			= string.lower(name)

					if (string.match(CurrentLoopPlayer, _Name)) then
						-- FOUND A PLAYER...
						_Player = v

						break
					end
				end
			end
			--
			--
			for k,v in pairs(t) do
				if (string.match(v, "p:") or string.match(v, ":")) then
					getPlayer(v)
				end
				--
				if (tonumber(v)) then -- Found the amount (which is a number)
					-- SPLIT THE STRING FROM THIS POS...
					_amount = tonumber(v)

					--
					--- GIVE PLAYER MONEY
					if (
						string.match(strText, "money") or
						string.match(strText, "bd")
					) then
						--
						givePlayerMoneyOrBuildPoints({
							Type 	= "money",
							Amount 	= _amount,
							Player 	= _Player,
							Admin	= LocalPlayer():MBDIsAnAdmin(true)
						})
					-- GIVE PLAYER BUILD POINTS
					elseif (
						string.match(strText, "bupo") or
						string.match(strText, "bp")
					) then
						--
						givePlayerMoneyOrBuildPoints({
							Type 	= "buildPoints",
							Amount 	= _amount,
							Player 	= _Player,
							Admin	= LocalPlayer():MBDIsAnAdmin(true)
						})
					end

					break
				end
			end
		elseif (
			LocalPlayer() and
			(
				LocalPlayer():MBDIsAnAdmin(true)
			)
		) then
			if (strText == "!start") then
				--
				--- START GAME
				net.Start("ControlGameStatusCommand")
					net.WriteString("start")
				net.SendToServer()
			elseif (strText == "!end") then
				--
				--- END GAME
				net.Start("ControlGameStatusCommand")
					net.WriteString("end")
				net.SendToServer()
			end
		end
    end)
end
HOOK_OnPlayerChat001()
--
--
--
--
--- -- --> WHEN AN ENTITY is created
--
function HOOK_onEntityCreated001()
	hook.Add("OnEntityCreated", "mbd:OnEntityCreated002", function(ent)
		if (!ent or !ent:IsValid() or ent:IsNPC()) then return end

		-- -- -- >>
		-- -->
		local _Model 	= ent:GetModel()
		local _Class 	= ent:GetClass()

		local entOwner 	= ent:GetNWEntity("PlayerOwnerEnt", nil)

		if (
			ent:IsValid() and
			_Class == "prop_physics" and
			!string.match(_Class, "vehicle") and
			string.lower(_Model) != "models/hunter/blocks/cube025x025x025.mdl" and -- THIS IS VERY IMPORTANT:....
			!string.match(string.lower(_Model), "gibs") and
			string.lower(_Model) != "models/props_c17/doll01.mdl"
		) then
			timer.Create("mbd:EntCreatedClient:"..ent:EntIndex(), 0.1, 50, function()
				entOwner = ent:GetNWEntity("PlayerOwnerEnt", nil)

				if entOwner and entOwner:IsValid() then -- Never go further if the owner could not get fetched
					timer.Stop("mbd:EntCreatedClient:"..ent:EntIndex())
					timer.Remove("mbd:EntCreatedClient:"..ent:EntIndex())

					if !ent:GetNWBool("IsFromDuplication", false) then setEntColorTransparent(ent, "1") end

					if (
						entOwner and LocalPlayer() and
						entOwner:IsValid() and LocalPlayer():IsValid() and
						entOwner:UniqueID() == LocalPlayer():UniqueID() -- Very important !!
					) then
						-- -- Everything OK >>>
						if (ent:IsValid()) then
							---
							-- - - FOR SECURITY PURPOSES
							timer.Simple(1.5, function()
								if !ent:GetNWBool("IsFromDuplication", false) then setEntColorNormal(ent, "1") end
							end)
							--
							-- --- >> Buy
							net.Start("PlayerWantsToSpawnProp")
								net.WriteEntity(ent)
							net.SendToServer()
						elseif (
							MBD_CheckIfNotBullseyeEntity(ent:GetClass()) and
							ent:GetClass() != "mbd_hate_trigger"
						) then
							-- Reset
							setEntColorNormal(ent, "2")
						end
					end
				elseif (
					timer.RepsLeft("mbd:EntCreatedClient:"..ent:EntIndex()) and
					timer.RepsLeft("mbd:EntCreatedClient:"..ent:EntIndex()) <= 10
				) then
					local allChildren = ent:GetChildren()

					for k,v in pairs(allChildren) do
						local entClass = v:GetClass()

						if (
							string.match(entClass, "npc_bullseye")
						) then return end

						if k == #allChildren then
							-- Remove when it is 1 sec. left, if no owner could be fetched
							print("M.B.D. TIMED OUT: Could not get Owner (Could Be a Ghost Prop; then no problem). Deleting Entity >>", ent)
							timer.Stop("mbd:EntCreatedClient:"..ent:EntIndex())
							timer.Remove("mbd:EntCreatedClient:"..ent:EntIndex())
							
							net.Start("RemoveAnEntity")
								net.WriteEntity(ent)
							net.SendToServer()
						end
					end
				end
			end)
		elseif (
			MBD_CheckIfNotBullseyeEntity(ent:GetClass()) and
			ent:GetClass() != "mbd_hate_trigger"
		) then 
			-- Reset
			setEntColorNormal(ent, "3")
		end
	end)
end
--
--- -- --> WHEN PLAYER wants to open the spawn menu
--
function HOOK_OnSpawnMenuOpen001()
	hook.Add("OnSpawnMenuOpen", "mbd:OnSpawnMenuOpen001", function()
		if (
			LocalPlayer() and
			(LocalPlayer():GetNWBool("isSpectating", false) and GameStarted) and
			LocalPlayer():MBDIsNotAnAdmin(true)
		) then return false end -- If you return anything, it will cancle the hook !
	end)
end
--
--
--
--- -- --> THE PLAYERS HUD-system for every visual information needed
--
timer.Create("mbd:GetLatestPyramidDropInformation", 0.3, 0, function()
	net.Start("get_mbd_howManyDropItemsPickedUpByPlayers", true)
	net.SendToServer()
	-- -
	timer.Simple(0.15, function()
		net.Start("get_mbd_howManyDropItemsSpawnedAlready", true)
		net.SendToServer()
	end)
end)
function HOOK_HUDPaint001()
	local keyDown0 = false

	-- Add hooks for keys
	hook.Add("KeyPress", "mbd:KeyPress:UI", function(ply, key)
		if (key == IN_SCORE) then
			keyDown0 = true
		end
	end)
	hook.Add("KeyRelease", "mbd:KeyRelease:UI", function(ply, key)
		if (key == IN_SCORE) then
			keyDown0 = false
		end
	end)

	--
	--- - DRAW ON-SCREEN HUD FOR PLAYER
	--
	hook.Add("HUDPaint", "mbd:RenderPlayersNPCBuyBoxThroughWalls", function()
		local playerisSpectating = LocalPlayer():GetNWBool("isSpectating", false)

		if !playerisSpectating then
			for id, pl in pairs(player:GetAll()) do
				-- The position to render the sphere at, in this case, the looking position of the local player
				local plPos = pl:OBBCenter()
				plPos.z = plPos.z + 15
				local pos = (pl:LocalToWorld(plPos)):ToScreen()
	
				local distanceFromLocalPlayerToPlayer = LocalPlayer():GetPos():DistToSqr(pl:GetPos())
	
				if pl and pl:IsValid() and !pl:GetNWBool("isSpectating", false) and LocalPlayer():GetEyeTrace().Entity != pl and distanceFromLocalPlayerToPlayer > 782826 then
					-- render.DrawSphere(pos, radius, wideSteps, tallSteps, Color(127, 255, 0, 250)) -- This needs to be in 3D hook
					local color = string.Explode(";", pl:GetNWString("infoPlateColor", table.concat({127, 255, 0, 255}, ";")))
					
					local width = 9
					local height = width

					local npcPosCenter = npc:OBBCenter()
					local npcPosMax = npc:OBBMaxs()
					local npcPos = npcPosCenter
					npcPos.z = npcPosMax.z + 80
					local pos = (npc:LocalToWorld(npcPos)):ToScreen()

					-- Lines
					surface.SetDrawColor(0, 0, 0, 230) -- black
					surface.DrawLine(pos.x, pos.y, pos.x + width, pos.y)
					surface.DrawLine(pos.x + width, pos.y, pos.x + width / 2, pos.y + height)
					surface.DrawLine(pos.x + width / 2, pos.y + height, pos.x, pos.y)
					-- Fill
					surface.SetDrawColor(color[1], color[2], color[3], 230) -- Green
					if npc:Health() <= 150 then surface.SetDrawColor(255, 85, 4, 253) --[[ redOrange ]] end
					surface.DrawPoly({
						{ x = pos.x, y = pos.y },
						{ x = pos.x + width, y = pos.y },
						{ x = pos.x + width / 2, y = pos.y + height }
					})
				end
			end
			-- Mark enemies with a small circle, that is far away...
			local allNPCSpawnerNPCs = GETAllValidNPCsWithinTheNPCTable()
			for id, npc in pairs(ents.FindByClass("npc_*")) do
				if npc and npc:IsValid() then
					local npcKey = GETMaybeCustomNPCKeyFromNPCClass(npc:GetClass())

					local radius = math.sin(CurTime()) * 9

					-- - -
					-- Only accept the NPC types spawned by the NPC spawner.. ( enemy NPCs )
					if table.HasValue(allowedCombines, npcKey) or table.HasValue(allowedZombies, npcKey) then
						local npcPos = npc:OBBCenter()
						npcPos.z = npcPos.z + 15
						local pos = (npc:LocalToWorld(npcPos)):ToScreen()

						local distanceFromLocalPlayerToNpc = LocalPlayer():GetPos():DistToSqr(npc:GetPos())
						if npc and npc:IsValid() and npc:Health() > 0 and npc:GetNWBool("NPCSpawnWasASuccess", false) and LocalPlayer():GetEyeTrace().Entity != npc and distanceFromLocalPlayerToNpc > 158660 then
							local radius = math.sin(CurTime()) * 3.3

							surface.SetDrawColor(190, 0, 0, 200) -- darkRed
							draw.Circle(pos.x + radius / 6.5, pos.y + radius / 6.5, radius, radius * 2)
						end
					end
				end
			end
			-- Mark BuyBoxes with a upside down triangle
			for id, buybox in pairs(ents.FindByClass("mbd_buybox")) do
				if buybox and buybox:IsValid() then
					local buyboxPos = buybox:OBBCenter() + Vector(0, 0, 86)
					local pos = (buybox:LocalToWorld(buyboxPos)):ToScreen()
	
					local width = 9
					local height = width
	
					pos.x = pos.x - width / 2
	
					local distanceFromLocalPlayerToBuyBox = LocalPlayer():GetPos():DistToSqr(buybox:GetPos())
	
					if buybox and buybox:IsValid() and LocalPlayer():GetEyeTrace().Entity != buybox and distanceFromLocalPlayerToBuyBox > 88660 then
						-- Lines
						surface.SetDrawColor(0, 0, 0, 210) -- black
						surface.DrawLine(pos.x, pos.y, pos.x + width, pos.y)
						surface.DrawLine(pos.x + width, pos.y, pos.x + width / 2, pos.y + height)
						surface.DrawLine(pos.x + width / 2, pos.y + height, pos.x, pos.y)
						-- Fill
						surface.SetDrawColor(255, 210, 4, 253) -- Yellow
						surface.DrawPoly({
							{ x = pos.x, y = pos.y },
							{ x = pos.x + width, y = pos.y },
							{ x = pos.x + width / 2, y = pos.y + height }
						})
					end
				end
			end
		end
	end)
	-- -
	local prevBuildPoints = LocalPlayer():GetNWInt("prevBuildPoints", 0)
	local prevMoney = LocalPlayer():GetNWInt("prevMoney", 0)

	local animateBuildPoints = false
	local animateMoney = false

	local startLocalPlayerBPandMoneyDifference = GetAnimationCurrentTimeFPS()
	local startLocalPlayerBPandMoneyDifferenceLimit = 0.6 -- Higher is faster animation
  
  	local buildPointsColorAlpha = 255
  	local moneyColorAlpha = 255
	-- - OWN HOOK for BD/BP anim.
	hook.Add("HUDPaint", "mbd:animateMoneyAndBuildPointsClient", function()
		-- -
		local buildPoints = LocalPlayer():GetNWInt("buildPoints", 0)
		local money = LocalPlayer():GetNWInt("money", 0)

		if math.Round(prevBuildPoints) != math.Round(buildPoints) then animateBuildPoints = true else animateBuildPoints = false end
		if math.Round(prevMoney) != math.Round(money) then animateMoney = true else animateMoney = false end

		local startLocalPlayerBPandMoneyDifferenceResult = GetAnimationCurrentTimeFPS() - startLocalPlayerBPandMoneyDifference

		-- --
		-- - -- -
		if animateBuildPoints then
			local newBuildPoints = MBDLerp(startLocalPlayerBPandMoneyDifferenceResult, prevBuildPoints, buildPoints)
			prevBuildPoints = math.Round(newBuildPoints)
        
			buildPointsColorAlpha = 150
		else
			-- Done for now SAVE
			LocalPlayer():SetNWInt("prevBuildPoints", buildPoints)
			prevBuildPoints = buildPoints
			buildPointsColorAlpha = 255
		end
		--
		if animateMoney then
			local newMoney = MBDLerp(startLocalPlayerBPandMoneyDifferenceResult, prevMoney, money)
			prevMoney = math.Round(newMoney, 1)
        
			moneyColorAlpha = 150
		else
			-- Done for now SAVE
			LocalPlayer():SetNWInt("prevMoney", money)
			prevMoney = money
			moneyColorAlpha = 255
		end
		-- - --
		-- For animation
		if GetAnimationCurrentTimeFPS() - startLocalPlayerBPandMoneyDifference > startLocalPlayerBPandMoneyDifferenceLimit then
			startLocalPlayerBPandMoneyDifference = GetAnimationCurrentTimeFPS()
		end
	end)
	--- -
	--- - Stamina stuff
	local maxWidthStamina = 600

	local maxWidthStaminaRun = maxWidthStamina
	local maxWidthStaminaJump = maxWidthStamina * 0.9

	local widthStaminaRun = maxWidthStamina
	local widthStaminaJump = maxWidthStamina

	local staminaRunTimeDifference = GetAnimationCurrentTimeHUD()
	local staminaJumpTimeDifference = GetAnimationCurrentTimeHUD()

	local staminaRGBColorTimeDifference = GetAnimationCurrentTimeHUD()

	local currRunRGB = { 248, 232, 140 } -- Yellow
	local currJumpRGB = { 210, 248, 140 } -- Green
	local lsv = function(index, to, isJumpRGB)
		local newValue

		local timeResult = GetAnimationCurrentTimeHUD() - staminaRGBColorTimeDifference
		if !isJumpRGB then
			newValue = MBDLerp(timeResult, currRunRGB[index], to)
			currRunRGB[index] = newValue
		else
			newValue = MBDLerp(timeResult, currJumpRGB[index], to)
			currJumpRGB[index] = newValue
		end

		return newValue
	end
	local currRunRGB = { 248, 232, 140 } -- Yellow
	local currJumpRGB = { 210, 248, 140 } -- Green

	local TopViewRGBColorTimeDifference = GetAnimationCurrentTimeHUD()

	local currRGBTopView = { 255, 30, 50 } -- red
	local currRGBTopViewOnlyAllowed = { 255, 30, 50 } -- red
	local lsvTopView = function(index, to)
		local newValue

		local timeResult = GetAnimationCurrentTimeHUD() - TopViewRGBColorTimeDifference
		newValue = MBDLerp(timeResult, currRGBTopView[index], to)
		currRGBTopView[index] = newValue

		return newValue
	end
	local lsvTopViewOnlyAllowed = function(index, to)
		local newValue

		local timeResult = GetAnimationCurrentTimeHUD() - TopViewRGBColorTimeDifference
		newValue = MBDLerp(timeResult, currRGBTopViewOnlyAllowed[index], to)
		currRGBTopViewOnlyAllowed[index] = newValue

		return newValue
	end

	hook.Add("HUDPaint", "mbd:HUDSystem", function()
		local _pl = LocalPlayer()
		
		if (!_pl:IsValid()) then return nil end

		-- Selected Camera View
		local text = ""
		if checkIfPlayerIsInTopView() then text = "Top View"
		elseif currentCameraView == 3 then text = "Third Person"
		elseif currentCameraView == 2 then text = "Side"
		elseif currentCameraView == 1 then text = "Cool View"
		else text = "Normal" end
		
		local extra_width, extra_height = getTextWidthAndHeight("spawnMenuText001", text)
		if viewCameraViewStatus then
			draw.DrawText(
				text,
				"spawnMenuText001",
				ScrW() / 2 - extra_width / 2,
				ScrH() / 2 - extra_height / 2 - 100,
				Color(255, 255, 255, 250),
				TEXT_ALIGN_LEFT
			)
		end

		--
		--- PLAYERS CLASSNAME
		
		-- GET TEXT SIZE ....
		--
		local classNameText = string.upper(LocalPlayer():GetNWString("classname", "No Class"))

		local extra_widthCLASSNAME, extra_heightCLASSNAME = getTextWidthAndHeight("HUD_className", classNameText)

		-- BACKGROUND
		local padding = 10
		draw.RoundedBox(
			5,
			-10,
			((ScrH() / 4) - (extra_heightCLASSNAME * 2) + (padding / 2)),
			(extra_widthCLASSNAME + padding + 30),
			(extra_heightCLASSNAME + padding),
			Color(000, 000, 000, 170)
		)
		-- CLASS NAME
		local __colorTextClassname = Color(255, 236, 15, 255) --default yellow
		draw.DrawText(
			classNameText,
			"HUD_className",
			15,
			((ScrH() / 4) - (extra_heightCLASSNAME + (padding * 2))),
			__colorTextClassname,
			TEXT_ALIGN_LEFT
		)

		local staminaRunTimeDifferenceResult = GetAnimationCurrentTimeHUD() - staminaRunTimeDifference
		local staminaJumpTimeDifferenceResult = GetAnimationCurrentTimeHUD() - staminaJumpTimeDifference

		-- SHOW STAMINA
		local currStaminaRun = LocalPlayer():GetNWInt("mbd:PlayerCurrentStaminaRun", 100)
		local newWidthStaminaRun = MBDLerp(staminaRunTimeDifferenceResult, widthStaminaRun, maxWidthStaminaRun * currStaminaRun / 100)

		widthStaminaRun = newWidthStaminaRun

		local currStaminaJump = LocalPlayer():GetNWInt("mbd:PlayerCurrentStaminaJump", 100)
		local newWidthStaminaJump = MBDLerp(staminaJumpTimeDifferenceResult, widthStaminaJump, maxWidthStaminaJump * currStaminaJump / 100)

		widthStaminaJump = newWidthStaminaJump

		-- Maybe update
		if GetAnimationCurrentTimeHUD() - staminaRunTimeDifference > 0.02 * 1.25 then
			staminaRunTimeDifference = GetAnimationCurrentTimeHUD()
		end
		if GetAnimationCurrentTimeHUD() - staminaJumpTimeDifference > 0.01 * 1.25 then
			staminaJumpTimeDifference = GetAnimationCurrentTimeHUD()
		end
		if GetAnimationCurrentTimeHUD() - staminaRGBColorTimeDifference > 0.023 * 1.25 then
			staminaRGBColorTimeDifference = GetAnimationCurrentTimeHUD()
		end

		local heightRun = 12
		local heightJump = 3

		local startY = 4
		local spaceBetweenY = 6
		--- - MAX
		-- Run
		local xPosStaminaMaxRun = math.Round(ScrW() / 2 - maxWidthStaminaRun / 2)
		local yPosStaminaMaxRun = math.Round(startY)
		-- Jump
		local xPosStaminaMaxJump = math.Round(ScrW() / 2 - maxWidthStaminaJump / 2)
		local yPosStaminaMaxJump = math.Round(yPosStaminaMaxRun + heightRun + spaceBetweenY)
		-- - - DYNAMIC
		-- Run
		local xPosStaminaRun = ScrW() / 2 - widthStaminaRun / 2
		local yPosStaminaRun = yPosStaminaMaxRun
		-- Jump
		local xPosStaminaJump = ScrW() / 2 - widthStaminaJump / 2
		local yPosStaminaJump = yPosStaminaMaxJump
		-- -
		-- THE HUD
		local alphaStamina = 190
		local borderSize = 1

		-- Always land on the right width...
		if widthStaminaRun + 1 > maxWidthStaminaRun then widthStaminaRun = maxWidthStaminaRun end
		if widthStaminaJump + 1 > maxWidthStaminaJump then widthStaminaJump = maxWidthStaminaJump end

		-- Run
		surface.SetDrawColor(0, 0, 0, alphaStamina)
		surface.DrawRect(
			math.ceil(xPosStaminaMaxRun - borderSize),
			math.ceil(yPosStaminaRun - borderSize),
			math.ceil(maxWidthStaminaRun + borderSize * 2),
			math.ceil(heightRun + borderSize * 2)
		)
		-- - Dynamic
		surface.SetDrawColor(lsv(1, 248), lsv(2, 232), lsv(3, 140), alphaStamina) -- Yellow
		if widthStaminaRun <= maxWidthStaminaRun * 0.12 then
			surface.SetDrawColor(lsv(1, 244), lsv(2, 68), lsv(3, 94), alphaStamina) -- ReddIsh
		elseif widthStaminaRun <= maxWidthStaminaRun * 0.4 then
			surface.SetDrawColor(lsv(1, 248), lsv(2, 178), lsv(3, 140), alphaStamina) -- OrangeIsh
		end
		surface.DrawRect(
			math.Round(xPosStaminaRun),
			math.Round(yPosStaminaRun),
			math.ceil(widthStaminaRun),
			math.ceil(heightRun)
		)
		-- Jump
		surface.SetDrawColor(0, 0, 0, alphaStamina)
		surface.DrawRect(
			math.ceil(xPosStaminaMaxJump - borderSize),
			math.ceil(yPosStaminaJump - borderSize),
			math.ceil(maxWidthStaminaJump + borderSize * 2),
			math.ceil(heightJump + borderSize * 2)
		)
		-- - Dynamic
		surface.SetDrawColor(lsv(1, 210, true), lsv(2, 248, true), lsv(3, 140, true), alphaStamina) -- Green
		if widthStaminaJump <= maxWidthStaminaJump * 0.3 then
			surface.SetDrawColor(lsv(1, 244, true), lsv(2, 68, true), lsv(3, 94, true), alphaStamina) -- ReddIsh
		elseif widthStaminaJump <= maxWidthStaminaJump * 0.6 then
			surface.SetDrawColor(lsv(1, 248, true), lsv(2, 140, true), lsv(3, 156, true), alphaStamina) -- Pinkish
		end
		surface.DrawRect(
			math.Round(xPosStaminaJump),
			math.Round(yPosStaminaJump),
			math.ceil(widthStaminaJump),
			math.ceil(heightJump)
		)
		-- -
		-- -- -
		-- GET TEXT SIZE
		--
		-- -
		local buildPointsText = prevBuildPoints.." BP"
		local extra_widthBUILDPOINTS, extra_heightBUILDPOINTS = getTextWidthAndHeight("HUD_buildPoints", buildPointsText)
		--
		local moneyText = prevMoney.." £B.D."
		local extra_widthMONEY, extra_heightMONEY = getTextWidthAndHeight("HUD_money", moneyText)
		--
		--
		local ExtraWidth = nil
		if (
			extra_widthMONEY > extra_widthBUILDPOINTS and
			extra_widthMONEY > extra_widthCLASSNAME
		) then
			ExtraWidth = extra_widthMONEY
		else
			if (
				extra_widthBUILDPOINTS > extra_widthMONEY and
				extra_widthBUILDPOINTS > extra_widthCLASSNAME
			) then
					ExtraWidth = extra_widthBUILDPOINTS
			else
				ExtraWidth = extra_widthCLASSNAME
			end
		end

		-- BACKGROUND
		local padding = 10
      
      	local buildPointsColor = Color(255, 236, 15, buildPointsColorAlpha) --default yellow
  		local moneyColor = Color(255, 236, 15, moneyColorAlpha) --default yellow
		
      draw.RoundedBox(
			5,
			-10,
			((ScrH() / 4) - padding),
			(ExtraWidth + 70),
			((40 * 3) + (padding * 2)),
			Color(6, 28, 4, 150)
		)
		-- BUILD POINTS
		draw.DrawText(
			buildPointsText,
			"HUD_buildPoints",
			15,
			(ScrH() / 4),
			buildPointsColor,
			TEXT_ALIGN_LEFT
		)
		-- MONEY
		draw.DrawText(
			moneyText,
			"HUD_money",
			15,
			((ScrH() / 4) + (40 * 2)),
			moneyColor,
			TEXT_ALIGN_LEFT
		)
		--
		--- ROUNDs (WAVES)

		-- GET TEXT SIZE ....
		local wavesText = "WAVE: "..currentRoundWave

		local extra_widthWAVE, extra_heightWAVE = getTextWidthAndHeight("HUD_wave", wavesText)
		--
		local paddingWave = 15
		draw.RoundedBox(
			5,
			(ScrW() - extra_widthWAVE - (paddingWave * 2) - (paddingWave / 2)),
			(ScrH() - extra_heightWAVE - (paddingWave * 9.3) - 9),
			(extra_widthWAVE + paddingWave),
			(extra_heightWAVE + paddingWave),
			Color(000, 000, 000, 170)
		)
		-- WAVES
		local __colorTextWave = Color(229, 212, 13, 255) --darker yellow
		draw.DrawText(
			wavesText,
			"HUD_wave",
			(ScrW() - extra_widthWAVE - (paddingWave * 2)),
			(ScrH() - extra_heightWAVE - (paddingWave * 9.3) + (paddingWave / 2) - 9),
			__colorTextWave,
			TEXT_ALIGN_LEFT
		)

		--
		--- KILLS (NPCs ...)

		-- GET TEXT SIZE ....
		local killsText = "KILLS: "..LocalPlayer():GetNWInt("killCount")

		local extra_widthKILLS, extra_heightKILLS = getTextWidthAndHeight("HUD_wave", killsText)
		--
		local paddingKills = 15
		draw.RoundedBox(
			5,
			(ScrW() - extra_widthKILLS - (paddingKills * 2) - (paddingKills / 2)),
			(ScrH() - extra_heightKILLS - (paddingKills * 11.3) - extra_heightWAVE),
			(extra_widthKILLS + paddingKills),
			(extra_heightWAVE + paddingKills),
			Color(000, 000, 000, 170)
		)
		-- KILLS
		local __colorTextKills = Color(229, 13, 30, 255) --red
		draw.DrawText(
			killsText,
			"HUD_wave",
			(ScrW() - extra_widthKILLS - (paddingKills * 2)),
			(ScrH() - extra_heightKILLS - (paddingKills * 11.3) + (paddingKills / 2) - extra_heightWAVE),
			__colorTextKills,
			TEXT_ALIGN_LEFT
		)

		-- -
		--- -- -
		if
			keyDown0 and
			( !container or ( container and !container:IsValid() ) ) and
			( !buyBoxMenu or ( buyBoxMenu and !buyBoxMenu:IsValid() ) ) and
			( !quickSettingMenu or ( quickSettingMenu and !quickSettingMenu:IsValid() ) ) and
			( !adminPanel or ( adminPanel and !adminPanel:IsValid() ) )
		then
			local fromBottom = 250
			local isPlayerSpectating = LocalPlayer():GetNWBool("isSpectating", false)

			-- - -
			-- - Lobby button:
			if ( !lobbyButton or ( lobbyButton and !lobbyButton:IsValid() ) ) then
				local size = 50

				lobbyButton = vgui.Create("DImageButton")
				lobbyButton:SetSize(size, size)
				lobbyButton:SetPos(20, ScrH() - fromBottom - size - 10)
		
				lobbyButton.Paint = function(s, w, h)
					local backgroundColor = Color(255, 235, 30, 255) -- yellow
					local textColor = Color(0, 0, 0, 245) -- black
					local borderColor = Color(0, 0, 0, 255) -- black
		
					local padding = 2
					local borderSize = 2
					local borderRadius = size / 2
		
					if s:IsHovered() then
						borderColor = Color(255, 235, 30, 255) -- yellow
					end
		
					draw.RoundedBox(
						borderRadius + borderSize,
						0 + padding,
						0 + padding,
						w - padding * 2,
						h - padding * 2,
						borderColor
					)
					draw.RoundedBox(
						borderRadius,
						0 + borderSize + padding,
						0 + borderSize + padding,
						w - borderSize * 2 - padding * 2,
						h - borderSize * 2 - padding * 2,
						backgroundColor
					)
		
					local text = "LO"
					local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("quickMenuButtons2", text)
					draw.DrawText(
						text,
						"quickMenuButtons2",
						w / 2 - extra_width_menuText / 2,
						h / 2 - extra_height_menuText / 2,
						textColor,
						TEXT_ALIGN_LEFT
					)
				end

				function lobbyButton:DoClick()
					openLobby()
				end
			end
			-- - -
			-- - Help Menu button:
			if ( !helpCommandsButton or ( helpCommandsButton and !helpCommandsButton:IsValid() ) ) then
				local size = 50

				helpCommandsButton = vgui.Create("DImageButton")
				helpCommandsButton:SetSize(size, size)
				helpCommandsButton:SetPos(20 + size + 10, ScrH() - fromBottom - size - 10)
		
				helpCommandsButton.Paint = function(s, w, h)
					local backgroundColor = Color(12, 107, 196, 250) -- blue
					local textColor = Color(255, 255, 255, 250) -- white
					local borderColor = Color(255, 255, 255, 255) -- white
		
					local padding = 2
					local borderSize = 1
					local borderRadius = size / 2
		
					if s:IsHovered() then
						borderColor = Color(12, 107, 196, 250) -- blue
					end
		
					draw.RoundedBox(
						borderRadius + borderSize,
						0 + padding,
						0 + padding,
						w - padding * 2,
						h - padding * 2,
						borderColor
					)
					draw.RoundedBox(
						borderRadius,
						0 + borderSize + padding,
						0 + borderSize + padding,
						w - borderSize * 2 - padding * 2,
						h - borderSize * 2 - padding * 2,
						backgroundColor
					)
		
					local text = "CH"
					local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("quickMenuButtons2", text)
					draw.DrawText(
						text,
						"quickMenuButtons2",
						w / 2 - extra_width_menuText / 2,
						h / 2 - extra_height_menuText / 2,
						textColor,
						TEXT_ALIGN_LEFT
					)
				end

				function helpCommandsButton:DoClick()
					createCommandsHelpPanel()
				end
			end

			-- ONLY FOR ADMIN ::
			if LocalPlayer():MBDIsAnAdmin(true) then
				-- - -
				-- - Quick Settings button:
				if ( !quickMenuButtonAdmin or ( quickMenuButtonAdmin and !quickMenuButtonAdmin:IsValid() ) ) then
					local size = 50

					quickMenuButtonAdmin = vgui.Create("DImageButton")
					quickMenuButtonAdmin:SetSize(size, size)
					quickMenuButtonAdmin:SetPos(20, ScrH() - fromBottom)
			
					quickMenuButtonAdmin.Paint = function(s, w, h)
						local backgroundColor = Color(12, 107, 196, 250) -- blue
						local textColor = Color(255, 255, 255, 250) -- white
						local borderColor = Color(255, 255, 255, 255) -- white
			
						local padding = 2
						local borderSize = 1
						local borderRadius = size / 2
			
						if s:IsHovered() then
							borderColor = Color(12, 107, 196, 250) -- blue
						end
			
						draw.RoundedBox(
							borderRadius + borderSize,
							0 + padding,
							0 + padding,
							w - padding * 2,
							h - padding * 2,
							borderColor
						)
						draw.RoundedBox(
							borderRadius,
							0 + borderSize + padding,
							0 + borderSize + padding,
							w - borderSize * 2 - padding * 2,
							h - borderSize * 2 - padding * 2,
							backgroundColor
						)
			
						local text = "QM"
						local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("quickMenuButtons2", text)
						draw.DrawText(
							text,
							"quickMenuButtons2",
							w / 2 - extra_width_menuText / 2,
							h / 2 - extra_height_menuText / 2,
							textColor,
							TEXT_ALIGN_LEFT
						)
					end

					function quickMenuButtonAdmin:DoClick()
						createQuickMenuAdmin()
					end
				end
				-- - -
				-- - Admin Settings button:
				if ( !settingButtonAdmin or ( settingButtonAdmin and !settingButtonAdmin:IsValid() ) ) then
					local size = 50

					settingButtonAdmin = vgui.Create("DImageButton")
					settingButtonAdmin:SetSize(size, size)
					settingButtonAdmin:SetPos(20 + size + 10, ScrH() - fromBottom)
			
					settingButtonAdmin.Paint = function(s, w, h)
						local backgroundColor = Color(255, 235, 30, 255) -- yellow
						local textColor = Color(0, 0, 0, 245) -- black
						local borderColor = Color(0, 0, 0, 255) -- black
			
						local padding = 2
						local borderSize = 2
						local borderRadius = size / 2
			
						if s:IsHovered() then
							borderColor = Color(255, 235, 30, 255) -- yellow
						end
			
						draw.RoundedBox(
							borderRadius + borderSize,
							0 + padding,
							0 + padding,
							w - padding * 2,
							h - padding * 2,
							borderColor
						)
						draw.RoundedBox(
							borderRadius,
							0 + borderSize + padding,
							0 + borderSize + padding,
							w - borderSize * 2 - padding * 2,
							h - borderSize * 2 - padding * 2,
							backgroundColor
						)
			
						local text = "AS"
						local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("quickMenuButtons2", text)
						draw.DrawText(
							text,
							"quickMenuButtons2",
							w / 2 - extra_width_menuText / 2,
							h / 2 - extra_height_menuText / 2,
							textColor,
							TEXT_ALIGN_LEFT
						)
					end

					function settingButtonAdmin:DoClick()
						showAdminPanel()
					end
				end
				
				-- - -
				-- - Only allow Camera Top view button:
				if ( !onlyAllowCameraTopViewButton or ( onlyAllowCameraTopViewButton and !onlyAllowCameraTopViewButton:IsValid() ) and !gameIsSingleplayer ) then
					local size = 60

					onlyAllowCameraTopViewButton = vgui.Create("DImageButton")
					onlyAllowCameraTopViewButton:SetSize(size * 2, size / 2)
					onlyAllowCameraTopViewButton:SetPos(20 - (size - 50) / 2, ScrH() - fromBottom - (size / 2) * 4 - 10 * 2 - size)

					TopViewRGBColorTimeDifference = GetAnimationCurrentTimeHUD()

					onlyAllowCameraTopViewButton.Paint = function(s, w, h)
						local backgroundColor
						local textColor = Color(0, 0, 0, 245) -- black
			
						local padding = 2
						local borderRadius = 5

						if s:IsHovered() then
							lsvTopViewOnlyAllowed(1, 255)
							lsvTopViewOnlyAllowed(2, 123)
							lsvTopViewOnlyAllowed(3, 30) -- Orange
						else
							if !onlyTopCameraViewIsAllowed then
								lsvTopViewOnlyAllowed(1, 255)
								lsvTopViewOnlyAllowed(2, 30)
								lsvTopViewOnlyAllowed(3, 50) -- Red
							else
								lsvTopViewOnlyAllowed(1, 163)
								lsvTopViewOnlyAllowed(2, 255)
								lsvTopViewOnlyAllowed(3, 30) -- Green
							end
						end backgroundColor = Color(currRGBTopViewOnlyAllowed[1], currRGBTopViewOnlyAllowed[2], currRGBTopViewOnlyAllowed[3], 255)

						draw.RoundedBox(
							borderRadius,
							0 + padding,
							0 + padding,
							w - padding * 2,
							h - padding * 2,
							backgroundColor
						)
			
						local text = "Only Top View?"
						local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("spawnMenuText003", text)
						draw.DrawText(
							text,
							"spawnMenuText003",
							w / 2 - extra_width_menuText / 2,
							h / 2 - extra_height_menuText / 2,
							textColor,
							TEXT_ALIGN_LEFT
						)
					end

					function onlyAllowCameraTopViewButton:DoClick()
						-- Send to server
						net.Start("mbd:onlyTopCameraViewIsAllowed")
							net.WriteBool(!onlyTopCameraViewIsAllowed)
						net.SendToServer()
					end
				end
				-- - -
				-- - Allow Camera Top view button:
				if ( !allowCameraTopViewButton or ( allowCameraTopViewButton and !allowCameraTopViewButton:IsValid() ) and !gameIsSingleplayer ) then
					local size = 60

					allowCameraTopViewButton = vgui.Create("DImageButton")
					allowCameraTopViewButton:SetSize(size * 2, size / 2)
					allowCameraTopViewButton:SetPos(20 - (size - 50) / 2, ScrH() - fromBottom - (size / 2) * 3 - 10 * 2 - size)

					TopViewRGBColorTimeDifference = GetAnimationCurrentTimeHUD()

					allowCameraTopViewButton.Paint = function(s, w, h)
						local backgroundColor
						local textColor = Color(0, 0, 0, 245) -- black
			
						local padding = 2
						local borderRadius = 5
			
						if s:IsHovered() then
							lsvTopView(1, 255)
							lsvTopView(2, 123)
							lsvTopView(3, 30) -- Orange
						else
							if !cameraTopViewIsAllowed then
								lsvTopView(1, 255)
								lsvTopView(2, 30)
								lsvTopView(3, 50) -- Red
							else
								lsvTopView(1, 163)
								lsvTopView(2, 255)
								lsvTopView(3, 30) -- Green
							end
						end backgroundColor = Color(currRGBTopView[1], currRGBTopView[2], currRGBTopView[3], 255)

						if GetAnimationCurrentTimeHUD() - TopViewRGBColorTimeDifference > 0.1 * 1.25 then
							TopViewRGBColorTimeDifference = GetAnimationCurrentTimeHUD()
						end

						draw.RoundedBox(
							borderRadius,
							0 + padding,
							0 + padding,
							w - padding * 2,
							h - padding * 2,
							backgroundColor
						)
			
						local text = "Top View Allowed?"
						local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("spawnMenuText003", text)
						draw.DrawText(
							text,
							"spawnMenuText003",
							w / 2 - extra_width_menuText / 2,
							h / 2 - extra_height_menuText / 2,
							textColor,
							TEXT_ALIGN_LEFT
						)
					end

					function allowCameraTopViewButton:DoClick()
						-- Send to server
						net.Start("mbd:cameraTopViewIsAllowed")
							net.WriteBool(!cameraTopViewIsAllowed)
						net.SendToServer()
					end
				end
			end

			-- ONLY for MECHANIC (or ADMIN)
			if !isPlayerSpectating and ( LocalPlayer():MBDShouldGetTheAdminBenefits(true) or string.lower( LocalPlayer():GetNWString("classname", "") ) == "mechanic" ) then
				-- - -
				-- - Quick Vechicle button:
				if ( !quickMenuButtonVehicle or ( quickMenuButtonVehicle and !quickMenuButtonVehicle:IsValid() ) ) then
					local size = 50

					quickMenuButtonVehicle = vgui.Create("DImageButton")
					quickMenuButtonVehicle:SetSize(size, size)
					quickMenuButtonVehicle:SetPos(20, ScrH() - fromBottom - size * 2 - 10 * 2)
			
					quickMenuButtonVehicle.Paint = function(s, w, h)
						local backgroundColor = Color(0, 0, 0, 250) -- black
						local textColor = Color(255, 255, 255, 250) -- white
						local borderColor = Color(80, 80, 80, 255) -- gray
			
						local padding = 2
						local borderSize = 1
						local borderRadius = size / 2
			
						if s:IsHovered() then
							borderColor = Color(0, 0, 0, 250) -- black
						end
			
						draw.RoundedBox(
							borderRadius + borderSize,
							0 + padding,
							0 + padding,
							w - padding * 2,
							h - padding * 2,
							borderColor
						)
						draw.RoundedBox(
							borderRadius,
							0 + borderSize + padding,
							0 + borderSize + padding,
							w - borderSize * 2 - padding * 2,
							h - borderSize * 2 - padding * 2,
							backgroundColor
						)
			
						local text = "VH"
						local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("quickMenuButtons2", text)
						draw.DrawText(
							text,
							"quickMenuButtons2",
							w / 2 - extra_width_menuText / 2,
							h / 2 - extra_height_menuText / 2,
							textColor,
							TEXT_ALIGN_LEFT
						)
					end

					function quickMenuButtonVehicle:DoClick()
						createQuickMenuVechicles()
					end
				end
			end

			-- - -
			-- - Change current camera-view button:
			if !isPlayerSpectating and ( !changeCameraViewButton or ( changeCameraViewButton and !changeCameraViewButton:IsValid() ) ) then
				local size = 50

				changeCameraViewButton = vgui.Create("DImageButton")
				changeCameraViewButton:SetSize(size, size)
				changeCameraViewButton:SetPos(20 + size + 10, ScrH() - fromBottom - size * 2 - 10 * 2)
		
				changeCameraViewButton.Paint = function(s, w, h)
					local backgroundColor = Color(196, 12, 15, 250) -- red
					local textColor = Color(255, 255, 255, 250) -- white
					local borderColor = Color(0, 0, 0, 255) -- black
		
					local padding = 2
					local borderSize = 1
					local borderRadius = size / 2
		
					if s:IsHovered() then
						borderColor = Color(196, 12, 15, 250) -- red
					end
		
					draw.RoundedBox(
						borderRadius + borderSize,
						0 + padding,
						0 + padding,
						w - padding * 2,
						h - padding * 2,
						borderColor
					)
					draw.RoundedBox(
						borderRadius,
						0 + borderSize + padding,
						0 + borderSize + padding,
						w - borderSize * 2 - padding * 2,
						h - borderSize * 2 - padding * 2,
						backgroundColor
					)
		
					local text = "CV"
					local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("quickMenuButtons2", text)
					draw.DrawText(
						text,
						"quickMenuButtons2",
						w / 2 - extra_width_menuText / 2,
						h / 2 - extra_height_menuText / 2,
						textColor,
						TEXT_ALIGN_LEFT
					)
				end

				function changeCameraViewButton:DoClick()
					local nextCameraView = currentCameraView + 1
					if nextCameraView > 4 then nextCameraView = 0 end

					if !gameIsSingleplayer then
						if nextCameraView == 4 and ( !cameraTopViewIsAllowed and onlyTopCameraViewIsAllowed ) then nextCameraView = 0 end
						if nextCameraView != 4 and onlyTopCameraViewIsAllowed then nextCameraView = 4 end
					elseif nextCameraView > 4 then nextCameraView = 0 end

					net.Start("mbd:SetPlayerCurrentCameraView")
						net.WriteInt(nextCameraView, 5)
					net.SendToServer()

					-- View the status to the user
					viewCameraViewStatus = true
					timer.Create("mbd:viewCameraViewStatus001", 3, 1, function()
						viewCameraViewStatus = false
					end)

					timer.Simple(1, function()
						LocalPlayer():GetActiveWeapon():SendWeaponAnim(ACT_IDLE)
						LocalPlayer():SetAnimation(PLAYER_IDLE)
						LocalPlayer():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_IDLE)
					end)
				end
			end
		end
		-- Remove...
		if !keyDown0 then
			if lobbyButton and lobbyButton:IsValid() then lobbyButton:Remove() end
			if helpCommandsButton and helpCommandsButton:IsValid() then helpCommandsButton:Remove() end
			if quickMenuButtonAdmin and quickMenuButtonAdmin:IsValid() then quickMenuButtonAdmin:Remove() end
			if allowCameraTopViewButton and allowCameraTopViewButton:IsValid() then allowCameraTopViewButton:Remove() end
			if onlyAllowCameraTopViewButton and onlyAllowCameraTopViewButton:IsValid() then onlyAllowCameraTopViewButton:Remove() end
			if quickMenuButtonVehicle and quickMenuButtonVehicle:IsValid() then quickMenuButtonVehicle:Remove() end
			if settingButtonAdmin and settingButtonAdmin:IsValid() then settingButtonAdmin:Remove() end
			if changeCameraViewButton and changeCameraViewButton:IsValid() then changeCameraViewButton:Remove() end
		else
			if gameIsSingleplayer then
				if allowCameraTopViewButton and allowCameraTopViewButton:IsValid() then allowCameraTopViewButton:Remove() end
				if onlyAllowCameraTopViewButton and onlyAllowCameraTopViewButton:IsValid() then onlyAllowCameraTopViewButton:Remove() end
			end
		end

		--
		--- AMOUNT OF ENEMIES THIS WAVE / ROUND
		if keyDown0 then
			-- GET TEXT SIZE ....
			local amountOfBuyBoxes_table = ents.FindByClass("mbd_buybox")
			local amountOfBuyBoxes_int = "N/A"
			if amountOfBuyBoxes_table && #amountOfBuyBoxes_table then
				amountOfBuyBoxes_int = #amountOfBuyBoxes_table
			end

			-- Enemies still alive
			local amountOfBuyBoxes = "BuyBox stations in map: "..amountOfBuyBoxes_int

			local amountOfEnemiesSpawningThisRound_int = "N/A"
			local allNPCSpawners = ents.FindByClass("mbd_npc_spawner_all")

			if (allNPCSpawners && #allNPCSpawners > 0) then
				amountOfEnemiesSpawningThisRound_int = 0

				for k,v in pairs(allNPCSpawners) do
					-- Add to total amount
					amountOfEnemiesSpawningThisRound_int = (amountOfEnemiesSpawningThisRound_int + v:GetNWInt("CurrentTotalAmountOfEnemiesSpawningThisWaveRound"))
				end
			end

			-- Enemies spawning this wave /round
			local amountOfEnemiesSpawningThisRound = "Enemies spawning this wave: "..amountOfEnemiesSpawningThisRound_int

			-- Pyramids already spawned
			local pyramidsSpawnedThisWave = howManyDropItemsSpawnedAlready
			local amountMax = howManyDropsNeedsToBePickedUpBeforeWaveEnd
			if !gameStarted or attackRoundIsOn or (amountMax and amountMax < 3) or (currentRoundWave and currentRoundWave < 4) then
				pyramidsSpawnedThisWave = nil
			end
			local amountOfSpawnedPyramidsThisWaveRound = "Pyramids spawned this wave: "..(pyramidsSpawnedThisWave or "N/A")

			---
			-- Print...
			local extra_widthBuyBoxes, extra_heightBuyBoxes = getTextWidthAndHeight("HUD_scoreBoardInfoEnemies", amountOfBuyBoxes)
			local extra_widthEnemiesSpawning, extra_heightEnemiesSpawning = getTextWidthAndHeight("HUD_scoreBoardInfoEnemies", amountOfEnemiesSpawningThisRound)
			local extra_widthSpawnedPyramids, extra_heightSpawnedPyramids = getTextWidthAndHeight("HUD_scoreBoardInfoEnemies", amountOfSpawnedPyramidsThisWaveRound)
			--
			local paddingEnemies = 15
			local extra0 = 5
			local awayFromBottom = 180

			surface.SetDrawColor(000, 000, 000, 240) surface.DrawRect(
				paddingEnemies + (extra0 * 2),
				ScrH() - awayFromBottom - paddingEnemies + (extra0 * 2),
				(math.max(extra_widthBuyBoxes, extra_widthEnemiesSpawning, extra_widthSpawnedPyramids) + (paddingEnemies * 2)),
				(extra_heightBuyBoxes + extra_heightEnemiesSpawning + extra_heightSpawnedPyramids) + (paddingEnemies * 2)
			)
			--- - -
			---
			local __colorTextBuyBox = Color(255, 210, 4, 255) --yellow
			local __colorTextEnemies = Color(229, 13, 30, 255) --red
			local __colorTextPyramids = Color(208, 0, 254, 255) --purple
			-- Buy Boxes
			draw.DrawText(
				amountOfBuyBoxes,
				"HUD_scoreBoardInfoEnemies",
				(paddingEnemies * 2) + (extra0 * 2),
				ScrH() - awayFromBottom + extra0,
				__colorTextBuyBox,
				TEXT_ALIGN_LEFT
			)
			-- Enemies spawning this round
			draw.DrawText(
				amountOfEnemiesSpawningThisRound,
				"HUD_scoreBoardInfoEnemies",
				(paddingEnemies * 2) + (extra0 * 2),
				ScrH() - awayFromBottom + (extra0 * 2) + extra_heightEnemiesSpawning,
				__colorTextEnemies,
				TEXT_ALIGN_LEFT
			)
			-- Pyramids already spawned
			draw.DrawText(
				amountOfSpawnedPyramidsThisWaveRound,
				"HUD_scoreBoardInfoEnemies",
				(paddingEnemies * 2) + (extra0 * 2),
				ScrH() - awayFromBottom + (extra0 * 3) + extra_heightEnemiesSpawning + extra_heightSpawnedPyramids,
				__colorTextPyramids,
				TEXT_ALIGN_LEFT
			)
		end

		--
		--- COUNTDOWNS...START ROUND AND END ROUND

		-- GET TEXT SIZE ....
		local countdownText = countDownerTime
		local extra_widthCOUNTDOWN, extra_heightCOUNTDOWN = getTextWidthAndHeight("HUD_countdown", countdownText)
		--
		local paddingCountdown = 15
		draw.RoundedBox(
			5,
			(ScrW() - extra_widthCOUNTDOWN - (paddingCountdown * 2) - (paddingCountdown / 2)),
			paddingCountdown,
			(extra_widthCOUNTDOWN + paddingCountdown),
			((extra_heightCOUNTDOWN + (extra_heightCOUNTDOWN / 2) - (paddingCountdown / 4)) + paddingCountdown),
			Color(000, 000, 000, 170)
		)
		-- COUNTDOWN
		local __colorTextCountdown = Color(229, 212, 13, 255) --darker yellow
		draw.DrawText(
			countdownText,
			"HUD_countdown",
			(ScrW() - extra_widthCOUNTDOWN - (paddingCountdown * 2)),
			(paddingCountdown * 2) - (paddingCountdown / 3),
			__colorTextCountdown,
			TEXT_ALIGN_LEFT
		)
		
		--
		--- Enemies Alive...

		-- GET TEXT SIZE ....
		local enemiesAliveText = 'ENEMIES ALIVE: '..enemiesAliveTotal

		local extra_widthENEMIESALIVE, extra_heightENEMIESALIVE = getTextWidthAndHeight("HUD_countdown", enemiesAliveText)
		--
		local paddingEnemiesAlive = 15
		local extraEnemiesAlive0 = 3.71
		draw.RoundedBox(
			20 + (extraEnemiesAlive0 * 2),
			(ScrW() - extra_widthENEMIESALIVE - paddingEnemiesAlive * 3) - (extraEnemiesAlive0 * 2),
			((extra_heightENEMIESALIVE + (extra_heightENEMIESALIVE / 2) - (paddingEnemiesAlive / 4)) + (paddingEnemiesAlive * 3) + (paddingEnemiesAlive / 3) - 4) - (extraEnemiesAlive0 * 2),
			(extra_widthENEMIESALIVE + (paddingEnemiesAlive * 2)) + ((extraEnemiesAlive0 * 2) * 2),
			((extra_heightENEMIESALIVE + (extra_heightENEMIESALIVE / 2) - (paddingEnemiesAlive / 4)) + paddingEnemiesAlive) + ((extraEnemiesAlive0 * 2) * 2),
			Color(177, 140, 37, 140) --beige
		)
		draw.RoundedBox(
			20 + extraEnemiesAlive0,
			(ScrW() - extra_widthENEMIESALIVE - paddingEnemiesAlive * 3) - extraEnemiesAlive0,
			((extra_heightENEMIESALIVE + (extra_heightENEMIESALIVE / 2) - (paddingEnemiesAlive / 4)) + (paddingEnemiesAlive * 3) + (paddingEnemiesAlive / 3) - 4) - extraEnemiesAlive0,
			(extra_widthENEMIESALIVE + (paddingEnemiesAlive * 2)) + (extraEnemiesAlive0 * 2),
			((extra_heightENEMIESALIVE + (extra_heightENEMIESALIVE / 2) - (paddingEnemiesAlive / 4)) + paddingEnemiesAlive) + (extraEnemiesAlive0 * 2),
			Color(198, 157, 42, 140) --beige
		)
		draw.RoundedBox(
			20,
			(ScrW() - extra_widthENEMIESALIVE - paddingEnemiesAlive * 3),
			((extra_heightENEMIESALIVE + (extra_heightENEMIESALIVE / 2) - (paddingEnemiesAlive / 4)) + (paddingEnemiesAlive * 3) + (paddingEnemiesAlive / 3) - 4),
			(extra_widthENEMIESALIVE + (paddingEnemiesAlive * 2)),
			((extra_heightENEMIESALIVE + (extra_heightENEMIESALIVE / 2) - (paddingEnemiesAlive / 4)) + paddingEnemiesAlive),
			Color(217, 179, 74, 140) --beige
		)

		-- ENEMIES ALIVE
		local __colorTextCountdown = Color(74, 112, 217, 255) --purple-blue
		draw.DrawText(
			enemiesAliveText,
			"HUD_countdown",
			(ScrW() - extra_widthENEMIESALIVE - (paddingEnemiesAlive * 2)),
			((extra_heightENEMIESALIVE + (extra_heightENEMIESALIVE / 2) - (paddingEnemiesAlive / 4)) + (paddingEnemiesAlive * 3) + (extra_heightENEMIESALIVE / 2)),
			__colorTextCountdown,
			TEXT_ALIGN_LEFT
		)

		--
		--- Pyramid Drops...

		-- GET TEXT SIZE ....
		if GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() > 0 then
			local pyramidDropsCountText = "PYRAMIDS: "..currentAmountOfDropsStatus

			local extra_widthpyramidDropsCount, extra_heightpyramidDropsCount = getTextWidthAndHeight("HUD_countdown", pyramidDropsCountText)
			--
			local paddingpyramidDropsCount = 15
			local paddingpyramidDropsCountExtra2 = ((extra_heightENEMIESALIVE + (extra_heightENEMIESALIVE / 2) - (paddingEnemiesAlive / 4)) + paddingEnemiesAlive) + 3
			local extrapyramidDropsCount0 = 3.71

			local boxXPos = (ScrW() - extra_widthpyramidDropsCount - paddingpyramidDropsCount * 2.732)
			local boxYPos = ((extra_heightpyramidDropsCount + (extra_heightpyramidDropsCount / 2) - (paddingpyramidDropsCount / 4)) + paddingpyramidDropsCountExtra2 + (paddingpyramidDropsCount * 3) + (paddingpyramidDropsCount / 3) - 4)
			local boxWidth = (extra_widthpyramidDropsCount + (paddingpyramidDropsCount * 2))
			local boxHeight = ((extra_heightpyramidDropsCount + (extra_heightpyramidDropsCount / 2) - (paddingpyramidDropsCount / 4)) + paddingpyramidDropsCount)

			draw.RoundedBox(
				20 + (extrapyramidDropsCount0 * 2),
				boxXPos 	- (extrapyramidDropsCount0 * 2),
				boxYPos 	- (extrapyramidDropsCount0 * 2),
				boxWidth 	+ ((extrapyramidDropsCount0 * 2) * 2),
				boxHeight 	+ ((extrapyramidDropsCount0 * 2) * 2),
				Color(74, 136, 217, 140) --purple-blue -- Color(177, 140, 37, 140) --beige
			)
			draw.RoundedBox(
				20 + extrapyramidDropsCount0,
				boxXPos 	- extrapyramidDropsCount0,
				boxYPos 	- extrapyramidDropsCount0,
				boxWidth 	+ (extrapyramidDropsCount0 * 2),
				boxHeight 	+ (extrapyramidDropsCount0 * 2),
				Color(74, 112, 217, 140) --purple-blue -- Color(198, 157, 42, 140) --beige
			)
			draw.RoundedBox(
				20,
				boxXPos,
				boxYPos,
				boxWidth,
				boxHeight,
				Color(74, 88, 217, 140) --purple-blue -- Color(217, 179, 74, 140) --beige
			)

			-- ENEMIES ALIVE
			local __colorTextCountdown = Color(217, 179, 74, 140) --beige
			draw.DrawText(
				pyramidDropsCountText,
				"HUD_countdown",
				boxXPos + boxWidth / 2 - extra_widthpyramidDropsCount / 2,
				((extra_heightpyramidDropsCount + (extra_heightpyramidDropsCount / 2) - (paddingpyramidDropsCount / 4)) + (paddingpyramidDropsCount * 3) + (extra_heightpyramidDropsCount / 2)) + paddingpyramidDropsCountExtra2,
				__colorTextCountdown,
				TEXT_ALIGN_LEFT
			)
		end
	end)
end
--
--- -- --> WHEN PLAYER looks at a prop; give the health of the prop back
--
function HOOK_HUDPaint002()
    --
    ---
    --
	--- For PROP HEALTH HUD...
	local health      = nil
	local healthLeft = nil

	local position  = nil
	--
	local width             = nil
	local width_constant    = nil
	local smooth_width      = nil
	local heightAbove       = nil
	local heightHealthBar   = nil
	--
	local ent_y = nil

	-- --->>
	local smoothWidthHealthBarTimeDifference = GetAnimationCurrentTimeFPS()

    hook.Add("HUDPaint", "mbd:EntHealthbarProp001", function()
        local ply = LocalPlayer()
		local ent = ply:GetEyeTrace().Entity
		if !ply:IsValid() or !ent:IsValid() then return nil end

        -- Retrive values
        health      = ent:GetNWInt("healthTotal", false)
		healthLeft = ent:GetNWInt("healthLeft", false)
		if !health or !healthLeft then return nil end

        --
        position  = (ent:LocalToWorld(ent:OBBCenter())):ToScreen()
        --
        width             = (60 --[[ Change this for healthbar-width when health is 100 % ]] * (healthLeft / health))
        width_constant    = (60 --[[ Change this for healthbar-width when health is 100 % ]] * (health / health))
		heightAbove       = 15
		smooth_width	  = width
		heightHealthBar   = 6
		borderRadius	  = 3
        --
        ent_y = ent:OBBMaxs().y
        --
        -- Draw Rounded Box
        -- Skin health-bar
        draw.RoundedBox(
            borderRadius,
            (position.x - (width_constant / 2)),
            (position.y - (heightAbove / 2) * 8.2),
            width_constant,
            heightHealthBar,
            Color(0, 0, 0, 220)
		)
		
		local smoothWidthHealthBarTimeDifferenceResult = GetAnimationCurrentTimeFPS() - smoothWidthHealthBarTimeDifference
		-- Real health-bar
		local newSmoothWidth = MBDLerp(smoothWidthHealthBarTimeDifferenceResult, smooth_width, width)
		--
		smooth_width = newSmoothWidth
		--- -

		local alpha = 200
		local colorHealthBar = getCorrectHealthColor(((healthLeft / health) * 100), {
			Color(101, 227, 7, alpha), -- Green
			Color(227, 120, 7, alpha), -- Orange
			Color(227, 45, 7, alpha) -- Red
		})

		draw.RoundedBox(
			borderRadius,
			(position.x - (width / 2) - ((width_constant - width) / 2)),
			(position.y - (heightAbove / 2) * 8.2),
			smooth_width,
			heightHealthBar,
			colorHealthBar
		)

		-- Maybe update
		if GetAnimationCurrentTimeFPS() - smoothWidthHealthBarTimeDifference > 0.03 then
			smoothWidthHealthBarTimeDifference = GetAnimationCurrentTimeFPS()
		end
	end)
end
--
--- -- --> THE LOBBY'S HUD
--
function HOOK_HUDPaint003(
	margin,
	hogdePluss,
    class0Btn,
    class1Btn,
    class2Btn,
    class3Btn
)
	if !container or !container:IsValid() then container = vgui.Create("DFrame") end
	--
	--
	---
	if (
		!container or
		!container:IsValid()
	) then return print("M.B.D.: An unknow error occured while trying to load the Lobby Panel.") end

	container:SetTitle("")
	container:SetSize(ScrW(), ScrH())
	container:Center()
	container:SetKeyboardInputEnabled(false)
	container:SetMouseInputEnabled(true)
	container:SetAllowNonAsciiCharacters(true)
	container:SetVisible(true)
	container:ShowCloseButton(false)
	container:SetDraggable(false)
	container:DockPadding(0, 0, 0, 0)
	container:SetKeyboardInputEnabled(false)
	container:SetMouseInputEnabled(false)

	local extra0 = 2
	local lobbyClassPanelW = (ScrW() - (ScrW() * 0.4))
	local lobbyClassPanelH = ( ScrH() - (ScrH() * 0.28) )
	local lobbyClassPanelX = 0
	local lobbyClassPanelY = ScrH() / 2 - lobbyClassPanelH / 2 + 25
	
	-- Players
	local lobbyPlayersPanelW = (ScrW() - (ScrW() * 0.6)) - 12
	local lobbyPlayersPanelH = ( ScrH() - (ScrH() * 0.35) )
	local lobbyPlayersPanelX = ScrW() - lobbyPlayersPanelW
	local lobbyPlayersPanelY = ScrH() / 2 - lobbyPlayersPanelH / 2 + 25

	-- -- Lobby Players Window Content
	local _LobbyScrollWindow_RichText = vgui.Create("RichText", container)
	_LobbyScrollWindow_RichText:SetVerticalScrollbarEnabled(true)

	function _LobbyScrollWindow_RichText:PerformLayout()
		self:SetFontInternal("lobbyPlayers")
		self:SetFGColor(
			Color(78, 78, 78, 250)
		)
	end
	_LobbyScrollWindow_RichText:SetSize(
		lobbyPlayersPanelW - extra0 * 4,
		lobbyPlayersPanelH - extra0 * 4 * 6
	)
	_LobbyScrollWindow_RichText:SetPos(
		lobbyPlayersPanelX + extra0 * 4,
		lobbyPlayersPanelY + extra0 * 4 * 6
	)

	local margin = 3
	local widthCB = lobbyClassPanelW / 2
	local heightCB = lobbyClassPanelH / 2
	-- - -
	--
	-- ENGINEER
	local class0Btn = vgui.Create("DImageButton", container)
	class0Btn:SetStretchToFit(false)
	-- class0Btn:SetColor(Color(22, 166, 236, 255))
	class0Btn:SetText("")
	-- class0Btn:SetIcon("mbd_lobby/engineer.png")
	class0Btn:SetSize(
		widthCB,
		heightCB
	)
	class0Btn:SetPos(
		0,
		lobbyClassPanelY
	)
	-- MECHANIC
	local class1Btn = vgui.Create("DImageButton", container)
	class1Btn:SetStretchToFit(false)
	-- class1Btn:SetColor(Color(52, 58, 50, 255))
	class1Btn:SetText("")
	-- class1Btn:SetIcon("mbd_lobby/mechanic.png")
	class1Btn:SetSize(
		widthCB,
		heightCB
	)
	class1Btn:SetPos(
		lobbyClassPanelW - widthCB,
		lobbyClassPanelY
	)
	-- MEDIC
	local class2Btn = vgui.Create("DImageButton", container)
	class2Btn:SetStretchToFit(false)
	-- class2Btn:SetColor(Color(90, 216, 51, 255))
	class2Btn:SetText("")
	-- class2Btn:SetIcon("mbd_lobby/medic.png")
	class2Btn:SetSize(
		widthCB,
		heightCB
	)
	class2Btn:SetPos(
		0,
		lobbyClassPanelY + heightCB
	)
	-- THE TERMINATOR
	local class3Btn = vgui.Create("DImageButton", container)
	class3Btn:SetStretchToFit(false)
	-- class3Btn:SetColor(Color(244, 13, 1, 255))
	class3Btn:SetText("")
	-- class3Btn:SetIcon("mbd_lobby/terminator.png")
	class3Btn:SetSize(
		widthCB,
		heightCB
	)
	class3Btn:SetPos(
		lobbyClassPanelW - widthCB,
		lobbyClassPanelY + heightCB
	)
	-- -
	-- -- -
	-- - -- -
	-- Classes
	-- The front panels
	local gradient = Material("gui/gradient")

	local function base(w, h)
		local extra_width_version, extra_height_version = getTextWidthAndHeight("lobbyText0", MBDTextCurrentVersion)

		-- Version/Incomming message
		local width = extra_width_version + 6
		local height = 38
		local xPos = ScrW() / 2 - width / 2
		local yPos = -10
		surface.SetDrawColor(30, 30, 30, 200)
		surface.DrawRect(xPos, yPos, width, height - 1)
		surface.DrawOutlinedRect(xPos, yPos + -2, width, height)
		surface.DrawOutlinedRect(xPos, yPos + -1, width, height)

		local topLeftTextColor = Color(255, 215, 0, 200)
		draw.DrawText(
			MBDTextCurrentVersion,
			"lobbyText0",
			ScrW() / 2 - extra_width_version / 2,
			6,
			topLeftTextColor,
			TEXT_ALIGN_LEFT
		)
		draw.DrawText(
			"Incoming messages:",
			"lobbyText0",
			5 + 8,
			30,
			Color(30, 30, 30, 255),
			TEXT_ALIGN_LEFT
		)
		--
		-- - - Incoming messages:
		--
		if gameStarted then
			if LocalPlayer() and LocalPlayer().Name then
				containerIncomingMessage = " ( "..LocalPlayer():Name().." )....Game Started! Survive for as long as you can."
			else
				containerIncomingMessage = " Game Started! Survive for as long as you can."
			end
		end
		-- -
		--
		surface.SetDrawColor(50, 50, 50, 240) --gray
		surface.DrawRect(
			5 + 20,
			20 + 35,
			ScrW() - (5 + 20) * 2,
			65
		)
		surface.SetDrawColor(115, 129, 95, 240) --lightGrayGreen
		surface.DrawOutlinedRect(
			5 + 20 - 1,
			20 + 35 - 1,
			ScrW() - (5 + 20) * 2 + 1,
			65 + 1
		)

		draw.DrawText(
			"> //\\//\\// Rebel; keep alive for as long as you can..",
			"lobbyIncomingMessageItalic",
			5 + 30,
			20 + 46,
			Color(173, 255, 47, 255),
			TEXT_ALIGN_LEFT
		)
		draw.DrawText(
			"> Our current official status: ",
			"lobbyIncomingMessageItalic",
			5 + 30,
			20 + 40 + 28,
			Color(173, 255, 47, 255), -- lightGreen
			TEXT_ALIGN_LEFT
		)
		draw.DrawText(
			containerIncomingMessage,
			"lobbyIncomingMessage",
			5 + 40 + 170,
			20 + 40 + 28,
			Color(173, 255, 47, 255), -- lightGreen
			TEXT_ALIGN_LEFT
		)
		
		-- Header
		draw.DrawText(
			"My Base Defence",
			"lobbyHeader1",
			ScrW() - 605 + 3,
			27 + 3,
			Color(75, 75, 75, 250),
			TEXT_ALIGN_LEFT
		)
		draw.DrawText(
			"My Base Defence",
			"lobbyHeader1",
			ScrW() - 605,
			27,
			Color(255, 215, 0, 255),
			TEXT_ALIGN_LEFT
		)

		-- Lobby Players background
		draw.RoundedBoxEx(
			15,
			lobbyPlayersPanelX - extra0 * 2, --x
			lobbyPlayersPanelY, --y
			w + (extra0 * 2),
			h,
			Color(50, 50, 50, 250),
			true,
			false,
			true,
			false
		)
		draw.RoundedBoxEx(
			15,
			lobbyPlayersPanelX, --x
			lobbyPlayersPanelY, --y
			w,
			h,
			Color(255, 255, 255, 255),
			true,
			false,
			true,
			false
		)
		-- -
		if gameStarted then
			draw.DrawText(
				"In Game (alive):",
				"lobbyHeader3",
				lobbyPlayersPanelX + extra0 * 8.5,
				lobbyPlayersPanelY + extra0 * 6,
				Color(0, 0, 0, 225),
				TEXT_ALIGN_LEFT
			)
		else
			draw.DrawText(
				"In Lobby:",
				"lobbyHeader3",
				lobbyPlayersPanelX + extra0 * 8.5,
				lobbyPlayersPanelY + extra0 * 6,
				Color(0, 0, 0, 225),
				TEXT_ALIGN_LEFT
			)
		end
	end
	--
	-- CLASS-amount taken/total
	local function classAmountFunc(
		width,
		height,
		xPos,
		yPos,
		__className
	)
		local extra0 = 11
		local extra1 = 1
		local borderRadius = 8
		local borderSize = 3

		-- Amount left
		draw.RoundedBox(
			borderRadius + borderSize,
			xPos + extra0 * 2 - extra1 * borderSize,
			(yPos - extra0 * 2) - extra1 * borderSize,
			width + (extra1 * borderSize * 2),
			height + (extra1 * borderSize * 2),
			Color(166, 236, 22, 130) -- lightGreen
		)
		draw.RoundedBox(
			borderRadius,
			xPos + extra0 * 2,
			(yPos - extra0 * 2),
			width,
			height,
			Color(43, 43, 43, 255)
		)
		draw.DrawText(
			playerClassesAvailable[__className].taken.." of "..playerClassesAvailable[__className].total,
			"DermaDefaultBold",
			(xPos + (width / 2)) + extra0 * 2,
			(yPos + (height / 2) - extra0 * 3 + 4),
			Color(255, 255, 255, 170),
			TEXT_ALIGN_CENTER
		)
	end

	--- -
	--- The Container Background
	local classPickerText = "Class Picker"
	local alpha001 = 130
	local originalClassPickerTextColor = Color(255, 255, 255, 195) -- White
	local warnClassPickerTextColor = Color(254, 208, 0, alpha001) -- Yellow
	local errorClassPickerTextColor = Color(254, 0, 46, alpha001) -- Red
	local okClassPickerTextColor = Color(0, 254, 81, alpha001) -- Green
	local ok2ClassPickerTextColor = Color(0, 173, 254, alpha001) -- Blue
	local classPickerTextColor = originalClassPickerTextColor

	local function setClassPickerTextColorType(type, timeToShowVisualMessage)
		local classPickerTextColorResetTimerID = "mbd:classPickerTextColorResetTimer001"

		if type == 0 then
			-- Error
			classPickerTextColor = errorClassPickerTextColor
		elseif type == 1 then
			-- Warning
			classPickerTextColor = warnClassPickerTextColor
		elseif type == 2 then
			-- OK
			if (
				!LocalPlayer():GetNWBool("isSpectating") or (
					LocalPlayer():GetNWBool("isSpectating")
					and GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() > -1
					and theSpawnButtonIsComplete
				)
			) then
				classPickerTextColor = okClassPickerTextColor

				surface.PlaySound("game/lobby_menu_class_pick.wav")
			end
		elseif type == 3 then
			-- OK 2 ( without sound )
			classPickerTextColor = ok2ClassPickerTextColor

			surface.PlaySound("game/lobby_menu_class_pick_minus.wav")
		end

		timer.Remove(classPickerTextColorResetTimerID)
		timer.Create(classPickerTextColorResetTimerID, timeToShowVisualMessage, 1, function()
			classPickerTextColor = originalClassPickerTextColor
		end)
	end

	local color1 = { 22, 166, 236 } -- Blue
	local color2 = { 255, 140, 0 } -- Orange; another orange 255, 192, 0
	local currRGBContainer = color1
	
	local currColor = 2 -- 1 or 2 ( starts at color 1 )

	container.Paint = function(s, w, h)

		surface.SetDrawColor(22, 166, 236, 215)
		surface.DrawRect(0, 0, w, h)
		--- -
		-- AUTHOR
		draw.DrawText(
			"TAB (+E) to OPEN in GAME\nCTRL+C to CLOSE (if allowed)\nCTRL+<A|H>\n\nMade by : ravo (Norway)",
			"Default",
			(ScrW() - 162),
			(ScrH() - 70),
			Color(255, 255, 255, 245),
			TEXT_ALIGN_LEFT
		)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(
			(ScrW() - 162) - 9,
			(ScrH() - 70) - 9,
			200,
			53
		)
		--
		--- -
		-- CLASS PICKER Window
		draw.RoundedBoxEx(
			35,
			lobbyClassPanelX - extra0,
			lobbyClassPanelY - extra0,
			lobbyClassPanelW + extra0 - 1,
			lobbyClassPanelH + (extra0 * 2),
			Color(236, 199, 22, 250),
			false,
			true,
			false,
			true
		)
		draw.RoundedBoxEx(
			35,
			lobbyClassPanelX,
			lobbyClassPanelY,
			lobbyClassPanelW,
			lobbyClassPanelH,
			Color(50, 50, 50, 255),
			false,
			true,
			false,
			true
		)
		local width = w * 0.55
		surface.SetDrawColor(163, 255, 30, 16)
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(
			0,
			lobbyClassPanelY,
			width,
			lobbyClassPanelH + extra0
		)
		-- -
		-- - Class Picker
		local extra_width, extra_height = getTextWidthAndHeight("lobbyHeader3", classPickerText)
		draw.DrawText(
			classPickerText,
			"lobbyHeader3",
			lobbyClassPanelX + lobbyClassPanelW / 2 - extra_width / 2 + 5,
			lobbyClassPanelY + lobbyClassPanelH / 2 - extra_height / 2 + 2,
			Color(0, 0, 0, 200),
			TEXT_ALIGN_LEFT
		)
		draw.DrawText(
			classPickerText,
			"lobbyHeader3",
			lobbyClassPanelX + lobbyClassPanelW / 2 - extra_width / 2,
			lobbyClassPanelY + lobbyClassPanelH / 2 - extra_height / 2,
			classPickerTextColor,
			TEXT_ALIGN_LEFT
		)
		-- -
		local margin2 = 6
		local widthCBL = 70
		local heightCBL = 30
		-->
		-- ENGINEER CLASS AMOUNT
		classAmountFunc(
			widthCBL,
			heightCBL,
			-margin2 / 2,
			lobbyClassPanelY + heightCBL + margin2,
			"engineer"
		)
		-- MECHANIC CLASS AMOUNT
		classAmountFunc(
			widthCBL,
			heightCBL,
			lobbyClassPanelW - widthCBL - widthCBL / 2 - margin2,
			lobbyClassPanelY + heightCBL + margin2,
			"mechanic"
		)
		-- MEDIC CLASS AMOUNT
		classAmountFunc(
			widthCBL,
			heightCBL,
			-margin2 / 2,
			lobbyClassPanelY - heightCBL / 2 + lobbyClassPanelH - margin2,
			"medic"
		)
		-- TERMINATOR CLASS AMOUNT
		classAmountFunc(
			widthCBL,
			heightCBL,
			lobbyClassPanelW - widthCBL - widthCBL / 2 - margin2,
			lobbyClassPanelY + lobbyClassPanelH - heightCBL / 2 - margin2,
			"terminator"
		)

		base(lobbyPlayersPanelW, lobbyPlayersPanelH)
	end

	container:MakePopup()
	--
	--- Move BUTTONS TO FRONT
	class0Btn:MoveToFront()
	class1Btn:MoveToFront()
	class2Btn:MoveToFront()
	class3Btn:MoveToFront()
	-- ---
	-- -
	_LobbyScrollWindow_RichText:MoveToFront()
	-- ---- -->>
	--
	local controlKeyDown = false
	--
	function container:OnKeyCodePressed(key)
		if (controlKeyDown && key == KEY_C) then
			-- Close lobby...
			closeLobby()
		elseif (controlKeyDown && key == KEY_A) then
			-- Open Admin settings
			showAdminPanel()
		elseif (controlKeyDown && key == KEY_H) then
			-- Open Help panel
			createCommandsHelpPanel()
		end
		
		if (key == KEY_LCONTROL || key == KEY_RCONTROL) then
			controlKeyDown = true
		else
			controlKeyDown = false
		end
	end
	function container:OnKeyCodeReleased(key)
		if (key == KEY_LCONTROL || key == KEY_RCONTROL) then
			controlKeyDown = false
		end
	end
	function container:OnClose()
		if (!LocalPlayer()) then
			-- IF an error occured... THIS will happen if you save this file when you are in-game
			chat.AddText(Color(254, 81, 0), "M.B.D. : Your lobby fu**ed up. You have to re-enter the server again... The \"cl_lobby\" file got changed while in-game.")
		end
	end

	--- -
	-- / // CLASSes
	local function chooseClassFunc(classInt)
		local className = MBDGetClassNameForPlayerClass(classInt)
		local currPlayerClassName = MBDGetClassNameForPlayerClass(LocalPlayer():GetNWInt("classInt", -1))
		classPickerTextColor = originalClassPickerTextColor

		--- - -
		-- Send a visual notification
		if !LocalPlayer():MBDPlayerCanChangeToNewClass(currentRoundWave, gameStarted) then
			-- Not modulo 3 (warning)
			setClassPickerTextColorType(1, 1)

			chat.AddText(Color(254, 81, 0), "You can only change class every three round! (", Color(254, 208, 0), "warning", Color(254, 81, 0), ")")
		elseif (
			playerClassesAvailable
			and playerClassesAvailable[className].taken == playerClassesAvailable[className].total
			and currPlayerClassName != className
		) then
			-- The class is full (error)
			setClassPickerTextColorType(0, 1.3)
		elseif currPlayerClassName != className then
			-- If class is not already picked by player and the game is started (OK)
			setClassPickerTextColorType(2, 1.3)
		elseif (
			!gameStarted
			and currPlayerClassName == className
		) then
			-- The class got removed from player (OK 2)
			setClassPickerTextColorType(3, 0.43)
		elseif (
			gameStarted
			and currPlayerClassName == className
		) then
			-- Same class (warning)
			setClassPickerTextColorType(0, 1)
		end
		--- - -
		-- Predict the change at Client side
		if (
			gameStarted
			and LocalPlayer():GetNWBool("isSpectating", false)
			and GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() > -1
		) then
			-- Will probably need to spawn from Button, so don't predict the Class table
			if respawnBtn and theSpawnButtonIsComplete then
				if playerClassesAvailable[className].taken != playerClassesAvailable[className].total then
					SetTextSpawnButton(respawnBtn, "ok", "SPAWN AS "..string.upper(className))

					--
					-- Send to SERVER
					net.Start("PlayerClass")
						net.WriteInt(classInt, 3)
					net.SendToServer()
				end
			end
		elseif LocalPlayer():MBDPlayerCanChangeToNewClass(currentRoundWave, gameStarted) then
			-- Regular Class spawn
			if (
				!gameStarted
				and currPlayerClassName == className
			) then
				LocalPlayer():MBDChangeClassesTableValue("1", playerClassesAvailable, className, false, true)
			else
				LocalPlayer():MBDChangeClassesTableValue("2", playerClassesAvailable, className, false, false)

				-- Maybe decrease the old one...
				if LocalPlayer():GetNWInt("classInt", -1) != -1 and currPlayerClassName != className then
					LocalPlayer():MBDChangeClassesTableValue("3", playerClassesAvailable, currPlayerClassName, false, true)
				end
			end

			--
			-- Send to SERVER
			net.Start("PlayerClass")
				net.WriteInt(classInt, 3)
			net.SendToServer()

			-- Extra information for the Players...>>
			sendANotificationBasedOnClass(classInt, '001')

			if classInt != 0 then
				sendANotificationBasedOnClass(0, '002') -- Everybody can now heal a prop; just re-using; don't need to change it
			end
		end
	end
	-- - Class Picker
	--
	function class0Btn:DoClick()
		chooseClassFunc(0) -- Engineer
	end
	function class1Btn:DoClick()
		chooseClassFunc(1) -- Mechanic
	end
	function class2Btn:DoClick()
		chooseClassFunc(2) -- Medic
	end
	function class3Btn:DoClick()
		chooseClassFunc(3) -- Terminator
	end
	local class0BtnHovered = false
	local class1BtnHovered = false
	local class2BtnHovered = false
	local class3BtnHovered = false

	class0BtnMaterial = Material("materials/mbd_lobby/engineer.png", "noclamp smooth")
	class1BtnMaterial = Material("materials/mbd_lobby/mechanic.png", "noclamp smooth")
	class2BtnMaterial = Material("materials/mbd_lobby/medic.png", "noclamp smooth")
	class3BtnMaterial = Material("materials/mbd_lobby/terminator.png", "noclamp smooth")

	local paintImage = function(panel, material)
		local radius = math.min(widthCB, heightCB) / 2 - 25
		-- -
		-- Picture
		surface.SetDrawColor(255, 255, 255, 248)
		surface.SetMaterial(material)
		draw.Circle(widthCB / 2, heightCB / 2, radius, radius * 2)
	end

	class0Btn.Paint = function (s, w, h)
		local onHover = s:IsHovered()
		if onHover then class0BtnHovered = true classPickerText = "Engineer" else class0BtnHovered = false end

		paintImage(s, class0BtnMaterial)
	end
	class1Btn.Paint = function (s, w, h)
		local onHover = s:IsHovered()
		if onHover then class1BtnHovered = true classPickerText = "Mechanic" else class1BtnHovered = false end

		paintImage(s, class1BtnMaterial)
	end
	class2Btn.Paint = function (s, w, h)
		local onHover = s:IsHovered()
		if onHover then class2BtnHovered = true classPickerText = "Medic" else class2BtnHovered = false end

		paintImage(s, class2BtnMaterial)
	end
	class3Btn.Paint = function (s, w, h)
		local onHover = s:IsHovered()
		if onHover then class3BtnHovered = true classPickerText = "Terminator" else class3BtnHovered = false end

		paintImage(s, class3BtnMaterial)
		
		-- Fallback text
		if !class0BtnHovered and !class1BtnHovered and !class2BtnHovered and !class3BtnHovered then classPickerText = "Class Picker" end
	end
	
	timer.Simple(0, function() addCustomCursorToParentAndChildren(container) end)
	-- - -
	-- Return to write fresh somewhere else -->>
	return _LobbyScrollWindow_RichText
end

function checkIfWitinHealingArea(ent)
	for _,child in pairs(ent:GetChildren()) do
		if (
			child and
			child:IsValid() and
			child:GetClass() == "mbd_healing_trigger"
		) then
			local currentAllowedPlayers = child:GetNWString("allowedPlayersHealProp", "")
			if currentAllowedPlayers == "" then currentAllowedPlayers = {} else
				currentAllowedPlayers = string.Split(currentAllowedPlayers, ",")
			end

			if !table.HasValue(currentAllowedPlayers, LocalPlayer():UniqueID()) then
				-- Cancle...
				return false
			end

			return true
		end
	end
end
-- Draw the Indicator for the Repair tools (prop and vehicle)
function PaintRepairToolIndicator(Owner, Ent)
	if !Owner or !Owner:IsValid() or !Ent or !Ent:IsValid() then return end

	PosOwner	= Owner:GetPos()
	PosEnt		= Ent:GetPos()
	
	local alpha = 200
	local __Color2 = nil
	local _Color = nil

	-- Check that the distance is OK >>
	local _Distance = PosOwner:Distance(Vector(PosEnt.x, PosEnt.y, PosOwner.z))

	-- Health for Prop/Vehicle
	local totalHealth	= Ent:GetNWInt("healthTotal", -1)
	local leftHealth	= Ent:GetNWInt("healthLeft", -1)
	if (
		(
			totalHealth == -1 or
			leftHealth == -1
		) and !Ent:IsNPC()
	) then return end

	local propStrengthenNumberTimes = Ent:GetNWInt("propIsAddedSuperStrongNumberTimes", -1)

	if !Ent:IsNPC() then 
		local __Color = getCorrectHealthColor(((leftHealth / totalHealth) * 100), {
			Color(189, 235, 8, alpha), 	-- YellowGreen (not max health, but OK)
			Color(227, 120, 8, alpha), 	-- Orange
			Color(235, 47, 8, alpha)	-- Red
		})

		_Color = __Color
	end

	-- NPC
	if _Distance <= 600 and _Distance > 60 and Ent:IsNPC() then -- A NPC you can damage
		_Color = Color(235, 225, 8, alpha) 		-- Yellow
	elseif _Distance <= 60 and Ent:IsNPC() then -- Needs to be within range (tell the Player)
		_Color = Color(255, 0, 0, alpha) 	-- Red
	elseif Ent:IsNPC() then return end

	-- -- - --
	-- Draw
	local w = 5
    local h = 2

	local amount = 10
	local amount_i = 1
	local offsetPosEnd = 30
	local offsetPosStart = offsetPosEnd * -1
	local addPoint = offsetPosEnd * 2 / amount

	local isWithinHealingArea = checkIfWitinHealingArea(Ent)

	local currOffsetPos = offsetPosStart
	local i2 = 0
	for i = 1, offsetPosEnd * 2 do
		if i2 == addPoint then
			i2 = 0

			-- Draw
			if (
				(
					amount_i == 1 or amount_i == 2 or amount_i == 3 or
					amount_i == 7 or amount_i == 8 or amount_i == 9
				) and !isWithinHealingArea
			) then
				surface.SetDrawColor(148, 148, 148, alpha) -- LightGray
			else
				surface.SetDrawColor(_Color.r, _Color.g, _Color.b, _Color.a) -- Health Color
			end

			-- Maybe Prop Is Strengthened.. Show
			if propStrengthenNumberTimes > -1 and (amount_i == 1 or amount_i == 9) then
				surface.SetDrawColor(18, 173, 243, alpha) -- BLue
			end

			surface.DrawRect(
				(ScrW() / 2 - (w / 2)) + currOffsetPos,
				(ScrH() / 2 - (h / 2)),
				w,
				h
			)

			amount_i = amount_i + 1
		end

		currOffsetPos = currOffsetPos + 1
		i2 = i2 + 1
	end

	----
	---
	-- Tell how many times prop has been strengthen (maybe)
	local extra0 = 20
	if propStrengthenNumberTimes > -1 then
		local strengthenText = "Super Strengthen × "..propStrengthenNumberTimes

		local extra_width, extra_height = getTextWidthAndHeight("TargetIDSmall", strengthenText)
		--
		local padding = 15

		local colorText = Color(18, 173, 243, alpha) --Blue
		draw.DrawText(
			strengthenText,
			"TargetIDSmall",
			(ScrW() / 2 - extra_width / 2),
			(ScrH() / 2 - extra_height / 2) - extra0,
			colorText,
			TEXT_ALIGN_LEFT
		)
	end

	-- Show health left..
	if !Ent:IsNPC() and Ent:GetNWInt("healthTotal", -1) > -1 then
		local hpLeft = leftHealth
		local hpTotal = totalHealth
		if hpLeft < 1 then hpLeft = math.Round(hpLeft, 1) else hpLeft = math.Round(hpLeft) end
		if hpTotal < 1 then hpTotal = math.Round(hpTotal, 1) else hpTotal = math.Round(hpTotal) end
		local healthLeftText = "HP "..hpLeft.." ("..hpTotal..")"

		local extra_width, extra_height = getTextWidthAndHeight("TargetIDSmall", healthLeftText)
		--
		local padding = 15
	
		local colorText = Color(244, 244, 244, alpha) --Blue
		draw.DrawText(
			healthLeftText,
			"TargetIDSmall",
			(ScrW() / 2 - extra_width / 2),
			(ScrH() / 2 - extra_height / 2) + extra0,
			colorText,
			TEXT_ALIGN_LEFT
		)
	end
end

local NPCList = list.Get("NPC")
local function npcForward(ent) if ent and ent:IsValid() then return ent:GetForward() * -1 end return Vector(1, 1, 1) end
-- - -
-- Particle effect Attach..
local function particleEffectAttach(attachName, ent)
	if ent and ent:IsValid() then
		local npcAttachID = ent:LookupAttachment(attachName)
		if npcAttachID > 0 then
			ParticleEffectAttach("mbd_blood_droplets_00", PATTACH_POINT_FOLLOW, ent, npcAttachID)
		end
	end
end

local function twitchRagdoll( ent, physObj, npcForward, damageForce, time1, time2, ownVector )
	local timeZ = math.random(time1, time2)
	local ownVec = ownVector or Vector(1, 1, 1)

	-- Pretty OK...
	physObj:AddVelocity(npcForward * damageForce)

	timer.Simple(timeZ, function()
		if ent and ent:IsValid() then
			local vel = Vector(150, 150, 150) * VectorRand() * ownVec

			physObj:SetVelocity(vel)
		end
	end)
end
hook.Add( "CreateClientsideRagdoll", "mbd:ChangeToCorrectRagdollModell", function(ent, ragdoll)
	-- Set the model again if needed...
	ragdoll:SetModel( MBDGETCorrectNPCModel( ragdoll:GetModel() ) )

	-- Remove ragdoll after some time
	timer.Simple( math.random( 12, 48 ), function() if ragdoll and ragdoll:IsValid() then ragdoll:SetSaveValue( "m_bFadingOut", true ) end end )

	local npcForward = npcForward(ent)
	-- local npcModelScale = ent:GetNWInt( "NPCModelScale", 1 )

	-- Stop all particles set on CLIENT and SERVER for ent....
	timer.Simple(0.15, function()
		if ent and ent:IsValid() then
			ent:StopParticlesNamed("mbd_blood_droplets_00")
			net.Start("mbd:StopParticleEffectOnEnt")
				net.WriteTable({
					ent,
					"mbd_blood_droplets_00"
				})
			net.SendToServer()
		end
	end)

	timer.Simple(0.06, function()
		if ent and ent:IsValid() and ragdoll and ragdoll:IsValid() then
			local vectorScale = Vector( npcModelScale, npcModelScale, npcModelScale )

			-- Set model scale...
			-- ragdoll:SetModelScale( npcModelScale )

			local damageForce = ent:GetNWVector("mbd:damageForceOnDeath", Vector(400, 400, 500))

			local npcModel = string.lower(ent:GetModel())
			local npcClass = ent:GetClass()
			local npcPos = ent:GetPos() + Vector(0, 0, 100)

			local attachmentHeadIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1") or ragdoll:LookupBone("ValveBiped.Bip01_Spine4")
			-- A particle effect
			if attachmentHeadIndex then
				local pos, ang = ragdoll:GetBonePosition(attachmentHeadIndex)

				local int0 = math.random(2, 6)
				local int1 = math.random(2, 6)

				-- ParticleEffect("vortigaunt_glow_charge_cp1", pos, ang, ragdoll) -- Causes bug sometimes?
				ParticleEffect("vortigaunt_glow_charge_cp1_beam"..int0, pos, ang, ragdoll)
				ParticleEffect("vortigaunt_glow_charge_cp1_beam"..int1, pos, ang, ragdoll)
			else
				local zPos = 10
				
				local int0 = math.random(2, 6)
				local int1 = math.random(2, 6)

				-- ParticleEffect("vortigaunt_glow_charge_cp1", npcPos + Vector(0, 0, zPos), AngleRand(), ragdoll) -- Causes bug sometimes?
				ParticleEffect("vortigaunt_glow_charge_cp1_beam"..int0, npcPos + Vector(0, 0, zPos), AngleRand(), ragdoll)
				ParticleEffect("vortigaunt_glow_charge_cp1_beam"..int1, npcPos + Vector(0, 0, zPos), AngleRand(), ragdoll)
			end
			-- - -- -
			-- - -
			-- Very important with a timer... So the NWBool's can get written in time on SERVER
			timer.Simple(0.5, function()
				local npc = ent
				--
				-- --
				local removeBodyGroup_HEAD = npc:GetNWBool("removeBodyGroup_HEAD", false)
				local removeBodyGroup_LEFTARM = npc:GetNWBool("removeBodyGroup_LEFTARM", false)
				local removeBodyGroup_RIGHTARM = npc:GetNWBool("removeBodyGroup_RIGHTARM", false)
				local removeBodyGroup_LEFTLEG = npc:GetNWBool("removeBodyGroup_LEFTLEG", false)
				local removeBodyGroup_RIGHTLEG = npc:GetNWBool("removeBodyGroup_RIGHTLEG", false)

				if removeBodyGroup_HEAD then particleEffectAttach("bodypart_blood_HEAD", ragdoll) end
				if removeBodyGroup_LEFTARM then particleEffectAttach("bodypart_blood_LEFTARM", ragdoll) end
				if removeBodyGroup_RIGHTARM then particleEffectAttach("bodypart_blood_RIGHTARM", ragdoll) end
				if removeBodyGroup_LEFTLEG then particleEffectAttach("bodypart_blood_LEFTLEG", ragdoll) end
				if removeBodyGroup_RIGHTLEG then particleEffectAttach("bodypart_blood_RIGHTLEG", ragdoll) end
			end)
			-- - -
			-- - Maybe set the model...
			local physObj = ragdoll:GetPhysicsObject()
			if ragdoll and ragdoll:IsValid() then
				physObj:AddVelocity(Vector(0, 0, 600))
			end
			timer.Simple(1, function()
				if ragdoll and ragdoll:IsValid() then
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 0, 5)
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 0, 5)
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 0, 5)
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 0, 5)

					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 2, 7)
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 2, 7)

					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 5, 9)
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 5, 9)

					local force = 3.6
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 3, 5, Vector(force, force, force))
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 12, 25, Vector(force, force, force))
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 12, 25, Vector(force, force, force))

					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 30, 40)
					twitchRagdoll(ragdoll, physObj, npcForward, damageForce, 35, 50, Vector(force, force, force))
				end
			end)
			
		end
	end)
end )
--
-- To choose a pre-set game quickly
function createQuickMenuAdmin()
	if LocalPlayer():MBDIsNotAnAdmin(true) then
		chat.AddText(Color(0, 254, 208), "Not an Admin.")

		return
	end

	if quickSettingMenu and quickSettingMenu:IsValid() then
		quickSettingMenu:Remove()
		quickSettingMenu = nil
	end
	--
	local wrapperWidth 	= 834
	local wrapperHeight = 465
	local paddingButton = 15

	local amountOfButtonsWide = 3
	local amountOfButtonsTall = 4
	--
	-- -
	quickSettingMenu = vgui.Create("DFrame")
	quickSettingMenu:SetTitle("My Base Defence : "..MBDTextCurrentVersion.." - Quick Settings : ( ADMIN )")
	quickSettingMenu:SetSize(wrapperWidth, wrapperHeight)
	quickSettingMenu:Center()
	quickSettingMenu:SetKeyboardInputEnabled(true)
	quickSettingMenu:SetMouseInputEnabled(true)
	quickSettingMenu:SetAllowNonAsciiCharacters(true)
	quickSettingMenu:SetVisible(true)
	quickSettingMenu:ShowCloseButton(true)
	quickSettingMenu:SetDraggable(true)
	quickSettingMenu.Paint = function(s, w, h)
		draw.RoundedBox(7,
			0,
			0,
			w,
			h,
			Color(39, 31, 0, 232) -- Background DarkOrange
		)
	end
	--
	--- Build UI =>>
	local iX = 0
	local iY = 0
	local makeButton = function(menuText, highlight1, highlight2)
		local width = wrapperWidth / amountOfButtonsWide - paddingButton * 2
		local height = wrapperHeight / amountOfButtonsTall - paddingButton * 2
		
		local posX = paddingButton * 2 + width * iX + paddingButton * iX
		local posY = 38 + height * iY + paddingButton * iY

		-- -
		local newButton = vgui.Create("DImageButton", quickSettingMenu)
		newButton:SetSize(width, height)
		newButton:SetPos(posX, posY)

		newButton.Paint = function(s, w, h)
			local backgroundColor = Color(12, 107, 196, 250) -- blue
			local textColor = Color(255, 255, 255, 250) -- white
			local borderColor = Color(12, 107, 196, 255) -- blue
			if highlight1 then borderColor = Color(245, 141, 85, 255) --[[ lightOrange ]] end
			if highlight2 then borderColor = Color(140, 156, 248, 255) --[[ lightPurple ]] end

			local padding = 2
			local borderSize = 3
			local borderRadius = 20

			if s:IsHovered() then
				backgroundColor = Color(210, 248, 140, 255)
				textColor = Color(0, 0, 0, 240)
				borderColor = Color(233, 200, 14, 255) -- orange
			end

			draw.RoundedBox(
				borderRadius + borderSize,
				0 + padding,
				0 + padding,
				w - padding * 2,
				h - padding * 2,
				borderColor
			)
			draw.RoundedBox(
				borderRadius,
				0 + borderSize + padding,
				0 + borderSize + padding,
				w - borderSize * 2 - padding * 2,
				h - borderSize * 2 - padding * 2,
				backgroundColor
			)

			local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("quickMenuButtons", menuText)
			draw.DrawText(
				menuText,
				"quickMenuButtons",
				w / 2 - extra_width_menuText / 2,
				h / 2 - extra_height_menuText / 2,
				textColor,
				TEXT_ALIGN_LEFT
			)
			
			draw.CustomCursor(s, Material("vgui/mbd_cursor_buybox", "smooth"))
		end
		--- -

		iX = iX + 1
		if iX >= amountOfButtonsWide then iX = 0 iY = iY + 1 end

		return newButton
	end

	-- Row 1
	local fastMBD = makeButton("Fast Game")
	local regularMBD = makeButton("Regular Game")
	local slowMBD = makeButton("Slow Game")
	-- Row 2
	local fastChaseMBD = makeButton("Fast Pyramid", false, true)
	local regularChaseMBD = makeButton("Reg. Pyramid", false, true)
	local slowChaseMBD = makeButton("Slow Pyramid", false, true)
	-- Row 3
	local endGameMBD = makeButton("END GAME", true)
	local startGameMBD = makeButton("START GAME", true)
	local nextWaveMBD = makeButton("NEXT WAVE", true)
	-- Row 4
	local increaseGameSpeedMBD = makeButton("SPEED+", true)
	local increaseWaveMBD = makeButton("WAVE+", true)
	local endWaveMBD = makeButton("END WAVE", true)

	local setSettings = function(id)
		net.Start("mbd_QuickSettingsSetServer")
			net.WriteString(id)
		net.SendToServer()
	end

	-- Settings:
	function regularMBD:DoClick()
		setSettings("game_0")
	end
	function fastMBD:DoClick()
		setSettings("game_1")
	end
	function slowMBD:DoClick()
		setSettings("game_2")
	end

	function regularChaseMBD:DoClick()
		setSettings("pyramid_0")
	end
	function fastChaseMBD:DoClick()
		setSettings("pyramid_1")
	end
	function slowChaseMBD:DoClick()
		setSettings("pyramid_2")
	end
	
	function endGameMBD:DoClick()
		setSettings("endGame")
	end
	function startGameMBD:DoClick()
		setSettings("startGame")
	end
	function nextWaveMBD:DoClick()
		setSettings("nextWave")
	end
	function increaseGameSpeedMBD:DoClick()
		setSettings("speed+")
	end
	function increaseWaveMBD:DoClick()
		setSettings("wave+")
	end
	function endWaveMBD:DoClick()
		setSettings("endWave")
	end
	
	quickSettingMenu:MakePopup()

	timer.Simple(0, function() addCustomCursorToParentAndChildren(quickSettingMenu, Material("vgui/mbd_cursor", "smooth")) end)
end
--
-- Create a buy menu for Vechicles (mechanic)
function createQuickMenuVechicles()
	if LocalPlayer():MBDIsNotAnAdmin(true) and LocalPlayer():GetNWInt("classname", "") != "mechanic" then
		chat.AddText(Color(0, 254, 208), "Not a Mechanic.")

		return
	end

	if quickVehicleMenu and quickVehicleMenu:IsValid() then
		quickVehicleMenu:Remove()
		quickVehicleMenu = nil
	end
	--
	local wrapperWidth 	= 834
	local wrapperHeight = 465
	local paddingButton = 26

	local amountOfButtonsWide = 2
	local amountOfButtonsTall = 2
	--
	-- -
	quickVehicleMenu = vgui.Create("DFrame")
	quickVehicleMenu:SetTitle("My Base Defence : "..MBDTextCurrentVersion.." - Vechicle Store : ( Mechanic )")
	quickVehicleMenu:SetSize(wrapperWidth, wrapperHeight)
	quickVehicleMenu:Center()
	quickVehicleMenu:SetKeyboardInputEnabled(true)
	quickVehicleMenu:SetMouseInputEnabled(true)
	quickVehicleMenu:SetAllowNonAsciiCharacters(true)
	quickVehicleMenu:SetVisible(true)
	quickVehicleMenu:ShowCloseButton(true)
	quickVehicleMenu:SetDraggable(true)
	quickVehicleMenu.Paint = function(s, w, h)
		draw.RoundedBox(7,
			0,
			0,
			w,
			h,
			Color(30, 30, 30, 232) -- Background lightBlack
		)
	end
	--
	--- Build UI =>>
	local iX = 0
	local iY = 0
	local makeButton = function(menuText, highlight1, highlight2)
		local width = wrapperWidth / amountOfButtonsWide - paddingButton * 2
		local height = wrapperHeight / amountOfButtonsTall - paddingButton * 2
		
		local posX = paddingButton * 2 + width * iX + paddingButton * iX
		local posY = 38 + height * iY + paddingButton * iY

		-- -
		local newButton = vgui.Create("DImageButton", quickVehicleMenu)
		newButton:SetSize(width, height)
		newButton:SetPos(posX, posY)

		newButton.Paint = function(s, w, h)
			local backgroundColor = Color(80, 80, 80, 250) -- gray
			local textColor = Color(255, 255, 255, 250) -- white
			local borderColor = Color(12, 107, 196, 255) -- blue
			if highlight1 then borderColor = Color(245, 141, 85, 255) --[[ lightOrange ]] end
			if highlight2 then borderColor = Color(140, 156, 248, 255) --[[ lightPurple ]] end

			local padding = 2
			local borderSize = 3
			local borderRadius = 20

			if s:IsHovered() then
				backgroundColor = Color(210, 248, 140, 255)
				textColor = Color(0, 0, 0, 240)
				borderColor = Color(233, 200, 14, 255) -- orange
			end

			draw.RoundedBox(
				borderRadius + borderSize,
				0 + padding,
				0 + padding,
				w - padding * 2,
				h - padding * 2,
				borderColor
			)
			draw.RoundedBox(
				borderRadius,
				0 + borderSize + padding,
				0 + borderSize + padding,
				w - borderSize * 2 - padding * 2,
				h - borderSize * 2 - padding * 2,
				backgroundColor
			)

			local extra_width_menuText, extra_height_menuText = getTextWidthAndHeight("quickMenuButtons", menuText)
			draw.DrawText(
				menuText,
				"quickMenuButtons",
				w / 2 - extra_width_menuText / 2,
				h - extra_height_menuText - 22,
				textColor,
				TEXT_ALIGN_LEFT
			)
			
			draw.CustomCursor(s, Material("vgui/mbd_cursor_buybox", "smooth"))
		end

		-- - - -
		-- Model of the Vehicle
		local newButtonModel = vgui.Create("DModelPanel", newButton)
		newButtonModel:SetPos(0, 0)
		newButtonModel:SetSize(width, height)
		newButtonModel:SetMouseInputEnabled(false)
		newButtonModel:SetKeyboardInputEnabled(false)
		newButtonModel:SetFOV(45)
		function newButtonModel:PreDrawModel(ent)
			ent:SetPos(Vector(0, 0, 36))
			ent:SetModelScale(0.17)
		end
		--- 

		iX = iX + 1
		if iX >= amountOfButtonsWide then iX = 0 iY = iY + 1 end

		return { newButton, newButtonModel }
	end

	-- Row 1
	local buggyMBD = makeButton("Jeep - 7000 £B.D.")
	local buggyMBDButton = buggyMBD[1] buggyMBD[2]:SetModel("models/buggy.mdl")
	local airboatMBD = makeButton("Airboat - 7000 £B.D.")
	local airboatMBDButton = airboatMBD[1] airboatMBD[2]:SetModel("models/airboat.mdl")
	-- Row 2
	local jalopyMBDButton
	if MBDCheckIfIsGameOwned("ep2") and IsMounted("ep2") then
		local jalopyMBD = makeButton("Jalopy - 8000 £B.D.")
		jalopyMBDButton = jalopyMBD[1] jalopyMBD[2]:SetModel("models/vehicle.mdl")
	end

	-- -
	local buyVehicle = function(vehicle)
		net.Start("MechanicWantsToBuyVehicle")
			net.WriteString(vehicle)
		net.SendToServer()
	end
	-- - -
	-- Try to Buy:
	function buggyMBDButton:DoClick()
		buyVehicle("Jeep")
	end
	function airboatMBDButton:DoClick()
		buyVehicle("Airboat")
	end

	if jalopyMBDButton then
		
		function jalopyMBDButton:DoClick()
			buyVehicle("Jalopy")
		end

	end
	
	quickVehicleMenu:MakePopup()

	timer.Simple(0, function() addCustomCursorToParentAndChildren(quickVehicleMenu, Material("vgui/mbd_cursor_buybox", "smooth")) end)
end
