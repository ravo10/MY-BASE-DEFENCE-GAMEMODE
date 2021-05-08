--

function HOOK_Initialize001()
	hook.Add("Initialize", "mbd:Initialize001", function()
		--
		-- Add Network Strings
		-- SERVER
		util.AddNetworkString("PlayerConnected")
		util.AddNetworkString("PlayerDisconnected")
		--
		util.AddNetworkString("RoundStatus")
		--
		util.AddNetworkString("OpenLobby")
		util.AddNetworkString("CloseLobby")
		util.AddNetworkString("LobbyCounter")
		util.AddNetworkString("StartGame")
		util.AddNetworkString("EndGame")
		util.AddNetworkString("PlayerClassAmount")
		util.AddNetworkString("PlayerFirstLoad")
		util.AddNetworkString("StartPauseLobbyCountdown")
		util.AddNetworkString("StartPauseCurrentCountdown")
		util.AddNetworkString("PlayerWantsToSpawnProp")
		util.AddNetworkString("PlayerWantsToBuySomething")
		util.AddNetworkString("GiveAPlayerBuildpointsOrMoney")
		util.AddNetworkString("MechanicWantsToBuyVehicle")
		util.AddNetworkString("DropCurrentPlayerWeapon")
		util.AddNetworkString("SpawnBlockerBlock")
		util.AddNetworkString("GetAdminPanelDataServer")
		util.AddNetworkString("RemoveAnEntity")
		util.AddNetworkString("SpawnAnEffectServerside")
		util.AddNetworkString("SetNWIntPlayerServerSide")
		util.AddNetworkString("RespawnPlayerFromButton")
		util.AddNetworkString("get_mbd_respawnTimeBeforeCanSpawnAgain")
		util.AddNetworkString("get_mbd_howManyDropItemsPickedUpByPlayers")
		util.AddNetworkString("get_mbd_howManyDropItemsSpawnedAlready")
		util.AddNetworkString("__NAME_Weapons_server")
		util.AddNetworkString("mbd_SendAvailableThingsThingsToBuy")
		util.AddNetworkString("mbd_QuickSettingsSetServer")

		util.AddNetworkString("mbd:update:CustomSettingsTable")

		util.AddNetworkString("mbd:GetABuyBoxListServer")
		util.AddNetworkString("mbd:SetABuyBoxListClient")

		util.AddNetworkString("mbd:SpawnDestructionProps")
		util.AddNetworkString("mbd:SpawnNPCBodyParts")

		util.AddNetworkString("mbd:SendAllowedNPCsCombined")

		util.AddNetworkString("mbd:StopParticleEffectOnEnt")
		util.AddNetworkString("mbd:cameraTopViewIsAllowed")
		util.AddNetworkString("mbd:onlyTopCameraViewIsAllowed")
		-- CVARS... 
		util.AddNetworkString("mbd_roundWaveNumber")
		util.AddNetworkString("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd")
		util.AddNetworkString("mbd_howManyDropItemsPickedUpByPlayers")
		util.AddNetworkString("mbd_howManyDropItemsSpawnedAlready")
		util.AddNetworkString("mbd_npcLimit")
		util.AddNetworkString("mbd_respawnTimeBeforeCanSpawnAgain")
		util.AddNetworkString("mbd_enableStrictMode")
		util.AddNetworkString("mbd_enableHardEnemiesEveryThreeRound")
		util.AddNetworkString("mbd_superAdminsDontHaveToPay")
		util.AddNetworkString("mbd_turnOffSirenSoundStartGame")
		util.AddNetworkString("mbd_countDownTimerAttack")
		util.AddNetworkString("mbd_countDownTimerEnd")
		util.AddNetworkString("mbd_enableAutoScaleModelNPC")
		-- CLIENT
		util.AddNetworkString("PlayerClass") -- Player wants to change his class
		util.AddNetworkString("PlayersClassData")
		util.AddNetworkString("RoundWaveChange")
		-- util.AddNetworkString("countDownerTime_Game")
		util.AddNetworkString("mbd:LobbyTimerStateChange")
		util.AddNetworkString("ControlGameStatusCommand")
		util.AddNetworkString("TotalAmountOfEnemies")
		util.AddNetworkString("PyramidStatus")
		util.AddNetworkString("TellNotificationError")
		util.AddNetworkString("AdminPanelDataClient")
		util.AddNetworkString("RemoveNotificationTimer")
		util.AddNetworkString("NotificationReceivedFromServer")
		util.AddNetworkString("UpdateSpawnButtonClassChosenText")
		util.AddNetworkString("receive_mbd_respawnTimeBeforeCanSpawnAgain")
		util.AddNetworkString("receive_mbd_howManyDropItemsPickedUpByPlayers")
		util.AddNetworkString("receive_mbd_howManyDropItemsSpawnedAlready")
		util.AddNetworkString("receive_mbd_attackRoundIsOn")
		util.AddNetworkString("gameIsAlreadyStarted")
		util.AddNetworkString("__NAME_Weapons_client")
		util.AddNetworkString("ClientPrintConsoleMessage")
		util.AddNetworkString("ClientPrintAddTextMessage")
		util.AddNetworkString("SendLocalSoundToAPlayer")

		util.AddNetworkString("mbd:GetSpawnListFromServerToPopulateSpawnMenu")

		util.AddNetworkString("mbd_stopAllSoundsClient")
		util.AddNetworkString("mbd:setCurrentCameraView")

		util.AddNetworkString("mbd:SetPlayerCurrentCameraView")
		util.AddNetworkString("mbd:onlyTopCameraViewIsAllowedClient")
		util.AddNetworkString("mbd:cameraTopViewIsAllowedClient")

		util.AddNetworkString("mbd_updateTheEnemyNPCTableThatNPCSpawnerUse")
		util.AddNetworkString("mbd:StatusOfSlowdowTime")

		util.AddNetworkString("mbd_PlayParticleEffectClient")
		util.AddNetworkString("mbd_PlayParticleEffectAttachClient")
		util.AddNetworkString("mbd_PlayParticleEffectStopClient")
		--
		util.AddNetworkString("OpenBuyBoxMenu")
		util.AddNetworkString("CloseBuyBoxMenu")
		util.AddNetworkString("PlayerGetAvailableThingsToBuy")
		-- SERVER and CLIENT (very much related)
		util.AddNetworkString("createANonSpawnedEntity")
		util.AddNetworkString("giveANonSpawnedEntity")
	end)
	hook.Add("Move", "mbd:OnMove001", function(pl, mv)
		-- Open lobby
		local buttonsDown = mv:GetButtons()
		if buttonsDown == (IN_SCORE + IN_USE) --[[ TAB + E ]] then tellPlayerPlayersToOpenLobby(pl, openLobby, false) end
	end)
end
function HOOK_Initialize002()
	hook.Add("Initialize", "mbd:Initialize002", function()
		-- ... -.. -
		-- CONSOLE RESPONSE TO CALL (THE CALLBACKS)
		cvars.AddChangeCallback("mbd_game_status", function(convarName, oldValue, newValue)
			--
			---
			-- STARTS THE GAME for SERVER and CLIENT
			if (newValue == 'start') then
				startGame()
			elseif (newValue == 'end') then
				endGame()
			end

			--reset
			GetConVar(convarName):SetString("")
		end)
		--
		cvars.AddChangeCallback("mbd_roundWaveNumber", function(convarName, oldValue, newValue)
			--
			--- SETS THE CURRENT round/Wave
			CurrentRoundWave = GetConVar("mbd_roundWaveNumber"):GetInt()
			--- CHANGE GAME ROUND
			nextRoundWave(false)
		end)
		--
		cvars.AddChangeCallback("mbd_countDownTimerAttack", function(convarName, oldValue, newValue)
			--
			--- CHANGE
			if (
				GameStarted and
				!timer.Exists("mbd:RoundCreator001")
			) then
				nextRoundCountdown001()
			end
			
		end)
		--
		cvars.AddChangeCallback("mbd_countDownTimerEnd", function(convarName, oldValue, newValue)
			--
			--- CHANGE
			if (
				GameStarted and
				!timer.Exists("mbd:nextRoundCountdown001")
			) then
				RoundCreator001()
			end
		end)
		--
		cvars.AddChangeCallback("mbd_disableStamina", function(convarName, oldValue, newValue)
			if !tonumber(newValue) then GetConVar("mbd_disableStamina"):SetInt(oldValue) return end
			newValue = tonumber(newValue)

			-- Report to all users
			local text = "Cheat enabled: Stamina DISABLED for all Players"
			if newValue <= 0 then text = "Stamina ENABLED for all Players (default)" end

			for _,pl in pairs(player.GetAll()) do
				ClientPrintAddTextMessage(pl, {Color(173, 254, 0), text})
			end
		end)
		--
		cvars.AddChangeCallback("mbd_disableSlowMotionEffect", function(convarName, oldValue, newValue)
			if !tonumber(newValue) then GetConVar("mbd_disableSlowMotionEffect"):SetInt(oldValue) return end
			newValue = tonumber(newValue)
		
			-- Report to all users
			local text = "Slow Motion Effect DISABLED"
			if newValue <= 0 then text = "Slow Motion Effect ENABLED (default)" end

			for _,pl in pairs(player.GetAll()) do
				ClientPrintAddTextMessage(pl, {Color(173, 254, 0), text})
			end
		end)
		-- -->
		--
		-- --  -=>>> SET ROUND CHANGER
		CurrentRoundWave = GetConVar("mbd_roundWaveNumber"):GetInt()

		checkIfAdminHasJoinedTheServerOneTime()
		checkIfThereIsAtleastOnePlayerToStartTheLobbyCountdown()
	end)
