include( "spawnmenu/spawnmenu.lua" )
local strictSetting = 1
if GetConVar("mbd_enableStrictMode"):GetInt() then
	strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()

	MsgC(Color(0, 211, 15), "Successfully got the MBD StrictSetting for Clientside Spawnmenu.: ", strictSetting, "\n")
end

--[[---------------------------------------------------------
	If false is returned then the spawn menu is never created.
	This saves load times if your mod doesn't actually use the
	spawn menu for any reason.
-----------------------------------------------------------]]
function GM:SpawnMenuEnabled()
	return true
end

--[[---------------------------------------------------------
	Called when spawnmenu is trying to be opened.
	Return false to dissallow it.
-----------------------------------------------------------]]
function GM:SpawnMenuOpen()

	-- GAMEMODE:SuppressHint( "OpeningMenu" )
	--GAMEMODE:AddHint( "OpeningContext", 20 )

	cleanup.UpdateUI()

	return true

end

--[[---------------------------------------------------------
	Called when context menu is trying to be opened.
	Return false to dissallow it.
-----------------------------------------------------------]]
function GM:ContextMenuOpen()

	-- GAMEMODE:SuppressHint( "OpeningContext" )
	--GAMEMODE:AddHint( "ContextClick", 20 )

	return true

end

--[[---------------------------------------------------------
	Backwards compatibility. Do Not Use!!!
-----------------------------------------------------------]]
function GM:GetSpawnmenuTools( name )
	return spawnmenu.GetToolMenu( name )
end

--[[---------------------------------------------------------
	Backwards compatibility. Do Not Use!!!
-----------------------------------------------------------]]
function GM:AddSTOOL( category, itemname, text, command, controls, cpanelfunction )
	self:AddToolmenuOption( "Main", category, itemname, text, command, controls, cpanelfunction )
end

--[[---------------------------------------------------------
	Don't hook or override this function.
	Hook AddToolMenuTabs instead!
-----------------------------------------------------------]]
function GM:AddGamemodeToolMenuTabs()

	-- This is named like this to force it to be the first tab
	spawnmenu.AddToolTab( "Main",		"#spawnmenu.tools_tab", "icon16/wrench.png" )
	if (strictSetting == 0) then spawnmenu.AddToolTab( "Utilities",	"#spawnmenu.utilities_tab", "icon16/page_white_wrench.png" ) end

end

--[[---------------------------------------------------------
	Add your custom tabs here.
-----------------------------------------------------------]]
function GM:AddToolMenuTabs()

	-- Hook me!

end

--[[---------------------------------------------------------
	Add categories to your tabs
-----------------------------------------------------------]]
function GM:AddGamemodeToolMenuCategories()

	spawnmenu.AddToolCategory( "Main", "Constraints",	"#spawnmenu.tools.constraints" )
	spawnmenu.AddToolCategory( "Main", "Construction",	"#spawnmenu.tools.construction" )
	if (strictSetting == 0) then spawnmenu.AddToolCategory( "Main", "Poser",			"#spawnmenu.tools.posing" ) end
	spawnmenu.AddToolCategory( "Main", "Render",		"#spawnmenu.tools.render" )

end

--[[---------------------------------------------------------
	Add categories to your tabs
-----------------------------------------------------------]]
function GM:AddToolMenuCategories()

	-- Hook this function to add custom stuff

end

--[[---------------------------------------------------------
	Add categories to your tabs
-----------------------------------------------------------]]
MBDResetClSpawnmenuIconSize = true

local lsvProp = function(index, to, table, difference)
	local newValue

	local timeResult = SysTime() - difference
	newValue = MBDLerp(timeResult, table[index], to)
	table[index] = newValue

	return newValue
