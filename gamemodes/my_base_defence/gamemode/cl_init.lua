local strictSetting = 1
if GetConVar("mbd_enableStrictMode"):GetInt() then
	strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
end

--[[---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode <== THIS IS MODDED FOR M.D.B ! OF COURSE

-----------------------------------------------------------]]
AddCSLuaFile( 'shared.lua' )
AddCSLuaFile( 'cl_spawnmenu.lua' )
AddCSLuaFile( 'cl_notice.lua' )
--AddCSLuaFile( 'cl_hints.lua' )
--AddCSLuaFile( 'cl_worldtips.lua' )
AddCSLuaFile( 'cl_search_models.lua' )
AddCSLuaFile( 'gui/IconEditor.lua' )
--
--
--
--- GLOBAL VARS. FOR CLIENT (RELATED TO THE WHOLE GAME)
GameIsNotLoadedYetForClient	= true
GameLoadingTimeStartClient	= 6 -- Seconds
GameLoadingTimeLobbyStartClient	= 3 -- When the lobby should open first time auto.
GameLoadingTimeLobbyScreenColor	= nil
function GameIsLoadingForClientAutoSetAndClose(color)
	if color then GameLoadingTimeLobbyScreenColor = {color.r, color.g, color.b, --[[ color.a ]] 200} else GameLoadingTimeLobbyScreenColor = {252, 216, 3, 200} --[[ Yellow ]] end
	timer.Create("mbd:gameIsLoadingForClient", GameLoadingTimeStartClient, 1, function() GameIsNotLoadedYetForClient = false end)
end
adminBtn					= nil -- the admin settings panel....
adminPanel					= nil
commandsHelpPanel			= nil
startGameTimerLeft 			= nil
gameStarted					= false
attackRoundIsOn				= false
currentRoundWave			= 0
countDownerTime				= "N/A (maybe paused)"
amountOfTextFilesForProps 	= 2 -- **THIS MUST BE PRESET** !....
enemiesAliveTotal			= 0
GlobalLobbyPanelRichText	= nil
currentAmountOfDropsStatus	= "N/A"

currRespawnButtonText		= "N/A"
currRespawnButtonBorderColor= Color(22, 236, 99, 255)

-- For HUD Painting Lobby
container 					= nil
containerIncomingMessage	= "..."

buyBoxMenu 					= nil
viewBuyBox 					= nil
fadingTransitionViewBuyBox	= nil

quickSettingMenu 			= nil
quickVehicleMenu 			= nil
quickMenuButtonAdmin 		= nil
quickMenuButtonVehicle 		= nil
settingButtonAdmin 			= nil
lobbyButton	 				= nil
helpCommandsButton	 		= nil
changeCameraViewButton	 	= nil
allowCameraTopViewButton	= nil
onlyAllowCameraTopViewButton= nil
onlyTopCameraViewIsAllowed	= false
cameraTopViewIsAllowed	 	= false
currentCameraView			= 0
viewCameraViewStatus 		= false

gameIsSingleplayer			= game.SinglePlayer()

howManyDropItemsPickedUpByPlayers = 0
howManyDropItemsSpawnedAlready = 0

slowMotionGameIsActivatedByPlayerSinglePlayer	= false
slowMotionKeyIsDown								= false

firstLoadComplete = false
-- -
-- -
--
--- Notifications-bools >>
hintShowed_Mechanic001 	= nil
hintShowed_Medic001 	= nil
hintShowed_Engineer001 	= nil
function resetHintNotificationBools()
	hintShowed_Mechanic001 	= false
	hintShowed_Medic001 	= false
	hintShowed_Engineer001 	= false
end
resetHintNotificationBools()
--
--
availableThingsToBuy = nil
MBDBuyBoxCurrentlyInClientBuyBox = {}
-- -
-- LOBBY RESPAWN --
respawnBtn = nil
repsLeftRespawnCountdown = nil
theSpawnButtonIsComplete = false -- When the countdown to allow spawning is complete..; i.e. everything is ready for spawing
timeBeforePlayerCanSpawnSeconds = -1
--
--
include( 'shared.lua' )
include( 'cl_spawnmenu.lua' )
include( 'cl_notice.lua' )
--include( 'cl_hints.lua' )
--include( 'cl_worldtips.lua' )
include( 'cl_search_models.lua' )
include( 'gui/IconEditor.lua' )
--- -
--- - - SOME CONVARS
-- Type setting type for BuyBox
CreateClientConVar("mbd_customize_list_buybox_entType", "Engineer", true, false, "Adjust Add Type (att./ammo/other) for BuyBox")
-- Price for settings Lists BuyBox
CreateClientConVar("mbd_customize_list_buybox_price_1", "900", true, false, "Add something with this price for BuyBox (swep/other)", 0, 10000)
CreateClientConVar("mbd_customize_list_buybox_price_2", "400", true, false, "Add something with this price for BuyBox (att./ammo)", 0, 10000)
-- ClassName settings for Lists BuyBox
CreateClientConVar("mbd_customize_list_buybox_classname", "Attachments", true, false, "Add something with this classname for BuyBox")
-- Disable Player tilt
CreateClientConVar("mbd_disablePlayerTilt", "1", true, false, "Disable Tilt for Local Player.", -1, 1)
cvars.AddChangeCallback("mbd_disablePlayerTilt", function(convarName, oldValue, newValue)
	if !tonumber(newValue) then GetConVar("mbd_disablePlayerTilt"):SetInt(oldValue) return end
	newValue = tonumber(newValue)

	-- Report to Player
	local text = "Player Tilt DISABLED (default) (CLIENT)."
	if newValue <= 0 then text = "Player Tilt ENABLED (CLIENT)." end
	chat.AddText(Color(173, 254, 0), text)
end)
-- Disable Blur Effect
CreateClientConVar("mbd_disablePlayerBlurEffect", "1", true, false, "Disable Blur Effect for Local Player.", -1, 1)
cvars.AddChangeCallback("mbd_disablePlayerBlurEffect", function(convarName, oldValue, newValue)
	if !tonumber(newValue) then GetConVar("mbd_diablePlayerBlurEffect"):SetInt(oldValue) return end
	newValue = tonumber(newValue)

	-- Report to Player
	local text = ""
	local text = "Player Blur Effect DISABLED (default) (CLIENT)."
	if newValue <= 0 then text = "Player Blur Effect ENABLED (CLIENT)." end
	chat.AddText(Color(173, 254, 0), text)
end)
-- Disable Toy Town Blur Effect
CreateClientConVar("mbd_disablePlayerToyTownBlurEffect", "1", true, false, "Disable ToyBox Blur Effect for Local Player.", -1, 1)
cvars.AddChangeCallback("mbd_disablePlayerToyTownBlurEffect", function(convarName, oldValue, newValue)
	if !tonumber(newValue) then GetConVar("mbd_disablePlayerToyTownBlurEffect"):SetInt(oldValue) return end
	newValue = tonumber(newValue)

	-- Report to Player
	local text = ""
	local text = "Player ToyBox Blur Effect DISABLED (default) (CLIENT)."
	if newValue <= 0 then text = "Player ToyBox Blur Effect ENABLED (CLIENT)." end
	chat.AddText(Color(173, 254, 0), text)
end)
-- Disable Color Enhancer
CreateClientConVar("mbd_PlayerColorEnhancerState", "0", true, false, "Disable Color Enhancer for Local Player.", -1, 2)
cvars.AddChangeCallback("mbd_PlayerColorEnhancerState", function(convarName, oldValue, newValue)
	if !tonumber(newValue) then GetConVar("mbd_PlayerColorEnhancerState"):SetInt(oldValue) return end
	newValue = tonumber(newValue)

	-- Report to Player
	local text = ""
	if newValue <= 0 then text = "Player Color Enhancer ENABLED (default) (CLIENT)."
	elseif newValue == 1 then text = "Player Small amount of Color Enhancer ENABLED (CLIENT)."
	elseif newValue == 2 then text = "Player Color Enhancer DISABLED (CLIENT)." end
	chat.AddText(Color(173, 254, 0), text)
end)
---
-- -
function checkIfPlayerIsInTopView() return ( ( gameIsSingleplayer and currentCameraView == 4 ) or ( cameraTopViewIsAllowed and currentCameraView == 4 ) or onlyTopCameraViewIsAllowed ) end
--- -
-- Get width and height of a text
function getTextWidthAndHeight(font, text)
	surface.SetFont(font)
	surface.SetTextColor(000, 000, 000, 0)
	surface.SetTextPos(0, 0)
	surface.DrawText(text)
	
	return surface.GetTextSize(text)
