--
---
----  - -  -=>>>> LOBBY STUFF
-----
----
---
--
local lobbyTimer001ID = "mbd:LobbyTimer001"

function tellPlayerPlayersToOpenLobby(pl, openLobby, makeThePlayerWaitMaybe)
	if makeThePlayerWaitMaybe then NowItIsPossibleToStartGame = false end

	local openLobbyYes = function()
		-- Open lobby
		net.Start("OpenLobby", openLobby)
		net.Send(pl)
	end

	if not NowItIsPossibleToStartGame then
		-- Wait a little; so the lobby can reappear again (this is also used in functions "endGame")
		timer.Create("mbd:CheckIfLobbyIsOpenedAgainAfterEndGame", 3, 1, function()
			timer.Simple(1, function() NowItIsPossibleToStartGame = true openLobbyYes() end)
		end)
	else openLobbyYes() end
end

function startGame()
	if GameStarted then
		for _,pl in pairs(player.GetAll()) do
			ClientPrintAddTextMessage(pl, {Color(208, 0, 254), "You can't start a new game before the current one is ended."})
		end

		return false
	end
	if not NowItIsPossibleToStartGame then
		for _,pl in pairs(player.GetAll()) do
			ClientPrintAddTextMessage(pl, {Color(208, 0, 254), "Wait a little..."})
		end

		return false
	end
	
	timer.Remove("mbd:RoundCreator001")
	timer.Remove("mbd:nextRoundCountdown001")
	timer.Remove(lobbyTimer001ID)
	--
	--
	--- INTERVAL TO REMOVE DEBRIS PROPS EVERY 10 SEC...
	timer.Remove("mbd:RemoveDebris001")
	--
	--
	GameStarted = true
	startGameTimerLeft = startGameTimerTotal
	ValidSpawnBackupPositionsVectorsFromNPCs = {}
	
	--
	nextRoundWave(false)
	currentRoundEnd(true)
	--
	--- GIVE PLAYERS HEALTH ==>=
	-- GIVE PLAYER CLASS VALUES (money, buildPoints)
	for k,v in pairs(player.GetAll()) do
		if (
			v:IsValid() and
			v:IsPlayer()
		) then
			if (v:GetNWInt("classInt", -1) != -1) then
				v:MBDGoIntoNormalMode("2") -- For saftey

				v:MBDResetPlayerHealthToMax(true)
				--
				v:MBDGiveStuffFirstRoundStart()
			elseif v:MBDIsNotAnAdmin(true) then
				-- Set Player to spectate-mode...
				v:MBDGoIntoSpectatorMode("4")
			end
		end
	end

	--
	net.Start("StartGame")
		net.WriteInt(startGameTimerLeft, 9)
	net.Broadcast()

	if GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() > 0 then
		timer.Simple(0.15, function()
			-- Reset
			net.Start("PyramidStatus")
				net.WriteString("0/"..GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt())
			net.Broadcast()
		end)
	end