end
-- Instant strip! Important
function GM:PlayerDeathThink(pl) pl:Spawn() if pl:GetNWBool("isSpectating", false) then pl:MBDStripPlayer() end return true end
--
--- -- --> ON WHEN PLAYER "dead"
hook.Add("PlayerDeath", "mbd:PlayerDeath001", function(victim, inflictor, attacker)
	if !victim or !victim:IsValid() then return end

	victim:ShouldDropWeapon(false)

	-- ----------- ---------------
	-- Make Player spectate (the real spectating happens at Spawn !)
	if GameStarted then
		victim:SetNWBool("isSpectating", true)

		-- Remove from the Players prev. class
		victim:RemoveFromClassSystem(PlayerClassesAvailable, PlayersClassData)
		---------------------------------------------------------
		-- MODEL THAT WILL FOLLOW PLAYER
		-- SET CUSTOM PROP ON ENT
		local d_model		= ents.Create("prop_physics")
		local plPos			= victim:GetPos()
		local AttackerPos	= attacker:GetAngles()

		-- "Death" Model
		d_model:SetModel("models/Gibs/HGIBS.mdl")
		d_model:SetName("mbd_d_prop")
		d_model:SetOwner(victim)
		d_model:SetSolid(SOLID_VPHYSICS)
		d_model:SetModelScale(1.3)
		d_model:Activate()
		d_model:SetAngles(
			Angle(
				AttackerPos.pitch,
				(AttackerPos.yaw * -1),
				AttackerPos.roll
			)
		)
		d_model:SetPos(
			Vector(
				plPos.x,
				plPos.y,
				plPos.z + (80 - 20)
			)
		)

		--------------------
		-- -
		-- Reset the Players values
		ResetPlayersValues("1", victim)

		victim:MBDRemoveAllRelatedDoors()
		victim:MBDResetPlayerHealthToOriginal()

		-- Notify Other Players
		if MBDCompleteCurrNPCList then
			local NPCData = MBDCompleteCurrNPCList[GETMaybeCustomNPCKeyFromNPCClass(attacker:GetClass())]

			if !NPCData then NPCData = {} NPCData["Name"] = attacker:GetClass() end

			for _,pl in pairs(player.GetAll()) do
				ClientPrintAddTextMessage(
					pl,
					{
						Color(255, 61, 0),
						"*Alert* ",
						Color(0, 255, 61),
						"Player \""..victim:Nick().."\" got ",
						Color(255, 61, 0),
						"killed ",
						Color(0, 255, 61),
						"by a ",
						Color(0, 255, 189),
						"NPC ",
						Color(255, 125, 0),
						"\""..NPCData.Name.."\"",
						Color(0, 255, 61),
						"."
					}
				)
			end
		end
	end
end)
--- -- - =>> WHEN A PLAYER spawns initially
--
function playerInitialSpawn(pl)
	--
	--
	timer.Create("mbd:PlayerConnectedAdd001", 3, 0, function()
		if (
			pl and
			pl.UniqueID and
			pl.SteamID and
			pl.Name and
			pl.IsValid and
			pl.IsSuperAdmin and
			pl.IsAdmin and
			pl:IsValid() and
			pl:IsPlayer() and
			PlayersConnected
		) then
			timer.Remove("mbd:PlayerConnectedAdd001")
			-- Add to PlayersConnected TABLE
			-- - -- >
			--
			table.Add(PlayersConnected, {
				{
					UniqueID 		= pl:UniqueID(),
					SteamID 		= pl:SteamID(),
					Name 			= pl:Name(),
					IsValid			= pl:IsValid(),
					Player			= pl,
					IsSuperAdmin 	= pl:IsSuperAdmin(),
					IsAdmin 		= pl:IsAdmin()
				}
			})
			--
			-- -
			--- -
			local ID = "mbd:PlayerConnected001"..pl:UniqueID()
			timer.Create(ID, 1, 20, function()
				-- Try for 20 seconds... >> >
				if (
					pl and
					pl:IsValid()
				) then
					for k,v in pairs(PlayersConnected) do
						if v.UniqueID == pl:UniqueID() then
							timer.Remove(ID)

							net.Start("PlayerConnected")
								net.WriteTable(PlayersConnected)
							net.Broadcast()

							break
						end
					end
					-- -- -
					--
					amountOfPlayersChanged()
					--
					pl:MBDStripPlayer()
					pl:MBDGivePlayer("4")
					-- -
					-- FIRST LOAD...
					if (pl:GetNWBool("PlayerFirstLoad", true)) then
						pl:SetNWBool("PlayerFirstLoad", true)
						--
						---

						if (pl:IsPlayer()) then
							ResetPlayersValues("2", pl)

							-- Wait a little... For security (like that nothing breaks)
							timer.Simple(0, function()
								net.Start("PlayerFirstLoad")
								net.Send(pl)

								-- Send current stats (if game has started)
								if EnemiesAliveTotal then
									net.Start("TotalAmountOfEnemies")
										net.WriteInt(EnemiesAliveTotal, 9)
									net.Send(pl)
								end
								if CurrentRoundWave then
									net.Start("RoundWaveChange")
										net.WriteInt(CurrentRoundWave, 15)
									net.Send(pl)
								end
							end)
						end

						-- IF THE GAME HAS STARTED... PUT PLAYER IN SPECTATOR MODE
						if GameStarted then
							pl:MBDGoIntoSpectatorMode("1")

							net.Start("gameIsAlreadyStarted")
							net.Send(pl)

							timer.Simple(1, function()
								if GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() >= 0 then
									net.Start("receive_mbd_respawnTimeBeforeCanSpawnAgain")
										net.WriteInt(GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt(), 12)
									net.Send(pl)
								end
							end)

							--
							---
							net.Start("CloseLobby")
							net.Send(pl)
						else
							pl:MBDGoIntoNormalMode("1")
						end

						if PlayerClassesAvailable then
							-- Send current table
							net.Start("PlayerClassAmount")
								net.WriteTable(PlayerClassesAvailable)
							net.Send(pl)
						end

						-- For BuyBox
						timer.Create("PlayerGetAvailableThingsToBuy001"..pl:UniqueID(), 0.5, (10 * 12), function()
							if AvailableThingsToBuy then
								net.Start("PlayerGetAvailableThingsToBuy")
									net.WriteTable(AvailableThingsToBuy)
								net.Send(pl)
							end
						end)
						-- For SpawnMenu
						local timerID0 = "mbd:GetSpawnListDataToSendToClient0"..pl:UniqueID()
						timer.Create(timerID0, 0.5, (10 * 12), function()
							if MBDcurrJSONFile001Data and MBDcurrJSONFile002Data and MBDSendTheSpawnListsToClients then
								timer.Remove(timerID0)
								
								MBDSendTheSpawnListsToClients(pl)
							end
						end)
					end
					--
					-- - Add a continous loop to check if Admin-status has changed for the Player..
					timer.Create("mbd:ContinuosLoopToCheckIfAdminNow"..pl:UniqueID(), 3, 0, function()
						if PlayersConnected then
							for index,playerTableMBD in pairs(PlayersConnected) do
								if playerTableMBD.UniqueID == pl:UniqueID() and (
									-- -- -
									-- -
									playerTableMBD.IsAdmin != pl:IsAdmin() or
									playerTableMBD.IsSuperAdmin != pl:IsSuperAdmin()
								) then
									-- Update..
									PlayersConnected[index].IsAdmin = pl:IsAdmin()
									PlayersConnected[index].IsSuperAdmin = pl:IsSuperAdmin()
		
									-- Update at client side also
									net.Start("PlayerConnected")
										net.WriteTable(PlayersConnected)
									net.Broadcast()

									-- Notify Player
									timer.Simple(0.3, function()
										local isAdmin if PlayersConnected[index].IsAdmin then isAdmin = "YES" else isAdmin = "NO" end
										local isSuperAdmin if PlayersConnected[index].IsSuperAdmin then isSuperAdmin = "FOK YEAH" else isSuperAdmin = "NO" end

										local message = "Your ADMIN STATUS have changed... Admin: "..isAdmin.." SuperAdmin: "..isSuperAdmin

										net.Start("NotificationReceivedFromServer")
											net.WriteTable({
												Text 	= message,
												Type	= NOTIFY_GENERIC,
												Time	= 12
											})
										net.Send(pl)
									end)
		
									break
								end
							end

							-- - -
							-- - Maybe Player needs to be unset for spectator mode.. E.g. If choosing a class as User and then becoming Admin
							-- before lobby start, the user will be stuck in spectator mode until start
							if (
								pl:IsAdmin(pl, true) and
								pl:GetNWBool("isSpectating", false) and
								!GameStarted
							) then
								if pl:GetNWInt("classInt") != -1 then
									pl:MBDGoIntoNormalMode("6.1", false, true)
								else
									pl:MBDGoIntoNormalMode("6.2")
								end
							end
							--
						end
					end)
				end
			end)
		end
	end)
end
hook.Add("PlayerInitialSpawn", "mbd:PlayerInitialSpawn001", playerInitialSpawn)
--
-- When a Player disconnects, remove them from the PlayersConnected TABLE
hook.Add("PlayerDisconnected", "mbd:PlayerDisconnected001", function(pl)
	if PlayersConnected then
		for k,v in pairs(PlayersConnected) do
			if (v.UniqueID == pl:UniqueID()) then
				table.remove(PlayersConnected, k)
	
				break
			end
		end
		-- -
		timer.Remove("mbd:ContinuosLoopToCheckIfAdminNow"..pl:UniqueID())
		--
		---
		pl:RemoveFromClassSystem(PlayerClassesAvailable, PlayersClassData)
		--
		--
		net.Start("PlayerDisconnected")
			net.WriteTable(PlayersConnected)
		net.Broadcast()
		--
		amountOfPlayersChanged()
	
		for _,_pl in pairs(player.GetAll()) do
			ClientPrintAddTextMessage(_pl, {Color(0, 173, 254), pl:Name(), Color(81, 0, 254), " has left the server."})
		end
	end
end)
--
---
----
-- -- - ==>>> WHEN A PLAYER spawns (the second time and up, after first ever spawn)
--
---
-- Choose the model for hands according to their player model. -- what ??
local function HandleWhatHappensNextAfterPlayerDeath(pl, respawnTime)
	--
	--- End game if this was the last alive Player.. >>>
	local _allPlayers = player.GetAll()
	local thereIsAPlayerStillAlive = false

	for k, v in pairs(_allPlayers) do
		if !v:GetNWBool("isSpectating", false) then thereIsAPlayerStillAlive = true end

		if k == #_allPlayers then
			-- If there is a Player and there is more than one Player on server... End game...
			if !thereIsAPlayerStillAlive and k > 1 or !thereIsAPlayerStillAlive and respawnTime < 0 then
				-- Stop the game...
				if !CurrentRoundWave then CurrentRoundWave = 0 end

				if GameStarted then
					ClientPrintAddTextMessage(v, {Color(254, 0, 46), "Every Player died... Better luck next time. The team achived wave nr. ", Color(0, 254, 208), CurrentRoundWave, Color(254, 0, 46), "!"})

					endGame()
				else startGame() timer.Simple(0.15, endGame) end
			end
		end
	end
end
hook.Add("PlayerSpawn", "mbd:PlayerSpawn001", function(pl)
	local respawnTime = GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt()

	-- UPDATE Players NW-values for buying stuff + killcount
	pl:ShouldDropWeapon(true)
	pl:SetJumpPower(285)

	if (
		pl:GetNWBool("isSpectating", false)
		and GameStarted
	) then
		pl:MBDGoIntoSpectatorMode("2")

		-- SET CUSTOM PROP ON ENT
		local d_model = ents.Create("prop_physics")

		d_model:SetModel("models/props_c17/doll01.mdl")
		d_model:SetName("mbd_d_prop")
		d_model:SetOwner(pl)
		d_model:SetSolid(SOLID_VPHYSICS)
		d_model:SetModelScale(1.3)

		d_model:SetAngles(pl:LocalToWorldAngles(Angle(0, 0, 0)))
		d_model:SetPos(pl:GetPos())

		d_model:SetParent(pl)

		d_model:Spawn()
		d_model:Activate()

		-- Just some custom stuff
		if (game.GetMap() == 'gm_construct') then
			-- SET POS FOR PLAYER
			pl:SetPos(Vector(-2942.613281, -1369.894409, -53.833542))
			-- ...SET ANGLE
			pl:SetEyeAngles(Angle(0, -40.213, 0))
		end

		HandleWhatHappensNextAfterPlayerDeath(pl, respawnTime)

		-- Then open the Lobby if respawning is enabled
		if respawnTime >= 0 then tellPlayerPlayersToOpenLobby(pl, openLobby, true) end

	elseif GameStarted then HandleWhatHappensNextAfterPlayerDeath(pl, respawnTime) pl:MBDResetPlayerHealthToMax(true) end
end)
--
---
-- - -- =>> WHEN A ENTITY is created
--
-- -
---- Some things that runs in order
local OnEntityCreatedTroubleShoot001 = false

local function CHECK_IsADoll(ent, ENTMODEL)
	if OnEntityCreatedTroubleShoot001 then print("CHECK_IsADoll", ent, ENTMODEL) end
	if (
		ENTMODEL and (
			string.match(string.lower(ENTMODEL), "gibs") or
			string.lower(ENTMODEL) == "models/props_c17/doll01.mdl"
		)
	) then setEntColorNormal(ent, "4") return true end

	return false
end
local function CHECK_MaybeIgnoreThisEnt0(ent, ENTCLASS)
	if OnEntityCreatedTroubleShoot001 then print("CHECK_MaybeIgnoreThisEnt0", ent, ENTCLASS) end
	if ent:IsValid() then
		if (
			string.match(ENTCLASS, "_env_") or
			string.match(ENTCLASS, "grenade") or
			ENTCLASS == "instanced_scripted_scene"
		) then setEntColorNormal(ent, "5") return true end
	end

	return false
end
local function CHECK_MaybeIgnoreThisEnt1(ent, ENTCLASS)
	if OnEntityCreatedTroubleShoot001 then print("CHECK_MaybeIgnoreThisEnt1", ent, ENTCLASS) end
	if (
		ENTCLASS == "mbd_npc_spawner_all" or
		ENTCLASS == "mbd_buybox" or
		ENTCLASS == "mbd_hate_trigger"
	) then setEntColorNormal(ent, "6") return true end

	return false