end
-- Color for health
function getCorrectHealthColor(percentHealthLeft, colorTable)
	if percentHealthLeft >= 75 then
		return colorTable[1] -- Green
	elseif percentHealthLeft >= 40 then
		return colorTable[2] -- Orange
	else
		return colorTable[3] -- Red
	end
end
--
function addCustomCursorToParentAndChildren(topParentPanel, maybeCustomMaterial)
	if topParentPanel and topParentPanel:IsValid() and topParentPanel:GetChildren() then
		-- Main Parent
		function topParentPanel:PaintOver(w, h)
			draw.CustomCursor(topParentPanel, maybeCustomMaterial)
		end

		-- Children
		for _,child in pairs(topParentPanel:GetChildren()) do
			if child and child:IsValid() then
				-- Paint over
				function child:PaintOver(w, h)
					draw.CustomCursor(child, maybeCustomMaterial)

					return false
				end
				-- -
				-- Children of Children
				if child and child:IsValid() and child:GetChildren() then
					for _,child2 in pairs(child:GetChildren()) do
						if child2 and child2:IsValid() then
							-- Paint over
							function child2:PaintOver(w, h)
								draw.CustomCursor(child2, maybeCustomMaterial)

								return false
							end

							-- Children of Children of Children
							if child2 and child2:IsValid() and child2:GetChildren() then
								for _,child3 in pairs(child2:GetChildren()) do
									if child3 and child3:IsValid() then
										-- Paint over
										function child3:PaintOver(w, h)
											draw.CustomCursor(child3, maybeCustomMaterial)
			
											return false
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
--
--
-- -- Functions >>
-- - - -
-- LOBBY RESPAWN --
function RemoveSpawnButton(_respawnBtn)
	if !_respawnBtn or !_respawnBtn:IsValid() then
		if container and container:IsValid() then
			-- print("'RemoveSpawnButton' was invalid...")
		end
		
		return
	end

	_respawnBtn:Remove()
	_respawnBtn = nil
end

-- -
function ResetSpawnProperties(_respawnBtn)
	theSpawnButtonIsComplete = false

	timer.Remove("CountdownToRespawn001")
	repsLeftRespawnCountdown = nil
	
	if !_respawnBtn or !_respawnBtn:IsValid() then
		if container and container:IsValid() then
			print("'ResetSpawnProperties' was invalid...")
		end

		_respawnBtn = nil
		
		return
	end
	
	RemoveSpawnButton(_respawnBtn)
end

function SetTextSpawnButton(_respawnBtn, typeString, text)
	if !_respawnBtn or !_respawnBtn:IsValid() then
		if container and container:IsValid() then
			-- print("'SetTextSpawnButton' was invalid...")
		end
		
		return
	end

    if typeString == "ok" then
        currRespawnButtonBorderColor = Color( -- Blue
			15, 152, 221,
            255
        )
    elseif typeString == "countdown" then
        currRespawnButtonBorderColor = Color( -- Red
            221, 42, 15,
            255
        )
    elseif typeString == "warning" then
        currRespawnButtonBorderColor = Color( -- Orange
			254, 81, 0,
            255
        )
	else
		currRespawnButtonBorderColor = Color( -- Mint
			22, 236, 99,
			255
		)
	end
	
	currRespawnButtonText = text
end

function tryToSpawnPlayer(_respawnBtn)
	if !_respawnBtn or !_respawnBtn:IsValid() then print("\"tryToSpawnPlayer\" was invalid...") return end

	if theSpawnButtonIsComplete then
		if LocalPlayer():GetNWInt("classInt", -1) != -1 then
			ResetSpawnProperties(_respawnBtn)

			StartGameClient(true)

			-- Spawn Self
			net.Start("RespawnPlayerFromButton")
			net.SendToServer()
		else SetTextSpawnButton(_respawnBtn, "warning", "CHOOSE A CLASS\nTO RESPAWN") end
	end
end
function WritePlayersLobby(lobbyPlayersPanel)
	if !container or !container.IsActive then return end
	if !lobbyPlayersPanel or !container:IsActive() then return end

	lobbyPlayersPanel:SetText('')

	local function PaintPlayerInfo(k, v)
		local _PlayerTable = v
		local __color = Color(78, 78, 78, 250)
		--
		-- - - --->>
		-- Name and class
		local __ClassName = nil
		if (
			_PlayerTable.Player and
			_PlayerTable.Player:IsValid()
		) then
			__ClassName = _PlayerTable.Player:GetNWString("classnameLobby", "No Class (Pick One)")

			-- Other stats
			local amountOfKills = _PlayerTable.Player:GetNWInt("killCount", -1)
			if amountOfKills <= 0 then amountOfKills = '' else
				if amountOfKills == 1 then
					amountOfKills = " ● "..amountOfKills.." KILL"
				else
					amountOfKills = " ● "..amountOfKills.." KILLS"
				end
			end

			-- -- -
			-- Colors
			local localPlayerColor = Color(30, 144, 255, 255) -- dodgerblue
			local externalPlayerColor = Color(10, 10, 10, 255) -- darkgray

			local lightGrayColor = Color(102, 102, 102, 255) -- gray

			local superAdminColor = Color(255, 0, 0, 255) -- red
			local adminColor = Color(37, 214, 20, 255) -- lightGreen

			if _PlayerTable.IsSuperAdmin then
				-- If an SuperAdmin
				lobbyPlayersPanel:InsertColorChange(superAdminColor.r, superAdminColor.g, superAdminColor.b, superAdminColor.a)
			elseif _PlayerTable.IsAdmin then
				-- If an Admin
				lobbyPlayersPanel:InsertColorChange(adminColor.r, adminColor.g, adminColor.b, adminColor.a)
			else
				lobbyPlayersPanel:InsertColorChange(lightGrayColor.r, lightGrayColor.g, lightGrayColor.b, lightGrayColor.a)
			end
			-- 0. Insert arrow
			local lobbyTextAPlayer0 = "▶ "
			lobbyPlayersPanel:AppendText(lobbyTextAPlayer0)

			-- 1. Insert NR
			lobbyPlayersPanel:InsertColorChange(lightGrayColor.r, lightGrayColor.g, lightGrayColor.b, lightGrayColor.a)
			local lobbyTextAPlayer1 = tostring(k).." "
			lobbyPlayersPanel:AppendText(lobbyTextAPlayer1)

			if (
				LocalPlayer() and
				LocalPlayer():IsValid() and
				_PlayerTable and
				_PlayerTable.UniqueID == LocalPlayer():UniqueID()
			) then
				-- If an localPlayer
				lobbyPlayersPanel:InsertColorChange(localPlayerColor.r, localPlayerColor.g, localPlayerColor.b, localPlayerColor.a)
			else
				lobbyPlayersPanel:InsertColorChange(lightGrayColor.r, lightGrayColor.g, lightGrayColor.b, lightGrayColor.a)
			end
			-- 2. Insert name and kills..
			local lobbyTextAPlayer2 = _PlayerTable.Name.." ● "..__ClassName..amountOfKills
			lobbyPlayersPanel:AppendText(lobbyTextAPlayer2)
			-- -
			--
			if _PlayerTable.IsSuperAdmin then
				-- If an SuperAdmin
				lobbyPlayersPanel:InsertColorChange(superAdminColor.r, superAdminColor.g, superAdminColor.b, superAdminColor.a)
				lobbyPlayersPanel:AppendText("\n└──────────SuperAdmin\n")
			elseif _PlayerTable.IsAdmin then
				-- If an Admin
				lobbyPlayersPanel:InsertColorChange(adminColor.r, adminColor.g, adminColor.b, adminColor.a)
				lobbyPlayersPanel:AppendText("\n└──────────Admin\n")
			else
				lobbyPlayersPanel:AppendText("\n\n")
			end
		end
	end
	-- ------->>
	--
	-- Write view of Players from TABLE
	for k,v in pairs(playersConnected) do
		--
		-- If IN GAME => Paint only alive players
		if (
			(
				gameStarted and
				v.IsValid and
				!v.Player:GetNWBool("isSpectating", false)
			) or (
				!gameStarted and
				v.IsValid
			)
		) then
			PaintPlayerInfo(k, v)
		end
	end
