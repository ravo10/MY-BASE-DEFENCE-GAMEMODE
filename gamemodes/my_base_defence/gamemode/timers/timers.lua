-- Remove Serverside Ragdolls
--
timer.Create("mbd:RemoveClientRagdolls001", 120, 0, function() -- Every 120 sec
	game.RemoveRagdolls()

	timer.Simple(6, function()
		for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
			-- Remove
			--
			if v:IsValid() then v:Remove() end
		end
	end)
end)
-- Update the amount if needed
timer.Create( "mbd:UpdateEnemiesAliveTotal001", 1, 0, function()

	-- More efficient to just run every second

	if GameStarted then
		
		--
		--- -
		-- Do a count on how many enemies are actually alive (if mis-counted)
		local allNPCSpawnerNPCs = GETAllValidNPCsWithinTheNPCTable()
		local newNPCCount = 0
		local totAmount = #allNPCSpawnerNPCs

		for i,npc in pairs( allNPCSpawnerNPCs ) do
			newNPCCount = newNPCCount + 1

			if i == totAmount then
				EnemiesAliveTotal = newNPCCount
				--
				--- Send to CLIENTS >>
				net.Start("TotalAmountOfEnemies")
					net.WriteInt(EnemiesAliveTotal, 9)
				net.Broadcast()
			end
		end

	else EnemiesAliveTotal = 0 end

end )
-- -- -
function isNPCFreezed(npc)
	if npc:IsEFlagSet(EFL_NO_THINK_FUNCTION) then return true end

	return false
end
function freezeEveryNPC()
	--
	--- FREEZ EVERY NPC (STOP THIER THINKING)
	for k,v in pairs(ents.FindByClass("npc_*")) do
		if (v:IsNPC()) then
			-- STOP THINKING
			v:AddEFlags(EFL_NO_THINK_FUNCTION)
		end
	end
end
function unfreezeEveryNPC()
	--
	--- UN-FREEZ EVERY NPC (START THIER THINKING)
	for k,v in pairs(ents.FindByClass("npc_*")) do
		if (v:IsNPC()) then
			-- START THINKING AGAIN...
			v:RemoveEFlags(EFL_NO_THINK_FUNCTION)
		end
	end
end

-- -
--
-- BUG:: Some NPC get stuck... This is because they can't find f.ex. animation act ACT_WALK/ACT_DIESIMPLE ( e.g.: npc_zombie:npc_zombie:models/zombie/Classic_split.mdl has no sequence for act:ACT_WALK )
local prevNPCPositionsAngles = {}
local removeCorrectWay = function(traceID, npc, LastNPCValidCheckCurTime)
    -- print("\"removeCorrectWay\" traceID:", traceID)
    -- If spawn time was above six seconds ago
    if LastNPCValidCheckCurTime and CurTime() - LastNPCValidCheckCurTime < 6 then return end

    timer.Simple(0.6, function()
        if npc and npc:IsValid() and GetConVar("developer"):GetInt() == 1 then
            local message = "M.B.D. Found an invalid NPC ( "..npc:GetClass().." ). Removes it...\n"
            if not LastNPCValidCheckCurTime then message = "M.B.D. Found an NPC not in World ( "..npc:GetClass().." ). Removes it...\n" end
            MsgC(Color(255, 64, 0), message)

            npc:Remove()
        end
    end)
end