end
local function CHECK_MaybeIgnoreThisEnt2(ent, ENTMODEL, ENTCLASS)
	if OnEntityCreatedTroubleShoot001 then print("CHECK_MaybeIgnoreThisEnt2", ent, ENTMODEL, ENTCLASS) end
	if (
		(
			ENTMODEL and
			string.match(ENTMODEL, "gib")
		) or (
			ENTCLASS and
			string.match(ENTCLASS, "gib")
		)
	) then setEntColorNormal(ent, "7") return true end

	return false
end
local function CHECK_MaybeFreezeNPC(ent)
	if OnEntityCreatedTroubleShoot001 then print("CHECK_MaybeFreezeNPC", ent) end
	if ent and ent:IsValid() and ent:IsNPC() then
		if timer.Exists("mbd:nextRoundCountdown001") then
			timer.Simple(1.15, function()
				if !ent or !ent:IsValid() or !ent:IsNPC() then return true end
				
				-- Freez...
				-- STOP NPC THINKING
				ent:AddEFlags(EFL_NO_THINK_FUNCTION)
			end)
		end
	end

	return false
end
local function MAYBE_SetNormalColorEnt(ent, ENTCLASS)
	if OnEntityCreatedTroubleShoot001 then print("MAYBE_SetNormalColorEnt", ent, ENTCLASS) end
	if (
		MBD_CheckIfNotBullseyeEntity(ENTCLASS)
		and ENTCLASS != "mbd_hate_trigger"
	) then setEntColorNormal(ent, "2") end
end
local function MAYBE_ScaleEntityNPC(ent)
	if ent and ent:IsValid() and ent:IsNPC() and ent:GetName() == "NPCSpawnerNPC" then
		local entClass = ent:GetClass()

		if string.match(entClass, "headcrab") then
			-- Scale it if needed...
			MBDMaybeScaleNPCModel(nil, ent)
		end
	end
end

hook.Add("OnEntityCreated", "mbd:OnEntityCreated001", function(ent)
	local ENTCLASS = ent:GetClass()
	local ENTMODEL = ent:GetModel()

	-- MOVED TO CLIENTSIDE .... Don't need anymore

	-- Make transparent
	setEntColorTransparent(ent, "1")

	-- Add to counter if it is an NPC -->> (do this only for NPC Spawner)
	-- MAYBE_IsANPC(ent, ENTCLASS)

	-- Stop here for Doll
	if CHECK_IsADoll(ent, ENTMODEL) then return end

	-- Non accepted ents in this hook
	if CHECK_MaybeIgnoreThisEnt0(ent, ENTCLASS) then return end
	-- IF an antilion guard gets killed and spawns parts of itself... aka class with name "prop_physics", ignore
	if CHECK_MaybeIgnoreThisEnt1(ent, ENTCLASS) then return end
	-- IF a gib
	if CHECK_MaybeIgnoreThisEnt2(ent, ENTMODEL, ENTCLASS) then return end

	-- Freez NPC if the game is paused... Maybe a headcrab spawns from a killed zombie...?
	if CHECK_MaybeFreezeNPC(ent) then return end

	-- Reset color
	MAYBE_SetNormalColorEnt(ent, ENTCLASS)
	
	-- Set model size
	-- MAYBE_ScaleEntityNPC(ent)

	-- For e.g. NPC Headcrab that spawns after a NPC Zombie is killed
	if ent:IsNPC() and string.match(ent:GetClass(), "headcrab") then
		timer.Simple(1.5, function()
			if IsValid(ent) then ent:MBDNPCLikeAllOtherNPCClassesInMergedNPCsTable() end
		end)
	end
end)
--
----
net.Receive("PlayerWantsToSpawnProp", function(len, pl)
	local ent 						= net.ReadEntity()
	local playerCurrentBuildPoints	= pl:GetNWInt("buildPoints", -1)

	-- Get the Owner (Player)
	local ownerOfEntity = pl

	-- SECURITY!
	if !MBDPropWhiteList then if ent and ent:IsValid() then undoEntityWithOwner(ownerOfEntity, ent, "Returned a Prop (could not get whitelist)") end return end

	local costOfProp = GetDynamicPriceForThisProp(ent)
	
	if ent and ent:IsValid() then ent:SetNWBool("CanNotGetDamage", true) end
	
	timer.Simple(0.15, function()
		if (!ent:IsValid()) then return end

		-- --- >>
		local _amountOfTries 	= 3 -- If you can't get players bp... try this function again x amount of times again...
		local _tryAgain 		= false

		--
		-- --
		if (
			playerCurrentBuildPoints < 0 and
			_amountOfTries > 0 and
			_tryAgain
		) then
			_tryAgain 		= true
			_amountOfTries 	= (_amountOfTries - 1)

			playerCurrentBuildPoints = pl:GetNWInt("buildPoints", -1)
			
			return GiveProp()
		elseif (
			playerCurrentBuildPoints < 0 and
			_amountOfTries <= 0 and
			_tryAgain
		) then
			ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "M.B.D. Buy Prop Error: For some reason, your B.P. is < 0..."})

			return
		end
	
		-- A PROP IS SPAWNED....
		--- -- - >
		local function deleteProp(id)
			--
			--print("Deleted from:", id)
			undoEntityWithOwner(ownerOfEntity, ent, "Returned a Prop (not enough money)")
		end
		if (
			!string.match(ent:GetClass(), "prop_vehicle") and
			(
				!playerCurrentBuildPoints or
				playerCurrentBuildPoints <= 0
			) and
			pl:MBDIsNotAnAdmin(true)
		) then
			if (
				!playerCurrentBuildPoints or
				playerCurrentBuildPoints <= 0
			) then ClientPrintAddTextMessage(pl, {Color(254, 81, 0), "You have no build points currently..."}) end
			
			deleteProp("1")
			
			return false
		end
		--
		--- --
		--
		-- SET THE COLOR TO INVISIBLE....JUST FOR VISUAL PURPOSES
		timer.Simple(0, function()
			if (
				ent:IsValid() and
				ent:GetName() != "mbd_d_prop" and
				ent:GetClass() == "prop_physics"
			) then
				if !ent:IsValid() then return nil end

				if ent:GetName() != "mbd_d_prop" then ent:SetRenderMode(RENDERMODE_NORMAL) end
				--
				--- -
				-- SECURITY!
				local entModel = ent:GetModel()
				local isAWhitelistedProp = MBDCheckTheWhiteListTableForMatch(entModel, pl, true)
				if !string.match(ent:GetClass(), "prop_vehicle") and isAWhitelistedProp --[[ IMPORTANT ]] then
					--
					if pl:MBDShouldGetTheAdminBenefits() then
						-- It is a superadmin; he gets it for free...>>
						--
						ent:SetNWInt("healthTotal", GetDynamicHealthForThisProp(ent).Health)
						ent:SetNWInt("healthLeft", GetDynamicHealthForThisProp(ent).Health)

						MBDSetConditionsForProp(ent, false, pl, playerCurrentBuildPoints, nil)
					else
						if !GameStarted or playerCurrentBuildPoints >= costOfProp then
							-- SET NEW HEALTH FOR PROP (SEVERSIDE) !!
							-- Normal Prop
							ent:SetNWInt("healthTotal", GetDynamicHealthForThisProp(ent).Health)
							ent:SetNWInt("healthLeft", GetDynamicHealthForThisProp(ent).Health)

							local cop = costOfProp
							if !GameStarted then cop = nil end
							MBDSetConditionsForProp(ent, false, pl, playerCurrentBuildPoints, cop)
						else
							ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "This prop is to expensive for you! This prop costs: ", Color(254, 81, 0), costOfProp, Color(173, 254, 0), " B.P"})
							net.Start("NotificationReceivedFromServer")
								net.WriteTable({
									Text 	= "Not enough cash",
									Type	= NOTIFY_ERROR,
									Time	= 2
								})
							net.Send(pl)

							deleteProp("2")
						end
					end
				elseif ent and ent:IsValid() then undoEntityWithOwner(ownerOfEntity, ent, "Returned a Prop (blacklisted)") return end
			end
		end)
	end)
end)
----
---
--
--- -  =>==>> WHEN A NPC is killed
--
--
--- A NPC was KILLED
hook.Add("OnNPCKilled", "mbd:OnNPCKilled001", function(npc, attacker, inflictor)
	-- MBDMaybeScaleToNormalNPCLooseBodyparts(npc)

	if !MBD_CheckIfCanContinueBecauseOfTheNPCClass(npc:GetClass()) then return end
	--
	-- GIVE THE PLAYER (attacker) a kill point
	local __moneyGive 		= nil
	local __buildPointsGive = nil
	--
	-- CALCULATE MONEY BASED ON THE ENTITYS MAX HEALTH..
	function calculateMoney(A)
		--
		return math.Round(((A * 3) / 9), 0)
	end
	function calculateBuildPoints(A)
		--
		return math.Round((A / 9), 0)
	end

	__moneyGive 		= calculateMoney(		npc:GetMaxHealth())
	__buildPointsGive 	= calculateBuildPoints(	npc:GetMaxHealth())
	--
	--
	if (attacker:IsPlayer()) then
		-- -
		attacker:SetNWInt("killCount", (attacker:GetNWInt("killCount", "0") + 1))

		--- -
		local npcPos = npc:GetPos() + Vector(0, 0, 15)
		local npcAngle = npc:GetAngles()
		-- -
		timer.Simple(0.1, function()
			local money = ents.Create("mbd_npc_drop_giver")
			money:SetModel("models/props_lab/clipboard.mdl")

			money:SetPos(npcPos + Vector(math.random(0, 5), math.random(0, 5), 3))
			money:SetAngles(npcAngle)

			money:SetTypeToGive("money")
			money:SetAmountToGive(__moneyGive)

			money:Spawn()
			money:Activate()
			--
			local buildPoints = ents.Create("mbd_npc_drop_giver")
			buildPoints:SetModel("models/props_c17/tools_wrench01a.mdl")

			buildPoints:SetPos(npcPos + Vector(math.random(-1, -5), math.random(-1, -5), 0))
			buildPoints:SetAngles(npcAngle)

			buildPoints:SetTypeToGive("buildPoints")
			buildPoints:SetAmountToGive(__buildPointsGive)

			buildPoints:Spawn()
			buildPoints:Activate()
		end)
	end
end)
--
--
-- - - ==>>> WHEN A PROP/NPC was damaged
--
---
local function scaleDmg(npc, dmginfo)
	npc:StopParticles()

	net.Start("mbd_PlayParticleEffectStopClient")
		net.WriteEntity(npc)
	net.Broadcast()
	
	dmginfo:ScaleDamage(npc:Health())
end
-- - -
-- Particle effect Attach..
local function particleEffectAttach(attachName, npc, attackerEnt)
	local npcAttachID = npc:LookupAttachment(attachName)
	if npcAttachID > 0 then
		ParticleEffectAttach("mbd_blood_droplets_00", PATTACH_POINT_FOLLOW, npc, npcAttachID)
	end

	if !GameIsSinglePlayer and attackerEnt and attackerEnt:IsValid() and attackerEnt:IsPlayer() then
		net.Start("mbd_PlayParticleEffectAttachClient")
		net.WriteTable({
			"mbd_blood_droplets_00",
				PATTACH_POINT_FOLLOW,
				npc,
				npcAttachID
			})
		net.Send(attackerEnt)
	end

	-- Particle effect on world
	local trace = util.TraceLine({
		start = npc:GetPos(),
		endpos = npc:GetPos() + Vector(0, 0, -500),
		filter = function(ent) if ent == game.GetWorld() then return true end end
	})
	local tracePos = trace.HitPos

	ParticleEffect("mbd_blood_droplets_01", tracePos, Angle(0, 0, 0), nil)
	if !GameIsSinglePlayer and attackerEnt and attackerEnt:IsValid() and attackerEnt:IsPlayer() then
		net.Start("mbd_PlayParticleEffectClient")
			net.WriteTable({
				"mbd_blood_droplets_01",
				tracePos,
				Angle(0, 0, 0),
				nil
			})
		net.Send(attackerEnt)
	end