end

function UpdateLobbyPlayers(trackID, panel)
	-- print("TrackID (UpdateLobbyPlayers) "..trackID)

	local ID = "mbd:UpdateLobby001"

	timer.Remove(ID)
	timer.Create(ID, (1 / 10), (3 * 10), function()
		-- Try for 3 seconds... >> >
		if (
			panel and
			panel.IsValid and
			panel:IsValid()
		) then
			-- Update the Lobby
			timer.Remove(ID)

			WritePlayersLobby(panel)
		end
	end)
end

-- -
-- -- -
--- -
function playerInfoPlate(pl)
	if !pl or !pl:IsValid() or !pl:IsPlayer() then
		print("Could not add a Player info. plate... Invalid Player.")

		return
	end
	-- -- -
	-- Settings...
	-- Text
	local textName = pl:Nick() -- static
	
	local textClassHealth
	local textEnemyKills

	local textColor1 = Color(
		255, -- Always keep it a light bright color..
		math.random(0, 255),
		math.random(0, 255),
		200
	)
	local __prevColor = pl:GetNWString("infoPlateColor", nil)
	if __prevColor and __prevColor != "" then
		textColor1 = string.Split(__prevColor, ";")
		textColor1 = Color(
			textColor1[1],
			textColor1[2],
			textColor1[3],
			textColor1[4]
		)
	else
		pl:SetNWString("infoPlateColor", table.concat({textColor1.r, textColor1.g, textColor1.b, textColor1.a}, ";"))
	end
	local textColor2 = Color(0, 0, 0, 0)
	local classInt

	-- View --
	local rotationSpeed1 = 5
	local rotationSpeed3 = 9
	local rotationSpeed2 = 7

	local getLatestSettingsData = function()
		-- Settings...
		-- Text
		textClassHealth = string.upper(pl:GetNWString("classname", "No Class")).." | "..pl:Health().." HP"
		textEnemyKills = pl:GetNWInt("killCount").." KILLS : 凸(｀0´)凸"

		classInt = pl:GetNWInt("classInt", -1)
		if (classInt == 0) then -- engineer
			textColor2 = Color( -- blue
				1,
				179,
				224,
				230
			)
		elseif (classInt == 1) then -- mechanic
			textColor2 = Color( -- black
				10,
				10,
				10,
				240
			)
		elseif (classInt == 2) then -- medic
			textColor2 = Color( -- green
				104,
				224,
				1,
				230
			)
		elseif (classInt == 3) then -- terminator
			textColor2 = Color( -- red
				224,
				2,
				2,
				230
			)
		end
	end

	local drawText = function (
		_pos,
		_ang,
		_scale,
		_text,
		_textColor,
		flipView
	)
		if (
			!pl:GetNWBool("isSpectating", false) and
			gameStarted
		) then
			if flipView then
				_ang:RotateAroundAxis(
					Vector(0, 0, 1),
					180
				)
			end
	
			cam.Start3D2D(_pos, _ang, _scale)
				draw.DrawText(
					_text,
					"Default",
					0,
					0,
					_textColor,
					TEXT_ALIGN_CENTER
				)
			cam.End3D2D()
		end
	end
	
	-- Unique ID (for players)--
	local hookIDPlayerInfoPlate001 = "playerInfoPlate001_"..pl:UniqueID()

	hook.Remove("PostDrawOpaqueRenderables", hookIDPlayerInfoPlate001)
	hook.Add("PostDrawOpaqueRenderables", hookIDPlayerInfoPlate001, function()
		if !pl or !pl:IsValid() then
			hook.Remove("PostDrawOpaqueRenderables", hookIDPlayerInfoPlate001)

			return
		end

		-- Get the latest data... E.g. health for the Player
		getLatestSettingsData()

		local localMaxs = pl:OBBMaxs()
	
		local pos1 = pl:GetPos() + Vector(0, 0, localMaxs.z + 6.5 + 9.5)
		local ang1 = Angle(0, (RealTime() * ((rotationSpeed1 * 10) % 360)), 90)
	
		-- For the Nick name (top)
		-- Draw front
		drawText(pos1, ang1, 0.6, textName, textColor1, false)
		-- Draw back
		drawText(pos1, ang1, 0.6, textName, textColor1, true)
		--- -

		local pos3 = pl:GetPos() + Vector(0, 0, localMaxs.z + 5.5 + 2.5)
		local ang3 = Angle(0, (RealTime() * ((rotationSpeed3 * 10) % 360)) * -1, 90)

		-- For the Enemy kills (middle)
		-- Draw front
		drawText(pos3, ang3, 0.2, textEnemyKills, textColor2, false)
		-- Draw back
		drawText(pos3, ang3, 0.2, textEnemyKills, textColor2, true)

		local pos2 = pl:GetPos() + Vector(0, 0, localMaxs.z + 5.5)
		local ang2 = Angle(0, (RealTime() * ((rotationSpeed2 * 10) % 360)) * -1, 90)

		-- For the Class name and Health (bottom)
		-- Draw front
		drawText(pos2, ang2, 0.4, textClassHealth, textColor2, false)
		-- Draw back
		drawText(pos2, ang2, 0.4, textClassHealth, textColor2, true)
		--- -
	end)
end
-- Draw Stuff above special M.B.D. Props  ==>>
function drawSpecialPropText(
	_pos,
	_ang,
	_scale,
	_text,
	_textColor,
	flipView
)
	if flipView then
		_ang:RotateAroundAxis( Vector(0, 0, 1), 180 )
	end

	cam.Start3D2D(_pos, _ang, _scale)
		draw.DrawText(
			_text,
			"GModWorldtip",
			0,
			0,
			_textColor,
			TEXT_ALIGN_CENTER
		)
	cam.End3D2D()
end
-- - - -
-- Show notification >
local function changeAHintsValue(hintID, value)
	--
	-- Only disable the right one
	if hintID == 'hintShowed_Mechanic001' then
		if value and hintShowed_Mechanic001 then return true end
		hintShowed_Mechanic001 = value
	elseif hintID == 'hintShowed_Medic001' then
		if value and hintShowed_Medic001 then return true end
		hintShowed_Medic001 = value
	elseif hintID == 'hintShowed_Engineer001' then
		if value and hintShowed_Engineer001 then return true end
		hintShowed_Engineer001 = value
	end

	return false
end
local function disableHintIsUsed(hintID) -- Only show a notification one time; reset these on Game End
	if changeAHintsValue(hintID, true) then return true end

	return false
end
local function resetHintAgain(hintID)
	changeAHintsValue(hintID, false)