local function RemoveStuckNPCs()
	local thereIsAtleastOnePlayerNotSpectaing = false
	for k,v in pairs(player.GetAll()) do
		if v and v:IsValid() and not v:GetNWBool("isSpectating", false) then thereIsAtleastOnePlayerNotSpectaing = true break end
	end

	local allNPCSpawnerNPCs = GETAllValidNPCsWithinTheNPCTable()
    for k,v in pairs(allNPCSpawnerNPCs) do
        -- Ignore these...
        local npcKey = GETMaybeCustomNPCKeyFromNPCClass(v:GetClass())
        local LastNPCValidCheckCurTime = v:GetNWInt("LastNPCValidCheckCurTime", -1)

        -- Timeout
        if not v:GetNWBool("NPCSpawnWasASuccess", false) and LastNPCValidCheckCurTime ~= -1 and CurTime() - LastNPCValidCheckCurTime >= 12 then removeCorrectWay("1", v, LastNPCValidCheckCurTime) return end
        -- Not in World
        if not util.IsInWorld(v:GetPos()) then removeCorrectWay("4", v, nil) return end

        if thereIsAtleastOnePlayerNotSpectaing and not isNPCFreezed(v) and ( table.HasValue(allowedCombines, npcKey) or table.HasValue(allowedZombies, npcKey) ) then
            local id = v:EntIndex()

            if prevNPCPositionsAngles[id] and ( not prevNPCPositionsAngles[id].Vector or not prevNPCPositionsAngles[id].Angles ) then
                prevNPCPositionsAngles[id] = { Vector = nil, Angles = nil }
            end

            -- Remove
            if v:IsValid() and v:Health() <= 0 then removeCorrectWay("2", v, LastNPCValidCheckCurTime) elseif v:IsValid() then
                local currNPCPos = v:GetPos()
                currNPCPos.x = math.Round(currNPCPos.x)
                currNPCPos.y = math.Round(currNPCPos.y)
                currNPCPos.z = math.Round(currNPCPos.z)

                local prevNPCPos = nil
                if prevNPCPositionsAngles[id] and prevNPCPositionsAngles[id].Vector then
                    prevNPCPos = prevNPCPositionsAngles[id].Vector
                end
                
                local currNPCAng = v:GetAngles()
                currNPCAng[1] = math.Round(currNPCAng[1])
                currNPCAng[2] = math.Round(currNPCAng[2])
                currNPCAng[3] = math.Round(currNPCAng[3])
                
                local prevNPCAng = nil
                if prevNPCPositionsAngles[id] and prevNPCPositionsAngles[id].Angles then
                    prevNPCAng = prevNPCPositionsAngles[id].Angles
                end
                -- -
                -- -- -
                -- -- - - Have not moved in a while... Remove
                local currSequence = v:GetSequence()
                if currSequence and currSequence < 1 and ( prevNPCPos and currNPCPos == prevNPCPos ) and ( prevNPCAng and currNPCAng == prevNPCAng ) then
                    removeCorrectWay("3", v, LastNPCValidCheckCurTime)
                else
                    -- Will only be set if OK
                    v:SetNWInt("LastNPCValidCheckCurTime", CurTime())
                end
            end
            --- -
            -- Position Vectors
            local updatedPos = v:GetPos()
            updatedPos.x = math.Round(updatedPos.x)
            updatedPos.y = math.Round(updatedPos.y)
            updatedPos.z = math.Round(updatedPos.z)
            -- Angles
            local updatedAng = v:GetAngles()
            updatedAng[1] = math.Round(updatedAng[1])
            updatedAng[2] = math.Round(updatedAng[2])
            updatedAng[3] = math.Round(updatedAng[3])
            -- Update
            if not prevNPCPositionsAngles[id] then
                prevNPCPositionsAngles[id] = { Vector = nil, Angles = nil }
            end
            prevNPCPositionsAngles[id].Vector = updatedPos
            prevNPCPositionsAngles[id].Angles = updatedAng
        end
    end
    --- - -
    -- Maybe remove the NPCs from the list.. Clean-up
    local newTable = {}
    for id,vectorAngle in pairs(prevNPCPositionsAngles) do
        local npc = ents.GetByIndex(id)

        if npc and npc:IsValid() then
            if not newTable[id] then
                newTable[id] = { Vector = nil, Angles = nil }
            end
            newTable[id].Vector = vectorAngle.Vector
            newTable[id].Angles = vectorAngle.Angles
        else
            newTable[id] = { Vector = nil, Angles = nil }
        end
    end prevNPCPositionsAngles = newTable
end