end
function endGame()
	if (!GameStarted) then
		for _,pl in pairs(player.GetAll()) do
			ClientPrintAddTextMessage(pl, {Color(208, 0, 254), "You can't end a game before a new one is started."})
		end
		
		return false
	end
	GameStarted 		= false
	NowItIsPossibleToStartGame = false
	-- Wait a little; so the lobby can reappear again (this is also used in function "tellPlayerPlayersToOpenLobby" )
	timer.Create("mbd:CheckIfLobbyIsOpenedAgainAfterEndGame", 9, 1, function()
		timer.Simple(1, function() NowItIsPossibleToStartGame = true end)
	end)
	CurrentRoundWave = 0
	ValidSpawnBackupPositionsVectorsFromNPCs = {}
	resetDrops0()
	-- RESET VARIABLES
	ResetClassesVaribles()

	-- REMOVE TIMERS ..>
	timer.Remove("mbd:RemoveDebris001")
	timer.Remove("mbd:RoundCreator001")
	timer.Remove("mbd:nextRoundCountdown001")

	sendCountDownerClient(0, "The Game Is Ended... You live another day.", nil)

	--
	-- COMPLETELY END THE GAME
	net.Start("EndGame")
		net.WriteBool(true)
	net.Broadcast()

	-- Send End Game Theme Song
	if GetConVar("mbd_turnOffSirenSoundStartGame"):GetInt() == 0 then
		timer.Simple(0.35, function()
			Entity_EmitLocalSoundEmitter("1",
				{
					Sound		= "game/end_game_theme_song.wav",
					Pitch		= 100,
					SoundEnt 	= nil,
					Volume		= 0.75
				},
				false
			)
		end)
	end

	if GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() > 0 then
		net.Start("PyramidStatus")
			net.WriteString("N/A")
		net.Broadcast()
	end

	for k, NPCSpawner in pairs(ents.FindByClass("mbd_npc_spawner_all")) do
		if NPCSpawner and NPCSpawner:IsValid() then
			NPCSpawner:ResetSequence("idle")
		end
	end

	freezeEveryNPC()

	--
	--- GIVE PLAYERS ORIGINAL HEALTH/RESET SOME OTHER STUFFff ==>=
	for k,v in pairs(player.GetAll()) do
		if (
			v:IsValid() and
			v:IsPlayer()
		) then
			-- Reset
			v:MBDResetPlayerHealthToOriginal()

			-- Set Player to spectate-mode...
			if v:MBDIsNotAnAdmin(true) then
				v:MBDGoIntoSpectatorMode("5")
			end
		end
	end
	--
	-- A small delay...This is one the client-side also
	timer.Simple(5, function()
		-- REMOVE TIMERS ..>
		timer.Remove("mbd:RoundCreator001")
		timer.Remove("mbd:nextRoundCountdown001")
		sendCountDownerClient(0, "The Game Is In Lobby", nil)
		sendLobbyCounter()
		
		---
		-- CLEAN UP EVERYTHING...
		local function __cleanUp(__table)
			for k,v in pairs(ents.GetAll()) do
				for l,w in pairs(__table) do
					--
					if (string.match(v:GetClass(), w)) then
						if (
							!string.match(v:GetName(), 'mbd_ent') and -- WON'T remove mbd_ent's (like for custom maps etc... Or in-game stuff)
							(
								v:IsValid() or -- is a PROP
								v:IsNPC() or -- is a NPC
								string.match(v:GetName(), 'mbd_d_prop')
							)
						) then
							-- Get the Owner (Player)
							local ownerOfEntity = v:GetCreator() --v:GetNWEntity("PlayerOwnerEnt", nil)
							
							-- REMOVE
							undoEntityWithOwner(ownerOfEntity, v, nil, false, true)
						end
					end
				end
			end
		end

		-- Very important...
		__cleanUp({
			"prop",
			"npc",
			"weapon_physgun",
			"gmod_tool",
			"swep_prop_repair",
			"swep_vehicle_repair",
			"fas2",
			"item_suitcharger",
			"item_healthcharger",
			"item_healthkit",
			"item_healthvial",
			"item_battery"
		})
		EnemiesAliveTotal = 0

		-- Send to CLIENTS >>
		net.Start("TotalAmountOfEnemies")
			net.WriteInt(EnemiesAliveTotal, 9)
		net.Broadcast()

		--
		-- Every PLAYER will go out of SPECTATOR MODE
		-- And get reset their varibles ready for a new ROUND
		local AllPlayers 		= ents.FindByClass("Player")
		local AllPlayersLength 	= #AllPlayers
		for k,v in pairs(AllPlayers) do
			v:MBDGoIntoNormalMode("3")
			
			ResetPlayersValues("3", v)

			if k == AllPlayersLength then
				-- Send The Updated List to All Players (CLIENT)...
				timer.Simple(0.3, function()
					-- SEND TO CLIENTs...
					net.Start("PlayerClassAmount")
						net.WriteTable(PlayerClassesAvailable)
					net.Broadcast()
				end)
				--
				timer.Simple(0.5, function()
					net.Start("PlayersClassData")
						net.WriteTable(PlayersClassData)
					net.Broadcast()
				end)
			end
		end
	end)
end

--
local timerLobbyCountDownIsOn = true