end
local function particleEffectAttach2(attachName, effectName, npc, attackerEnt)
	local npcAttachID = npc:LookupAttachment(attachName)
	if npcAttachID > 0 then
		ParticleEffectAttach(effectName, PATTACH_POINT_FOLLOW, npc, npcAttachID)
	end

	if !GameIsSinglePlayer and attackerEnt and attackerEnt:IsValid() and attackerEnt:IsPlayer() then
		net.Start("mbd_PlayParticleEffectAttachClient")
		net.WriteTable({
			effectName,
			PATTACH_POINT_FOLLOW,
			npc,
			npcAttachID
			})
		net.Send(attackerEnt)
	end
end
-- Change the model of the NPC..
local function SpawnBodyPartNPC( bodygroupName, npc, npcModel, dmginfo )
	local removeBodyGroup_HEAD = npc:GetNWBool("alreadySpawnedBodyGroup_HEAD", false)
	local removeBodyGroup_LEFTARM = npc:GetNWBool("alreadySpawnedBodyGroup_LEFTARM", false)
	local removeBodyGroup_RIGHTARM = npc:GetNWBool("alreadySpawnedBodyGroup_RIGHTARM", false)
	local removeBodyGroup_LEFTLEG = npc:GetNWBool("alreadySpawnedBodyGroup_LEFTLEG", false)
	local removeBodyGroup_RIGHTLEG = npc:GetNWBool("alreadySpawnedBodyGroup_RIGHTLEG", false)
	-- Maybe cancel...
	if bodygroupName == "HEAD" and removeBodyGroup_HEAD then return end
	if bodygroupName == "LEFTARM" and removeBodyGroup_LEFTARM then return end
	if bodygroupName == "RIGHTARM" and removeBodyGroup_RIGHTARM then return end
	if bodygroupName == "LEFTLEG" and removeBodyGroup_LEFTLEG then return end
	if bodygroupName == "RIGHTLEG" and removeBodyGroup_RIGHTLEG then return end

	net.Start( "mbd:SpawnNPCBodyParts" )

		net.WriteTable({
			npc				= npc,
			npcModel		= npcModel,
			bodygroupName	= bodygroupName,
			npcModelScale	= npc:GetModelScale(),
			ang				= AngleRand(),
			pos				= dmginfo:GetDamagePosition(),
			attacker		= dmginfo:GetAttacker(),
			damageForce		= dmginfo:GetDamageForce()
		})

	net.Broadcast()

	-- Particle effect
	if bodygroupName == "HEAD" then particleEffectAttach2("bodypart_blood_HEAD", "mbd_blood_trail_00", npc, dmgInfo) end
	if bodygroupName == "LEFTARM" then particleEffectAttach2("bodypart_blood_LEFTARM", "mbd_blood_trail_00", npc, dmgInfo) fleshPlayARandomSound(bodypart) end
	if bodygroupName == "RIGHTARM" then particleEffectAttach2("bodypart_blood_RIGHTARM", "mbd_blood_trail_00", npc, dmgInfo) fleshPlayARandomSound(bodypart) end
	if bodygroupName == "LEFTLEG" then particleEffectAttach2("bodypart_blood_LEFTLEG", "mbd_blood_trail_00", npc, dmgInfo) fleshPlayARandomSound(bodypart) end
	if bodygroupName == "RIGHTLEG" then particleEffectAttach2("bodypart_blood_RIGHTLEG", "mbd_blood_trail_00", npc, dmgInfo) fleshPlayARandomSound(bodypart) end
end
local function SetBodyGroupNPC(bodygroupName, npc, npcModel, dmginfo)
	local bodygroupID = npc:FindBodygroupByName(bodygroupName)

	if npc:GetBodygroup(bodygroupID) == 1 then return end -- Don't spawn more than one time for each bodypart

	npc:SetBodygroup(bodygroupID, 1)

	-- Spawn the body group
	SpawnBodyPartNPC( bodygroupName, npc, npcModel, dmginfo )