timer.Create( "mbd:RemoveStuckNPCs000", 3, 0, RemoveStuckNPCs )

function createTMinusTimer()
	timer.Remove("mbd:RoundCreator001")

	local __time = (GetConVar("mbd_countDownTimerEnd"):GetInt() + 1)
	local __i = 0

	-- For client
	sendCountDownerClient(1, "T-minus to safety: ", __time)
	-- For server
	timer.Create("mbd:RoundCreator001", 1, __time, function()
		__i = (__i + 1)

		--
		if (__i >= __time) then
			--
			timer.Remove("mbd:RoundCreator001") --for safety...
			currentRoundEnd()
			timer.Remove("mbd:RoundCreator001") --for safety...
		else MaybeSpawnAPyramidDropPlayerMustPickUp() end
	end)
end
function RoundCreator001()
	createTMinusTimer()
end
--
--
function createAttackTimer()
	timer.Remove("mbd:nextRoundCountdown001")

	local __time = (GetConVar("mbd_countDownTimerAttack"):GetInt() + 1)
	local __i = __time

	net.Start("receive_mbd_attackRoundIsOn")
		net.WriteBool(true)
	net.Broadcast()

	-- For client
	sendCountDownerClient(1, "T-minus to attack: ", __time)
	-- For server
	timer.Create("mbd:nextRoundCountdown001", 1, __time, function()
		__i = (__i - 1)

		if (__i <= 0) then
			timer.Remove("mbd:nextRoundCountdown001") --for saftey...
			-- START NEXT ROUND
			
			nextRoundWave(true)
			nextRoundStart()

			for _,pl in pairs(player:GetAll()) do
				if pl and pl:IsValid() then
					ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "WAVE Started! (", Color(254, 0, 46), CurrentRoundWave, Color(254, 208, 0), ") Go Go!"})

					if (CurrentRoundWave == 1) then
						ClientPrintAddTextMessage(pl, {Color(0, 254, 208), "Good luck..."})
						ClientPrintAddTextMessage(pl, {Color(81, 0, 254), "Start building your defences! Work together."})
					end
				end
			end

			--
			timer.Remove("mbd:nextRoundCountdown001") --for saftey...

			net.Start("receive_mbd_attackRoundIsOn")
				net.WriteBool(false)
			net.Broadcast()
		end
	end)
end
function nextRoundCountdown001()
	createAttackTimer()
end
--
function nextRoundWave(addAlso)
	if (!CurrentRoundWave) then CurrentRoundWave = 0 end
	resetDrops0()
	--
	if (addAlso) then
		CurrentRoundWave = (CurrentRoundWave + 1)

		--- SAVE HERE ALSO ...
		GetConVar("mbd_roundWaveNumber"):SetInt(CurrentRoundWave)
	end

	--
	net.Start("RoundWaveChange")
		net.WriteInt(CurrentRoundWave, 15) -- MAYBE INCREASE the bit, a bit.....
	net.Broadcast()
	--
	--
	if CurrentRoundWave == 1 and GameStarted then -- FIRST TIME....
		nextRoundStart()
	end