end
function showNotification(text, type, lifespan, delay, id, dontCareIfGameIsStarted)
	if !gameStarted and !dontCareIfGameIsStarted then return end -- Don't care to show any notifications when the game is not started
	
	text = tostring(text)
	type = tonumber(type)
	delay = tonumber(delay)

	--
	--- ID Only ( for class notifications ... )
	if (id) then if disableHintIsUsed(id) then return end end
	
	-- https://wiki.garrysmod.com/page/Enums/NOTIFY
	timer.Simple(delay, function()
		--
		--- Show notification
		notification.AddLegacy(text, type, lifespan)

		-- Reset >>
		--
		timer.Simple((lifespan + 0.5), function()
			if (id) then resetHintAgain(id) end
		end)
	end)
end
--
--- - Notification based on class
function sendANotificationBasedOnClass(class, type)
	-- Type = 001 or 002 etc.
	--
	if (
		class == 1 and -- Mechanic
		type == '001'
	) then
		showNotification("Type \"!bv\" (or press TAB) to Buy a Vehicle.", NOTIFY_HINT, 6, 4, 'hintShowed_Mechanic'..type)
	elseif (
		class == 2 and -- Medic
		type == '001'
	) then
		showNotification("You can Heal Players!", NOTIFY_GENERIC, 5, 4, 'hintShowed_Medic'..type)
	elseif (
		class == 0 and -- Engineer
		type == '001'
	) then
		showNotification("You can Heal Props faster than other classes!", NOTIFY_HINT, 5, 4, 'hintShowed_Engineer'..type)
	elseif (
		class == 0 and -- Engineer
		type == '002'
	) then
		showNotification("You can Heal Damaged Props!", NOTIFY_HINT, 5, 4, 'hintShowed_Engineer'..type)
	end
end
-- --
-- Make The Commands Panel (for guideance)
function CreateACommandGuideancePanel(parentPanel, Position, Size)
	local staticData002 = vgui.Create("RichText", parentPanel)
	staticData002:SetVerticalScrollbarEnabled(true)
	staticData002:SetPos(Position[1], Position[2])
	staticData002:SetSize(Size[1], Size[2])
	staticData002:InsertColorChange(255, 255, 224, 185)
	local function addCommandLineDesc(_command, _desc, _isForAdmin)
		staticData002:InsertColorChange(255, 255, 224, 185)
		staticData002:AppendText("--------------------------------------------------------------->\n")

		staticData002:InsertColorChange(229, 185, 123, 185)
		staticData002:AppendText(_command)
		staticData002:InsertColorChange(255, 255, 224, 55)
		staticData002:AppendText(" → ")
		if _isForAdmin then
			staticData002:InsertColorChange(229, 132, 123, 100)
			staticData002:AppendText("(Admin)\n")
		else
			staticData002:InsertColorChange(91, 229, 13, 100)
			staticData002:AppendText("(All)\n")
		end
		staticData002:InsertColorChange(123, 167, 229, 255)
		staticData002:AppendText(_desc..".\n")
		staticData002:InsertColorChange(255, 255, 224, 185)
	end
	addCommandLineDesc("!/!bd", "Open Lobby")
	addCommandLineDesc("!!", "Open Admin Settings", true)
	addCommandLineDesc("!start", "Starts a new game", true)
	addCommandLineDesc("!end", "Ends the current game", true)
	addCommandLineDesc("!g/!give <Player ((p:PlayerNick|:PlayerNick) (the first string match in a random Player's nick)|nil)> <type ((money|bd)|(bupo|bp))> <amount>", "Give money or build points. E.g.: \"!give p:ravo 1000 money\" or \"!give 1000 bp\" (=Give to Self)", false)
	addCommandLineDesc("!bv <type (jeep|airboat|jalopy)>", "Buy a vehicle (Mechanic). E.g.: \"!bv jeep\"")
	addCommandLineDesc("!d/!drop", "Drops the current active weapon")
	addCommandLineDesc("!bl <size (s|m|l)> <amount>", "Spawn Blockers. E.g.: \"!bl m 15\"", true)
	addCommandLineDesc("!h/!help", "Opens a Commands/Help Panel", false)

	staticData002:MoveToFront()
