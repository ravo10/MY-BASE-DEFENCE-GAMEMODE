--
-- CHANGING VARS.
playersConnected		= {}
playerClassesAvailable	= nil
playersClasses			= nil
--
--
--
function resetClassesVaribles()
	playerClassesAvailable	= {
		engineer 	= {
			total = 2,
			taken = 0
		},
		mechanic 	= {
			total = 1,
			taken = 0
		},
		medic 		= {
			total = 1,
			taken = 0
		},
		terminator 	= {
			total = 1,
			taken = 0
		}
	}
	playersClasses = {}
end
resetClassesVaribles()
--
----
--
function givePlayerMoneyOrBuildPoints(data)
	if data.Player then
		net.Start("GiveAPlayerBuildpointsOrMoney")
			net.WriteTable({
				Type 	= data.Type,
				Amount 	= data.Amount,
				Player	= data.Player,
				Admin	= data.Admin
			})
		net.SendToServer()
	else
		net.Start("GiveAPlayerBuildpointsOrMoney")
			net.WriteTable({
				Type 	= data.Type,
				Amount 	= data.Amount,
				Player	= false,
				Admin	= data.Admin
			})
		net.SendToServer()
	end
end
-----------------------------
-----------------------------
-------- NETWORK COM. -------

-----------------------------
--
--
-- PLAYERS CONNECTED SERVICE
local function PlayerConnectedFunc()
	playersConnected = net.ReadTable()

	local timerID = "mbd:PlayerConnected001"

	timer.Stop(timerID)
	timer.Remove(timerID)
	
	local oldLength = #playersConnected

	timer.Create(timerID, 1, 60, function()
		local lastPlayerConnected = playersConnected[#playersConnected]
		if lastPlayerConnected then
			lastPlayerConnected = lastPlayerConnected.Player
		else
			lastPlayerConnected = nil
		end

		if (
			#playersConnected > oldLength and
			lastPlayerConnected and
			lastPlayerConnected:IsValid() and
			lastPlayerConnected:IsPlayer()
		) then
			timer.Stop(timerID)
			timer.Remove(timerID)

			-- Update the Lobby -- Maybe just the admin-status have changed..
			UpdateLobbyPlayers("001", GlobalLobbyPanelRichText)

			-- Set a Info Plate Above the Player (on client side)
			playerInfoPlate(lastPlayerConnected)
		elseif (
			timer.RepsLeft(timerID) and
			timer.RepsLeft(timerID) <= 10
		) then
			timer.Stop(timerID)
			timer.Remove(timerID)

			MsgC(Color(239, 99, 0), "M.B.D. Warning: Could not get the new connected Player to show in lobby...\n")
		end

	end)
end
net.Receive("PlayerConnected", PlayerConnectedFunc)
--- -
-- Run an Interval here, to always ensure LocalPlayer can see every other Players stats
local playerInfoPlate001InfiniteID = "playerInfoPlate001Infinite"
timer.Remove(playerInfoPlate001InfiniteID)
timer.Create(playerInfoPlate001InfiniteID, 15, 0, function()
	for k,_Player in pairs(player.GetAll()) do
		playerInfoPlate(_Player)
	end
end)
--
local function PlayerDisconnectedFunc()
	playersConnected = net.ReadTable()

	local timerID = "mbd:PlayerDisconnected001"

	timer.Stop(timerID)
	timer.Remove(timerID)
	
	local oldLength = #playersConnected

	timer.Create(timerID, 1, 60, function()

		if #playersConnected > oldLength then
			timer.Stop(timerID)
			timer.Remove(timerID)

			-- Update the Lobby
			UpdateLobbyPlayers("002", GlobalLobbyPanelRichText)
		elseif (
			timer.RepsLeft(timerID) and
			timer.RepsLeft(timerID) <= 10
		) then
			timer.Stop(timerID)
			timer.Remove(timerID)

			print("M.B.D. Warning: Could not get the disconnected Player to show in lobby...")
		end

	end)
end
net.Receive("PlayerDisconnected", PlayerDisconnectedFunc)
--
---
-- THE AMOUT OF CLASSES AVAILABLE HAVE CANGED (only numbers)
net.Receive("PlayerClassAmount", function()
	local Data = net.ReadTable()
	
	-- UPDATE PLAYERS OVERVIEW..
	timer.Simple(0.15, function()
		playerClassesAvailable = Data
	end)
end)
--
--
-- First Time Player Enters The Server, After Last Disconnect
net.Receive("PlayerFirstLoad", function()
	timer.Create("mbd:FirstLoadShow001", 0.15, 0, function()
		if (
			LocalPlayer() and
			LocalPlayer().PrintMessage
		) then
			timer.Remove("mbd:FirstLoadShow001")
			
			local _T = {}
			_T["SetNWIntPlayerServerSide"] 		= -2
			_T["PlayerCountdownToSpawnRespawn"] = -1
			
			net.Start("SetNWIntPlayerServerSide")
				net.WriteTable(_T)
			net.SendToServer()
			
			timer.Create("mbd:PlayerFirstLoadSetLoadingScreen", 0.3, 0, function()
				local hookTable = hook.GetTable()

				if hookTable and hookTable["HUDPaint"]["mbd:LoadingScreenFirstTime"] then
					timer.Remove("mbd:PlayerFirstLoadSetLoadingScreen")
					--
					--- Open the Lobby
					GameIsLoadingForClientAutoSetAndClose()
					timer.Simple(GameLoadingTimeLobbyStartClient, function() openLobby() end)
					--
					--
				end
			end)

			--- -->>
			-- Set Self Player
			HOOK_HUDPaint001()
			timer.Simple(0.5, function()
				HOOK_HUDPaint002()

				timer.Simple(0.5, function()
					HOOK_onEntityCreated001()

					timer.Simple(0.5, function()
						HOOK_OnSpawnMenuOpen001()
					end)
				end)
			end)
			
			chat.AddText(Color(237, 254, 0), "WELCOME TO M.B.D.! Build your defences to survive!")

			--- -- -
			-- Set the Info. Plate Above the Players (on client side)
			for _,Player in pairs(player.GetAll()) do
				if Player and Player:IsValid() then
					playerInfoPlate(Player)
				end
			end
		end
	end)
end)
net.Receive("PlayersClassData", function()
	-- THIS WILL ONLY HAVE VALID DATA.... UPDATE PLAYERS OVERVIEW..
	playersClasses = net.ReadTable()

	local timerID = "mbd:PlayersClassData001"

	-- Check that the Player is valid before updating anything...
	timer.Stop(timerID)
	timer.Remove(timerID)
	
	timer.Create(timerID, 1, 60, function()
		if #playersClasses == 0 then
			-- --
			timer.Stop(timerID)
			timer.Remove(timerID)

			-- Update the Lobby
			UpdateLobbyPlayers("003", GlobalLobbyPanelRichText)
		end

		local lastPlayerUniqueIDConnected = playersClasses[#playersClasses]
		
		if lastPlayerUniqueIDConnected then
			lastPlayerUniqueIDConnected = lastPlayerUniqueIDConnected.UniqueID

			local lastPlayerConnected = nil
			if lastPlayerUniqueIDConnected then
				lastPlayerConnected = player.GetByUniqueID(lastPlayerUniqueIDConnected)
			end
	
			if (
				lastPlayerConnected and
				lastPlayerConnected:IsValid() and
				lastPlayerConnected:IsPlayer()
			) then
				timer.Stop(timerID)
				timer.Remove(timerID)
	
				-- Update the Lobby
				UpdateLobbyPlayers("004", GlobalLobbyPanelRichText)
			end
		end
		-- -
		if (
			timer.RepsLeft(timerID) and
			timer.RepsLeft(timerID) <= 10
		) then
			timer.Stop(timerID)
			timer.Remove(timerID)

			print("M.B.D. Warning: Could not get the new Players class data to show in lobby...")
		end

	end)
end)
--
--
---
---- OPEN the BuyBoxMenu
local buyBoxType 		= 2
local buyBoxTypeName 	= "Ammo"

local buyBoxLimitAmount = 0
local buyBoxLimitReached = false
local buyBoxLimitWaitTimeTip = ''
--
function PlayerWantsToBuySomethingFromTheBuyBox(entClass, category)
	-- Wait if the limit is reached... 10 items per. min (exclude Admins (we trust them))
	if LocalPlayer():MBDIsNotAnAdmin(true) then
		if timer.Exists(buyBoxLimitTimerID) then
			-- Notify
			notification.AddLegacy(buyBoxLimitWaitTimeTip, NOTIFY_GENERIC, 4)
		end
		if buyBoxLimitReached then return end

		buyBoxLimitAmount = (buyBoxLimitAmount + 1)
		-- SETTINGS 0 -
		if buyBoxLimitAmount == 10 then
			-- SETTINGS 1 -
			local delayTimeSeconds = 60

			buyBoxLimitReached = true
			-- Time format: https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/strftime-wcsftime-strftime-l-wcsftime-l?view=vs-2019
			buyBoxLimitWaitTimeTip = "Try again when "..math.Round(delayTimeSeconds, 2).." seconds has passed ("..os.date("%T", (os.time() + delayTimeSeconds))..")"
			
			timer.Remove(buyBoxLimitTimerID)
			timer.Create(buyBoxLimitTimerID, delayTimeSeconds, 1, function()
				-- Reset
				buyBoxLimitReached = false
				buyBoxLimitAmount = 0
			end)
		end
	end
	-- -
	if !buyBoxLimitReached then
		-- PLAYER WANTS TO BUY; MAYBE PLAYER CAN BUY =>
		---
		net.Start("PlayerWantsToBuySomething")
			net.WriteTable({
				entClass = entClass,
				category = category
			})
		net.SendToServer()
	end
end
--
PrintViewTextBuyBox = nil
local function PrintView(__table, IsAmmo)
	if !__table or #__table <= 0 then return end

	--- -
	-- Check if Active Prim. or Sec ammo name matches with something in the BuyBox
	-- and return true or false
	local checkIfAmmoNameConnectsWithAWeapon = function(IsAmmo, currItemFromBuyBoxTable)
		if IsAmmo and currItemFromBuyBoxTable and currItemFromBuyBoxTable.entClass then
			-- -- -
			-- Show the correct ammo for the Player (maybe)
			local plWeaponTable = LocalPlayer():GetActiveWeapon()
			--
			if plWeaponTable and plWeaponTable:IsValid() then
				-- -
				-- Prim.
				local PrimaryAmmoNamePlayer = LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()
				if PrimaryAmmoNamePlayer and PrimaryAmmoNamePlayer >= 0 then
					PrimaryAmmoNamePlayer = string.lower(game.GetAmmoName(PrimaryAmmoNamePlayer))
				else
					PrimaryAmmoNamePlayer = nil
				end
				--- -
				-- - Sec
				local SecondaryAmmoNamePlayer = LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType()
				if SecondaryAmmoNamePlayer and SecondaryAmmoNamePlayer >= 0 then
					SecondaryAmmoNamePlayer = string.lower(game.GetAmmoName(SecondaryAmmoNamePlayer))
				else
					SecondaryAmmoNamePlayer = nil
				end
				-- -
				-- -- -
				-- - -
				-- - - Split and try to search for it.. .
				local searchStringForMatchToClassName = function(NiceAmmoName)
					local splittedWords = string.Split(NiceAmmoName, " ")
					table.Add(splittedWords, string.Split(NiceAmmoName, "x"))

					local finishedSearchWords = {}

					for k,v in pairs(splittedWords) do
						-- - E.g.: 7.62x39mm or .380 acp for e.g. class mbd_fas2_ammo_380acp or mbd_fas2_ammo_762x39
						-- Search 0
						local batch0 = string.Split(v, ".")
						-- Join again...
						batch0 = table.concat(batch0)
						local batch1 = string.Split(batch0, "mm")
						-- Join again...
						batch1 = table.concat(batch1)

						-- Write finished String
						local finishedString = batch1

						-- Done
						table.insert(finishedSearchWords, finishedString)
					end

					-- Search all finished words... Needs matches to approve
					local amountOfMatches = 0
					for k,v in pairs(finishedSearchWords) do
						if string.match(currItemFromBuyBoxTable.entClass, v) then amountOfMatches = amountOfMatches + 1 end

						if amountOfMatches >= 2 then return true end
					end
				end
				-- -
				-- -- - Check
				if PrimaryAmmoNamePlayer and searchStringForMatchToClassName(PrimaryAmmoNamePlayer) then return true end
				if SecondaryAmmoNamePlayer and searchStringForMatchToClassName(SecondaryAmmoNamePlayer) then return true end
			end
		end

		return false
	end
	local checkIfAttachmentIsConnenctedToWeapon = function(currItemFromBuyBoxTable)
		local possibleAttachmentNames = {
			"acog",
			"c79",
			"compm4",
			"eotech",
			"foregrip",
			"harrisbipod",
			"leupold",
			"m2120mag",
			"mp5k30mag",
			"pso1",
			"sg55x30mag",
			"sks20mag",
			"sks30mag",
			"suppressor",
			"tritiumsights",
			"uziwoodenstock"
		}
		if currItemFromBuyBoxTable and currItemFromBuyBoxTable.entClass then
			local attachmentType = nil
			for _,attachmentName in pairs(possibleAttachmentNames) do
				if string.match(currItemFromBuyBoxTable.entClass, attachmentName) then attachmentType = attachmentName break end
			end
			-- - -
			if attachmentType and LocalPlayer() then
				-- Get Weapons SWEP Data..
				local currWep = LocalPlayer():GetActiveWeapon()
				if currWep and currWep:IsValid() then
					local weaponList = weapons.Get(currWep:GetClass())

					if weaponList and weaponList.Attachments then
						-- Check if the attachment found in BuyBox table matches any of
						-- the possible attachments available for the current FA:S 2 weapon..
						local possibleWepAtt = weaponList.Attachments
						for _,theAttachmentTable in pairs(possibleWepAtt) do
							-- Check the "atts" table
							if theAttachmentTable.atts then
								for __,theAttachmentName in pairs(theAttachmentTable.atts) do
									-- Maybe a match for current item in BuyBox?
									if theAttachmentName == attachmentType then return true end
								end
							end
						end
					end
				end
			end
		end

		return false
	end

	local buyBoxLimitTimerID = "buyBoxLimitAmount001"..LocalPlayer():UniqueID()
	--
	-- FILL THE VIEW...
	local nextPosX 		= -1
	local nextPosY 		= -1
	local totalAmount 	= #__table
	-- -
	-- -
	-- local shoppingCartMaterial = Material("materials/mbd_buybox/cart-sharp.png", "noclamp smooth")
	--
	local i = 0
	for k, v in pairs(__table) do

		if not table.HasValue( MBDBuyBoxCurrentlyInClientBuyBox, v.entClass ) then

			-- Store
			table.insert( MBDBuyBoxCurrentlyInClientBuyBox, v.entClass )

			local markTheBox = checkIfAmmoNameConnectsWithAWeapon(IsAmmo, v) or checkIfAttachmentIsConnenctedToWeapon(v)

			-- EVERY second time
			if ((i % 2) == 0) then
				nextPosX = 0
				nextPosY = (nextPosY + 1)
			end
			if ((i % 2) != 0) then
				nextPosX = (nextPosX + 1)
			end
			--
			-- Create BuyBox button for something
			local DButton = vgui.Create("DImageButton", viewBuyBox)
			-- -
			-- -- - SIZE / POS for the Button
			local __padding = 3
			local __height 	= 206
			local __width 	= (viewBuyBox:GetWide() / 2) - (__padding * 4)
			--
			local PosX = ((__width + __padding) * nextPosX)
			local PosY = ((__height + __padding) * nextPosY)
			--
			DButton:SetSize( __width, __height )
			DButton:SetPos( PosX, PosY )
			-- -
			local extraBorderSize = 0

			function DButton:OnDepressed() extraBorderSize = 3 end
			function DButton:OnReleased() extraBorderSize = 0 end
			-- -
			local picture = nil
			if v.picture != "" then picture = Material(v.picture, "noclamp smooth") end
			--
			DButton.Paint = function(s, w, h)
				local xPos, yPos = s:GetPos()

				local backgroundColor = Color(233, 200, 14, 250) -- yellow
				local textColor = Color(82, 122, 7, 250) -- green
				local borderColor = Color(75, 0, 130, 255) --purple

				local padding = 2
				local borderSize = 5
				local borderRadius = 14

				-- Make it more visible
				if markTheBox then
					textColor = Color(55, 130, 0, 253) -- darkGreen
					borderColor = Color(55, 130, 0, 253) -- darkGreen
					borderSize = 7
					backgroundColor = Color(247, 228, 122, 255) --lightYellow
				end

				if s:IsHovered() then
					if !markTheBox then backgroundColor = Color(246, 224, 103, 255) else backgroundColor = Color(248, 232, 140, 255) end
				end

				draw.RoundedBox(
					borderRadius + borderSize,
					0 + padding - extraBorderSize / 2,
					0 + padding - extraBorderSize / 2,
					w - padding * 2 + extraBorderSize,
					h - padding * 2 + extraBorderSize,
					borderColor
				)
				draw.RoundedBox(
					borderRadius,
					0 + borderSize + padding + extraBorderSize / 2,
					0 + borderSize + padding + extraBorderSize / 2,
					w - borderSize * 2 - padding * 2 - extraBorderSize,
					h - borderSize * 2 - padding * 2 - extraBorderSize,
					backgroundColor
				)
				-- - -
				-- - - Start pos.
				local startPointCornerText = 15
				-- Nr.
				local nr = "#"..k.." - "
				local extra_width_nr, extra_height_nr = getTextWidthAndHeight("buyboxText0", nr)

				draw.DrawText(
					nr,
					"buyboxText0",
					startPointCornerText,
					startPointCornerText,
					Color(31, 88, 31, 250),
					TEXT_ALIGN_LEFT
				)
				-- Cost
				local cost = v.price.." £B.D. "
				local cost_1 = "FREE! 0 £B.D. "
				if LocalPlayer():MBDShouldGetTheAdminBenefits() then cost = cost_1 end
				local extra_width_cost, extra_height_cost = getTextWidthAndHeight("buyboxText1", cost)
				
				draw.DrawText(
					cost,
					"buyboxText1",
					startPointCornerText + extra_width_nr,
					startPointCornerText,
					Color(75, 0, 130, 250), -- purple
					TEXT_ALIGN_LEFT
				)
				--
				local margin0 = (borderSize + padding)
				surface.SetDrawColor(30, 30, 30, 200)
				surface.DrawLine(margin0, startPointCornerText + 20, w - margin0 * 3.4, startPointCornerText + 20) -- Top line
				-- - -
				-- Name
				local name = v.name
				local typeOfFontName = "buyboxText2"
				if #name >= 18 then typeOfFontName = "buyboxText2.1" end
				if #name >= 28 then typeOfFontName = "buyboxText2.2" end
				local extra_width_name, extra_height_name = getTextWidthAndHeight(typeOfFontName, name)
				-- -
				local xPos = w / 2 - extra_width_name / 2 - __padding / 2
				local yPos = h / 2 - extra_height_name / 2 - __padding / 2 + 46

				local paddingBck = 8

				local xPosBck = margin0
				local yPosBck = yPos - paddingBck
				local widthBck = w - margin0 * 2
				local heightBck = extra_height_name + paddingBck * 2 - 3
				-- -- -
				-- -
				surface.SetDrawColor(30, 30, 30, 200)
				surface.DrawLine(xPosBck, yPosBck, widthBck + paddingBck - 1, yPosBck) -- Lines between the Nice name text
				surface.DrawLine(xPosBck, yPosBck + heightBck, widthBck + paddingBck - 1, yPosBck + heightBck) -- Lines between the Nice name text
				surface.SetDrawColor(30, 30, 30, 96)
				surface.DrawRect(
					xPosBck,
					yPosBck,
					widthBck,
					heightBck
				)
				draw.DrawText(
					name,
					typeOfFontName,
					xPos,
					yPos,
					textColor,
					TEXT_ALIGN_LEFT
				)
				-- -
				-- -- - Visual (THE IMAGE)
				local extra0 = 23
				local circleX = DButton:GetWide() - 40 - extra0
				local circleY = 40 + extra0
				local radius = 24 + extra0
				local borderWithCircle = 3

				draw.NoTexture()
				
				-- Border
				surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, 255)
				draw.Circle(circleX, circleY, (radius + borderWithCircle), (radius + borderWithCircle) * 2)
				
				-- Background
				surface.SetDrawColor(255, 255, 255, 255)
				draw.Circle(circleX, circleY, radius, radius * 2)

				if picture then
					-- Picture
					surface.SetMaterial(picture)
					draw.Circle(circleX, circleY, radius, radius * 2)
				else
					-- Letter from Name as "picture"
					surface.SetDrawColor(borderColor.r + 22, borderColor.g, borderColor.b, 255)
					draw.Circle(circleX, circleY, radius, radius * 2)

					-- Write display text
					local newNameString = ""
					local nameSplit = string.sub(name, 0)
					nameSplit = string.gsub(nameSplit, "-", " ")
					nameSplit = string.gsub(nameSplit, "[^%a%d%s]", "")
					nameSplit = string.Split(nameSplit, " ")
					table.foreach(nameSplit, function(k,v)
						local newChar = string.upper(string.sub(v, 0, 1))
						if string.gmatch(newChar, "[%a%d]") then newNameString = newNameString..newChar end
					end)

					local extra_width, extra_height = getTextWidthAndHeight("spawnMenuText001", newNameString)
					draw.DrawText(
						newNameString,
						"spawnMenuText001",
						circleX,
						circleY - (extra_height / 2),
						Color(255, 255, 255, 255),
						TEXT_ALIGN_CENTER
					)
				end

				draw.CustomCursor(s, Material("vgui/mbd_cursor_buybox", "smooth"))
			end
			-- - -
			-- Shopping cart
			--
			local img_shoppingCart = vgui.Create("DImage", DButton)
			local img_shoppingCartSize = 19
			--

			img_shoppingCart:SetSize(img_shoppingCartSize, img_shoppingCartSize)
			img_shoppingCart:SetPos(15, __height - img_shoppingCartSize - 15)

			img_shoppingCart:SetImage("materials/mbd_buybox/cart-sharp.png")

			function DButton:DoClick()
				-- Wait if the limit is reached... 10 items per. min (exclude Admins (we trust them))
				if LocalPlayer():MBDIsNotAnAdmin(true) then
					if timer.Exists(buyBoxLimitTimerID) then
						-- Notify
						notification.AddLegacy(buyBoxLimitWaitTimeTip, NOTIFY_GENERIC, 4)
					end
					if buyBoxLimitReached then return end

					buyBoxLimitAmount = (buyBoxLimitAmount + 1)
					-- SETTINGS 0 -
					if buyBoxLimitAmount == 10 then
						-- SETTINGS 1 -
						local delayTimeSeconds = 60

						buyBoxLimitReached = true
						-- Time format: https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/strftime-wcsftime-strftime-l-wcsftime-l?view=vs-2019
						buyBoxLimitWaitTimeTip = "Try again when "..math.Round(delayTimeSeconds, 2).." seconds has passed ("..os.date("%T", (os.time() + delayTimeSeconds))..")"
						
						timer.Remove(buyBoxLimitTimerID)
						timer.Create(buyBoxLimitTimerID, delayTimeSeconds, 1, function()
							-- Reset
							buyBoxLimitReached = false
							buyBoxLimitAmount = 0
						end)
					end
				end
				
				-- PLAYER WANTS TO BUY; MAYBE PLAYER CAN BUY =>
				---
				net.Start("PlayerWantsToBuySomething")
					net.WriteTable({
						entClass = v.entClass,
						category = v.category
					})
				net.SendToServer()
			end

		end
		-- - -
		-- - - -- -
		--
		i = (i + 1)
	end
end
local loadPrintView = function(playerClassString)
	if (
		!buyBoxType or
		buyBoxType == 0
	) then
		PrintView(availableThingsToBuy[playerClassString].weapons)
	elseif (buyBoxType == 1) then
		PrintView(availableThingsToBuy[playerClassString].attachments)
	elseif (buyBoxType == 2) then
		PrintView(availableThingsToBuy[playerClassString].ammo, true)
	elseif (buyBoxType == 3) then
		PrintView(availableThingsToBuy[playerClassString].other)
	end
end
local function engineerBuyBoxVIEW()
	loadPrintView("engineer")
end
local function mechanicBuyBoxVIEW()
	loadPrintView("mechanic")
end
local function medicBuyBoxVIEW()
	loadPrintView("medic")
end
local function terminatorBuyBoxVIEW()
	loadPrintView("terminator")
end
--
--
-- WRITE VIEW
local paddingTop 	= 24

local function CleanMakeView(buyBoxMenu)
	if viewBuyBox and viewBuyBox:IsValid() then viewBuyBox:Remove() end
	if fadingTransitionViewBuyBox and fadingTransitionViewBuyBox:IsValid() then fadingTransitionViewBuyBox:Remove() end
	--
	local __classInt = LocalPlayer():GetNWInt("classInt", -1)
	--
	-- -
	viewBuyBox = vgui.Create("DScrollPanel", buyBoxMenu)
	viewBuyBox:SetPos(10, paddingTop)
	viewBuyBox:SetSize(((buyBoxMenu:GetWide() / 3) * 2) - 10 * 2, (buyBoxMenu:GetTall() - paddingTop - 12))
	-- -
	surface.PlaySound("game/buybox_category_click_SoundBible_Mike_Koenig.wav")
	--
	-- THE VIEW
	MBDBuyBoxCurrentlyInClientBuyBox = {}

	if !availableThingsToBuy then MsgC(Color(255, 0, 0), "\"availableThingsToBuy\": The client table was nil... Could not write BuyBox menu...\n") return end
	if (__classInt == 0) then -- Engineer
		--
		if engineerBuyBoxVIEW then engineerBuyBoxVIEW() end
	elseif (__classInt == 1) then -- Mechanic
		--
		if mechanicBuyBoxVIEW then mechanicBuyBoxVIEW() end
	elseif (__classInt == 2) then -- Medic
		--
		if medicBuyBoxVIEW then medicBuyBoxVIEW() end
	elseif (__classInt == 3) then -- Terminator
		--
		if terminatorBuyBoxVIEW then terminatorBuyBoxVIEW() end
	else
		-- An ADMIN have not chosen a class yet.. Show everything
		if (
			LocalPlayer():MBDIsAnAdmin(true)
		) then
			if engineerBuyBoxVIEW 	then engineerBuyBoxVIEW() 	end
			if mechanicBuyBoxVIEW 	then mechanicBuyBoxVIEW() 	end
			if medicBuyBoxVIEW 		then medicBuyBoxVIEW() 		end
			if terminatorBuyBoxVIEW then terminatorBuyBoxVIEW() end
		else
			chat.AddText(Color(254, 0, 46), "Fok off :). Choose a class and play fair, rebel.")
		end
	end
	-- -
	-- - - Paint some nice transition
	-- -
	fadingTransitionViewBuyBox = vgui.Create("DLabel", buyBoxMenu)
	fadingTransitionViewBuyBox:SetText("")
	fadingTransitionViewBuyBox:SetPos(0, 0)
	fadingTransitionViewBuyBox:SetSize(viewBuyBox:GetWide(), viewBuyBox:GetTall() + 36)
	fadingTransitionViewBuyBox:DockMargin(0, 0, 0, 0)
	fadingTransitionViewBuyBox:DockPadding(0, 0, 0, 0)

	local gradientDown = Material("gui/gradient_down")
	local gradientUp = Material("gui/gradient_up")

	fadingTransitionViewBuyBox.Paint = function(s, w, h)
		surface.SetDrawColor(15, 2, 29)

		local height = 50
		local xPos = 12
		local yPos = 24

		surface.SetMaterial(gradientDown)
		surface.DrawTexturedRect(
			xPos,
			yPos,
			w - xPos * 2,
			height
		)
		surface.SetMaterial(gradientUp)
		surface.DrawTexturedRect(
			xPos,
			h - height - yPos / 2,
			w - xPos * 2 ,
			height
		)
	end

	timer.Simple(0, function() addCustomCursorToParentAndChildren(buyBoxMenu, Material("vgui/mbd_cursor_buybox", "smooth")) end)
end
--
local function BuyBoxSIDEMENU(
	buyBoxMenu,
	paddingTop,
	paddingButton
)
	local widthButton = (buyBoxMenu:GetWide() / 3) * 1
	local heightButton = 90

	local btn0Hovered = false
	local btn1Hovered = false
	local btn2Hovered = false
	local btn3Hovered = false

	local original_buyBoxTypeName = buyBoxTypeName
	local orignal_baseBackgroundColor = Color(10, 4, 0, 255) -- blackOrange
	local orignal_baseSecBackgroundColor = Color(226, 95, 0, 245) -- orange
	local orignal_baseSecBorderColor = Color(246, 104, 0, 245) -- lighterOrange

	-- Logo
	local logo = vgui.Create("DImageButton", buyBoxMenu)
	logo:SetSize(60, 60)
	logo:SetPos(buyBoxMenu:GetWide() - 47, buyBoxMenu:GetTall() - 47)
	logo.Paint = function(s, w, h)
		local circleXLogo = w / 2
		local circleYLogo = h / 2
		local radiusLogo = w / 6

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("materials/mbd_buybox/mybasedefence_basic.png", "smooth"))
		draw.Circle(circleXLogo, circleYLogo, radiusLogo, radiusLogo * 2)
	end

	-- -
	-- - Paint text for button
	local paintButtonText = function(panel, text, w, h, borderSize, padding, shadowColor)
		local extra_width, extra_height = getTextWidthAndHeight("buyboxText3", text)
		---
		local shadowSize = 1
		draw.DrawText(
			text,
			"buyboxText3",
			w / 2 + borderSize / 2 - padding / 2 - extra_width / 2,
			(h + borderSize) / 2 - extra_height / 2 + shadowSize,
			shadowColor,
			TEXT_ALIGN_LEFT
		)
		draw.DrawText(
			text,
			"buyboxText3",
			w / 2 + borderSize / 2 - padding / 2 - extra_width / 2,
			(h + borderSize) / 2 - extra_height / 2,
			Color(0, 0, 0, 255),
			TEXT_ALIGN_LEFT
		)
	end
	--
	local weaponBtn = vgui.Create("DImageButton", buyBoxMenu)
	weaponBtn:SetSize(widthButton - (paddingButton * 2), heightButton)
	weaponBtn:SetPos(buyBoxMenu:GetWide() - widthButton + paddingButton / 2, paddingTop)
	weaponBtn.Paint = function(s, w, h)
		local xPos, yPos = s:GetPos()

		local borderColor = Color(196, 193, 12, 255) -- Yellow
		local backgroundColor = orignal_baseBackgroundColor
		if s:IsHovered() then
			backgroundColor = orignal_baseSecBackgroundColor
			borderColor = orignal_baseSecBorderColor
			
			btn0Hovered = true
			buyBoxTypeName = "Weapons"
		else
			btn0Hovered = false
		end

		local padding = 2
		local borderSize = 5
		local borderRadius = 40
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
		-- -
		paintButtonText(s, "Weapons", w, h, borderSize, padding, borderColor)
	end
	function weaponBtn:DoClick()
		buyBoxType 		= 0
		buyBoxTypeName 	= "Weapons"
		original_buyBoxTypeName = buyBoxTypeName
		CleanMakeView(buyBoxMenu)
	end
	--
	local attachmentBtn = vgui.Create("DImageButton", buyBoxMenu)
	attachmentBtn:SetSize(widthButton - (paddingButton * 2), heightButton)
	attachmentBtn:SetPos(buyBoxMenu:GetWide() - widthButton + paddingButton / 2, (paddingTop + paddingButton + heightButton))
	attachmentBtn.Paint = function(s, w, h)
		local xPos, yPos = s:GetPos()

		local borderColor = Color(12, 107, 196, 255) -- blue
		local backgroundColor = orignal_baseBackgroundColor
		if s:IsHovered() then
			backgroundColor = orignal_baseSecBackgroundColor
			borderColor = orignal_baseSecBorderColor
			
			btn1Hovered = true
			buyBoxTypeName = "Attachments"
		else
			btn1Hovered = false
		end

		local padding = 2
		local borderSize = 5
		local borderRadius = 40
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
		-- -
		paintButtonText(s, "Attachments", w, h, borderSize, padding, borderColor)
	end
	function attachmentBtn:DoClick()
		buyBoxType 		= 1
		buyBoxTypeName 	= "Attachments"
		original_buyBoxTypeName = buyBoxTypeName
		CleanMakeView(buyBoxMenu)
	end
	--
	local ammoBtn = vgui.Create("DImageButton", buyBoxMenu)
	ammoBtn:SetSize(widthButton - (paddingButton * 2), heightButton)
	ammoBtn:SetPos(buyBoxMenu:GetWide() - widthButton + paddingButton / 2, (paddingTop + (paddingButton * 2) + (heightButton * 2)))
	ammoBtn.Paint = function(s, w, h)
		local xPos, yPos = s:GetPos()

		local borderColor = Color(196, 12, 15, 255) -- red
		local backgroundColor = orignal_baseBackgroundColor
		if s:IsHovered() then
			backgroundColor = orignal_baseSecBackgroundColor
			borderColor = orignal_baseSecBorderColor
			
			btn2Hovered = true
			buyBoxTypeName = "Ammo"
		else
			btn2Hovered = false
		end

		local padding = 2
		local borderSize = 5
		local borderRadius = 40
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
		-- -
		paintButtonText(s, "Ammo", w, h, borderSize, padding, borderColor)
	end
	function ammoBtn:DoClick()
		buyBoxType 		= 2
		buyBoxTypeName 	= "Ammo"
		original_buyBoxTypeName = buyBoxTypeName
		CleanMakeView(buyBoxMenu)
	end
	--
	local otherBtn = vgui.Create("DImageButton", buyBoxMenu)
	otherBtn:SetSize(widthButton - (paddingButton * 2), heightButton)
	otherBtn:SetPos(buyBoxMenu:GetWide() - widthButton + paddingButton / 2, (paddingTop + paddingButton * 3 + heightButton * 3))
	otherBtn.Paint = function(s, w, h)
		local xPos, yPos = s:GetPos()

		local borderColor = Color(10, 159, 82, 255) -- green
		local backgroundColor = orignal_baseBackgroundColor
		if s:IsHovered() then
			backgroundColor = orignal_baseSecBackgroundColor
			borderColor = orignal_baseSecBorderColor
			
			btn3Hovered = true
			buyBoxTypeName = "Other"
		else
			btn3Hovered = false
		end

		local padding = 2
		local borderSize = 5
		local borderRadius = 40
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
		-- -
		paintButtonText(s, "Other", w, h, borderSize, padding, borderColor)

		-- Reset the type to the original
		if (
			!btn0Hovered and
			!btn1Hovered and
			!btn2Hovered and
			!btn3Hovered
		) then buyBoxTypeName = original_buyBoxTypeName end
	end
	function otherBtn:DoClick()
		buyBoxType 		= 3
		buyBoxTypeName 	= "Other"
		original_buyBoxTypeName = buyBoxTypeName
		CleanMakeView(buyBoxMenu)
	end