end
function currentRoundEnd(dontCheckIfPyramidDropsAreOK, doNotCancelSound)
	-- Check if all drops are picked up...
	-- If not: End Game
	if
		!dontCheckIfPyramidDropsAreOK and
		GetConVar("mbd_howManyDropItemsSpawnedAlready"):GetInt() >= GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt()
	then
		if GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() > 0 and CurrentRoundWave and CurrentRoundWave > 3 and GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt() != GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() then
			endGame()
	
			net.Start("NotificationReceivedFromServer")
				net.WriteTable({
					Text 	= "Fail - The team failed to pick up all of the PYRAMID DROPS this wave...",
					Type	= NOTIFY_GENERIC,
					Time	= 5
				})
			net.Broadcast()
	
			return
		end
		if GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() > 0 then
			-- Reset
			net.Start("PyramidStatus")
				net.WriteString("0/"..GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt())
			net.Broadcast()
		end
		if GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() > 0 and CurrentRoundWave and CurrentRoundWave == 3 then
			local longText = "The next waves forwards, your team has to gather up all PYRAMID DROPS (by NPCs) each wave to survive."
			local shortText = "The next waves forwards, gather all PYRAMID DROPS"
			---
			-- GG
			net.Start("NotificationReceivedFromServer")
				net.WriteTable({
					Text 	= shortText,
					Type	= NOTIFY_HINT,
					Time	= 6
				})
			net.Broadcast()
			--
			timer.Simple(0.15, function()
				for _,pl in pairs(player:GetAll()) do
					if pl and pl:IsValid() then
						ClientPrintAddTextMessage(pl, {Color(208, 0, 254), longText})
					end
				end
			end)
		end
	end
	
	freezeEveryNPC()
	-- --->>
	for _,v in pairs(player.GetAll()) do
		if (!v:GetNWBool("isSpectating", true)) then
			v:MBDGiveBuildPointsOnRoundWaveEnd()
			v:MBDGiveMoneyOnRoundWaveEnd()
			-- GIVE SOME HEALTH TO THA PLAYER HUEH ?
			v:MBDGiveHealthOnRoundWaveEnd()
		end
	end
	--

	sendCountDownerClient(0, "You're safe; for now.", nil)
	if (!CurrentRoundWave) then return false end
	
	for _,pl in pairs(player.GetAll()) do
		if (
			pl and pl:IsValid() and
			CurrentRoundWave < 10 and
			CurrentRoundWave > 1
		) then
			ClientPrintAddTextMessage(pl, {Color(173, 254, 0), "Current WAVE done."})
		elseif (CurrentRoundWave > 1) then
			ClientPrintAddTextMessage(pl, {Color(173, 254, 0), "Current WAVE done. Good job."})
		end
	end
	--
	--
	AttackRoundIsOn = false
	--
	--- START COUNTDOWN....
	timer.Simple(2, function()
		--
		nextRoundCountdown001()
	end)

	-- Send Siren Safe Sound To All Players On Server >>
	--- --
	if !doNotCancelSound and GetConVar("mbd_turnOffSirenSoundStartGame"):GetInt() == 0 then
		Entity_EmitLocalSoundEmitter("3",
			{
				Sound		= "game/train_whistle1_newMix.wav",
				Pitch		= 100,
				SoundEnt 	= nil,
				Volume		= 0.46
			},
			false
		)
	end
end
--
function nextRoundStart(doNotCancelSound)
	-- Send Siren Sound To All Players On Server >>
	--- --
	if !doNotCancelSound and GetConVar("mbd_turnOffSirenSoundStartGame"):GetInt() == 0 then
		local sound = math.random(0, 0) -- Better to only have the good one
		
		if sound == 0 then
			sound = "game/siren1_2_newMix_Mike_Koenig.wav"
		elseif sound == 1 then
			sound = "game/siren1_2_yeah_boy_1.wav"
		elseif sound == 2 then
			sound = "game/siren1_2_yeah_boy_2.wav"
		elseif sound == 3 then
			sound = "game/siren1_2_yeah_boy_3.wav"
		elseif sound == 4 then
			sound = "game/siren1_2_yeah_boy_4.wav"
		elseif sound == 5 then
			sound = "game/siren1_2_yeah_boy_5.wav"
		elseif sound == 6 then
			sound = ""
		end

		timer.Simple(0.35, function()
			Entity_EmitLocalSoundEmitter("4",
				{
					Sound		= sound,
					Pitch		= 100,
					SoundEnt 	= nil,
					Volume		= 0.82
				},
				false
			)
		end)
	end

	sendCountDownerClient(0, "Incoming Attack! Get Ready...", nil)
	
	timer.Simple(3, function()
		--
		unfreezeEveryNPC()

		--
		---
		RoundCreator001()
		--
		--
		AttackRoundIsOn = true
	end)