end
local iconCount = 0
function GM:PopulatePropMenu()
	if strictSetting == 1 then -- Custom View For Props
		spawnmenu.AddContentType( "model", function( container, obj )
			iconCount = iconCount + 1
			local icon = vgui.Create( "SpawnIcon", container )

			local thisCurrCount = iconCount
			local propRGBColorDifference = RealTime()
			local baseSpeedRGBColor = 0.003
			local propRGBColorAnimationSpeed = baseSpeedRGBColor

			local propIconSizeDifference = RealTime()
			local propIconSizeDifferenceSpeed = 0.1
			local iconSizeBase = 140
			local iconTall = iconSizeBase
			local iconWide = iconSizeBase

			-- Customm MBD
			icon:SetTall(iconTall)
			icon:SetWide(iconWide)

			-- M.B.D. :: This is for calculating price!! Works for most props, if not all....
			local PriceForEnt 	= GetDynamicPriceForThisProp(nil, obj.model)
			local HealthForEnt 	= GetDynamicHealthForThisProp(nil, obj.model).Health
			
			if !PriceForEnt 	then PriceForEnt = "N/A" end
			if !HealthForEnt 	then HealthForEnt = "N/A" else HealthForEnt = math.Round(HealthForEnt, 0) end

			if ( obj.body ) then
				obj.body = string.Trim( tostring(obj.body), "B" )
			end

			icon:InvalidateLayout( true )

			icon:SetModel( obj.model, obj.skin or 0, obj.body )

			-- --
			-- Show The Price, Health and Model (ToolTip)
			local name 	= string.Split(obj.model, "/")
			name 		= string.Replace(name[#name], ".mdl", "")
			name		= string.Split(name, "0")

			local newName = {}
			for k,v in pairs(name) do
				v = string.gsub(v, [[%d]], [[]])

				if #v == 1 then v = "" elseif string.match(v, [[%d]]) then
					if string.match(v, [[_]]) then
						-- Remove numbers...
						local nV = string.Split(v, "")

						local nV2 = {}
						for l,w in pairs(nV) do
							--
							-- 1
							nV = string.Replace(nV, "_", " ")
							-- 2
							if tonumber(w) then w = "" end
							-- 3
							if #w > 1 then table.insert( nV2, w ) end
						end

						nV = table.concat(nV2, "")

						v = nV
					else v = "" end
				end

				table.insert(newName, v)
			end

			local newName2 = {}
			local newName3 = {}
			for k,v in pairs(newName) do
				-- 1
				v = string.Replace(v, "_", " ")
				
				local nV = string.Split(v, " ")
				-- 2
				local nV2 = ""
				for l,w in pairs(nV) do
					--
					-- 1
					if tonumber(w) then w = "" end
					-- 2
					if #w > 1 then
						local firstLetter = string.upper(string.Split(w, "")[1])

						nV2 = string.Split(w, "")
						nV2[1] = ""
						nV2 = table.concat(nV2, "")

						nV2 = firstLetter..nV2
					end
				end

				table.insert(newName2, nV2)

				if k == #newName then
					newName3 = table.concat(newName2, "")
				end
			end

			-- Finally, add spaces between big letters >> > >
			local newName4 = string.Split(newName3, "")
			local newName5 = {}
			for k,v in pairs(newName4) do
				-- Find tha big laattars
				-- -
				if string.match(v, [[%u]]) then
					-- Add some spacee
					v = " "..v
				end

				table.insert(newName5, v)
			end
			local newName6 = table.concat(newName5, "")

			-- Just remove the first space ...
			local t = string.Split(newName6, "")
			table.remove(t, 1)

			newName6 = table.concat(t, "")
			-- --- --
			-- DONE Nicsesst Good (Boii aka a nice Dog) Namee
			local NiceName = newName6

			local heightBox = 37

			local currRGBProp = { 0, 0, 0 } -- black
			local currRGBPropTextColor = { 255, 255, 255 } -- white

			-- TOP
			local defaultTopTextXPos = function( xPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
				return (widthBox / 2 - width0 / 2) - (iconWide - iconSizeBase)
			end
			local defaultTopTextYPos = function( yPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
				return (yPos + padding) - (iconTall - iconSizeBase) - padding * 2
			end
			-- BOTTOM
			local defaultBottomTextXPos = function( xPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
				return iconWide - width1 + padding * 18
			end
			local defaultBottomTextYPos = function( yPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
				return (yPos + height0 + heightBox / 4) - (iconTall - iconSizeBase)
			end

			local topTextXPos
			local topTextYPos
			
			local bottomTextXPos
			local bottomTextYPos

			local text0 = NiceName
			local text1 = PriceForEnt.." B.P. (" ..HealthForEnt.. " HP)"
			local text1_1 = "FREE! 0 B.P. (" ..HealthForEnt.. " HP)"
			if LocalPlayer():MBDShouldGetTheAdminBenefits() then text1 = text1_1 end

			local padding = 1

			local width0, height0 = getTextWidthAndHeight("spawnMenuText001", text0)
			local width1, height1 = getTextWidthAndHeight("spawnMenuText002", text1)

			local iconOriginalPosX, iconOriginalPosY

			function icon:PaintOver(width, height)
				local widthBox = width

				local yPos = height - heightBox / 2
				local xPos = 0

				surface.SetDrawColor( 202, 229, 255, 130) -- lightBlue Base: rgb(202,229,255) lightGreen/mint: 11, 242, 178, 130
				surface.DrawRect(xPos, yPos, widthBox, heightBox)

				if MBDResetClSpawnmenuIconSize then

					iconTall = iconSizeBase
					iconWide = iconSizeBase

				end

				-- Init.
				if MBDResetClSpawnmenuIconSize or ( not topTextXPos and not topTextYPos and not bottomTextXPos and not bottomTextYPos ) then
					topTextXPos = defaultTopTextXPos( xPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
					topTextYPos = defaultTopTextYPos( yPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
					
					bottomTextXPos = defaultBottomTextXPos( xPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
					bottomTextYPos = defaultBottomTextYPos( yPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
				end

				draw.DrawText(
					text0,
					"spawnMenuText001",
					topTextXPos,
					topTextYPos,
					Color(currRGBPropTextColor[1], currRGBPropTextColor[2], currRGBPropTextColor[3], 245),
					TEXT_ALIGN_LEFT
				)
				draw.DrawText(
					text1,
					"spawnMenuText002",
					bottomTextXPos,
					bottomTextYPos,
					Color(78, 78, 78, 245),
					TEXT_ALIGN_LEFT
				)

				if RealTime() - propIconSizeDifference > propIconSizeDifferenceSpeed then propIconSizeDifference = RealTime() end

				local borderColor0
				propRGBColorAnimationSpeed = baseSpeedRGBColor

				local timeResultIconSize = RealTime() - propIconSizeDifference

				if icon:IsHovered() then
					if not iconOriginalPosX and not iconOriginalPosY then iconOriginalPosX, iconOriginalPosY = icon:GetPos() end

					lsvProp(1, 233, currRGBProp, propRGBColorDifference)
					lsvProp(2, 200, currRGBProp, propRGBColorDifference)
					lsvProp(3, 14, currRGBProp, propRGBColorDifference) -- Orange

					lsvProp(1, 233, currRGBPropTextColor, propRGBColorDifference)
					lsvProp(2, 200, currRGBPropTextColor, propRGBColorDifference)
					lsvProp(3, 14, currRGBPropTextColor, propRGBColorDifference) -- Orange

					propRGBColorAnimationSpeed = 0.3

					local newIconTall = MBDLerp(timeResultIconSize, iconTall, 167)
					local newIconWide = MBDLerp(timeResultIconSize, iconWide, 167)
					iconTall = newIconTall
					iconWide = newIconWide

					heightBox = 37 * 1.5
					
					topTextXPos = padding * 4
				else
					if not iconOriginalPosX and not iconOriginalPosY then iconOriginalPosX, iconOriginalPosY = icon:GetPos() end

					-- Normal
					lsvProp(1, 202, currRGBProp, propRGBColorDifference)
					lsvProp(2, 229, currRGBProp, propRGBColorDifference)
					lsvProp(3, 255, currRGBProp, propRGBColorDifference)
					
					lsvProp(1, 78, currRGBPropTextColor, propRGBColorDifference)
					lsvProp(2, 78, currRGBPropTextColor, propRGBColorDifference)
					lsvProp(3, 78, currRGBPropTextColor, propRGBColorDifference)

					-- Higher is faster
					propRGBColorAnimationSpeed = 0.5

					local newIconTall = MBDLerp(timeResultIconSize, iconTall, iconSizeBase)
					local newIconWide = MBDLerp(timeResultIconSize, iconWide, iconSizeBase)
					iconTall = newIconTall
					iconWide = newIconWide

					heightBox = 37

					topTextXPos = defaultTopTextXPos( xPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
					topTextYPos = defaultTopTextYPos( yPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
					
					bottomTextXPos = defaultBottomTextXPos( xPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
					bottomTextYPos = defaultBottomTextYPos( yPos, iconWide, iconTall, width0, height0, width1, height1, widthBox, padding )
				end
				borderColor0 = Color(currRGBProp[1], currRGBProp[2], currRGBProp[3], 230)
				
				local differanseWide = iconWide - iconSizeBase
				local differanseTall = iconTall - iconSizeBase
				icon:SetPos( iconOriginalPosX - differanseWide / 2, iconOriginalPosY - differanseTall / 2 )

				icon:SetTall(iconTall)
				icon:SetWide(iconWide)

				surface.SetDrawColor(borderColor0.r, borderColor0.g, borderColor0.b, borderColor0.a)
				surface.DrawOutlinedRect(0, 0, width - 1, height - 1)
				
				surface.SetDrawColor(0, 0, 0, 230)
				surface.DrawOutlinedRect(0, 0, width, height)

				if SysTime() - propRGBColorDifference > propRGBColorAnimationSpeed then propRGBColorDifference = SysTime() end

				return false
			end

			icon.DoClick = function( s ) -- Left Click
				RunConsoleCommand(
					"gm_spawn",
					s:GetModelName(),
					s:GetSkinID() or 0,
					s:GetBodyGroup() or ""
				)
			end

			icon.OpenMenu = function( icon ) -- Right Click
				-- Lightly MODDED (only need this/these) > >> >
				-- -- --
				local menu = DermaMenu()
				menu:AddOption("#spawnmenu.menu.copy", function()
					SetClipboardText(
						string.gsub( obj.model, "\\", "/" )
					) end
				):SetIcon("icon16/page_copy.png")

				menu:Open()
			end

			icon:InvalidateLayout( true )

			if ( IsValid( container ) ) then
				container:Add( icon )
			end

			return icon

		end )
	end

	--spawnmenu.PopulateFromEngineTextFiles()
end