end
--
net.Receive("OpenBuyBoxMenu", function()
	if (LocalPlayer()) then
		--
		local wrapperWidth 	= 500
		local wrapperHeight = 355
		local paddingButton = 10
		--
		--
		--
		local wrapperWidth 	= 834
		local wrapperHeight = 465
		local paddingButton = 10
		--
		-- -
		buyBoxMenu = vgui.Create("DFrame")
		buyBoxMenu:SetTitle("My Base Defence : "..MBDTextCurrentVersion.." - BuyBox Station")
		buyBoxMenu:SetSize(wrapperWidth, wrapperHeight)
		buyBoxMenu:Center()
		buyBoxMenu:SetKeyboardInputEnabled(true)
		buyBoxMenu:SetMouseInputEnabled(true)
		buyBoxMenu:SetAllowNonAsciiCharacters(true)
		buyBoxMenu:SetVisible(true)
		buyBoxMenu:ShowCloseButton(true)
		buyBoxMenu:SetDraggable(false)
		buyBoxMenu.Paint = function(s, w, h)
			draw.RoundedBox(7,
				0,
				0,
				w,
				h,
				Color(15, 2, 29, 210) -- Background darkPurpleBlack
			)
			-- Category
			local extra_width, extra_height = getTextWidthAndHeight("buyboxText2", buyBoxTypeName)
			-- -
			draw.DrawText(
				buyBoxTypeName,
				"buyboxText2",
				wrapperWidth - extra_width - 10,
				30,
				Color(110, 187, 0, 230),
				TEXT_ALIGN_LEFT
			)
		end
		--
		--- Build UI =>>
		BuyBoxSIDEMENU(buyBoxMenu, paddingTop * 2.5, paddingButton, viewBuyBox)
		CleanMakeView(buyBoxMenu)

		buyBoxMenu:MakePopup()

		timer.Simple(0, function() addCustomCursorToParentAndChildren(buyBoxMenu, Material("vgui/mbd_cursor_buybox", "smooth")) end)
	end
end)
net.Receive("CloseBuyBoxMenu", function()
	if (
		LocalPlayer() and
		buyBoxMenu and
		buyBoxMenu.Close
	) then
		buyBoxMenu:Close()
	end
end)
--
--
-- ON START LOAD AVAILABLE STUFF TO BUY
net.Receive("PlayerGetAvailableThingsToBuy", function()
	--
	availableThingsToBuy = net.ReadTable()
end)
--
--
-- ....................... --

-------- NETWORK COM. -------
-----------------------------
-- ....................... --
--
--

-----------------------------
-----------------------------
--- STANDALONE CALLED HOOKS -

-----------------------------

--
-- ....................... --

--- STANDALONE CALLED HOOKS -
-----------------------------
-- ....................... --
--