--
net.Receive("StartPauseLobbyCountdown", function()
	-- START/PAUSE CURRENT TIMER (LOBBY)
	if (timerLobbyCountDownIsOn) then
		timer.Pause(lobbyTimer001ID)

		--
		--- SEND A "PAUSE MESSAGE" ... Let em know
		net.Start("LobbyCounter")
			net.WriteInt(-3, 9)
		net.Broadcast()

		--
		timerLobbyCountDownIsOn = false
	else
		timer.UnPause(lobbyTimer001ID)

		--
		timerLobbyCountDownIsOn = true
	end
end)
function sendLobbyCounter()
	--
	-- Show countdown for client
	timer.Remove(lobbyTimer001ID)
	timer.Create(lobbyTimer001ID, 1, startGameTimerTotal, function()
		startGameTimerLeft = timer.RepsLeft(lobbyTimer001ID)
		--
		net.Start("LobbyCounter")
			net.WriteInt(startGameTimerLeft, 9)
		net.Broadcast()
		--
		if (startGameTimerLeft == 1 and !GameStarted) then
			startGame()
		end
	end)
end
-- Used to prevent game start when an admin has never joined the server, and sat it up... (the spawner etc.)
function checkIfAdminHasJoinedTheServerOneTime()
	-- -
	-- Check if an Admin has joined the game one time, then start lobby countdown

	--
	--- SEND A "ADMIN HAS NOT SET UP THE GAME YET MESSAGE" ... Let em know
	timer.Remove("mbd:LobbyCheckForAdminFirstTime001")
	timer.Create("mbd:LobbyCheckForAdminFirstTime001", 0.5, 0, function()
		timer.Remove(lobbyTimer001ID)

		net.Start("LobbyCounter")
			net.WriteInt(-4, 9)
		net.Broadcast()

		-- OK for now..
		if haveSpawnedImportantGameProps then
			timer.Remove("mbd:LobbyCheckForAdminFirstTime001")

			--
			-- --
			sendLobbyCounter()
		end
	end)
end

function checkIfThereIsAtleastOnePlayerToStartTheLobbyCountdown()
	-- -
	-- Check if an Admin has joined the game one time, then start lobby countdown

	--
	--- ... Let em know!!
	local tMinusToAttackTimerID = "mbd:nextRoundCountdown001"
	local ltMinusToSafteyTimerID = "mbd:RoundCreator001"

	local haveRanNilPlayersLogic = false
	local haveRanMoreThanOnePlayerLogic = false

	timer.Create("mbd:GameCheckNeedsOnePlayer001", 1, 0, function()
		if haveSpawnedImportantGameProps then
			if #PlayersConnected == 0 and !haveRanNilPlayersLogic then
				haveRanNilPlayersLogic = true haveRanMoreThanOnePlayerLogic = false
				
				if GameStarted then
					---
					-- -- Pause Game
					if !AttackRoundIsOn then
						changeCountDown(0, timer.RepsLeft("mbd:nextRoundCountdown001"), false)
						timer.Pause(tMinusToAttackTimerID)
					else
						changeCountDown(1, timer.RepsLeft("mbd:RoundCreator001"), true)
						timer.Pause(ltMinusToSafteyTimerID)
					end

					timerCountDownIsOn = false
				else
					--- SEND A "NO PLAYERS MESSAGE" ... Let em know (lol no one will know...)
					timer.Remove(lobbyTimer001ID)

					net.Start("LobbyCounter")
						net.WriteInt(-5, 9)
					net.Broadcast()
				end
			elseif #PlayersConnected > 0 and !haveRanMoreThanOnePlayerLogic then
				haveRanNilPlayersLogic = false haveRanMoreThanOnePlayerLogic = true

				if !GameStarted then
					---
					-- Start Lobby
					sendLobbyCounter()
				else
					---
					-- -- UnPause Game
					if !AttackRoundIsOn then
						changeCountDown(0, timer.RepsLeft("mbd:nextRoundCountdown001"), false)
						timer.UnPause(tMinusToAttackTimerID)
					else
						changeCountDown(1, timer.RepsLeft("mbd:RoundCreator001"), true)
						timer.UnPause(ltMinusToSafteyTimerID)
					end

					timerCountDownIsOn = true
				end
			end
		end
	end)
end
net.Receive("SetNWIntPlayerServerSide", function(len, pl)
	local _DataTable = net.ReadTable()
	
	-- Set
	for Key,Value in pairs(_DataTable) do
		pl:SetNWInt(Key, Value)
	end
end)