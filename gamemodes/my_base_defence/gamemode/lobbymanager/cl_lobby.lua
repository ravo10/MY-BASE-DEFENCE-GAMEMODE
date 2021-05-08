--
---
----  - -  -=>>>> LOBBY STUFF
-----
----
---
--
-- VARS.
local frame 					= nil
local lobbyOverview 			= nil
local lobbyIsOpen				= false
--- -
--
--
-- LOBBY-VALUES
local margin = 20
local hogdePluss = 35

local gradientDown = Material("gui/gradient_down")
local gradientUp = Material("gui/gradient_up")
--
function openLobby()
	if lobbyIsOpen then return end
	lobbyIsOpen = true
	---
	--
	container = vgui.Create("DFrame")
	timer.Create("mbd:HOOK_HUDPAINT003_001", 0.3, 0, function()
		if (
			container and
			container:IsValid()
		) then
			timer.Remove("mbd:HOOK_HUDPAINT003_001")

			GlobalLobbyPanelRichText = HOOK_HUDPaint003(
				margin,
				hogdePluss,
				class0Btn,
				class1Btn,
				class2Btn,
				class3Btn
			) -- Returns A RichText Panel For Writing Lobby InfoData...
			
			timer.Create("mbd:HOOK_HUDPAINT003_002", 0.35, 0, function()
				if (
					GlobalLobbyPanelRichText and
					GlobalLobbyPanelRichText:IsValid()
				) then
					timer.Remove("mbd:HOOK_HUDPAINT003_002")

					--
					--- Write Players
					WritePlayersLobby(GlobalLobbyPanelRichText)
				end
			end)
		end
	end)
	--
	-- -
	--
	-- LEAVE/DISCONNECT
	local leaveBtn = vgui.Create("DImageButton", container)
	leaveBtn:SetSize(150, 45)
	leaveBtn:SetPos(10, ScrH() - 55)
	leaveBtn:SetConsoleCommand("disconnect")
	leaveBtn.Paint = function(s, w, h)
		local xPos, yPos = s:GetPos()

		local backgroundColor = Color(30, 144, 255, 255) -- dodgerblue
		if s:IsHovered() then backgroundColor = Color(4, 131, 255, 255) end

		local padding = 2
		local borderSize = 3
		local borderRadius = 3
		draw.RoundedBox(
			borderRadius,
			0 + padding,
			0 + padding,
			w - padding * 2,
			h - padding * 2,
			Color(0, 0, 0, 255) -- black
		)
		draw.RoundedBox(
			borderRadius,
			0 + borderSize + padding,
			0 + borderSize + padding,
			w - borderSize * 2 - padding * 2,
			h - borderSize * 2 - padding * 2,
			backgroundColor
		)
		local height = h - 10
		surface.SetDrawColor(255, 255, 255, 34)
		surface.SetMaterial(gradientDown)
		surface.DrawTexturedRect(
			borderRadius + padding,
			borderRadius + padding,
			w - borderRadius * 2 - padding * 2,
			height
		)
		draw.DrawText(
			"LEAVE SERVER",
			"Default",
			(w - borderSize * 2 - padding * 2) / 2 - 10,
			(h - borderSize * 2 - padding * 2) / 2 - 10,
			Color(255, 255, 255, 245),
			TEXT_ALIGN_LEFT
		)
	end
	--
	--
	-- RECONNECT
	local closeBtn = nil

	local createAdminBtn = function()
		--
		---
		adminBtn = vgui.Create("DImageButton", container)
		adminBtn:SetSize(150, 45)
		adminBtn:SetPos(((150 * 2) + 10 + (5 * 2)), ScrH() - 55)

		local i = 1
		local animBackground = function() if i < 12 * 5 then i = i + 1 else i = nil end end
		adminBtn:SetCursor("blank")
		adminBtn.Paint = function(s, w, h)
			local xPos, yPos = s:GetPos()

			local backgroundColor = Color(255, 235, 30, 255) -- yellow
			if s:IsHovered() then backgroundColor = Color(163, 255, 30, 255) --[[ green ]] end

			if i then
				if i % 4 == 0 then
					backgroundColor = Color(30, 144, 255, 255) --[[ dodgerblue ]]
				else
					backgroundColor = Color(255, 235, 30, 255) --[[ yellow ]]
				end animBackground()
			end

			local padding = 2
			local borderSize = 3
			local borderRadius = 3
			draw.RoundedBox(
				borderRadius,
				0 + padding,
				0 + padding,
				w - padding * 2,
				h - padding * 2,
				Color(0, 0, 0, 255) -- black
			)
			draw.RoundedBox(
				borderRadius,
				0 + borderSize + padding,
				0 + borderSize + padding,
				w - borderSize * 2 - padding * 2,
				h - borderSize * 2 - padding * 2,
				backgroundColor
			)
			local height = h - 10
			surface.SetDrawColor(255, 255, 255, 44)
			surface.SetMaterial(gradientDown)
			surface.DrawTexturedRect(
				borderRadius + padding,
				borderRadius + padding,
				w - borderRadius * 2 - padding * 2,
				height
			)
			draw.DrawText(
				"ADMIN SETTINGS",
				"Default",
				(w - borderSize * 2 - padding * 2) / 2 - 20,
				(h - borderSize * 2 - padding * 2) / 2 - 10,
				Color(0, 0, 0, 245),
				TEXT_ALIGN_LEFT
			)

			draw.CustomCursor(s)
		end
		function adminBtn:DoClick()
			-- Show Admin panel
			showAdminPanel()
		end
	end
	local createCloseBtn = function()
		-- Create one
		closeBtn = vgui.Create("DImageButton", container)
		closeBtn:SetSize(150, 45)
		closeBtn:SetPos(ScrW() - 150 * 3 + 120, ScrH() - 55)
		closeBtn:SetCursor("blank")
		closeBtn.Paint = function(s, w, h)
			local xPos, yPos = s:GetPos()

			local backgroundColor = Color(81, 169, 255, 255) -- dodgerblueLight
			if s:IsHovered() then backgroundColor = Color(236, 22, 59, 255) end

			local padding = 2
			local borderSize = 3
			local borderRadius = 3
			draw.RoundedBox(
				borderRadius,
				0 + padding,
				0 + padding,
				w - padding * 2,
				h - padding * 2,
				Color(0, 0, 0, 255) -- black
			)
			draw.RoundedBox(
				borderRadius,
				0 + borderSize + padding,
				0 + borderSize + padding,
				w - borderSize * 2 - padding * 2,
				h - borderSize * 2 - padding * 2,
				backgroundColor
			)
			local height = h - 10
			surface.SetDrawColor(255, 255, 255, 28)
			surface.SetMaterial(gradientDown)
			surface.DrawTexturedRect(
				borderRadius + padding,
				borderRadius + padding,
				w - borderRadius * 2 - padding * 2,
				height
			)
			draw.DrawText(
				"CLOSE",
				"Default",
				(w - borderSize * 2 - padding * 2) / 2 + 35,
				(h - borderSize * 2 - padding * 2) / 2 - 10,
				Color(255, 255, 255, 245),
				TEXT_ALIGN_LEFT
			)
		end
		function closeBtn:DoClick()
			closeLobby()
		end
	end
	-- --
	-- Commands/Help Panel
	-- Create one
	local CommandsHelpBtn = vgui.Create("DImageButton", container)
	CommandsHelpBtn:SetSize(150, 45)
	CommandsHelpBtn:SetPos(((150 * 3) + 10 + (5 * 3)), ScrH() - 55)
	CommandsHelpBtn.Paint = function(s, w, h)
		local xPos, yPos = s:GetPos()

		local backgroundColor = Color(30, 144, 255, 255) -- dodgerblue
		if s:IsHovered() then backgroundColor = Color(4, 131, 255, 255) end

		local padding = 2
		local borderSize = 3
		local borderRadius = 3
		draw.RoundedBox(
			borderRadius,
			0 + padding,
			0 + padding,
			w - padding * 2,
			h - padding * 2,
			Color(0, 0, 0, 255) -- black
		)
		draw.RoundedBox(
			borderRadius,
			0 + borderSize + padding,
			0 + borderSize + padding,
			w - borderSize * 2 - padding * 2,
			h - borderSize * 2 - padding * 2,
			backgroundColor
		)
		local height = h - 10
		surface.SetDrawColor(255, 255, 255, 34)
		surface.SetMaterial(gradientDown)
		surface.DrawTexturedRect(
			borderRadius + padding,
			borderRadius + padding,
			w - borderRadius * 2 - padding * 2,
			height
		)
		draw.DrawText(
			"COMMANDS/HELP",
			"Default",
			(w - borderSize * 2 - padding * 2) / 2 - 25,
			(h - borderSize * 2 - padding * 2) / 2 - 10,
			Color(255, 255, 255, 245),
			TEXT_ALIGN_LEFT
		)
	end
	function CommandsHelpBtn:DoClick()
		createCommandsHelpPanel()
	end
	-- --
	-- CLOSE and ADMIN PANEL BUTTON
	timer.Create("mbd:ClosePanelButton001", 0.6, 0, function()
		-- Only show the Admin button when the Client is an Admin
		if (
			LocalPlayer() and
			LocalPlayer():IsValid() and
			LocalPlayer():MBDIsAnAdmin(true) and
			container and container:IsValid()
		) then
			-- Create admin button
			if !adminBtn or ( adminBtn and !adminBtn:IsValid() ) then
				createAdminBtn()
			end
		else
			if adminBtn then adminBtn:Remove() adminBtn = nil end
		end

		--
		--- - Only show the button when the game has started, or the Client is an Admin
		-- AND never show if game has started and Player have to spawn with "respawn" button (or else Player won't respawn properly)
		if (
			(
				LocalPlayer() and
				LocalPlayer():IsValid() and
				container and container:IsValid() and
				(
					(
						(
							LocalPlayer():MBDIsAnAdmin(true) and
							!gameStarted and
							!repsLeftRespawnCountdown and
							!theSpawnButtonIsComplete
						)
					) or (
						gameStarted
					) or (
						LocalPlayer():GetNWInt("classInt", -1) != -1 and (
							(
								LocalPlayer():MBDIsAnAdmin(true) and
								!gameStarted and
								!LocalPlayer():GetNWBool("isSpectating", false)
							) or (
								gameStarted and
								!LocalPlayer():GetNWBool("isSpectating", false)
							)
						) and !repsLeftRespawnCountdown and !theSpawnButtonIsComplete
					)
				)
			)
		) then
			if !closeBtn or ( closeBtn and !closeBtn:IsValid() ) then
				createCloseBtn()
			end
		else
			if closeBtn then closeBtn:Remove() closeBtn = nil end
		end
	end)
end
function closeLobby()
	if (
		!gameStarted and
		LocalPlayer() and
		LocalPlayer():MBDIsNotAnAdmin(true)
	) then return false elseif !LocalPlayer() then return false end
	
	if (!container or !container.Close) then return false end

	lobbyIsOpen = false
	container:Close()
end
net.Receive("OpenLobby", openLobby)
net.Receive("CloseLobby", closeLobby)
-- --
--
local function LobbyCounter()
	startGameTimerLeft = net.ReadInt(9)
	--
	if (startGameTimerLeft == -5) then
		if !container then return false end
		containerIncomingMessage = "No Players On Server... Waiting for atleast one Player..." -- No one will see this message, but it is there
		
		return
	end
	if (!container or !LocalPlayer() or !LocalPlayer().Name) then return false end
	if (startGameTimerLeft == -3) then
		containerIncomingMessage = " ( "..LocalPlayer():Name().." )....PAUSED BY ADMIN"
	elseif (startGameTimerLeft == -4) then
		containerIncomingMessage = " ( "..LocalPlayer():Name().." )....*An Admin needs to set the game up... Waiting for that... Spawn atleast one NPC Spawner and one BuyBox."
	else
		local sOrNot = ""
		if startGameTimerLeft != 1 then sOrNot = "s" end
		containerIncomingMessage = " ( "..LocalPlayer():Name().." )....Starting in -"..startGameTimerLeft.." second"..sOrNot.."... Prepare yourself!"
	end
end
net.Receive("LobbyCounter", LobbyCounter)
--
-- -
-- CONTROL THE LOBBY WHEN THE GAME STARTS/ENDS
--
function StartGameClient(dontUpdate_startGameTimerLeft)
	if !dontUpdate_startGameTimerLeft then startGameTimerLeft = net.ReadInt(9) end
	gameStarted = true

	RunConsoleCommand("stopsound")

	-- enemiesAliveTotal 	= 0 -- For saftey...
	-- Start Loading Screen...
	GameLoadingTimeStartClient = 0.75
	GameIsNotLoadedYetForClient = true
	GameIsLoadingForClientAutoSetAndClose(Color(45, 45, 45, 255)) -- lightBlack

	if LocalPlayer() then
		if (
			LocalPlayer() and
			LocalPlayer().PrintMessage
		) then
			chat.AddText(Color(254, 208, 0), "You Spawned as ", Color(81, 0, 254), LocalPlayer():GetNWString("classname", "N/A"))
		end
		
		if LocalPlayer():GetNWInt("classInt", -1) != -1 then
			showNotification("Type \"!\" (or press TAB) to open the Lobby/Class Picker.", NOTIFY_HINT, 7, 3)

			-- Extra information for the Players...>>
			-- -
			local __ClassInt = LocalPlayer():GetNWInt("classInt", -1)
			sendANotificationBasedOnClass(__ClassInt, '001')

			if classInt != 0 then
				sendANotificationBasedOnClass(0, '002') -- Everybody can now heal a prop; just re-using; don't need to change it
			end
		end
	end
	
	closeLobby()
end
net.Receive("StartGame", StartGameClient)
net.Receive("EndGame", function()
	local ok = net.ReadBool()

	local timerID = "endGame001"
	timer.Create(timerID, 1, 60, function()
		if (
			LocalPlayer() and
			LocalPlayer():IsValid()
		) then
			timer.Remove(timerID)

			closeLobby()
	
			local prevRound 	= currentRoundWave
			gameStarted 		= false
			currentRoundWave 	= 0
			enemiesAliveTotal 	= 0

			resetHintNotificationBools()
			resetClassesVaribles()
			-- GAME ENDED OFFICIALLY
			if ok then
				-- IT WAS BROADCASTED...NOT SENT ON PLAYER-INITIALIZE SPAWN
				if (
					LocalPlayer() and
					LocalPlayer().PrintMessage and
					prevRound and prevRound > 0
				) then
					chat.AddText(Color(254, 0, 46), "Game Ended")
				elseif prevRound == 0 then
					chat.AddText(Color(254, 0, 46), "Game got canceled by an Admin or the System...")
				end

				timer.Simple(5, function()
					if !lobbyIsOpen then openLobby() end
				end)
			end
		end
	end)
end)