end
-- - --
----
--
function sendCountDownerClient(state, messageString, countdownTimeTotalStart)
	net.Start("mbd:LobbyTimerStateChange")
		net.WriteTable({
			state = state,
			messageString = messageString,
			countdownTimeTotalStart = countdownTimeTotalStart
		})
	net.Broadcast()
	--
	--- Also send status of Pyramids (if updated)
	timer.Simple(0.15, function()
		local amountMax = GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt()
		local status = GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt().."/"..amountMax
		if amountMax < 3 or timer.Exists("mbd:nextRoundCountdown001") or (CurrentRoundWave and CurrentRoundWave < 4) then status = "N/A" end
		
		net.Start("PyramidStatus")
			net.WriteString(status)
		net.Broadcast()
	end)
end
--
net.Receive("StartPauseCurrentCountdown", function()
	-- START/PAUSE CURRENT TIMER
	-- Only one timer can exsist at once ==-->>>
	if (timer.Exists("mbd:RoundCreator001")) then
		if (timerCountDownIsOn) then
			changeCountDown(1, timer.RepsLeft("mbd:RoundCreator001"), true)
			timer.Pause("mbd:RoundCreator001")
			timerCountDownIsOn = false
		else
			changeCountDown(1, timer.RepsLeft("mbd:RoundCreator001"), false)
			timer.UnPause("mbd:RoundCreator001")
			timerCountDownIsOn = true
		end
	elseif (timer.Exists("mbd:nextRoundCountdown001")) then
		if (timerCountDownIsOn) then
			changeCountDown(0, timer.RepsLeft("mbd:nextRoundCountdown001"), true)
			timer.Pause("mbd:nextRoundCountdown001")
			timerCountDownIsOn = false
		else
			changeCountDown(0, timer.RepsLeft("mbd:nextRoundCountdown001"), false)
			timer.UnPause("mbd:nextRoundCountdown001")
			timerCountDownIsOn = true
		end
	end
end)
--
net.Receive("mbd_roundWaveNumber", function()
	--
	GetConVar("mbd_roundWaveNumber"):SetInt(net.ReadInt(15))
end)
net.Receive("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd", function()
	--
	GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):SetInt(net.ReadInt(15))
end)
net.Receive("mbd_npcLimit", function()
	--
	GetConVar("mbd_npcLimit"):SetInt(net.ReadInt(15))
end)
net.Receive("mbd_respawnTimeBeforeCanSpawnAgain", function()
	--
	GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):SetInt(net.ReadInt(15))
end)
net.Receive("mbd_enableStrictMode", function()
	--
	GetConVar("mbd_enableStrictMode"):SetInt(net.ReadInt(3))
end)
net.Receive("mbd_enableHardEnemiesEveryThreeRound", function()
	--
	GetConVar("mbd_enableHardEnemiesEveryThreeRound"):SetInt(net.ReadInt(3))
end)
net.Receive("mbd_superAdminsDontHaveToPay", function()
	--
	GetConVar("mbd_superAdminsDontHaveToPay"):SetInt(net.ReadInt(3))
end)
net.Receive("mbd_turnOffSirenSoundStartGame", function()
	--
	GetConVar("mbd_turnOffSirenSoundStartGame"):SetInt(net.ReadInt(3))
end)
net.Receive("mbd_enableAutoScaleModelNPC", function()
	--
	GetConVar("mbd_enableAutoScaleModelNPC"):SetInt(net.ReadInt(3))
end)
net.Receive("mbd_countDownTimerAttack", function()
	--
	GetConVar("mbd_countDownTimerAttack"):SetInt(net.ReadInt(15))
	timer.Simple(0.3, function()
		if timer.Exists("mbd:nextRoundCountdown001") then
			createAttackTimer()
		end
	end)
end)
net.Receive("mbd_countDownTimerEnd", function()
	--
	GetConVar("mbd_countDownTimerEnd"):SetInt(net.ReadInt(15))
	timer.Simple(0.3, function()
		if timer.Exists("mbd:RoundCreator001") then
			createTMinusTimer()
		end
	end)
end)
