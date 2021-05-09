if engine.ActiveGamemode() == "my_base_defence" then -- Very important
    AddCSLuaFile()

    if SERVER or CLIENT then
        -------------------- ---- ---
        -- *SETTINGS FOR NPCS * --
        ----------------------- -----
        -- Combine
        allowedCombines = {
            "MBDNPCCombineElite",
            "MBDNPCShotgunSoldier",
            "MBDNPCCombineS",
            "MBDNPCCombinePrison",
            "MBDNPCPrisonShotgunner",
            "npc_metropolice",
            "npc_stalker"--[[ ,
            "npc_hunter" ]] --<<-- This sh*t has weird collison on props... Figured out that it is best to remove it
            -- I have made a custom prop to collide with it, but that is also buggy for no good reason......
        -- Zombie/"Alien"
        }
        allowedZombies = {
            "MBDNPCZombie",
            "MBDNPCZombine",
            "npc_fastzombie",
            "npc_zombie_torso",
            "npc_antlion"
        }
        allowedNPCsCombined = {}
        allowedNPCClassesCombined = {}

        otherClassesNeeded = {
            "npc_headcrab",
            "npc_headcrab_black",
            "npc_headcrab_poison",
            "npc_headcrab_fast"
        }

        otherClassesNPCsShouldLikeButWillNotBeSpawnedByNPCSpawner = {
            "MBDNPCCombineElite",
            "MBDNPCShotgunSoldier",
            "MBDNPCCombineS",
            "MBDNPCCombinePrison",
            "MBDNPCPrisonShotgunner",
            "MBDNPCZombie",
            "MBDNPCZombine",
            "npc_metropolice",
            "npc_stalker",
            "npc_fastzombie",
            "npc_zombie_torso",
            "npc_antlion",
            --[[ Def. needed ]]
            "npc_strider",
            "npc_combinegunship",
            "npc_helicopter"
        }
        table.Merge(otherClassesNPCsShouldLikeButWillNotBeSpawnedByNPCSpawner, otherClassesNeeded)

        if GetConVar("mbd_enableStrictMode"):GetInt() == 0 then
            -- Just add all...
            otherClassesNPCsShouldLikeButWillNotBeSpawnedByNPCSpawner = {}
            for NPCKey,_ in pairs(MBDCompleteCurrNPCList) do
                table.insert(otherClassesNPCsShouldLikeButWillNotBeSpawnedByNPCSpawner, NPCKey)
            end
        end everyNPCClassListMerged = {} -- Used for matching... E.g. if they should like each other

        -- Get the actual class name for the NPC ( need the class, not the table key name... Which is inserted in the "allowedCombines" & "allowedZombies" table )
        function GETCorrectNPCEntityClassForRelationship(NPCclass)
            if !MBDCompleteCurrNPCList or !NPCclass then return NPCclass end
            NPCclass = string.lower(NPCclass)

            local i = 0 local maxI = #table.GetKeys(MBDCompleteCurrNPCList)
            for NPCKey,NPCData in pairs(MBDCompleteCurrNPCList) do
                i = i + 1

                if string.lower(NPCKey) == NPCclass then return NPCData["Class"] end
                if i == maxI then return NPCclass end
            end
        end
        function GETCorrectNPCClassFromKey( NPCKey )

            local class = MBDCompleteCurrNPCList[ NPCKey ] -- Can happen sometimes...
            if not class then class = NPCKey else class = MBDCompleteCurrNPCList[ NPCKey ][ "Class" ] end

            return class
        end
        function GETMaybeCustomNPCKeyFromNPCClass(NPCclass)
            if !MBDCompleteCurrNPCList or !MBDCustomKeyToModelNPCs or !NPCclass then return NPCclass end
            NPCclass = string.lower(NPCclass)

            local i = 0 local maxI = #table.GetKeys(MBDCustomKeyToModelNPCs)
            for CustomNPCKey,_ in pairs(MBDCustomKeyToModelNPCs) do
                i = i + 1

                if MBDCompleteCurrNPCList[CustomNPCKey] and MBDCompleteCurrNPCList[CustomNPCKey]["Class"] == NPCclass then
                    return CustomNPCKey
                end if i == maxI then return NPCclass end
            end
        end
        function GETAllValidNPCsWithinTheNPCTable()
            if !allowedNPCClassesCombined then return end

            local newNPCTable = {}

            -- Add NPCs
            for _,NPCClass in pairs( allowedNPCClassesCombined ) do

                for _,NPC in pairs( ents.FindByClass( NPCClass ) ) do table.insert( newNPCTable, NPC ) end

            end

            return newNPCTable
        end

        -- Can be used for dynamic purposes later If I WANT to make it ...
        function updateCurrentNPCSpawnerTables(newAllowedCombinesTable, newAllowedZombiesTable, other, aCustomGeneratedListFromGameOption)
            allowedCombines = newAllowedCombinesTable
            allowedZombies = newAllowedZombiesTable
            otherClassesNPCsShouldLikeButWillNotBeSpawnedByNPCSpawner = other

            allowedNPCsCombined = {}
            table.Add(allowedNPCsCombined, allowedCombines)
            table.Add(allowedNPCsCombined, allowedZombies)

            -- Used for searching through every valid NPC
            allowedNPCClassesCombined = {}
            for _,NPCKey in pairs(allowedNPCsCombined) do
                
                if MBDCompleteCurrNPCList[NPCKey] then
                    local NPCClass = MBDCompleteCurrNPCList[NPCKey]["Class"]
                    if not table.HasValue( allowedNPCClassesCombined, NPCClass ) then
                        table.insert( allowedNPCClassesCombined, NPCClass )
                    end
                end

            end

            everyNPCClassListMerged = {}
            table.Add(everyNPCClassListMerged, newAllowedCombinesTable)
            table.Add(everyNPCClassListMerged, newAllowedZombiesTable)
            table.Add(everyNPCClassListMerged, other)

            -- Remove duplicates
            local tempEveryNPCTable = {}
            for _, npcClass in pairs( everyNPCClassListMerged ) do
                if not table.HasValue( tempEveryNPCTable, npcClass ) then table.insert( tempEveryNPCTable, npcClass ) end

                -- Save
                if _ == #everyNPCClassListMerged then everyNPCClassListMerged = tempEveryNPCTable end
            end

            if SERVER then
                net.Start("mbd_updateTheEnemyNPCTableThatNPCSpawnerUse")
                    net.WriteTable({
                        allowedCombines = newAllowedCombinesTable,
                        allowedZombies = newAllowedZombiesTable
                    })
                net.Broadcast()
                net.Start("mbd:SendAllowedNPCsCombined")
                    net.WriteTable(allowedNPCsCombined)
                net.Broadcast()

                if aCustomGeneratedListFromGameOption then
                    net.Start("NotificationReceivedFromServer")
						net.WriteTable({
							Text 	= "An Admin updated the current NPC Spawner list!",
							Type	= NOTIFY_GENERIC,
							Time	= 6
						})
					net.Broadcast()
                end
            end
        end

        -- This for when a Player writes a custom list
        function MBDWriteNPCSpawnerNPCsCusmoizedListFromWithinTheGameOnly()
			local newJSONTable = [[{
				"customCombinesGroupKeys": ]]..MBDTableToJSON(allowedCombines, true)..[[,
				"customZombiesGroupKeys": ]]..MBDTableToJSON(allowedZombies, true)..[[
			}]]
			timer.Simple(0.3, function()
				-- Write a new file wiith the current data!
				local npcFolder = "mbd-npc"
				local theCustomConfigFileName = MBDRoot_folder_path.."/"..npcFolder.."/npc_custom_settings.json"
				file.Write(theCustomConfigFileName, newJSONTable) MBDCreateNPCConfigFilesAndTablesSERVER(true)
            end)
        end
    end

    if CLIENT then
        net.Receive("mbd:SendAllowedNPCsCombined", function()
            local npcTable = net.ReadTable()

            allowedNPCsCombined = npcTable
        end)
    end

    if SERVER then
        function MBDFindOutHowManyValidNPCsOnMapNumberNPCSpawnerDynamic()
            local everyNPC_unvalid = GETAllValidNPCsWithinTheNPCTable()
            local everyNPC_validated = {}
        
            local count = 0
            for _,npc in pairs(everyNPC_unvalid) do count = count + 1 end

            EnemiesAliveTotal = count return count
        end
        function MBDFindOutHowManyValidNPCsOnMapNumberNPCSpawnerStatic()
            return EnemiesAliveTotal
        end
        function MBDAddToHowManyValidNPCsOnMapNumberNPCSpawnerStatic(npc)
            if EnemiesAliveTotal > GetConVar("mbd_npcLimit"):GetInt() then
                if npc and npc:IsValid() then npc:Remove() end return false
            end

            local newValue = EnemiesAliveTotal + 1
            if newValue > EnemiesAliveTotal then EnemiesAliveTotal = newValue end

            return true
        end
        function MBDSubtractToHowManyValidNPCsOnMapNumberNPCSpawnerStatic()
            EnemiesAliveTotal = EnemiesAliveTotal - 1
        end

        function MBDMaybeSubtractWhenNPCKilledRemoved(npc)
            if !npc or ( npc and !npc:IsValid() ) or ( npc:IsValid() and MBD_CheckIfCanContinueBecauseOfTheNPCClass(npc:GetClass()) ) then
                if npc:GetNWBool("NPCSpawnWasASuccess", false) then
                    MBDSubtractToHowManyValidNPCsOnMapNumberNPCSpawnerStatic()

                    if EnemiesAliveTotal < 0 then EnemiesAliveTotal = 0 end
                end
            end
        end

        function MBDMaybeScaleNPCModel(self, npc, onlyGetSizeNumber, Position, Normal, Offset)
            if GetConVar("mbd_enableAutoScaleModelNPC"):GetInt() == 0 or (
                npc:GetClass() == "npc_strider" or
                npc:GetClass() == "npc_combinegunship" or
                npc:GetClass() == "npc_helicopter"
            ) then npc:FinishNPCSpawnFromNPCSpawner() return end

            -- Change here to scale differently
            local npcModelScale = npc:GetModelScale()

            -- Doing it like this to hinder a math.random/rand bug.... Where it just got mixed up sometimes when called right after eachother...
            local smallSetting = { 0.3, 0.5 }
            local bigSetting = { 1.3, 3 }

            -- Maybe there is no NPC Spawner to check settings for
            local scaleModelSettings = self
            if (
                scaleModelSettings and
                scaleModelSettings:IsValid()
            ) then scaleModelSettings = self:GetNWString("NPCSpawnerScaleModelSettings", "off") else scaleModelSettings = false end

            local setNewModelScale = function(randNumber)
                local newModelSize = npcModelScale * randNumber

                if !onlyGetSizeNumber then
                    npc:SetModelScale(newModelSize, 0.8)
                    npc:SetNWInt("NPCModelScale", newModelSize)

                    npc:Activate() -- Read that this could resize some collision bounds and hitboxes...

                    timer.Simple(0.9, function()
                        if Position and Normal and Offset and npc and npc:IsValid() then
                            npc:AdjustVectorPositionForNPCToAValidOne(Position, Normal, Offset)
                            npc:FinishNPCSpawnFromNPCSpawner()
                        end
                    end)
                end

                return newModelSize
            end

            local maybeOverideRandomSettings = GetConVar("mbd_enableAutoScaleModelNPC"):GetInt()
            if maybeOverideRandomSettings == 1 and scaleModelSettings != false then

                if scaleModelSettings == "off" then return nil
                elseif scaleModelSettings == "smaller" then return setNewModelScale( math.Rand(smallSetting[1], smallSetting[2]) )
                elseif scaleModelSettings == "bigger" then return setNewModelScale( math.Rand(bigSetting[1], bigSetting[2]) ) end

            end

            -- Override random settings
            if maybeOverideRandomSettings == 2 then return setNewModelScale( math.Rand( smallSetting[1], smallSetting[2] ) ) end
            if maybeOverideRandomSettings == 3 then return setNewModelScale( math.Rand( bigSetting[1], bigSetting[2] ) ) end

            return nil -- This will probably never happen
        end

        local metaTableNPCRef = FindMetaTable("NPC")
        function metaTableNPCRef:AdjustVectorPositionForNPCToAValidOne(Position, Normal, Offset)
            local npcWorldPos = Position + Normal * Offset
        
            -- Draw a trace line to find valid spawn point for Z axis...
            -- Draw a line up to nearest World from NPC Max Point
            x, y, z = ( self:OBBCenter().x ), ( self:OBBCenter().y ), ( self:OBBMaxs().z + 33 )
            local startPosTraceLimitZStartPoint = npcWorldPos + Vector(0, 0, 33)
            local endPosTraceLimitZStartPoint = startPosTraceLimitZStartPoint + Vector(0, 0, 3000)
            local traceLimitZStartPoint = util.TraceLine({
                start = startPosTraceLimitZStartPoint,
                endpos = endPosTraceLimitZStartPoint,
                filter = function(ent) if ent:IsWorld() then return true end end
            })
        
            -- Draw a line down to nearest World from nearest top World
            local startPosTraceLimitZEndPoint = traceLimitZStartPoint.HitPos
            local endPosTraceLimitZEndPoint = startPosTraceLimitZEndPoint - Vector(0, 0, 3500)
            local traceLimitZEndPoint = util.TraceLine({
                start = startPosTraceLimitZEndPoint,
                endpos = endPosTraceLimitZEndPoint,
                filter = function(ent) if ent:IsWorld() then return true end end
            })
        
            local newPosition = traceLimitZEndPoint.HitPos
            newPosition = newPosition + traceLimitZEndPoint.HitNormal * Offset
            self:SetPos(newPosition)
        end
        function metaTableNPCRef:FinishNPCSpawnFromNPCSpawner()
            -- Add to COUNTER >>
            local didAdd = MBDAddToHowManyValidNPCsOnMapNumberNPCSpawnerStatic( self )
            if not didAdd then return end

            local timerID = "mbd:onNPCSpawnEffect"..self:EntIndex()
			local effectOn = false

			timer.Create(timerID, 0.15, (6 / 0.15), function()
				if self and self:IsValid() then
					if effectOn then self:SetColor(Color(255, 128, 0, 190)) effectOn = false else self:SetColor(Color(255, 255, 255, 255)) effectOn = true end
				else timer.Remove(timerID) end
			end)
			timer.Simple(6, function()
				timer.Remove(timerID)

				-- OK (we hope)... Finished. Atleast assume it
				if self and self:IsValid() then
					self:SetCollisionGroup(COLLISION_GROUP_NPC)
					self:SetColor(Color(255, 255, 255, 255))

					self:SetNWBool("NPCSpawnWasASuccess", true)
					self:SetNWInt("LastNPCValidCheckCurTime", CurTime())

					-- Set enemies
					self:MBDConfigureAfterSpawn()

					if GameStarted then
						-- Pyramid dropss
						MaybeSpawnAPyramidDropPlayerMustPickUp(self)
					end
				end
			end)
        end
        function metaTableNPCRef:MBDConfigureAfterSpawn()
            self:MBDNPCBecomeNeturalAgainsSpectatingPlayers()
        
            self:AlertSound()
            self:MBDSetRandomPlayerTargetForNPC()
        end
        function metaTableNPCRef:MBDInitAfterSpawnCheckIfDone(message)
            if self:GetNWBool("NPCSpawnWasASuccess", false) then return true end
            if !self or !self:IsValid() or ( CurTime() - self:GetNWInt("respawnTimeCurTime", 0) > 9 ) then
                if self and self:IsValid() and !self:GetNWBool("NPCSpawnWasASuccess", false) then self:Remove() print(message) end
                
                return true
            end

            return false
        end

        function metaTableNPCRef:MBDNPCBecomeNeturalAgainsSpectatingPlayers()
            for k, v in pairs(player.GetAll()) do

                if !v or !v:IsValid() or !self or !self:IsValid() then return end
                if v:GetNWBool("isSpectating", false) then
                    --- BE NEUTRAL AGAINS Spectation Players
                    self:AddEntityRelationship(v, D_NU, 99)
                end

            end
        end
        function metaTableNPCRef:MBDNPCBecomeNeturalAgainsSpectatingPlayer(pl)
            if !pl or !pl:IsValid() or !self or !self:IsValid() then return end
            if pl:GetNWBool("isSpectating", false) then
                --- BE NEUTRAL AGAINS Spectation Players
                self:AddEntityRelationship(pl, D_NU, 99)
            end
        end

        function metaTableNPCRef:MBDNPCLikeAllOtherNPCClassesInMergedNPCsTable()
            -- LIKE Feelz for every NPC class in the merged list of every possible spawned NPC connected to M.B.D. Spawner and it's NPCs
            for _,theNPCWillLikeThisNPCKey in pairs(everyNPCClassListMerged) do

                local NPCClass = GETCorrectNPCClassFromKey( theNPCWillLikeThisNPCKey ) if NPCClass and self:GetClass() != NPCClass then
                    -- print(self, "==> SHOULD LIKE CLASS:", NPCClass)
                    self:AddRelationship( NPCClass .. " D_NU 9" )
                end

            end
        end
        function metaTableNPCRef:MBDSetRandomPlayerTargetForNPC()
            if self:IsNPC() and ( !self:GetEnemy() or !self:GetEnemy():IsValid() ) then
                local allSearchEntities = {}
                
                for _, pl in pairs(player.GetAll()) do

                    if pl and pl:IsValid() and !pl:GetNWBool("isSpectating", false) then
                        table.insert(allSearchEntities, pl)
                    else
                        self:MBDNPCBecomeNeturalAgainsSpectatingPlayer(pl)
                    end

                end table.Add(allSearchEntities, ents.FindByClass("npc_bullseye"))

                local winnerPlayerIndex = math.Round(math.random(1, #allSearchEntities))
                local plOrNPCBullseye = allSearchEntities[winnerPlayerIndex]

                -- Set the enemy for the NPC, so it does not just stand
                -- there after i.e. spawn or otherwise ...
                if !self or !self:IsValid() or !plOrNPCBullseye or !plOrNPCBullseye:IsValid() then return end

                self:SetEnemy(plOrNPCBullseye)
                self:UpdateEnemyMemory(plOrNPCBullseye, plOrNPCBullseye:GetPos())
                self:SetSchedule(SCHED_WAKE_ANGRY) -- SCHED_WAKE_ANGRY SCHED_ESTABLISH_LINE_OF_FIRE
            end
        end

        MBDNPCWillHaveCustomData = false
        MBDNPCIsFinishedLoaded = false
        -------------------- ---- ---
        -- * SETTINGS FOR NPCS * --
        ----------------------- -----

        -- NPCs allowed to be spawned by the Spawner =>>>
        MBDAmountOfHunters = 0

        -- -- --
        -- - The SERVER (A USER) wants it's own npcs =>> If it exists in the data folder
        -- 1. Edit the npc_custom_settings.json to change
        -- -- --
        -- Wait a little bit, so the NPC list etc. from the servers are properly populated !!
        local npcFolder = "mbd-npc"
        if !file.Exists(MBDRoot_folder_path, "DATA") then file.CreateDir(MBDRoot_folder_path) end
        if !file.Exists(MBDRoot_folder_path.."/"..npcFolder, "DATA") then file.CreateDir(MBDRoot_folder_path.."/"..npcFolder) end

        local customCombineTableKey = "customCombinesGroupKeys"
        local customZombieTableKey = "customZombiesGroupKeys"

        function MBDCreateNPCConfigFilesAndTablesSERVER(aCustomGeneratedListFromGameOption)
            local theCustomConfigFileName = MBDRoot_folder_path.."/"..npcFolder.."/npc_custom_settings.json"
            if !file.Exists(theCustomConfigFileName, "DATA") then
                file.Write(theCustomConfigFileName,
                    [[{
                        "]]..customCombineTableKey..[[": [],
                        "]]..customZombieTableKey..[[": []
                    }]]
                )
            end

            local latestVersionOfOriginalConfigFil = "0"
            local latestVersionOfOriginalConfigName = "--Just A Backup From Original Settings You Can Use--npc_original_settings.json"
            local theOriginalConfigFileName = MBDRoot_folder_path.."/"..npcFolder.."/"..latestVersionOfOriginalConfigName
            local function writeOriginalConfigFile()
                file.Delete(theOriginalConfigFileName)

                -- Write
                file.Write(theOriginalConfigFileName,
                    [[{
                        "version": ]]..latestVersionOfOriginalConfigFil..[[,
                        "]]..customCombineTableKey..[[": ]]..MBDTableToJSON(allowedCombines, true)..[[,
                        "]]..customZombieTableKey..[[": ]]..MBDTableToJSON(allowedZombies, true)..[[
                    }]]
                )
            end
            if !file.Exists(theOriginalConfigFileName, "DATA") then
                writeOriginalConfigFile()
            end
            timer.Simple(0.15, function()
                local originalConfigFileRaw = file.Read(theOriginalConfigFileName, false)

                timer.Simple(2, function()
                    if !originalConfigFileRaw then MsgC(Color(255, 0, 0), "M.B.D.: Could not read original config file for NPC... Canceling further operations.") return end

                    -- ... Maybe update the original version
                    local originalConfigData = util.JSONToTable(originalConfigFileRaw)
                    if originalConfigData["version"] and tostring(originalConfigData["version"]) != tostring(latestVersionOfOriginalConfigFil) then
                        -- Write the newest
                        writeOriginalConfigFile()
                    end
                    -- Write a list of all npcs available one each start-up (cause it might change often)
                    -- -
                    if !file.Exists(MBDRoot_folder_path.."/server-lists/", "DATA") then file.CreateDir(MBDRoot_folder_path.."/server-lists/") end
                    -- -
                    local npcList = {}
                    local temp_npcList = table.Copy(MBDCompleteCurrNPCList)
                    local npcListFilePlacement = MBDRoot_folder_path.."/server-lists/all-npcs.json"
                    -- --
                    -- Go ahead and check that all values are rounded for the price (since JSON file allows comma)
                    local convertToWholeNumber = function(tableOfPrices)
                        local newTable = {}
                        for k,v in pairs(tableOfPrices) do newTable[k] = math.Round(tonumber(v)) end
                        return newTable
                    end
                    -- -
                    --
                    -- Delete
                    if file.Exists(npcListFilePlacement, "DATA") then file.Delete(npcListFilePlacement) end
                    -- Write
                    temp_npcList["AAAA-MBD"] = {
                        [1] = ".",
                        [3] = ".",
                        [2] = ".",
                        [4] = ".",
                        PrintName = "This file was created at: "..os.date("Time: %T Date: %D", os.time())
                    }
                    -- SORT
                    for id,data in SortedPairsByMemberValue(temp_npcList, "PrintName", false) do
                        npcList[id] = data
                    end
                    -- - --
                    -- -
                    ---
                    -- NPCs
                    local temp_npcList = {}
                    for key,data in SortedPairs(npcList) do
                        table.insert(temp_npcList, [["]]..key..[[":]]..util.TableToJSON(data))
                    end
                    table.SortDesc(temp_npcList)
            
                    -- Write...
                    local newTableNpcList = "{"..table.concat(table.Reverse(temp_npcList), ",").."}"
                    file.Write(npcListFilePlacement, newTableNpcList)
                    -- - - - -
                    -- - -
                    -- Check the file... If anything in allowedWeapons or allowedOther, overwrite everything...
                    if file.Exists(theCustomConfigFileName, "DATA") then
                        local customConfigFileRaw = file.Read(theCustomConfigFileName, false)
            
                        local customConfigData = util.JSONToTable(customConfigFileRaw)
            
                        local fieldHasData = function(key)
                            if #customConfigData[key] > 0 then return true end
            
                            return false
                        end
            
                        -- Check if going custom...
                        local timerID0 = "checkIfGoingCustom0"
                        timer.Create(timerID0, 0.5, 0, function()
                            if customConfigData then -- This will either be empty ( not customized ) or have something. Checks that underneath =>
                                timer.Remove(timerID0)

                                if (
                                    (
                                        customConfigData[customCombineTableKey] and
                                        customConfigData[customZombieTableKey] and (
                                            fieldHasData(customCombineTableKey) or
                                            fieldHasData(customZombieTableKey)
                                        )
                                    ) or aCustomGeneratedListFromGameOption
                                ) then
                                    --
                                    MsgC(Color(0, 170, 255), "M.B.D.: (1 of 4) Custom NPC data detected. Writing custom NPC data...\n")
                                    MBDNPCWillHaveCustomData = true
                                    MBDNPCIsFinishedLoaded = false
                                    -- Create custom list based on the custom content!
                                    -- - - Lets' G O
                                    local GetCustomNPCGroup = function(key)
                                        if !customConfigData[key] or #customConfigData[key] == 0 then return {} end
                                        
                                        return customConfigData[key]
                                    end
                                    -- -
                                    -- Custom NPCs from JSON File
                                    allowedCombines = GetCustomNPCGroup(customCombineTableKey)
                                    allowedZombies = GetCustomNPCGroup(customZombieTableKey)
                                    MsgC(Color(0, 170, 255), "M.B.D.: (2 of 4) Done writing custom NPC data.\n")

                                    MsgC(Color(0, 170, 255), "M.B.D.: (3 of 4) Handling the custom NPC data...\n")
                                    timer.Simple(1.5, function()
                                        --- -- -
                                        -- - - Check if every class is valid (that the server has the values)
                                        -- .. AND Clean up up the non valid weapon classes for this server
                                        local filterOutOnlyValidNPCs = function(allowedTableForTheClass)
                                            if #allowedTableForTheClass == 0 then return {} end

                                            local temp_newFilteredValidData = {}
                    
                                            -- Loop
                                            local maxI = #allowedTableForTheClass
                                            for i, npcKey in pairs(allowedTableForTheClass) do
                                                if MBDCompleteCurrNPCList[npcKey] and !temp_newFilteredValidData[npcKey] then
                                                    temp_newFilteredValidData[i] = npcKey
                                                end

                                                if i == maxI then return temp_newFilteredValidData end
                                            end
                                        end
                                        allowedCombines = filterOutOnlyValidNPCs( allowedCombines )
                                        allowedZombies = filterOutOnlyValidNPCs( allowedZombies )

                                        -- -
                                        -- Wait for the lists above to get loaded...
                                        timer.Simple(0.6, function()
                                            --
                                            -- - -- -
                                            -- -- Very finished.. SAVEED.. Will now Update Generation List
                                            -- --
                                            updateCurrentNPCSpawnerTables(allowedCombines, allowedZombies, otherClassesNPCsShouldLikeButWillNotBeSpawnedByNPCSpawner, aCustomGeneratedListFromGameOption)
                                            
                                            MsgC(Color(170, 255, 0), "M.B.D.: (4 of 4) Done handling the custom NPC data. Everything should be 100 % OK Finished.\n")

                                            MBDNPCIsFinishedLoaded = true
                                        end)
                                    end)
                                else
                                    -- Use the default settings
                                    updateCurrentNPCSpawnerTables(allowedCombines, allowedZombies, otherClassesNPCsShouldLikeButWillNotBeSpawnedByNPCSpawner, aCustomGeneratedListFromGameOption)

                                    MsgC(Color(170, 255, 0), "M.B.D.: (0) Not going custom with the NPC data.\n")

                                    MBDNPCIsFinishedLoaded = true
                                end
                            end
                        end)
                    end
                end)
            end)
        end timer.Simple(6, MBDCreateNPCConfigFilesAndTablesSERVER)
    end
end