end
hook.Add("ScaleNPCDamage", "mbd:ScaleNPCDamage001", function(npc, hitgroup, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if (
		not attacker:GetNWBool("NPCSpawnWasASuccess", true) or (
			attacker:IsNPC() and (
				not attacker:GetNWBool("NPCSpawnWasASuccess", false)
			)
		)
	) then dmginfo:ScaleDamage(0) return end

	-- Save the force from the gun...
	npc:SetNWVector("mbd:damageForceOnDeath", dmginfo:GetDamageForce() / 2 + Vector(0, 0, 200))

	local npcCLass = npc:GetClass()

	if MBD_CheckIfCanContinueBecauseOfTheNPCClass(npcCLass) then
		-- Make NPCs handle more damage if the Round/Wave is higher....
		-- -- - > >>>
		local _base = 1.65 -- 1 = normal (higher = NPC's take more damage)

		-- Very scaled up NPCs will have higher health (take less damage)
		if not npc or not npc:IsValid() then return end
		if npc:GetModelScale() and npc:GetModelScale() >= 2.8 then
			_base = (_base / 2.1)
		end

		if hitgroup == HITGROUP_HEAD then
			-- Insta kill almost always...
			-- -- -
			dmginfo:ScaleDamage(_base * 6)

			-- If killed..
			local npcAttahHead = npc:LookupAttachment("head")
			local npcAttahEye = npc:LookupAttachment("eyes")

			local attachmentID
			if npcAttahHead and npcAttahHead > 0 then
				attachmentID = npcAttahHead
			elseif npcAttahEye and npcAttahEye > 0 then
				attachmentID = npcAttahEye
			end
			if attachmentID then
				-- local boneVec, boneAng = npc:GetBonePosition(npcHeadBoneID)

				local nextHealth = npc:Health() - (dmginfo:GetDamage() * _base * 6)
				if nextHealth <= 0 and dmginfo:IsBulletDamage() then
					ParticleEffectAttach("mbd_blood_cloud_01", PATTACH_POINT_FOLLOW, npc, attachmentID)
					ParticleEffectAttach("mbd_blood_trail_00", PATTACH_POINT_FOLLOW, npc, attachmentID)
					ParticleEffectAttach("antlion_gib_02_slime", PATTACH_POINT_FOLLOW, npc, attachmentID)
					ParticleEffectAttach("antlion_gib_02_juice", PATTACH_POINT_FOLLOW, npc, attachmentID)

					fleshPlayHeadShotSound(npc)
					
					local attackerEnt = dmginfo:GetAttacker()
					if !GameIsSinglePlayer and attackerEnt and attackerEnt:IsValid() and attackerEnt:IsPlayer() then
						net.Start("mbd_PlayParticleEffectAttachClient")
						net.WriteTable({
							"mbd_blood_cloud_01",
								PATTACH_POINT_FOLLOW,
								npc,
								attachmentID
							})
						net.Send(attackerEnt)
						--
						net.Start("mbd_PlayParticleEffectAttachClient")
						net.WriteTable({
							"mbd_blood_trail_00",
								PATTACH_POINT_FOLLOW,
								npc,
								attachmentID
							})
						net.Send(attackerEnt)
						-- -
						net.Start("mbd_PlayParticleEffectAttachClient")
							net.WriteTable({
								"antlion_gib_02_slime",
								PATTACH_POINT_FOLLOW,
								npc,
								attachmentID
							})
						net.Send(attackerEnt)
						--
						net.Start("mbd_PlayParticleEffectAttachClient")
							net.WriteTable({
								"antlion_gib_02_juice",
								PATTACH_POINT_FOLLOW,
								npc,
								attachmentID
							})
						net.Send(attackerEnt)
					end
				end
			end
		else
			local pos = dmginfo:GetDamagePosition()
			local ang = dmginfo:GetAttacker():EyeAngles()

			spawnBodyBodyPartParticles(npc, pos, ang, true)
		end

		if CurrentRoundWave then
			if CurrentRoundWave >= 30 then
				dmginfo:ScaleDamage(_base * 0.5)
			elseif CurrentRoundWave >= 20 then
				dmginfo:ScaleDamage(_base * 0.65)
			elseif CurrentRoundWave >= 15 then
				dmginfo:ScaleDamage(_base * 0.75)
			elseif CurrentRoundWave >= 10 then
				dmginfo:ScaleDamage(_base * 0.85)
			elseif CurrentRoundWave >= 5 then
				dmginfo:ScaleDamage(_base * 0.95)
			else
				dmginfo:ScaleDamage(_base)
			end
		end

		-- -- -
		-- - - -- Change the model of the NPC (maybe remove bodygroups..)
		local npcModel = string.lower(npc:GetModel())
		if
			npcModel == string.lower("models/zombie/Classic_split.mdl") or
			npcModel == string.lower("models/zombie/Zombie_Soldier_split.mdl") or
			npcModel == string.lower("models/combine/Combine_Super_Soldier_split.mdl") or
			npcModel == string.lower("models/combine/Combine_Soldier_split.mdl") or
			npcModel == string.lower("models/combine/Combine_Soldier_PrisonGuard_split.mdl")--[[  or
			npcModel == "models/police.mdl" ]]
		then
			if dmginfo:GetDamage() >= 12 then
				-- DYNAMIC
				if npcModel == string.lower("models/zombie/Classic_split.mdl") then
					if hitgroup == HITGROUP_LEFTLEG then npc:SetNWBool("removeBodyGroup_LEFTLEG", true) end
					if hitgroup == HITGROUP_RIGHTARM then npc:SetNWBool("removeBodyGroup_RIGHTARM", true) end
					if hitgroup == HITGROUP_LEFTARM then npc:SetNWBool("removeBodyGroup_LEFTARM", true) end
				elseif npcModel == string.lower("models/zombie/Zombie_Soldier_split.mdl") then
					if hitgroup == HITGROUP_LEFTLEG then npc:SetNWBool("removeBodyGroup_LEFTLEG", true) end
					if hitgroup == HITGROUP_RIGHTARM then npc:SetNWBool("removeBodyGroup_RIGHTARM", true) end
				elseif
					npcModel == string.lower("models/combine/Combine_Super_Soldier_split.mdl") or
					npcModel == string.lower("models/combine/Combine_Soldier_split.mdl") or
					npcModel == string.lower("models/combine/Combine_Soldier_PrisonGuard_split.mdl")
				then
					if hitgroup == HITGROUP_LEFTARM then npc:SetNWBool("removeBodyGroup_LEFTARM", true) end
					if hitgroup == HITGROUP_RIGHTLEG then npc:SetNWBool("removeBodyGroup_RIGHTLEG", true) end
				end
			end
			-- -
			if dmginfo:GetDamage() >= npc:Health() or npc:Health() <= 0 then
				-- DYNAMIC
				if npcModel == string.lower("models/zombie/Classic_split.mdl") then
					if hitgroup == HITGROUP_RIGHTLEG then npc:SetNWBool("removeBodyGroup_RIGHTLEG", true) scaleDmg(npc, dmginfo) end
					if hitgroup == HITGROUP_HEAD then npc:SetNWBool("removeBodyGroup_HEAD", true) scaleDmg(npc, dmginfo) end
				elseif npcModel == string.lower("models/zombie/Zombie_Soldier_split.mdl") then
					if hitgroup == HITGROUP_LEFTARM then npc:SetNWBool("removeBodyGroup_LEFTARM", true) scaleDmg(npc, dmginfo) end
					if hitgroup == HITGROUP_LEFTLEG then npc:SetNWBool("removeBodyGroup_LEFTLEG", true) scaleDmg(npc, dmginfo) end
					if hitgroup == HITGROUP_RIGHTLEG then npc:SetNWBool("removeBodyGroup_RIGHTLEG", true) scaleDmg(npc, dmginfo) end
				elseif
					npcModel == string.lower("models/combine/Combine_Super_Soldier_split.mdl") or
					npcModel == string.lower("models/combine/Combine_Soldier_split.mdl") or
					npcModel == string.lower("models/combine/Combine_Soldier_PrisonGuard_split.mdl")
				then
					if hitgroup == HITGROUP_RIGHTARM then npc:SetNWBool("removeBodyGroup_RIGHTARM", true) scaleDmg(npc, dmginfo) end
					if hitgroup == HITGROUP_LEFTLEG then npc:SetNWBool("removeBodyGroup_LEFTLEG", true) scaleDmg(npc, dmginfo) end
					if hitgroup == HITGROUP_HEAD then npc:SetNWBool("removeBodyGroup_HEAD", true) scaleDmg(npc, dmginfo) end
				end
			end
			-- - -
			-- -- - -
			local removeBodyGroup_HEAD = npc:GetNWBool("removeBodyGroup_HEAD", false)
			local removeBodyGroup_LEFTARM = npc:GetNWBool("removeBodyGroup_LEFTARM", false)
			local removeBodyGroup_RIGHTARM = npc:GetNWBool("removeBodyGroup_RIGHTARM", false)
			local removeBodyGroup_LEFTLEG = npc:GetNWBool("removeBodyGroup_LEFTLEG", false)
			local removeBodyGroup_RIGHTLEG = npc:GetNWBool("removeBodyGroup_RIGHTLEG", false)

			if removeBodyGroup_HEAD then SetBodyGroupNPC("HEAD", npc, npcModel, dmginfo) end
			if removeBodyGroup_LEFTARM then particleEffectAttach("bodypart_blood_LEFTARM", npc, dmgInfo) SetBodyGroupNPC("LEFTARM", npc, npcModel, dmginfo) end
			if removeBodyGroup_RIGHTARM then particleEffectAttach("bodypart_blood_RIGHTARM", npc, dmgInfo) SetBodyGroupNPC("RIGHTARM", npc, npcModel, dmginfo) end
			if removeBodyGroup_LEFTLEG then particleEffectAttach("bodypart_blood_LEFTLEG", npc, dmgInfo) SetBodyGroupNPC("LEFTLEG", npc, npcModel, dmginfo) end
			if removeBodyGroup_RIGHTLEG then particleEffectAttach("bodypart_blood_RIGHTLEG", npc, dmgInfo) SetBodyGroupNPC("RIGHTLEG", npc, npcModel, dmginfo) end
		end
	end
end)
local destructableProps = {
	"models/props_c17/oildrum001_explosive.mdl"
}
local function IsNotUnvalidNPCType(ent)
	if (
		MBD_CheckIfNotBullseyeEntity(ent:GetClass()) --[[ and
		ent:GetClass() != "mbd_hate_trigger" ]]
	) then return true else return false end
end
local function EntIsAMBDTriggerAndParentIsValid(ent)
	if (ent:GetClass() == "mbd_hate_trigger") then
		if (entParent:IsValid()) then
			-- Is a valid Prop>>
			--
			return true
		else return nil end
	else return nil end
end
local function MaybeRemovePropIfHurtEnough( ent, newHealth, didDamage, didDamageInflictor )
	if (
		ent and
		ent:IsValid() and
		newHealth <= 0 and
		!ent:GetNWBool("iHaveSpawnedMyKillProps", false) and
		!ent:IsPlayer() and
		!ent:IsNPC() and
		!ent:GetNWBool("hasReceivedDeadDamage", false)
	) then
		if (!ent:IsValid()) then return false end
		if ent:GetCollisionGroup() == COLLISION_GROUP_DEBRIS then return end

		-- Get the Owner (Player)
		local ownerOfEntity = ent:GetCreator() --ent:GetNWEntity("PlayerOwnerEnt", nil)

		-- Exceptions (for destructable props !!)...
		if (
			-- Barrels can explode...
			table.HasValue(destructableProps, string.lower(ent:GetModel()))
		) then
			ent:SetNWBool("shouldNotGiveBuildPoints", true)

			-- Something wrong with this....
			ent:Ignite(10, 160)

			-- This is necasaryy...
			local dmginfo2 = DamageInfo()
			dmginfo2:SetDamageType(DMG_BURN)
			dmginfo2:SetInflictor(didDamageInflictor)
			dmginfo2:SetAttacker(didDamage)
			dmginfo2:SetDamageForce(Vector(100, 100, 100))
			dmginfo2:SetDamagePosition(ent:GetPos())
			--dmginfo2:SetDamage(90000)
			
			ent:SetNWBool("hasReceivedDeadDamage", true)

			timer.Simple(1, function()
				if (
					ent and
					ent:IsValid()
				) then ent:TakeDamageInfo(dmginfo2) end
			end)
		else
			ent:SetNWBool("iHaveSpawnedMyKillProps", true)

			--
			-- Create new random position of killmodel-props
			SpawnKillmodelProps( ent, { "models/hunter/blocks/cube025x025x025.mdl", "models/hunter/blocks/cube025x025x025.mdl", "models/hunter/blocks/cube025x025x025.mdl" }, 0 )

			-- DELETE PROP...
			timer.Simple(0.05, function()
				if (ent:IsValid()) then
					ent:SetNWBool("shouldNotGiveBuildPoints", true)
					--
					----
					undoEntityWithOwner(ownerOfEntity, ent, nil, true)

					if didDamage:IsValid() and didDamage:IsPlayer() then
						net.Start("RemoveNotificationTimer")
							net.WriteString("mbd:RemoveEnt001:"..ent:EntIndex())
						net.Send(didDamage)
					end
				end
			end)
		end
	end
end
hook.Add("EntityTakeDamage", "mbd:EntDamage001", function(ent, dmginfo)
	if not ent or not ent:IsValid() then return end

	local __EntInflictorModel = dmginfo:GetInflictor()
	if __EntInflictorModel and __EntInflictorModel:IsValid() then
		__EntInflictorModel = __EntInflictorModel:GetModel()
		if __EntInflictorModel then
			__EntInflictorModel = string.lower(__EntInflictorModel)
		else return end
	else return end

	if not ent or not ent:IsValid() then return end
	local __EntModel = ent:GetModel()
	if __EntModel then
		__EntModel = string.lower(__EntModel)
	else return end
	if (
		dmginfo:GetInflictor() and
		dmginfo:GetInflictor():IsValid() and
		table.HasValue(destructableProps, string.lower(__EntInflictorModel))
	) then return end -- Let the damage be as is

	if not ent or not ent:IsValid() then return end
	if (
		bit.bor(dmginfo:GetDamageType(), DMG_BURN) == DMG_BURN and
		ent and
		ent:IsValid() and
		table.HasValue(destructableProps, __EntModel)
	) then
		timer.Simple(2, function()
			if (
				ent and
				ent:IsValid()
			) then ent:SetHealth(0) end
		end)

		return
	end

	local entParent = ent:GetParent()
	if (
		entParent and
		entParent:IsValid() and
		!MBD_CheckIfNotBullseyeEntity(ent:GetClass())
	) then
		entParent = entParent:GetNWEntity("mbd_npc_bullseye_parent", nil)
	end
	
	local _Class = ent:GetClass()
	if (
		_Class == "mbd_door_trigger" or
		_Class == "mbd_hate_trigger" or
		_Class == "mbd_healing_trigger" or
		_Class == "mbd_prop_block_npc"
	) then
		-- Get Parent, and set it as the ent
		---
		ent = ent:GetParent()
	end
	
	if (
		(
			ent:IsValid() and
			ent:GetNWBool("CanNotGetDamage", false)
		) or (
			!MBD_CheckIfNotBullseyeEntity(ent:GetClass()) and
			entParent:IsValid() and
			entParent:GetNWBool("CanNotGetDamage", false)
		)
	) then dmginfo:ScaleDamage(0) return end

	local damageTaken 			= dmginfo:GetDamage()

	local didDamage 			= dmginfo:GetAttacker()
	local didDamageInflictor 	= dmginfo:GetInflictor()

	-- Make Players receive more damage...
	if ent and ent:IsValid() and ent:IsPlayer() then
		local _classInt = ent:GetNWInt("classInt", -1)

		if _classInt == 3 then
			-- Terminator clas
			dmginfo:ScaleDamage(0.93)
		else
			--  Everything other class
			dmginfo:ScaleDamage(1.31)
		end
	end

	local NPCBullseye = nil
	if !MBD_CheckIfNotBullseyeEntity(ent:GetClass()) then
		NPCBullseye = ent
		if NPCBullseye:GetClass() == "mbd_npc_bullseye" then
			NPCBullseye = ent:GetChildren()[1]
		end
		
		-- We don't want the normal damage... This messes up things....
		dmginfo:ScaleDamage(0)
		
		if (
			didDamage and
			didDamage:IsValid() and
			didDamage:IsPlayer()
		) then
			-- Players can't damage NPC bullseye... This is because it messes up the balance...
			-- - -
			return
		end
	end

	-- PLAYERS CAN NOT DAMAGE EACHOTHER | IMPORTANT ... this can be adjusted if needed/wanted by an ADMIN... (this is not added yet)
	if not didDamageInflictor or not didDamageInflictor:IsValid() then return end
	if (
		(
			didDamageInflictor:GetClass() == "prop_physics"
		) or (
			!string.match(didDamageInflictor:GetClass(), "vehicle") and
			ent == didDamage
		) or (
			didDamage:IsValid() and
			didDamage:IsPlayer() and
			ent:IsValid() and
			ent:IsPlayer() and
			ent != didDamage
		)
	) then dmginfo:ScaleDamage(0) return end
	--
	local __EntModel = ent:GetModel()
	if (
		!__EntModel or
		(
			__EntModel and
			string.match(__EntModel, "gibs") -- If e.g. an antilion gib(s) gets destroyed ?
		)
	) then return end
	--
	-- NPC bullseye or hate triggers takes no damage....
	if (
		ent:IsValid() and
		!IsNotUnvalidNPCType(ent) -- NPC Bullseye and MBD hate trigger will get no damage
	) then
		-- Special prop
		dmginfo:ScaleDamage(0)
	elseif (
		ent:IsValid() and
		string.match(ent:GetClass(), "prop_physics")
	) then
		-- Normal Prop
		dmginfo:ScaleDamage(0)
	end
	--
	--
	--- - If a Vehicle/or some NPC took damage ...
	local __EntClass 			= ent:GetClass() 				-- Took damage
	local __EntClassDidDamage 	= didDamage:GetClass() 			-- Did damage
	local __EntClassInflictor 	= didDamageInflictor:GetClass() -- Who did the damage (could be a Player, could be a Vehicle...)
	--
	--- ---
	if (
		didDamageInflictor:IsValid() and
		didDamageInflictor.IsValidVehicle and
		didDamageInflictor:IsValidVehicle() and
		__EntClassInflictor and
		string.match(__EntClassInflictor, "prop_vehicle") and
		ent:IsValid() and
		didDamage:IsValid() and
		(
			ent == didDamage or
			!ent:IsPlayer()
		) and
		!ent:IsNPC()
	) then
		--
		-- The car collided with e.g. the World, where Player hurt itself
		if (ent == didDamage) then
			didDamageInflictor:SetNWInt("healthLeft", (didDamageInflictor:GetNWInt("healthLeft", -1) - (damageTaken * 17)))
		elseif (ent:GetClass() == "prop_physics") then
			--
			-- The prop the Vehicle hit...>>
			local newHealth = ent:GetNWInt("healthLeft", -1) - damageTaken
			ent:SetNWInt("healthLeft", newHealth)
			
			MaybeRemovePropIfHurtEnough(ent, newHealth, didDamage, didDamageInflictor)
		end
	elseif (
		ent:IsValid() and
		IsNotUnvalidNPCType(ent) and
		(
			__EntClassDidDamage and
			string.match(__EntClassDidDamage, "prop_vehicle") and
			didDamage.IsValidVehicle and
			didDamage:IsValidVehicle()
		) or (
			__EntClassInflictor and
			string.match(__EntClassInflictor, "prop_vehicle") and
			didDamageInflictor.IsValidVehicle and
			didDamageInflictor:IsValidVehicle()
		) or
		ent:IsNPC()
	) then
		-- I.e. a vehicle hit a NPC.. >>
		-- Choose one...>>
		if (
			string.match(__EntClassDidDamage, "prop_vehicle") and
			ent:IsNPC()
		) then
			--
			-- The car hit a NPC
			didDamage:SetNWInt("healthLeft", (didDamage:GetNWInt("healthLeft", -1) - (damageTaken / 5)))
		elseif (
			ent:IsValid() and
			ent:IsNPC()
		) then
			if (
				didDamageInflictor:IsValid() and
				didDamageInflictor:IsPlayer() and
				didDamageInflictor.IsValidVehicle and
				didDamageInflictor:GetVehicle():IsValidVehicle()
			) then
				local _Vehicle = didDamageInflictor:GetVehicle()
				--
				-- A Player did the damage, so set its Vehicle health >>
				_Vehicle:SetNWInt("healthLeft", (_Vehicle:GetNWInt("healthLeft", -1) - (damageTaken / 5)))
			elseif (
				didDamageInflictor:IsValid() and
				!didDamageInflictor:IsPlayer()
			) then
				--
				-- The Vehicle was the Inflictor>>
				didDamageInflictor:SetNWInt("healthLeft", (didDamageInflictor:GetNWInt("healthLeft", -1) - (damageTaken / 5)))
			end
		end
	elseif (
		(
			(
				__EntClass and
				string.match(__EntClass, "prop_vehicle")
			) or
			(
				EntIsAMBDTriggerAndParentIsValid(ent)
			)
		) and
		didDamage:IsValid() and
		didDamage:IsNPC()
	) then
		--
		-- A NPC attacked a Vehicle.. >>
		if (EntIsAMBDTriggerAndParentIsValid(ent)) then
			--
			-- It was a MBD trigger on the Vehicle that took damage>>
			entParent:SetNWInt("healthLeft", (entParent:GetNWInt("healthLeft", -1) - damageTaken))
		else
			--
			-- It was the Vehicle that took damage
			ent:SetNWInt("healthLeft", (ent:GetNWInt("healthLeft", -1) - damageTaken))
		end
	end

	--- ---->>
	-- Normal NPC...>>
	if (
		ent:IsNPC() and
		IsNotUnvalidNPCType(ent)
	) then return end

	if (
		didDamage:IsNPC() and
		IsNotUnvalidNPCType(didDamage) and
		ent:IsPlayer() and
		GameStarted == false
	) then dmginfo:ScaleDamage(0) return end
	--
	--- --->>
	if (
		(
			!string.match(__EntClass, "prop_vehicle") and
			!string.match(__EntClassInflictor, "prop_vehicle")
		) and
			ent:GetName() != "mbd_prop_bullseye_target" and (
			!ent:IsValid() or
			(
				ent:IsPlayer() or
				ent:IsNPC() or
				(
					ent:GetClass() != 'prop_physics' and
					!string.match(ent:GetClass(), "prop_vehicle")
				) or
				string.match(ent:GetModel(), "models/hunter/blocks/cube025x025x025.mdl")
			)
		)
	) then return elseif (ent:GetName() == "mbd_prop_bullseye_target") then
		-- Make NPC Bullseye not loose any health; have this NPC only as an attack-point
		dmginfo:ScaleDamage(0)

		-- ... Apply damage to parent instead later...
		if (entParent:IsValid()) then
			ent = entParent
		else return end
	end
	--
	--- --
	---
	-- Don't take any damage if it was a PLAYER or THE WORLD
	if (
		didDamage:IsValid() and (
			didDamage:IsWorld() or
			didDamage:IsPlayer() or
			(
				didDamage:IsNPC() and
				IsNotUnvalidNPCType(didDamage)
			)
		)
	) then
		--
		--- Set Take DAMAGE..
		local currentHealth = ent:GetNWInt("healthLeft", -1)
		local newHealth 	= (currentHealth - damageTaken)
		
		-- --- --->>
		---
		local __VehicleHealth	= didDamageInflictor:GetNWInt("healthLeft", false) -- Gets set above if... For Vehicles...
		local __VehicleEnt		= didDamageInflictor
		if (
			!__VehicleHealth and
			string.match(__VehicleEnt:GetClass(), "prop_vehicle")
		) then
			--
			__VehicleHealth = didDamage:GetNWInt("healthLeft", false) -- Gets set above if... For Vehicles...
			__VehicleEnt	= didDamage
		end
		local _VehicleDriver = nil
		if (__VehicleEnt.GetDriver) then _VehicleDriver = __VehicleEnt:GetDriver() end
		if (
			__VehicleHealth and
			__VehicleEnt:IsValid() and
			__VehicleHealth <= 0 and
			string.match(__VehicleEnt:GetClass(), "prop_vehicle")
		) then
			--
			-- Tell the Driver that he destroyed the car>>
			if (
				_VehicleDriver and
				_VehicleDriver:IsValid()
			) then
				ClientPrintAddTextMessage(_VehicleDriver, {Color(254, 81, 0), "Your Vehicle got Destroyed..."})
				local _PlayerOwnerCar = __VehicleEnt:GetCreator()--[[ GetNWString("PlayerOwner", false) ]]

				--
				if (_PlayerOwnerCar) then
					_PlayerOwnerCar = player.GetByUniqueID(_PlayerOwnerCar)
					--
					-- Tell the Owner of the car that it got destroyed
					if (_PlayerOwnerCar != _VehicleDriver) then
						ClientPrintAddTextMessage(_PlayerOwnerCar, {Color(254, 81, 0), "\"", Color(208, 0, 254), _VehicleDriver:Nick(), Color(254, 81, 0) "\" Destroyed your car :>..."})
					end
				end
			end
			--
			-- The car got destroyed..>>
			SpawnKillmodelProps( __VehicleEnt, { "models/hunter/blocks/cube025x025x025.mdl", "models/hunter/blocks/cube025x025x025.mdl", "models/props_c17/tools_wrench01a.mdl" }, 10 )
			-- -
			-- DELETE Vehicle...
			timer.Simple(0.2, function()
				if (__VehicleEnt:IsValid()) then
					undoEntityWithOwner(ownerOfEntity, __VehicleEnt, nil, true)

					if didDamage:IsValid() and didDamage:IsPlayer() then
						net.Start("RemoveNotificationTimer")
							net.WriteString("mbd:RemoveEnt001:"..__VehicleEnt:EntIndex())
						net.Send(didDamage)
					end
				end
			end)
		end
		-- - ---->>
		-- SET
		if newHealth < 0 then newHealth = 0 end
		ent:SetNWInt("healthLeft", newHealth)
		--
		--- Remove if health <= 0
		MaybeRemovePropIfHurtEnough( ent, newHealth, didDamage, didDamageInflictor )
	end
end)
local function checkIfEntIsToDamagedForReturn(ent)
	-- DON'T GIVE BACK POINTS IF PROP IS DAMAGED
	local checkThisEnt = GetCorrectEntForProps(ent)

	if checkThisEnt:GetNWInt("healthLeft", -2) < checkThisEnt:GetNWInt("healthTotal", -1) then
		return true
	else return false end
end
local function removeEntityProperly(ent, creator)
	local entClass = ent:GetClass()

	if string.match(entClass, "prop") and creator and creator:IsValid() and creator:IsPlayer() and ( ent and ent:IsValid() and !ent:IsNPC() ) then
		if !checkIfEntIsToDamagedForReturn(ent) then
			undoEntityWithOwner(creator, ent, nil, false, true)
		else
			undoEntityWithOwner(creator, ent, "M.B.D.: Your Prop got Destroyed!")
		end
	elseif string.match(entClass, "npc_bullseye") then
		MBDDoUndoRemoveNullEntities(creator)
	elseif !creator or ( creator and !creator:IsValid() ) or ( ent and ent:IsValid() and ent:IsNPC() ) then ent:Remove() end -- Fallback
end
hook.Add("EntityRemoved", "mbd:EntityRemoved001", function(ent)
	if !ent or !ent:IsValid() then removeEntityProperly(ent, creator) return end
	local creator = ent:GetCreator()

	if ent:IsNPC() then
		--- Subtract from counter -->>
		--
		MBDMaybeSubtractWhenNPCKilledRemoved(ent)
	end

	local bullsEye = ent:GetNWEntity("mbd_npc_bullseye_parent", nil)
	local entOwner = creator --ent:GetNWEntity("PlayerOwnerEnt", nil) -- .... Could just use getCreator ....

	if ( bullsEye and bullsEye:IsValid() ) or !entOwner or !entOwner:IsValid() then -- Todo with NPC bullseye
		removeEntityProperly(ent, creator)
	end
	---- -- --- -
	-- If a weld is removed, and it is connected to a vehicle.>>
	if (ent:GetClass() == "phys_constraint") then
		--
		local Ent1 = ent.Ent1
		local Ent2 = ent.Ent2
		if (
			Ent1:IsValid() and
			Ent1:GetNWBool("isWeldedToVehicle", false)
		) then Ent1:SetNWBool("isWeldedToVehicle", false) end
		if (
			Ent2:IsValid() and
			Ent2:GetNWBool("isWeldedToVehicle", false)
		) then Ent2:SetNWBool("isWeldedToVehicle", false) end
	end
	-- ---
	-- Give back cash money for vehicle maybe
	local __EntModel = ent:GetModel()
	if (
		__EntModel and
		(
			string.match(__EntModel, "models/buggy.mdl") or
			string.match(__EntModel, "models/vehicle.mdl") or
			string.match(__EntModel, "models/airboat.mdl")
		)
	) then
		-- If !GameStarted Vehicle damaged...
		if !GameStarted or (ent:GetNWInt("healthLeft", -1) < ent:GetNWInt("healthTotal", -2)) then removeEntityProperly(ent, creator) return end
		--
		local price = 7000
		-- Jalopy 8000 BD money
		if __EntModel == "models/vehicle.mdl" then price = 8000 end

		local VehicleOwnerPlayer = ent:GetCreator()--[[ GetNWString("PlayerOwner", false) ]]

		if !VehicleOwnerPlayer or ( VehicleOwnerPlayer and !VehicleOwnerPlayer:IsValid() ) then removeEntityProperly(ent, creator) return end
		VehicleOwnerPlayer = player.GetByUniqueID(VehicleOwnerPlayer)

		VehicleOwnerPlayer:SetNWInt("money", VehicleOwnerPlayer:GetNWInt("money", -1) + price)
		VehicleOwnerPlayer:SetNWBool("HasOneVehicle", false)

		-- -
		-- -- Send a notification
		if (
			VehicleOwnerPlayer and
			VehicleOwnerPlayer:IsValid() and
			GameStarted and (
				pl:MBDIsNotAnAdmin(false) or !pl:MBDShouldGetTheAdminBenefits()
			) and VehicleOwnerPlayer:UniqueID() == entOwner:UniqueID()
		) then
			net.Start("NotificationReceivedFromServer")
				net.WriteTable({
					Text 	= "You received a refund (Vehicle)",
					Type	= NOTIFY_GENERIC,
					Time	= 2
				})
			net.Send(VehicleOwnerPlayer)
		end
	end
	if !entOwner or !entOwner:IsValid() then return end
	--
	-- ADD POINTS BACK
	local checkThisEnt = GetCorrectEntForProps(ent)
	if (
		checkThisEnt:GetNWBool("shouldNotGiveBuildPoints", false) or -- IF IT WAS REMOVED BECAUSE IT WAS DESTROYED...
		checkIfEntIsToDamagedForReturn(ent)
	) then removeEntityProperly(ent, creator) return false end

	--- -- -
	---
	if (
		GameStarted and
		ent:GetClass() == "prop_physics" and
		!string.match(ent:GetName(), "mbd_d_prop") and
		!string.match(ent:GetClass(), "prop_vehicle")
	) then
		-- Get the Owner (Player)
		local pl = entOwner

		if (
			pl and
			pl.IsPlayer and
			pl:IsPlayer() and (
				pl:MBDIsNotAnAdmin(false) or !pl:MBDShouldGetTheAdminBenefits()
			) and pl:UniqueID() == entOwner:UniqueID()
		) then
			local total = (pl:GetNWInt("buildPoints", 0) + GetDynamicPriceForThisProp(ent))
			if (total < 0) then total = 0 end

			pl:SetNWInt("buildPoints", total)
			--
			-- -- Send a notification
			net.Start("NotificationReceivedFromServer")
				net.WriteTable({
					Text 	= "You received a refund (Prop)",
					Type	= NOTIFY_GENERIC,
					Time	= 2
				})
			net.Send(pl)

			removeEntityProperly(ent, creator, nil, false, true)
		end
	end
end)
--
-- -
--- When someone PICKS something up with the Physgun
local function ItIsAValidProp(class, model)
	if (
		string.match(class, "prop_physics") or
		string.match(class, "vehicle")
	) and (
		string.lower(model) != "models/hunter/blocks/cube025x025x025.mdl" and -- THIS IS VERY IMPORTANT:....
		!string.match(string.lower(model), "gibs") and
		string.lower(model) != "models/props_c17/doll01.mdl"
	) then return true else return false end
end
local PhysGunNoCollide = "mbd:PhysgunNoCollideProp001"
local function CreateACheckerNoCollide(pl, ent)
	-- Check if the user holds down a key that makes it no-collide >> >
	local ID = PhysGunNoCollide..ent:EntIndex()

	timer.Remove(ID)
	timer.Create(ID, 0.1, 0, function()
		if pl:KeyDown(IN_RELOAD) then
			ent:SetCollisionGroup(COLLISION_GROUP_BREAKABLE_GLASS)
		else
			ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		end
	end)
end
hook.Add("PhysgunPickup", "mbd:PhysgunPickup001", function(pl, ent)
	if ent:GetClass() == "prop_ragdoll" then return false end

	local __Owner = pl:GetCreator()--[[ GetNWString("PlayerOwner", false) ]]
	if (
		__Owner and
		__Owner != pl:UniqueID()
	) then
		if (
			pl:MBDIsNotAnAdmin(true)
		) then return false end
	end

	-- -- No one can pick up Vehicles expect Admins...
	local __EntModel = ent:GetModel()
	if (
		(
			__EntModel and
			(
				string.match(__EntModel, "models/buggy.mdl") or
				string.match(__EntModel, "models/vehicle.mdl") or
				string.match(__EntModel, "models/airboat.mdl")
			) and (
				pl:MBDIsNotAnAdmin(true)
			)
		) or (
			ent:GetNWBool("isWeldedToVehicle", false) and (
				pl:MBDIsNotAnAdmin(true)
			)
		)
	) then return false end

	--
	local PropEnt	= GetCorrectEntForProps(ent)
	
	local _EntClass = PropEnt:GetClass()
	local _Model 	= PropEnt:GetModel()
	if (
		(
			_EntClass == "mbd_buybox" 				or
			_EntClass == "mbd_npc_spawner_all"
		) and (
			pl:MBDIsAnAdmin(true)
		)
	) then
		ent:SetNWBool("isBeingUsedByAPhysgun", true)
		CreateACheckerNoCollide(pl, ent)

		return true
	elseif (
		(
			_EntClass != "mbd_buybox" 				and
			_EntClass != "mbd_npc_spawner_all"
		) and ItIsAValidProp(_EntClass, _Model)
	) then
		-- A Prop; make it collidable
		-- -- -
		if !string.match(_EntClass, "vehicle") then -- ** Must be like this
			PropEnt:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		end

		ent:SetNWBool("isBeingUsedByAPhysgun", true)
		CreateACheckerNoCollide(pl, ent)

		return true
	elseif pl:MBDIsNotAnAdmin(false) then
		return false
	end
end)
hook.Add("PhysgunDrop", "mbd:PhysgunPickup001", function(pl, ent)
	local ID = PhysGunNoCollide..ent:EntIndex()
	timer.Remove(ID)

	local __Owner = pl:GetCreator()--[[ GetNWString("PlayerOwner", false) ]]
	if (
		__Owner and
		__Owner != pl:UniqueID()
	) then
		if (
			pl:MBDIsNotAnAdmin(true)
		) then return false end
	end
	--
	local PropEnt	= GetCorrectEntForProps(ent)
	
	local _EntClass = PropEnt:GetClass()
	local _Model 	= PropEnt:GetModel()
	if ItIsAValidProp(_EntClass, _Model) then
		-- A Prop; set back the normal collision group again
		-- -- -
		if !string.match(_EntClass, "vehicle") then -- ** Must be like this
			PropEnt:SetCollisionGroup(COLLISION_GROUP_BREAKABLE_GLASS)
		end

		ent:SetNWBool("isBeingUsedByAPhysgun", false)

		return true
	elseif pl:MBDIsNotAnAdmin(false) then
		return false
	end
end)
---
--- --
-- When Player wants to no-clip >
hook.Add("PlayerNoClip", "DisableNoclip", function(pl, noClipState)
	if (
		noClipState and
		pl:MBDIsNotAnAdmin(true) and (
			pl:GetNWBool("isSpectating", false) or
			GetConVar("sbox_noclip") == 1
		)
	) then return true elseif (
		pl:MBDIsAnAdmin(true)
	) then return true else return false end

	--
	--- -
end)
-- -
-- -- HOOKS FOR LADDER PROP
hook.Add("PhysgunPickup", "mbd:PhysgunPickupLadder001", function(pl, ent)
	if ent:GetClass() == "mbd_ladder" then
		if (
			pl:MBDIsAnAdmin(true) or 
			pl == ent:GetOwnerOfLadder()
		) then
			return true
		else
			return false
		end
	end
end)
hook.Add("OnPhysgunFreeze", "mbd:PhysgunOnFreezeLadder001", function(weapon, phys, ent, pl)
	if ent:GetClass() == "mbd_ladder" then
		return false
	end
end)

-- -- -
-- Control stamina
local function controlPlayeRunningSpeed(pl, currStaminaRun)
	local newValue = 1

	if currStaminaRun < 2 then
		newValue = 0.23
	elseif currStaminaRun < 20 then
		newValue = 0.5
	end

	pl:SetLaggedMovementValue(newValue)
end
local function playerStartsRunning(pl)
	if GetConVar("mbd_disableStamina"):GetInt() > 0 then return end

	local playerIsInNoClip = pl:GetNWBool("mbd:PlayerIsInNoClip", false)
	if pl:GetNWBool("isSpectating", false) or pl:InVehicle() or playerIsInNoClip then return end

	pl:SetNWBool("playerIsAiming", false)
	pl:SetNWBool("mbd:PlayerIsCurrentlyRunning", true)

	local canPlayerRun = pl:GetNWBool("mbd:PlayerStaminaCanRun", true)
	if !canPlayerRun then pl:SetRunSpeed(250) --[[ normal walk speed for MBD ]] end

	-- print("RUN START", CurTime())
	local timerIDTake = "mdb:staminaControlRunTake_"..pl:UniqueID()
	local timerIDGive = "mdb:staminaControlRunGive_"..pl:UniqueID()
	
	timer.Stop(timerIDTake)
	timer.Stop(timerIDGive)

	timer.Create(timerIDTake, 0.3, 0, function()
		local playerIsInNoClip = pl:GetNWBool("mbd:PlayerIsInNoClip", false)
		
		if pl and pl:IsValid() and !playerIsInNoClip then
			local canPlayerRun = pl:GetNWBool("mbd:PlayerStaminaCanRun", true)
			if !canPlayerRun then pl:SetRunSpeed(250) --[[ normal walk speed for MBD ]] end
			timer.Stop(timerIDGive)

			-- Retract Stamina
			local currStaminaRun = pl:GetNWInt("mbd:PlayerCurrentStaminaRun", 100)

			controlPlayeRunningSpeed(pl, currStaminaRun)

			local newStamina = currStaminaRun - 1.8
			if newStamina < 0 then newStamina = 0 end
			pl:SetNWInt("mbd:PlayerCurrentStaminaRun", newStamina)

			if newStamina == 0 then
				timer.Stop(timerIDTake)

				-- Stop Player from running anymore...
				pl:SetNWBool("mbd:PlayerStaminaCanRun", false)

				pl:SetRunSpeed(250) --[[ normal walk speed for MBD ]]
			end

			-- print("TAKE STAMINA:", newStamina)
		elseif !playerIsInNoClip then timer.Stop(timerIDTake) end
	end)
end
local function playerStartsAndStopsJumping(pl)
	if GetConVar("mbd_disableStamina"):GetInt() > 0 then return end
	
	local playerIsInNoClip = pl:GetNWBool("mbd:PlayerIsInNoClip", false)
	if pl:GetNWBool("isSpectating", false) or pl:InVehicle() or playerIsInNoClip then return end
	
	local canPlayerJump = pl:GetNWBool("mbd:PlayerStaminaCanJump", true)
	if !canPlayerJump then pl:SetJumpPower(0) --[[ disallow jump ]] else pl:SetJumpPower(285) --[[ normal jump for MBD ]] end

	pl:SetNWBool("playerIsAiming", false)

	-- print("JUMP START", CurTime())

	local timerIDGive = "mdb:staminaControlJumpGive_"..pl:UniqueID()
	timer.Stop(timerIDGive)

	-- Set
	local currStaminaJump = pl:GetNWInt("mbd:PlayerCurrentStaminaJump", 100)
	local newStamina = currStaminaJump - 20
	if newStamina < 0 then newStamina = 0 end
	pl:SetNWInt("mbd:PlayerCurrentStaminaJump", newStamina)

	if newStamina == 0 then
		pl:SetNWBool("mbd:PlayerStaminaCanJump", false)

		pl:SetJumpPower(0) --[[ disallow jump ]]
	end

	timer.Create(timerIDGive, 0.7, 0, function()
		local playerIsInNoClip = pl:GetNWBool("mbd:PlayerIsInNoClip", false)

		if pl and pl:IsValid() and !playerIsInNoClip then
			local canPlayerJump = pl:GetNWBool("mbd:PlayerStaminaCanJump", true)
			if !canPlayerJump then pl:SetJumpPower(0) --[[ disallow jump ]] else pl:SetJumpPower(285) --[[ normal jump for MBD ]] end

			-- Give Stamina
			local currStaminaJump = pl:GetNWInt("mbd:PlayerCurrentStaminaJump", 100)

			local newStamina = currStaminaJump + 10
			if pl:Crouching() then newStamina = newStamina + 10 end
			if newStamina > 100 then newStamina = 100 end
			pl:SetNWInt("mbd:PlayerCurrentStaminaJump", newStamina)

			if newStamina > 0 then
				pl:SetNWBool("mbd:PlayerStaminaCanJump", true)

				pl:SetJumpPower(285) --[[ normal jump for MBD ]]
			end
			if newStamina == 100 then timer.Stop(timerIDGive) end

			-- print("GIVE JUMP STAMINA:", newStamina)
		elseif !playerIsInNoClip then timer.Stop(timerIDGive) end
	end)
end
local function playerStopsRunning(pl)
	if pl:InVehicle() then return end

	pl:SetNWBool("mbd:PlayerIsCurrentlyRunning", false)

	local canPlayerRun = pl:GetNWBool("mbd:PlayerStaminaCanRun", true)
	if !canPlayerRun then pl:SetRunSpeed(250) --[[ normal walk speed for MBD ]] else pl:SetRunSpeed(450) --[[ normal run speed for MBD ]] end

	-- print("RUN STOP", CurTime())
	local timerIDTake = "mdb:staminaControlRunTake_"..pl:UniqueID()
	local timerIDGive = "mdb:staminaControlRunGive_"..pl:UniqueID()

	timer.Stop(timerIDTake)
	timer.Stop(timerIDGive)

	timer.Create(timerIDGive, 0.7, 0, function()
		if pl and pl:IsValid() then
			local canPlayerRun = pl:GetNWBool("mbd:PlayerStaminaCanRun", true)
			if !canPlayerRun then pl:SetRunSpeed(250) --[[ normal walk speed for MBD ]] else pl:SetRunSpeed(450) --[[ normal run speed for MBD ]] end
			timer.Stop(timerIDTake)

			-- Give Stamina
			local currStaminaRun = pl:GetNWInt("mbd:PlayerCurrentStaminaRun", 100)

			controlPlayeRunningSpeed(pl, currStaminaRun)

			local newStamina = currStaminaRun + 3
			if pl:Crouching() then newStamina = newStamina + 3 end
			if newStamina > 100 then newStamina = 100 end
			pl:SetNWInt("mbd:PlayerCurrentStaminaRun", newStamina)

			if newStamina > 0 then
				pl:SetNWBool("mbd:PlayerStaminaCanRun", true)

				pl:SetRunSpeed(450) --[[ normal run speed for MBD ]]
			end
			if newStamina == 100 then timer.Stop(timerIDGive) end

			-- print("GIVE STAMINA:", newStamina)
		else timer.Stop(timerIDGive) end
	end)
end

local function setStatusOfSlowDownTimeClient(pl)
	net.Start("mbd:StatusOfSlowdowTime")
		net.WriteTable({
			slowMotionKeyIsDown,
			slowMotionGameIsActivatedByPlayerSinglePlayer
		})
	net.Send(pl)
end

local slowMotionGameCurrentValue = 0 -- Can go from 0.1 - 0.9 => Set by holding IN_USE and scrolling ( IN_WEAPON1 or IN_WEAPON2 )
local function slowGameTimeScaleDown(pl)
	slowMotionGameIsActivatedByPlayerSinglePlayer = true
	setStatusOfSlowDownTimeClient(pl)

	local newSlowMotionValue = GetConVar("mbd_currentGameSpeedSetReadOnly"):GetInt() * slowMotionGameCurrentValue
	
	game.SetTimeScale(newSlowMotionValue)
end
local function resetSlowGameTimeScaleDown(pl)
	slowMotionGameIsActivatedByPlayerSinglePlayer = false
	setStatusOfSlowDownTimeClient(pl)
	
	game.SetTimeScale(GetConVar("mbd_currentGameSpeedSetReadOnly"):GetInt())
end
local function resetSlowGameTimeScaleDownToNoramalSlowMotionEffect(pl)
	slowMotionGameCurrentValue = 0.4

	if pl and slowMotionGameIsActivatedByPlayerSinglePlayer then slowGameTimeScaleDown(pl) elseif pl then
		net.Start("mbd_stopAllSoundsClient")
		net.Send(pl)
	end
end
resetSlowGameTimeScaleDownToNoramalSlowMotionEffect(nil)
local function adjustSlowGameTimeScaleDown(pl, goUp)
	local newSlowMotionValue = slowMotionGameCurrentValue

	if goUp then
		newSlowMotionValue = newSlowMotionValue + 0.1
	else
		newSlowMotionValue = newSlowMotionValue - 0.1
	end
	if newSlowMotionValue > 0.9 then newSlowMotionValue = 0.9 elseif newSlowMotionValue < 0.1 then newSlowMotionValue = 0.1 end
	slowMotionGameCurrentValue = newSlowMotionValue

	-- Adjust the value
	slowGameTimeScaleDown(pl)
end

hook.Add("KeyPress", "mbd:KeyPress001", function(pl, key)
	local mbd_disableHonkHornSoundEffect = GetConVar("mbd_disableHonkHornSoundEffect"):GetInt() > 0

	-- Honk the horn
	if !mbd_disableHonkHornSoundEffect then
		if key == IN_ATTACK and pl:InVehicle() then
			local vehicle = pl:GetVehicle()
	
			if vehicle and vehicle:IsValid() and !vehicle:IsVehicleBodyInWater() then
				local vehicleModel = vehicle:GetModel()
	
				local IsJeep = vehicleModel == "models/buggy.mdl"
				local IsJalopy = vehicleModel == "models/vehicle.mdl"
				local IsAirboat = vehicleModel == "models/airboat.mdl"
	
				-- Maybe A CLOWN ?
				local IsClown = math.random(0, 5)
				if IsClown > 4 then IsClown = true else IsClown = false end
				if IsClown then
					vehicle:EmitSound("horn_clown")
				else
					if IsJeep then
						vehicle:EmitSound("horn_jeep")
					elseif IsJalopy then
						vehicle:EmitSound("horn_jalopy")
					elseif IsAirboat then
						vehicle:EmitSound("horn_airboat")
					end
				end
			end
		end
	end

	local playerIsRunning = pl:GetNWBool("mbd:PlayerIsCurrentlyRunning", false)

	-- Start running
	if (
		(
			( pl:KeyDown(IN_SPEED) and ( key == IN_FORWARD or key == IN_BACK or key == IN_MOVELEFT or key == IN_MOVERIGHT ) ) or
			( ( pl:KeyDown(IN_FORWARD) or pl:KeyDown(IN_BACK) or pl:KeyDown(IN_MOVELEFT) or pl:KeyDown(IN_MOVERIGHT) ) and key == IN_SPEED )
		) and !playerIsRunning and pl and pl:IsValid()
	) then playerStartsRunning(pl) end
	-- Start jumping
	if key == IN_JUMP and pl and pl:IsValid() and pl:GetVelocity()[ 3 ] == 0 then playerStartsAndStopsJumping(pl) end

	if GameIsSinglePlayer and GetConVar("mbd_disableSlowMotionEffect"):GetInt() <= 0 then
		local inUseIsDown = pl:KeyDown(IN_USE)

		-- Activate Slow Motion until IN_USE is released
		if inUseIsDown then slowMotionKeyIsDown = true setStatusOfSlowDownTimeClient(pl) end
		if !slowMotionGameIsActivatedByPlayerSinglePlayer and inUseIsDown and key == IN_ATTACK then slowGameTimeScaleDown(pl) end
	end
end)
hook.Add("KeyRelease", "mbd:KeyRelease001", function(pl, key)
	if key == IN_ATTACK and pl:InVehicle() then -- Remove pl:InVehicle to stop instantly ( but it is a cool effect )
		local vehicle = pl:GetVehicle()

		if vehicle and vehicle:IsValid() then
			vehicle:StopSound("horn_jeep")
			vehicle:StopSound("horn_jalopy")
			vehicle:StopSound("horn_airboat")
		end
	end

	local playerIsRunning = pl:GetNWBool("mbd:PlayerIsCurrentlyRunning", false)

	-- Stop running
	if (
		(
			key == IN_SPEED or (
				( key == IN_FORWARD and !pl:KeyDown(IN_BACK) and !pl:KeyDown(IN_MOVELEFT) and !pl:KeyDown(IN_MOVERIGHT) ) or
				( key == !pl:KeyDown(IN_FORWARD) and key == IN_BACK and !pl:KeyDown(IN_MOVELEFT) and !pl:KeyDown(IN_MOVERIGHT) ) or
				( key == !pl:KeyDown(IN_FORWARD) and !pl:KeyDown(IN_BACK) and key == IN_MOVELEFT and !pl:KeyDown(IN_MOVERIGHT) ) or
				( key == !pl:KeyDown(IN_FORWARD) and !pl:KeyDown(IN_BACK) and !pl:KeyDown(IN_MOVELEFT) and key == IN_MOVERIGHT )
			)
			
		) and playerIsRunning and pl and pl:IsValid()
	) then playerStopsRunning(pl) end

	if GameIsSinglePlayer and GetConVar("mbd_disableSlowMotionEffect"):GetInt() <= 0 then
		local inUseIsDown = key == IN_USE

		-- Deactivate Slow Motion
		if inUseIsDown then slowMotionKeyIsDown = false setStatusOfSlowDownTimeClient(pl) end
		if slowMotionGameIsActivatedByPlayerSinglePlayer and inUseIsDown then resetSlowGameTimeScaleDown(pl) end
	end
end)
local function shouldGoUp(mouseWheelScrollDelta) if mouseWheelScrollDelta > 0 then return true end return false end
local function lockAndAdjustPlayer(pl, mv, value)
	mv:SetForwardSpeed(0) mv:SetSideSpeed(0)

	pl:SetNWInt("playerCurrentCameraView", value)
end
hook.Add("SetupMove", "mbd:SetupMove001", function(pl, mv, cmd)
	local playerCurrentCameraView = pl:GetNWInt("playerCurrentCameraView", 0)

	if GameIsSinglePlayer then
		if mv:KeyDown(IN_USE) then
			local mouseWheelScrollDelta = cmd:GetMouseWheel()
		
			-- Change the slowdown effect up or down
			if mouseWheelScrollDelta != 0 then
				local goUp = shouldGoUp(mouseWheelScrollDelta)

				adjustSlowGameTimeScaleDown(pl, goUp)
			end
		end
	end
	-- - -
	-- Lock Player and Adjust if needed (security) (someone tries to hackintosh also maybe ?)
	if !GameIsSinglePlayer then
		if playerCurrentCameraView == 4 and ( !CameraTopViewIsAllowed and !OnlyTopCameraViewIsAllowed ) then
			lockAndAdjustPlayer(pl, mv, 0)
		elseif playerCurrentCameraView != 4 and OnlyTopCameraViewIsAllowed then
			lockAndAdjustPlayer(pl, mv, 4)
		end
	end
end)
hook.Add("PlayerButtonDown", "mbd:PlayerButtonDown001", function(pl, button)
	if button == MOUSE_MIDDLE and pl:KeyDown(IN_USE) then
		-- Reset slow motion to normal slow motion value
		resetSlowGameTimeScaleDownToNoramalSlowMotionEffect(pl)
	end
end)
-- -
hook.Add("VehicleMove", "mbd:PlayerTick001", function(pl, veh, mv)
	local mbd_disablePlayerBlurEffect = tonumber(pl:GetInfoNum("mbd_disablePlayerBlurEffect", 0)) > 0
	local vehSpeed = veh:GetSpeed()

	-- If high speed, make it blur
	if vehSpeed >= 38 then
		if mbd_disablePlayerBlurEffect and GameIsSinglePlayer then -- Only allow in single-player... It will be allot easier to drive
			pl:SetNWString("mbd:blurAmountForPlayerVehicle", "0.09,9.38,0.000015")
		else
			pl:SetNWString("mbd:blurAmountForPlayerVehicle", "0.16,9.38,0.000015")
		end
	elseif vehSpeed >= 20 then
		if mbd_disablePlayerBlurEffect and GameIsSinglePlayer then -- Only allow in single-player... It will be allot easier to drive
			pl:SetNWString("mbd:blurAmountForPlayerVehicle", "0.3,9.38,0.000015")
		else
			pl:SetNWString("mbd:blurAmountForPlayerVehicle", "0.23,9.38,0.000015")
		end
	else
		-- Normal state
		pl:SetNWString("mbd:blurAmountForPlayerVehicle", "0.515,1.3,0.00002")
	end
end)

hook.Add("GetFallDamage", "mbd:GetFallDamage001", function(pl, speed)
	if !GameStarted then return 0 end
end)

hook.Add("PlayerNoClip", "mbd:GetFallDamage001", function(pl, desiredState)
	if pl:MBDIsAnAdmin(true) and desiredState then pl:SetNWBool("mbd:PlayerIsInNoClip", true) else pl:SetNWBool("mbd:PlayerIsInNoClip", false) end
end)