end
function createCommandsHelpPanel()
	if commandsHelpPanel and commandsHelpPanel:IsValid() then commandsHelpPanel:Remove() end

	-- Create A Help/Command Box
	commandsHelpPanel = vgui.Create("DFrame")

	local frame = commandsHelpPanel
	frame:SetTitle("M.B.D. Manual ("..MBDTextCurrentVersion..")")

	frame:SetSize(300, 600)
	frame:Center()
	frame:MakePopup()

	CreateACommandGuideancePanel(frame, {
		5,
		25
	}, {
		frame:GetWide() - 5,
		400
	})

	-- -- --
	-- Text >> >
	local staticData001 = vgui.Create("RichText", frame)
	staticData001:SetVerticalScrollbarEnabled(true)

	staticData001:SetPos(
		5,
		(400 + 20)
	)
	staticData001:SetSize(
		frame:GetWide() - 5,
		(200 - 20 - 5)
	)

	local DWh	= {
		255, 255, 224, 185
	}
	local BWh	= {
		255, 255, 225, 255
	}
	local function SetColor(vgui, type)
		if type == "dwh" then
			vgui:InsertColorChange(DWh[1], DWh[2], DWh[3], DWh[4])
		elseif type == "bwh" then
			vgui:InsertColorChange(BWh[1], BWh[2], BWh[3], BWh[4])
		end
	end

	--- -- -
	-- Tips
	SetColor(staticData001, "bwh")
	staticData001:AppendText("TIPS/INFO. ::\n\n")
	SetColor(staticData001, "dwh")
	-- Slow motion
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> Slow Motion Effect\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("Custom slow motion effect can be experienced in single player.\nPressing \"E\" (IN_USE) while shooting (ATTACK_1).\nYou can also adjust the speed with the scroll wheel.\n")
	-- Quick Access To Menus
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> Quick Access to Menus\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("Press TAB (IN_SCORE) and look at the left hand side to see available menus.\nIt can change according to class picked and if an Admin.\n")
	-- Spawn Menu/Tools Menu
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> Spawn Menu/Tools Menu\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("Like in Garry's Mod Sandbox, Press and Hold \"Q\". This is a modified version for M.B.D.\nAdmins can turn off strict mode, which will enable the normal Sandbox Menu. This requires Players to re-join the Server.\n")
	-- Prop Moving (Phys. Gun)
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> Prop Moving (Phys.Gun)\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("When you move a Prop with the Phys.Gun, it will collide with other Props. However, if you press and hold \"R\", it will not collide with other Props!\nAll Props will no-collide with each other by default.\n")
	-- Roofing
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> Roofing\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("There are some props in the build category (the larger ones), which will act as a roof when placed at an 180(+-)° angle. Press and hold \"E\" to rotate within fixed angles.\nWhen a prop is marked as a roof, the hitbox attached to it, will act differently when enemies are around (to your advantage). Hitboxes are used by enemy NPCs.\n")
	-- How the game gets harder (difficulty)
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> Automatic difficulty\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("The difficulty of the game will self-adjust when the wave/round increases over certain levels. This is fixed (for now). When the difficulty increases, it will become harder to kill enemy NPC's.\n")
	-- More Difficult NPC's
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> More Difficult NPC's\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("Every three wave/round, there will spawn a Strider for the combines group.\n")
	-- Points Money System
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> Points/Money System\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("You have B.P. (build points) and £B.D. (money). B.P. buys stuff related to Props. £B.D. buys stuff related to Weapons, Players or Vehicles.\n")
	-- Super Strong Props
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> S.S.P\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("You can super-strengthen props by using the \"Tool Repair Props\" SWEP. Right-Click; but remember that it costs 750 B.P.! This adds 2000 extra health. An Engineer will add 3000 health and Super Admins will add 5000.\n")
	-- Class changing in Game
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> Class Changing in Game\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("You can change your class in a started game every three wave/round; so think strategically. If you are an Admin on the server, this does not apply.\n")
	-- Engineer Class
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> The Engineer\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("Engineers can fix props even faster!\n")
	-- Mechanic Class
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> The Mechanic\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("Mechanics can buy and fix their cars with their \"Tool Repair Vehicle\" SWEP.\n")
	-- Medic Class
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> The Medic\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("Medics can heal and buy healing dispensers! This can help allot.\n")
	-- Terminator Class
	SetColor(staticData001, "bwh")
	staticData001:AppendText("----------------------\n")
	staticData001:AppendText("> The Terminator\n")
	staticData001:AppendText("-----------------------------\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("Terminators have access suit chargers (BuyBox) and a wider selection of weapons and more powerful weapons. The Terminator also have much more health!\n")
	---- -
	staticData001:AppendText("\n")
	staticData001:AppendText("----------------  --------------- ----\n")
	staticData001:AppendText("----------------------------------------------------------\n")
	--- --
	-- Important Stuff
	SetColor(staticData001, "bwh")
	staticData001:AppendText("::: ADMINS : : : IMPORTANT GAME STUFF :::\n\n")
	SetColor(staticData001, "dwh")
	-- About Strict Mode
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- Strict Mode --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("This will limit the tools and spawnmenu props available! (default) (Look under: Admin Panel)\n")
	SetColor(staticData001, "dwh")
	-- About Respawning
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- Respawning --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("You can configure to allow respawning after death. Then, if more than one Player on the server, all Players can spawn if there is atleast one Player alive.\n*If only one Player on the server, the Player will always be able to respawn.\n")
	SetColor(staticData001, "dwh")
	-- About NPC scaling
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- Automatic NPC Size Scaling --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("You can configure to allow automatic NPC size scaling (bigger or smaller | normal). This will change the NPC to a random scale size each round within the \"bigger\" or \"smaller\" realm. Makes it more interesting and challenging/easier depending on the realm.\n")
	SetColor(staticData001, "dwh")
	-- About Placement of the NPC Spawner
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- NPC Spawner Placement --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("To hinder stuck enemies on spawn, it is recommended to place the NPC Spawner at a big clear area that is as flat as possible; and some room above, if you have more difficult NPCs every three round enabled.\n")
	SetColor(staticData001, "dwh")
	-- About Admin Panel
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- Admin Panel --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("You can access this if you are an >= Admin. Here you can i.e. enable/disable strict mode, change the intensity of the NPC Spawner etc.\n")
	SetColor(staticData001, "dwh")
	-- About Console Variables
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- Console Variables (serverside mostly...) --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("If you wish to use the CLI: mbd_**\n")
	SetColor(staticData001, "dwh")

	-- Some none HUD Panel accessible CLIENT convars
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- ConVar TILT (CLIENT) --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("mbd_disablePlayerTilt (0 or 1) Will disabled lean/tilt effect on player lean.\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- ConVar SCREEN COLOR (CLIENT) --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("mbd_PlayerColorEnhancerState (0 (default), 1, 2 (disabled)) Will change\nthe regular color effect on screen.\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- ConVar MOTION BLUR (CLIENT) --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("mbd_disablePlayerBlurEffect (0 or 1) Will disable the motion blur effect.\n")
	SetColor(staticData001, "dwh")
	staticData001:AppendText("-----------------------------\n")
	staticData001:AppendText("-- ConVar TOY TOWN BLUR (CLIENT) --\n")
	SetColor(staticData001, "bwh")
	staticData001:AppendText("mbd_disablePlayerToyTownBlurEffect (0 or 1) Will disable the top and botton screen blur effect; also called \"toy town\" effect.\n")
	SetColor(staticData001, "dwh")
end
-- - -
--- Show Administrator Panel
----
function showAdminPanel()
	if (
		!LocalPlayer() or
		(
			LocalPlayer():MBDIsNotAnAdmin(true)
		)
	) then return false end
	if adminPanel and adminPanel:IsValid() then adminPanel:Remove() end

	--
	-- Open ADMIN settings PANEL
	adminPanel = vgui.Create("DFrame")
	adminPanel:SetTitle("M.B.D. Admin Settings - "..MBDTextCurrentVersion)

	--
	adminPanel:SetSize(300, 766)
	adminPanel:Center()
	adminPanel:SetVisible(true)
	adminPanel:ShowCloseButton(true)
	adminPanel:SetDraggable(true)

	adminPanel:MakePopup()


	--
	-- BUTTONS IN ADMIN PANEL
	-- Start Game
	local gameStart = vgui.Create("DButton", adminPanel)
	gameStart:SetText("Start Game")
	gameStart:SetPos(
		5,
		(40)
	)
	gameStart:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	-- End Game
	local gameEnd = vgui.Create("DButton", adminPanel)
	gameEnd:SetText("End Game")
	gameEnd:SetPos(
		5,
		(40 + ((20 + 5) * 1))
	)
	gameEnd:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	-- Start/Pause current countdown
	local gameCountdown = vgui.Create("DButton", adminPanel)
	gameCountdown:SetText("Game Countdown | Start/Pause")
	gameCountdown:SetPos(
		5,
		(40 + ((20 + 5) * 3))
	)
	gameCountdown:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	-- Start/Pause current LobbyCountdown
	local gameLobbyCountdown = vgui.Create("DButton", adminPanel)
	gameLobbyCountdown:SetText("Lobby Countdown | Start/Pause")
	gameLobbyCountdown:SetPos(
		5,
		(40 + ((20 + 5) * 4))
	)
	gameLobbyCountdown:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	---
	--- Knapp-funksjonar
	function gameStart:DoClick()
		--
		--- Start GAME
		net.Start("ControlGameStatusCommand")
			net.WriteString("start")
		net.SendToServer()
	end
	function gameEnd:DoClick()
			--
			--- End GAME
			net.Start("ControlGameStatusCommand")
				net.WriteString("end")
			net.SendToServer()
		end
	function gameLobbyCountdown:DoClick()
			-- START/PAUSE COUNTDOWN
			if (!gameStarted) then
				net.Start("StartPauseLobbyCountdown")
				net.SendToServer()
			end
		end
	function gameCountdown:DoClick()
		-- START/PAUSE COUNTDOWN
		net.Start("StartPauseCurrentCountdown")
		net.SendToServer()
	end
	--
	--- ---
	local function CheckboxModeTextColor(DCheckBoxLabel)
		if (DCheckBoxLabel:GetChecked()) then
			-- On (green)
			DCheckBoxLabel:SetTextColor(Color(91, 229, 13, 255))
		else
			-- Off (orange/orangered)
			DCheckBoxLabel:SetTextColor(Color(229, 100, 13, 255))
		end
	end
	---- Activate/Deactivate strict-mode
	local gameStrictMode = vgui.Create("DCheckBoxLabel", adminPanel)
	gameStrictMode:SetText("Strict mode (def.) (menu/tools) (req. re-join)")
	gameStrictMode:SetPos(
		5,
		(40 + ((20 + 5) * 6))
	)
	gameStrictMode:SetValue(GetConVar("mbd_enableStrictMode"):GetInt())
	CheckboxModeTextColor(gameStrictMode)
	--
	--- ---
	---- Activate/Deactivate strict-mode
	local gameHarderEnemiesEveryThreeRound = vgui.Create("DCheckBoxLabel", adminPanel)
	gameHarderEnemiesEveryThreeRound:SetText("Harder enemies every three round\n(map must have navigation node(s))")
	gameHarderEnemiesEveryThreeRound:SetPos(
		5,
		(40 + ((20 + 5) * 7 - 8))
	)
	gameHarderEnemiesEveryThreeRound:SetValue(GetConVar("mbd_enableHardEnemiesEveryThreeRound"):GetInt())
	--
	--- ---
	---- Activate/Deactivate SuperAdmins Can Buy everything for free
	-- ADDED UNDERNEATH =>>
	local gameSuperAdminsBuyFree = vgui.Create("DCheckBoxLabel", adminPanel)
	gameSuperAdminsBuyFree:MoveToBack()
	--
	--- ---
	---- Activate/Deactivate Sound Effect On Game Start
	-- ADDED UNDERNEATH =>>
	local gameTurnOffSirenSoundGameStart = vgui.Create("DCheckBoxLabel", adminPanel)
	gameTurnOffSirenSoundGameStart:MoveToBack()
	--
	--- ---
	---- Activate/Deactivate Auto. NPC scaling on new wave/round
	-- ADDED UNDERNEATH =>> 1 = random NPC scaling, 2 = small scaling, 3 = big scaling
	local gameEnableAutoScaleModelNPC = vgui.Create("DTextEntry", adminPanel)
	---- Activate/Deactivate Enable auto scale change on new round
	gameEnableAutoScaleModelNPC:SetPlaceholderText("<Scale NPC models → |0=off|1=auto|2=small|3=big|>")
	gameEnableAutoScaleModelNPC:SetPos(
		5,
		(40 + ((20 + 5) * 10))
	)
	gameEnableAutoScaleModelNPC:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	gameEnableAutoScaleModelNPC:MoveToFront()
	--
	--
	--- - - CHANGE THE VALUE FOR ATTACK/END COUNTDOWN
	local gameCountdownValueAttack = vgui.Create("DTextEntry", adminPanel)
	gameCountdownValueAttack:SetPlaceholderText("<Countdown Attack Timer Number>")
	gameCountdownValueAttack:SetPos(
		5,
		(40 + ((20 + 5) * 11))
	)
	gameCountdownValueAttack:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	local gameCountdownValueEnd = vgui.Create("DTextEntry", adminPanel)
	gameCountdownValueEnd:SetPlaceholderText("<Countdown Round End Timer Number>")
	gameCountdownValueEnd:SetPos(
		5,
		(40 + ((20 + 5) * 12))
	)
	gameCountdownValueEnd:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	--
	--- 
	--- - - CHANGE THE VALUE FOR the current ROUND/WAVE
	local gameCurrentRoundWaveNumber = vgui.Create("DTextEntry", adminPanel)
	gameCurrentRoundWaveNumber:SetPlaceholderText("<Current Round/Wave Number>")
	gameCurrentRoundWaveNumber:SetPos(
		5,
		(40 + ((20 + 5) * 13))
	)
	gameCurrentRoundWaveNumber:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	--
	--- 
	--- - - CHANGE THE VALUE FOR the current ROUND/WAVE
	local gameSetDropCountEachRoundWave = vgui.Create("DTextEntry", adminPanel)
	gameSetDropCountEachRoundWave:SetPlaceholderText("<Round/Wave Drops Number>")
	gameSetDropCountEachRoundWave:SetPos(
		5,
		(40 + ((20 + 5) * 14))
	)
	gameSetDropCountEachRoundWave:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	--
	--- 
	--- - - CHANGE THE VALUE FOR the NPC limit
	local gameNPCLimit = vgui.Create("DTextEntry", adminPanel)
	gameNPCLimit:SetPlaceholderText("<NPC-Spawner Limit Number>")
	gameNPCLimit:SetPos(
		5,
		(40 + ((20 + 5) * 15))
	)
	gameNPCLimit:SetSize(
		adminPanel:GetWide() - 10,
		20
	)
	--
	--- 
	--- - - CHANGE THE VALUE FOR the NPC limit
	local gamePlayerRespawnAfterFirstDeath = vgui.Create("DTextEntry", adminPanel)
	gamePlayerRespawnAfterFirstDeath:SetPlaceholderText("<Player Respawn Time After First Death>")
	gamePlayerRespawnAfterFirstDeath:SetPos(
		5,
		(40 + ((20 + 5) * 16))
	)
	gamePlayerRespawnAfterFirstDeath:SetSize(
		adminPanel:GetWide() - 10,
		20
	)

	-- Vis current data
	local currentData = vgui.Create("RichText", adminPanel)
	currentData:SetVerticalScrollbarEnabled(false)
	currentData:SetPos(
		5,
		(40 + ((20 + 5) * 17))
	)
	currentData:SetSize(adminPanel:GetWide() - 5, 150)
	local function setCurrentData()
		currentData:SetText('Loading...')

		-- Send Request
		net.Start("GetAdminPanelDataServer")
		net.SendToServer()

		net.Receive("AdminPanelDataClient", function()
			local _Data = net.ReadTable()

			timer.Simple(0.45, function()
				if (
					!_Data
					or !adminPanel
					or ( adminPanel and !adminPanel:IsValid() )
					or !gameSuperAdminsBuyFree
					or ( gameSuperAdminsBuyFree and !gameSuperAdminsBuyFree:IsValid() )
					or !currentData
				) then return end

				---- Activate/Deactivate SuperAdmins Can Buy everything for free (PANEL; NOT TEXT)
				gameSuperAdminsBuyFree:SetText("Admins will get free stuff/get benefits -\nApplies to: Spawnmenu, Lobby, BuyBox & Vehicles.")
				gameSuperAdminsBuyFree:SetPos(
					5,
					(40 + ((20 + 5) * 8) - 5)
				)
				gameSuperAdminsBuyFree:SetValue(_Data.mbd_superAdminsDontHaveToPay)
				gameSuperAdminsBuyFree:MoveToFront()

				---- Activate/Deactivate Game Sound Siren On New Game Round
				gameTurnOffSirenSoundGameStart:SetText("Disable sound effect on new wave/round")
				gameTurnOffSirenSoundGameStart:SetPos(
					5,
					(40 + ((20 + 5) * 9))
				)
				gameTurnOffSirenSoundGameStart:SetValue(_Data.mbd_turnOffSirenSoundStartGame)
				gameTurnOffSirenSoundGameStart:MoveToFront()

				currentData:SetText('')

				local __scaleType = tonumber(_Data.mbd_enableAutoScaleModelNPC) -- it should be a number from before...
				if __scaleType == 0 then
					__scaleType = "off"
				elseif __scaleType == 1 then
					__scaleType = "auto."
				elseif __scaleType == 2 then
					__scaleType = "smaller"
				elseif __scaleType == 3 then
					__scaleType = "bigger"
				end
				currentData:InsertColorChange(255, 255, 224, 255)
				currentData:AppendText("NPC Size Scaling: ")
				currentData:InsertColorChange(91, 229, 13, 255)
				currentData:AppendText(_Data.mbd_enableAutoScaleModelNPC.." ")
				currentData:InsertColorChange(255, 255, 224, 255)
				currentData:AppendText("("..__scaleType..")")
				currentData:InsertColorChange(255, 255, 224, 105)
				currentData:AppendText(" | 1\n")
				currentData:InsertColorChange(255, 255, 224, 255)
				
				currentData:InsertColorChange(255, 255, 224, 255)
				currentData:AppendText("Countdown to Attack: ")
				currentData:InsertColorChange(91, 229, 13, 255)
				currentData:AppendText(_Data.mbd_countDownTimerAttack)
				currentData:InsertColorChange(91, 229, 13, 100)
				currentData:AppendText(" sec. ")
				currentData:InsertColorChange(255, 255, 224, 255)
				currentData:AppendText("("..math.Round((_Data.mbd_countDownTimerAttack / 60), 2).." min)")
				currentData:InsertColorChange(255, 255, 224, 105)
				currentData:AppendText(" | 30\n")
				currentData:InsertColorChange(255, 255, 224, 255)

				currentData:AppendText("Countdown to Round End: ")
				currentData:InsertColorChange(91, 229, 13, 255)
				currentData:AppendText(_Data.mbd_countDownTimerEnd)
				currentData:InsertColorChange(91, 229, 13, 100)
				currentData:AppendText(" sec. ")
				currentData:InsertColorChange(255, 255, 224, 255)
				currentData:AppendText("("..math.Round((_Data.mbd_countDownTimerEnd / 60), 2).." min)")
				currentData:InsertColorChange(255, 255, 224, 105)
				currentData:AppendText(" | 300\n")
				currentData:InsertColorChange(255, 255, 224, 255)

				currentData:AppendText("Round/Wave (current): ")
				currentData:InsertColorChange(91, 229, 13, 255)
				currentData:AppendText(_Data.mbd_roundWaveNumber)
				currentData:InsertColorChange(255, 255, 224, 105)
				currentData:AppendText(" | 0\n")
				currentData:InsertColorChange(255, 255, 224, 255)
				
				currentData:AppendText("Round/Wave Drops (to pick up): ")
				currentData:InsertColorChange(91, 229, 13, 255)
				currentData:AppendText(_Data.mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd)
				currentData:InsertColorChange(255, 255, 224, 105)
				currentData:AppendText(" | 3\n")
				currentData:InsertColorChange(255, 255, 224, 255)

				currentData:AppendText("NPC-Spawner limit: ")
				currentData:InsertColorChange(91, 229, 13, 255)
				currentData:AppendText(_Data.mbd_npcLimit)
				currentData:InsertColorChange(255, 255, 224, 255)
				currentData:AppendText(" (carefull)")
				currentData:InsertColorChange(255, 255, 224, 105)
				currentData:AppendText(" | 100\n")
				currentData:InsertColorChange(255, 255, 224, 255)
				
				currentData:AppendText("Player Respawn Time: ")
				currentData:InsertColorChange(91, 229, 13, 255)
				currentData:AppendText(_Data.mbd_respawnTimeBeforeCanSpawnAgain)
				currentData:InsertColorChange(91, 229, 13, 100)
				currentData:AppendText(" sec. ")
				currentData:InsertColorChange(255, 255, 224, 255)
				currentData:AppendText(" (<0 →No Respw.(-1))")
				currentData:InsertColorChange(255, 255, 224, 105)
				currentData:AppendText(" | 5\n")
				currentData:InsertColorChange(255, 255, 224, 255)
			end)
		end)
	end
	
	setCurrentData(currentData)
	-- 
	--- Static:
	timer.Simple(0.5, function()
		local staticData001 = vgui.Create("RichText", adminPanel)
		staticData001:SetVerticalScrollbarEnabled(false)
		staticData001:SetPos(
			5,
			(40 + ((20 + 5) * 17) + 80)
		)
		staticData001:SetSize(adminPanel:GetWide() - 5, 150)
		staticData001:InsertColorChange(255, 255, 224, 185)

		staticData001:AppendText("\n+\n")
		staticData001:AppendText("++\n")
		staticData001:AppendText("+++\n")
		staticData001:AppendText("Chat Commands:\n")
	end)

	timer.Simple(0.6, function()
		if adminPanel then
			CreateACommandGuideancePanel(adminPanel, {
				5,
				(40 + ((20 + 5) * 18) + 120)
			}, {
				adminPanel:GetWide() - 5,
				150
			})
		end
	end)
	--
	---- - Action ...
	local _allowChange = function(self, val, orginalVal)
		if LocalPlayer():MBDIsNotAnAdmin(false) then
			-- Change it back
			if val != orginalVal then
				local timerID = "_allowChangeLoader"..math.random(-10000, 10000)
				timer.Create(timerID, 0.15, (10 / 0.15), function()
					if self and self:IsValid() then
						timer.Remove(timerID)

						-- Set
						if val == 1 then self:SetValue(0) else self:SetValue(1) end
					end
				end)
			end

			return false
		end

		return true
	end

	function gameStrictMode:OnChange(booleanVal)
		local val = booleanVal
		if val then val = 1 else val = 0 end

		net.Start("mbd_enableStrictMode")
			net.WriteInt(val, 3)
		net.SendToServer()

		CheckboxModeTextColor(gameStrictMode)
	end
	function gameHarderEnemiesEveryThreeRound:OnChange(booleanVal)
		local val = booleanVal
		if val then val = 1 else val = 0 end

		net.Start("mbd_enableHardEnemiesEveryThreeRound")
			net.WriteInt(val, 3)
		net.SendToServer()
	end
	local originalValue_gameSuperAdminsBuyFree = GetConVar("mbd_superAdminsDontHaveToPay"):GetInt()
	function gameSuperAdminsBuyFree:OnChange(booleanVal)
		local val = booleanVal
		if val then val = 1 else val = 0 end

		if !_allowChange(self, val, originalValue_gameSuperAdminsBuyFree) then return end

		net.Start("mbd_superAdminsDontHaveToPay")
			net.WriteInt(val, 3)
		net.SendToServer()
	end
	local originalValue_gameTurnOffSirenSoundGameStart = GetConVar("mbd_turnOffSirenSoundStartGame"):GetInt()
	function gameTurnOffSirenSoundGameStart:OnChange(booleanVal)
		local val = booleanVal
		if val then val = 1 else val = 0 end

		if !_allowChange(self, val, originalValue_gameTurnOffSirenSoundGameStart) then return end

		net.Start("mbd_turnOffSirenSoundStartGame")
			net.WriteInt(val, 3)
		net.SendToServer()
	end
	gameSetDropCountEachRoundWave.OnEnter = function(self)
		local value = tonumber(self:GetValue())

		-- >=3 = Enabled
		-- -1 = Disabled
		if value < 3 then value = -1 end

		self:SetValue(value)

		net.Start("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd")
			net.WriteInt(value, 15)
		net.SendToServer()

		setCurrentData()
	end
	--
	--- Felt-funksjonar
	gameCountdownValueAttack.OnEnter = function(self)
		--
		---- CHANGE
		if (
			tonumber(self:GetValue()) and
			tonumber(self:GetValue()) >= 2
		) then
			net.Start("mbd_countDownTimerAttack")
				net.WriteInt(tonumber(self:GetValue()), 15)
			net.SendToServer()

			setCurrentData()
		end
	end
	gameCountdownValueEnd.OnEnter = function(self)
			--
			---- CHANGE
			if (
				tonumber(self:GetValue()) and
				tonumber(self:GetValue()) >= 2
			) then
				net.Start("mbd_countDownTimerEnd")
					net.WriteInt(tonumber(self:GetValue()), 15)
				net.SendToServer()

				setCurrentData()
			end
		end
	gameCurrentRoundWaveNumber.OnEnter = function(self)
		--
		---- CHANGE
		if (
			tonumber(self:GetValue()) and
			tonumber(self:GetValue()) >= 0
		) then
			net.Start("mbd_roundWaveNumber")
				net.WriteInt(tonumber(self:GetValue()), 15)
			net.SendToServer()

			setCurrentData()
		end
	end
	gameEnableAutoScaleModelNPC.OnEnter = function(self)
		local value = tonumber(self:GetValue())

		-- 1 = auto scaling
		-- 2 = small scaling
		-- 3 = big scaling
		if value > 3 then value = 1 end

		self:SetValue(value)

		net.Start("mbd_enableAutoScaleModelNPC")
			net.WriteInt(value, 3)
		net.SendToServer()

		setCurrentData()
	end
	gameNPCLimit.OnEnter = function(self)
		--
		---- CHANGE
		if (
			tonumber(self:GetValue()) and
			tonumber(self:GetValue()) >= 0
		) then
			net.Start("mbd_npcLimit")
				net.WriteInt(tonumber(self:GetValue()), 15)
			net.SendToServer()

			setCurrentData()
		end
	end
	gamePlayerRespawnAfterFirstDeath.OnEnter = function(self)
		if !self:GetValue() or !tonumber(self:GetValue()) then return end

		local Value = tonumber(self:GetValue())
		if Value < 0 then
			Value = -1
		end

		--
		---- CHANGE
		net.Start("mbd_respawnTimeBeforeCanSpawnAgain")
			net.WriteInt(Value, 15)
		net.SendToServer()

		setCurrentData()
	end
end
--
--
--
--[[ Include Custom Scripts ]]
--
 -- Fonts
--
surface.CreateFont( "GModWorldtip", {
	font		= "Helvetica",
	size		= 20,
	weight		= 700
})
surface.CreateFont("lobbyHeader1", {
	font 		= "Halo", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 43,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("lobbyHeader2", {
	font 		= "Halo", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 16.5,
	weight 		= 100,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("lobbyHeader3", {
	font 		= "Halo", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 15,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("lobbyHeader4", {
	font 		= "Halo", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 9,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("lobbyPlayers", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 16,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("lobbyText0", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 18,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("buyboxText0", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 16,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 4,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("buyboxText1", {
	font 		= "Roboto Bk", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 17.7,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 4,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("buyboxText2", {
	font 		= "DISPLAY FREE TFB", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 24,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 2,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("buyboxText2.1", {
	font 		= "DISPLAY FREE TFB", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 20,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 2,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("buyboxText2.2", {
	font 		= "DISPLAY FREE TFB", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 15,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 2,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("buyboxText3", {
	font 		= "Halo", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 13,
	weight 		= 100,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("lobbyIncomingMessageItalic", {
	font 		= "Lucida Console", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name Lucida Console
	extended 	= false,
	size 		= 10,
	weight 		= 100,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= true,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= true,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("lobbyIncomingMessage", {
	font 		= "Lucida Console", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 10,
	weight 		= 100,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= true,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("HUD_className", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 30,
	weight 		= 800,
	blursize 	= 0,
	scanlines 	= 2,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= true
})
surface.CreateFont("HUD_buildPoints", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 60,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= true
})
surface.CreateFont("HUD_money", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 30,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= true
})
surface.CreateFont("HUD_wave", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 30,
	weight 		= 500,
	blursize 	= 0,
	scanlines 	= 2,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("HUD_scoreBoardInfoEnemies", {
	font 		= "DebugFixed", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 20,
	weight 		= 100,
	blursize 	= 0,
	scanlines 	= 2,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("HUD_countdown", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 20,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 2,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("TOOLGunScreen001", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 41,
	weight 		= 200,
	blursize 	= 2,
	scanlines 	= 5,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= true
})
surface.CreateFont("quickMenuButtons", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 30,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("quickMenuButtons2", {
	font 		= "Verdana", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 20,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 1,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("spawnMenuText001", {
	font 		= "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 16,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("spawnMenuText002", {
	font 		= "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 14,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
surface.CreateFont("spawnMenuText003", {
	font 		= "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended 	= false,
	size 		= 12,
	weight 		= 1000,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
})
--
----
-- TIMERS
--
AddCSLuaFile("timers/cl_timers.lua")
include("timers/cl_timers.lua")
-- HOOKS
--
AddCSLuaFile("hooks/hooks.shared.lua")
AddCSLuaFile("hooks/cl_hooks.lua")
include("hooks/hooks.shared.lua")
include("hooks/cl_hooks.lua")
-- SERVICE FOR THE GAME ITSELF (more related)
--
AddCSLuaFile("services/game.service.shared.lua")
AddCSLuaFile("services/cl_game.service.lua")
include("services/game.service.shared.lua")
include("services/cl_game.service.lua")
-- SERVICE FOR CONNECTED PLAYERS/PLAYER CLASSES
--
AddCSLuaFile("services/cl_players_playerclasses.service.lua")
include("services/cl_players_playerclasses.service.lua")
-- OTHER LOBBY STUFF
AddCSLuaFile("lobbymanager/cl_lobby.lua")
include("lobbymanager/cl_lobby.lua")
AddCSLuaFile("lobbymanager/cl_lobby_respawn.lua")
include("lobbymanager/cl_lobby_respawn.lua")

--
--
--
--
-- Make BaseClass available
--
DEFINE_BASECLASS( "gamemode_base" )


local physgun_halo = CreateConVar( "physgun_halo", "1", { FCVAR_ARCHIVE }, "Draw the physics gun halo?" )

function GM:Initialize()

	BaseClass.Initialize( self )
	
end

function GM:LimitHit( name )

	self:AddNotify( "#SBoxLimit_"..name, NOTIFY_ERROR, 3 )
	-- surface.PlaySound( "buttons/button10.wav" )

end

function GM:OnUndo( name, strCustomString )

	if ( !strCustomString ) then
		-- MODDED :: Easier this way here I guess...
		text = "#Undone_"..name
		if string.match(string.lower(name), "prop") then text = "Returned a M.B.D. Prop!"
		elseif string.match(string.lower(name), "vehicle") then text = "Returned a M.B.D. Vehicle!" end
		
		self:AddNotify( text, NOTIFY_UNDO, 2 )
	else
		self:AddNotify( strCustomString, NOTIFY_UNDO, 2 )
	end
	
	-- Find a better sound :X I DID!
	-- surface.PlaySound( Sound("game/mbd_undo_prop.wav") )

end

function GM:OnCleanup( name )

	self:AddNotify( "#Cleaned_"..name, NOTIFY_CLEANUP, 5 )
	
	-- Find a better sound :X I DID!
	surface.PlaySound( Sound("game/mbd_clean_up_everything.wav") )

end

function GM:UnfrozeObjects( num )

	self:AddNotify( "Unfroze "..num.." Objects", NOTIFY_GENERIC, 3 )
	
	-- Find a better sound :X I DID!
	surface.PlaySound( Sound("game/mbd_unfreeze_objects.wav") )

end

--[[---------------------------------------------------------
	Draws on top of VGUI..
-----------------------------------------------------------]]
function GM:PostRenderVGUI()

	BaseClass.PostRenderVGUI( self )

end

local PhysgunHalos = {}

--[[---------------------------------------------------------
   Name: gamemode:DrawPhysgunBeam()
   Desc: Return false to override completely
-----------------------------------------------------------]]
function GM:DrawPhysgunBeam( ply, weapon, bOn, target, boneid, pos )

	if ( physgun_halo:GetInt() == 0 ) then return true end

	if ( IsValid( target ) ) then
		PhysgunHalos[ ply ] = target
	end
	
	return true

end

hook.Add( "PreDrawHalos", "AddPhysgunHalos", function()

	if ( !PhysgunHalos || table.Count( PhysgunHalos ) == 0 ) then return end


	for k, v in pairs( PhysgunHalos ) do
		local CONTINUE = false

		if ( !IsValid( k ) ) then CONTINUE = true end

		if !CONTINUE then local size = math.random( 1, 2 )
			local colr = k:GetWeaponColor() + VectorRand() * 0.3
			 
			halo.Add( PhysgunHalos, Color( colr.x * 255, colr.y * 255, colr.z * 255 ), size, size, 1, true, false ) end
	end
	
	PhysgunHalos = {}
end )


--[[---------------------------------------------------------
   Name: gamemode:NetworkEntityCreated()
   Desc: Entity is created over the network
-----------------------------------------------------------]]
function GM:NetworkEntityCreated( ent )

	--
	-- If the entity wants to use a spawn effect
	-- then create a propspawn effect if the entity was
	-- created within the last second (this function gets called
	-- on every entity when joining a server)
	--

	if ( ent:GetSpawnEffect() && ent:GetCreationTime() > (CurTime() - 1.0) ) then
	
		local ed = EffectData()
			ed:SetOrigin( ent:GetPos() )
			ed:SetEntity( ent )
		util.Effect( "propspawn", ed, true, true )

	end

end
