--[[---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode (A MODIFIED version; aka "My Base Defence" gamemode)

-----------------------------------------------------------]]

-- These files get sent to the client

AddCSLuaFile( 'shared.lua' )
AddCSLuaFile( 'cl_spawnmenu.lua' )
AddCSLuaFile( 'cl_notice.lua' )
AddCSLuaFile( 'cl_search_models.lua' )
AddCSLuaFile( 'gui/IconEditor.lua' )

AddCSLuaFile( 'spawnmenu/controls/manifest.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/manifest.lua' )

AddCSLuaFile( 'spawnmenu/controls/control_presets.lua' )
AddCSLuaFile( 'spawnmenu/controls/preset_editor.lua' )
AddCSLuaFile( 'spawnmenu/controls/ropematerial.lua' )
AddCSLuaFile( 'spawnmenu/controls/ctrlnumpad.lua' )
AddCSLuaFile( 'spawnmenu/controls/ctrlcolor.lua' )
AddCSLuaFile( 'spawnmenu/controls/ctrllistbox.lua' )

AddCSLuaFile( 'spawnmenu/creationmenu/content/content.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contentcontainer.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contentheader.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenticon.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contentsearch.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contentsidebar.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contentsidebartoolbox.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/postprocessicon.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/manifest.lua' )

AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/addonprops.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/custom.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/dupes.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/entities.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/gameprops.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/npcs.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/postprocess.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/saves.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/vehicles.lua' )
AddCSLuaFile( 'spawnmenu/creationmenu/content/contenttypes/weapons.lua' )

--
--
--
--[[ Include Custom Scripts ]]
AddCSLuaFile("LobbyManager/cl_lobby.lua")
AddCSLuaFile("LobbyManager/cl_lobby_respawn.lua")

AddCSLuaFile( "spawnmenu/spawnmenu.lua" )

AddCSLuaFile( 'prop_tools.lua' )

AddCSLuaFile( 'spawnmenu/controlpanel.lua' )

AddCSLuaFile( "spawnmenu/toolpanel.lua" )

AddCSLuaFile( "spawnmenu/toolmenu.lua" )
AddCSLuaFile( "spawnmenu/contextmenu.lua" )
AddCSLuaFile( "spawnmenu/creationmenu.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_notice.lua" )
AddCSLuaFile( "cl_search_models.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "cl_worldtips.lua" )
AddCSLuaFile( "persistence.lua" )
AddCSLuaFile( "player_extension.lua" )
AddCSLuaFile( "save_load.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "gui/IconEditor.lua" )

AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )
AddCSLuaFile( 'commands.lua' )
include( 'commands.lua' )
AddCSLuaFile( 'player.lua' )
include( 'player.lua' )
AddCSLuaFile( 'spawnmenu/init.lua' )
include( 'spawnmenu/init.lua' )
---> >> >
--- -- --
----
--[[ ----------------------------------------------------

								| My Base Defence |
										 Beta 2.25
										-. . .-
							    Is Made By:
		ravo (Norway), SteamID: STEAM_0:1:18860056
							    ---  ...  ---
 First Official Version Released: 07. February 2019
								      ---
								       -
		   *Remember to read the LICENSE.txt* .-)
		
---------------------------------------------------  ]]--
---- --->>
-- ->
-- GLOBAL VARS. FOR SERVER (RELATED TO THE WHOLE GAME)
startGameTimerTotal 	= 120
startGameTimerLeft 		= startGameTimerTotal
GameStarted				= false 				-- *NOTE : *THIS MUST START WITH FALSE !
NowItIsPossibleToStartGame = true
AttackRoundIsOn			= false					-- *NOTE : *THIS MUST START WITH FALSE !
--HardnessOfGame		= 1						-- easy=1 medium=1.3 hard=1.8
CurrentRoundWave		= nil
timerCountDownIsOn 		= true
EnemiesAliveTotal		= 0
ValidSpawnBackupPositionsVectorsFromNPCs = {}
--ValidSpawnNPCs__Timers = {}

AvailableThingsToBuy = nil

GameIsSinglePlayer = game.SinglePlayer()

slowMotionGameIsActivatedByPlayerSinglePlayer	= false
slowMotionKeyIsDown 							= false
CameraTopViewIsAllowed							= false
OnlyTopCameraViewIsAllowed						= false

-- Have to define these at server side, becuase they are really ment only for client side!
NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_UNDO = 2
NOTIFY_HINT = 3
NOTIFY_CLEANUP = 4

-- --->
--- - =>> > CONSOLE VARS. for SERVERSIDE ONLY (ADMIN) | The other ones are in the config .txt file... These will be saved on server quit
CreateConVar("mbd_game_status", "", FCVAR_PROTECTED, "Starts (start) or Ends (end) the main game on the SERVER and CLIENT (ADMIN).")
CreateConVar("mbd_roundWaveNumber", 0, FCVAR_PROTECTED, "What round the current game is on.")
CreateConVar("mbd_disableSlowMotionEffect", 0, { FCVAR_PROTECTED }, "Disable Slow Motion Effect when pressing \"E\" and shooting.")
CreateConVar("mbd_shouldOutputWhenPropIsRemoved", 0, { FCVAR_PROTECTED }, "Just shows a console message when a prop is undone and which player did it.")
--

CreateConVar("mbd_howManyDropItemsPickedUpByPlayers", 0, { FCVAR_PROTECTED, FCVAR_UNREGISTERED }, "How many Pyramid drops picked up by Players this wave/round.")
CreateConVar("mbd_howManyDropItemsSpawnedAlready", 0, { FCVAR_PROTECTED, FCVAR_UNREGISTERED }, "How many Pyramid drops currently spawned by NPCs/BuyBox/NPC Spawner this wave/round.")

CreateConVar("mbd_currentGameSpeedSetReadOnly", 1, { FCVAR_PROTECTED, FCVAR_UNREGISTERED }, "Current game speed set my an admin.")

-- Cheats (sv_cheats)
CreateConVar("mbd_disableStamina", 0, { FCVAR_PROTECTED, FCVAR_CHEAT }, "Disable Stamina for all Players (makes the game easier).")
--
-- Set some variables..>>
game.ConsoleCommand("ai_serverragdolls 0\n") -- Disables server ragdolls...
--- -
--- - -
-- Check that the Admin has spawned necesarry props..
haveSpawnedImportantGameProps = false
timer.Create("mbd:checkForImportantGamePropsBeingSpawned", 2, 0, function()
	local amountOfNPCSpawners = 0
	local amountOfBuyBox = 0

	for _,prop in pairs(ents.FindByClass("mbd_**")) do
		if prop:GetClass() == "mbd_npc_spawner_all" then amountOfNPCSpawners = amountOfNPCSpawners + 1 end
		if prop:GetClass() == "mbd_buybox" then amountOfBuyBox = amountOfBuyBox + 1 end
	end
	
	if amountOfNPCSpawners > 0 and amountOfBuyBox > 0 then haveSpawnedImportantGameProps = true else
		haveSpawnedImportantGameProps = false

		if checkIfAdminHasJoinedTheServerOneTime then checkIfAdminHasJoinedTheServerOneTime() else print("M.B.D. Error: checkIfAdminHasJoinedTheServerOneTime Function is nil for now...") end
	end
end)
-- -
function ClientPrintAddTextMessage(pl, __table)
	-- Convert number to string..
	local newTable = {}
	for _,tData in pairs(__table) do
		local newData
		if !tData then newData = "NULL"
		elseif isnumber(tData) then newData = tostring(tData) else newData = tData end

		table.insert(newTable, newData)
	end

	net.Start("ClientPrintAddTextMessage", true)
		net.WriteTable(newTable)
	net.Send(pl)
end
--
function changeCountDown(text, time, pause)
	if text == 0 then
		text = "T-minus to attack: "
	elseif text == 1 then
		text = "T-minus to safety: "
	end

	if !time then time = "N/A" end

	if pause then
		sendCountDownerClient(0, text..time, nil)
	else
		sendCountDownerClient(1, text, time)
	end
end
--- -
function resetDrops0()
	timer.Simple(0.15, function()
		GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):SetInt(0)
		GetConVar("mbd_howManyDropItemsSpawnedAlready"):SetInt(0)
	end)
end
-- Should always do this really.. If it is spawned by Player. After "Spawn()" for entity
function registerAnEntityForUndoLater(name, ent, pl, isVehicle)
	if ent and ent:IsValid() and pl and pl:IsValid() then
		undo.Create(name)
			undo.AddEntity(ent)
			undo.SetPlayer(pl)
		if isVehicle then pl:AddCleanup( "vehicles", ent ) undo.SetCustomUndoText("Returned a M.B.D. Vehicle") else pl:AddCleanup( "props", ent ) end
		undo.AddFunction(function(tab, arg2)
			local ent = tab.Entities[1]
			local owner = tab.Owner

			if GetConVar("mbd_shouldOutputWhenPropIsRemoved"):GetInt() == 1 and ent and ent:IsValid() and owner and owner:IsValid() then
				text0 = "PROP"
				if string.match(string.lower(ent:GetClass()), "vehicle") then text0 = "VEHICLE" end

				print("A "..text0.." got REMOVED. Connected to Player \""..owner:Nick().."\".".."Ref.: ", arg2)
			end
		end, 0)
		undo.Finish()
	else print("M.B.D. Error: Could not add entity to undo... It or owner was invalid.") end
end
function undoEntityWithOwner(owner, ent, ownText, dontNotify, onlyForceUpdateNoText)
	-- -
	-- Remove from Undo list
	if owner and owner:IsValid() and ent and ent:IsValid() then
		if !dontNotify then
			-- Custom functions that works... Removes the entity from Undo list also + gives the custom Undo message back to Player
			MBDDoUndo({
				Owner = owner,
				Name = "M.B.D. Undo",
				Entities = { ent },
				CustomUndoText = ownText or "Returned an Entity"
			}, true, onlyForceUpdateNoText)
		else ent:Remove() --[[ This should not be Player produced props maybe... ]] end
	elseif !owner or ( owner and !owner:IsValid() and ent and ent:IsValid() ) then ent:Remove() end
end
--- -
-- Maybe Spawn a drop so Players can continue the wave/round
-- - This function will only run on NPC Entities
-- This function gets triggered on NPC spawn and every tick on the saftey T-minus counter
function MaybeSpawnAPyramidDropPlayerMustPickUp(ent)
	if
		GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt() >= GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() or
		GetConVar("mbd_howManyDropItemsSpawnedAlready"):GetInt() >= GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() then
		
			return
	end

	local repsLeftFromRoundCreator = timer.RepsLeft("mbd:RoundCreator001")
	if !repsLeftFromRoundCreator or !CurrentRoundWave or CurrentRoundWave <= 3 then return end
	-- - -
	-- Chances of getting spawneD (Algorithm)
	local algorithmAllowsSpawnOfPyramid = function() -- Should almost always be a 100 % success rate to produce enough Pyramid drops each round...
		-- The starting time
		local maxTimeFromStart = GetConVar("mbd_countDownTimerEnd"):GetInt()
		-- Time left
		local maxTimeLeft = repsLeftFromRoundCreator - 6
		if maxTimeLeft < 0 then maxTimeLeft = 0 end
		-- Total amount that HAVE to be spawned
		local amountThatNeedsToBeProduced = GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt()
		-- Amount that have ALREADY been spawned
		local amountThatHaveToBeSpawned = GetConVar("mbd_howManyDropItemsSpawnedAlready"):GetInt()
		-- - - -
		-- --
		-- -
		local percentageRoundComplete = math.Round((maxTimeFromStart - maxTimeLeft) / maxTimeFromStart, 2)
		
		--- - -
		-- CANCEL
		if percentageRoundComplete <= 0.3 then
			return false
		end -- Wait a little before allowing drops
		-- - -
		-- ALLOW
		if percentageRoundComplete >= 0.94 then
			return true
		end -- Very little time left... Just allow - 94 % complete
		if percentageRoundComplete <= 0.73 and math.Round(math.Rand(0, 3/3), 2) <= math.Round(1/3, 2) then
			return true
		end -- Below 73 % and a 1/3 chance of getting spawned
		if percentageRoundComplete > 0.73 and percentageRoundComplete < 0.94 and math.Round(math.Rand(0, 2/3), 2) <= math.Round(1/3, 2) then
			return true
		end -- Above 73 % and below 94 % and a 2/3 chance of getting spawned

		return false
	end
	--
	-- -
	if !algorithmAllowsSpawnOfPyramid() then return end
	-- - -
	-- Save a postion... If low time and no Entities, spawn at random valid positions..
	if ent and ent:IsValid() then
		-- IGNORE FOR THESE NPCs (cancel)... Because they can be high up in the air...
		local npcClass = ent:GetClass()
		if (
			npcClass == "npc_antlion" or
			npcClass == "npc_fastzombie" or
			npcClass == "npc_combinegunship" or
			npcClass == "npc_helicopter" or
			npcClass == "npc_strider"
		) then return end

		--- -
		-- Save entPos to Spawn Backup Positions
		if #ValidSpawnBackupPositionsVectorsFromNPCs < 100 then
			if
				ent and ent:IsValid() and
				GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt() < GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() and
				GetConVar("mbd_howManyDropItemsSpawnedAlready"):GetInt() < GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() and
				ent:GetNWBool("NPCSpawnWasASuccess", false) then
					local pos = ent:LocalToWorld( ent:OBBMins() + Vector(0, 0, 5) )
					if !table.HasValue(ValidSpawnBackupPositionsVectorsFromNPCs, pos) then table.insert(ValidSpawnBackupPositionsVectorsFromNPCs, pos) end
			end
		end
	end
	--- -
	-- Spawn Pyramid Drop 100 %
	local SpawnPyramidDrop = function(dropContinueWaveRoundEnt, __ent)
		local npc = __ent
		--- -
		-- -
		-- Spawn
		local npcPos
		local npcAngle

		--- Maybe set backup position
		local currTableLengthSavedPos = #ValidSpawnBackupPositionsVectorsFromNPCs
		local backUpPosition = nil
		if ( !npc or !npc:IsValid() ) and currTableLengthSavedPos > 0 then
			local randIndex = math.random(1, currTableLengthSavedPos)
			backUpPosition = ValidSpawnBackupPositionsVectorsFromNPCs[randIndex]
			timer.Simple(0.15, function() table.remove(ValidSpawnBackupPositionsVectorsFromNPCs, randIndex) end)
		end
		--
		--- -
		if npc and npc:IsValid() then
			npcPos = npc:LocalToWorld(npc:OBBMins() + Vector(0, 0, 5))
			npcAngle = npc:GetAngles()
		elseif backUpPosition then
			-- Backup position from another NPC spawn Pos...
			npcPos = backUpPosition -- Vector
			npcAngle = Angle(0, 0, 0)
		else
			-- LAST Backup position...
			-- Check for BuyBox (best)
			local oneRandomBuyBox = ents.FindByClass("mbd_buybox")
			if oneRandomBuyBox and #oneRandomBuyBox > 0 then
				oneRandomBuyBox = oneRandomBuyBox[math.random(1, #oneRandomBuyBox)]

				npcPos = oneRandomBuyBox:LocalToWorld(oneRandomBuyBox:OBBMins() + Vector(math.random(-20, 20), math.random(-20, 20), 15))
				npcAngle = oneRandomBuyBox:GetAngles()

				backUpPosition = true
			else
				-- Check for NPC Spawner
				local oneRandomNPCSpawner = ents.FindByClass("mbd_npc_spawner_all")
				if oneRandomNPCSpawner and #oneRandomNPCSpawner > 0 then
					oneRandomNPCSpawner = oneRandomNPCSpawner[math.random(1, #oneRandomNPCSpawner)]

					npcPos = oneRandomNPCSpawner:LocalToWorld(oneRandomNPCSpawner:OBBMins() + Vector(math.random(-20, 20), math.random(-20, 20), 5))
					npcAngle = oneRandomNPCSpawner:GetAngles()

					backUpPosition = true
				else print("Uexpected error with spawning a pyramid drop... No Vector Pos. set.. Removed.") dropContinueWaveRoundEnt:Remove() return end
			end
		end
		-- - -
		-- -
		timer.Simple(0.1, function()
			-- One last check....
			if (
				GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt() >= GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() or
				GetConVar("mbd_howManyDropItemsSpawnedAlready"):GetInt() >= GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() or (
					repsLeftFromRoundCreator >= GetConVar("mbd_countDownTimerEnd"):GetInt() / 5 and -- Only allow when small amount of time left to spawn at a buybox or npc spawner
					backUpPosition == true
				) or (!npc or (npc and npc:IsValid() and !npc:GetNWBool("NPCSpawnWasASuccess", false)))
			) then --[[ Cancle ]] dropContinueWaveRoundEnt:Remove() return else
				dropContinueWaveRoundEnt:SetPos(npcPos)
				dropContinueWaveRoundEnt:SetAngles(npcAngle)

				dropContinueWaveRoundEnt:Spawn()
				dropContinueWaveRoundEnt:Activate()

				local howManyDropItemsSpawnedAlready = GetConVar("mbd_howManyDropItemsSpawnedAlready"):GetInt()
				GetConVar("mbd_howManyDropItemsSpawnedAlready"):SetInt(howManyDropItemsSpawnedAlready + 1)
			end
		end)
	end
	--- -
	-- Wait.. Try for 10 seconds
	local waitUntilNext = 0.5
	local tries = 10 / waitUntilNext
	MBD_internal_checkIfValid = function(dropContinueWaveRoundEnt)
		if tries >= 0 and !dropContinueWaveRoundEnt or !dropContinueWaveRoundEnt:IsValid() then tries = (tries - 1) timer.Simple(waitUntilNext, function() MBD_internal_checkIfValid() end)
		elseif dropContinueWaveRoundEnt and dropContinueWaveRoundEnt:IsValid() and GetConVar("mbd_howManyDropItemsSpawnedAlready"):GetInt() < GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() then
			SpawnPyramidDrop(dropContinueWaveRoundEnt, ent) end
	end

	local dropContinueWaveRoundEnt = ents.Create("mbd_npc_drop_continue_game")
	MBD_internal_checkIfValid(dropContinueWaveRoundEnt)
end
--
--- Extra materials
--list.Add( "OverrideMaterials", "models/Debug/debugmesh" ) -- Lightning DONT need this for the material tool
--
--
local function checkIfWitinHealingArea(ent, _Owner)
	-- Check that the Player Owner is allowed to heal the Prop
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

					if !table.HasValue(currentAllowedPlayers, _Owner:UniqueID()) then
							-- Cancle...
							return false
					end

					return true
			end
	end
end
function WeaponHitEffect(type, trace, ent, useTracePos)
		if SERVER then
			local effectdata = EffectData()

			local entCenter = ent:OBBCenter()
			if !useTracePos then
					entCenter	= ent:LocalToWorld(entCenter)
					effectdata:SetOrigin(entCenter)
			else effectdata:SetOrigin(trace.HitPos) end
			effectdata:SetAngles(ent:GetAngles())
			effectdata:SetEntity(ent)
			effectdata:SetDamageType(DMG_CLUB)

			util.Effect(type, effectdata, true, true)
		end
end
local function SpawnEffectAnEffectForWorld(Effectdata, TypeTable, WorldPos, TraceData)
	-- SetUp Position
	local _Pos 			= nil
	local HitNormal = nil
	if !WorldPos then
		_Pos 				= TraceData.HitPos
		_HitNormal 	= TraceData.HitNormal
	else
		_Pos 				= WorldPos
		_HitNormal 	= Vector(0, 0, 0)
	end

	--- Define More Custom Data
	Effectdata:SetOrigin(_Pos)
	Effectdata:SetNormal(_HitNormal)
	-- --
	-- Produce >> >
	for _,EffectType in pairs(TypeTable) do
		util.Effect(EffectType, Effectdata, true, true)
	end
end
net.Receive("SpawnAnEffectServerside", function(len, pl)
	local _EffectData = net.ReadTable()

	local _EffectID,
	_EffectTypeTable,
	_EffectWorldPos,
	_EffectTraceData = _EffectData.ID, _EffectData.EffectTypeTable, _EffectData.WorldPos, _EffectData.TraceData

	local _HitPosEntity = _EffectTraceData.Entity
	
	local effectdata = EffectData()
	effectdata:SetOrigin(Vector(0, 0, 0))

	-- - - GOO >>> >
	if _EffectID == 1 then
		-- PointerEffect 1 and 2 (A long line also from World Vector 0,0,0 => To trace position)
		effectdata:SetMagnitude(2)
		effectdata:SetScale(1)
		effectdata:SetRadius(4)

		SpawnEffectAnEffectForWorld(effectdata, _EffectTypeTable, nil, _EffectTraceData)
	elseif _EffectID == 2 then
		-- Repairing Prop/Vehicle Effect
		local IsFullHealth = _HitPosEntity:GetNWInt("healthLeft", -1) == _HitPosEntity:GetNWInt("healthTotal", -2)
		if (
				_HitPosEntity and
				_HitPosEntity:IsValid() and
				IsFullHealth
		) then
				-- Full Health (smaller effect)
				effectdata:SetMagnitude(1)
				effectdata:SetScale(1)
				effectdata:SetRadius(1)
		else
				-- Borrowed Code For The Effect... (lasertrace.lua)
				-- Not full Health
				effectdata:SetMagnitude(2)
				effectdata:SetScale(1)
				effectdata:SetRadius(9)
		end

		-- Yees
		SpawnEffectAnEffectForWorld(effectdata, _EffectTypeTable, nil, _EffectTraceData)
	else
		-- Whateever else
		--- --
		-- EffectData (Normal)
		effectdata:SetMagnitude(2)
		effectdata:SetScale(1)
		effectdata:SetRadius(4)

	end
end)
function HinderDuplicationOrRemovalOfEntities(self, ent, type)
	if (
			ent and
			ent:IsValid()
		) then
			local _OwnerOfEntity 	= ent:GetCreator() -- ent:GetNWEntity("PlayerOwnerEnt", nil)
			local _OwnerOfTool		= self:GetOwner()
			-- -- Use:: :
			-- Return "true" (boolean) to Hinder; "false" (boolean) to Allow

			local TheOwnerOfTheEntity = nil
			if (
				(
					!_OwnerOfEntity or
					!_OwnerOfEntity:IsValid() or
					!_OwnerOfTool or
					!_OwnerOfTool:IsValid()
				) and (
					_OwnerOfTool:IsValid() and
					_OwnerOfTool:MBDIsNotAnAdmin(true)
				)
			) then return true end

			-- Don't allow to use on NPCs or Players...
			if (_OwnerOfTool:MBDIsNotAnAdmin(true) and (
					ent:IsNPC() or
					ent:IsPlayer()
				)) then return true end

			-- This only checks in, if the Player is an Admin
			if (
				!_OwnerOfEntity or
				!_OwnerOfEntity:IsValid()
			) then
				TheOwnerOfTheEntity = true
			else TheOwnerOfTheEntity = _OwnerOfEntity:UniqueID() == _OwnerOfTool:UniqueID() end

			local entClass = ent:GetClass()

			-- -
			--- -
			-- For SuperAdmins (allow everything)
			if (
				!TheOwnerOfTheEntity and
				_OwnerOfTool:MBDIsAnAdmin(false)
			) then return false end
			
			-- --- -
			-- Check the Owner
			if (
				type == "remove" and -- Allow Trying to Duplicate Others Props, but not removing !!
				!TheOwnerOfTheEntity and
				_OwnerOfTool:MBDIsNotAnAdmin(true)
			) then return true end

			-- --
			-- Check the type
			if _OwnerOfTool:MBDIsNotAnAdmin(true) then -- Only check if not an Admin ...
				if (
					!string.match(entClass, "prop") and
					!string.match(entClass, "vehicle")
				) then return true end
			end
		else return true end

		return false
end
--
--- --
--- SF Enumations... >> https://wiki.garrysmod.com/page/Enums/SF
MBDNewFlags0 = tostring(
	bit.bor(
		SF_NPC_ALWAYSTHINK,
		SF_NPC_FADE_CORPSE,
		--[[ SF_NPC_LONG_RANGE, ]]
		SF_NPC_NO_WEAPON_DROP
	)
)
MBDNewFlags1 = tostring(
	bit.bor(
		SF_NPC_ALWAYSTHINK,
		SF_NPC_FADE_CORPSE,
		--[[ SF_NPC_LONG_RANGE, ]]
		SF_NPC_DROP_HEALTHKIT
	)
)
MBDNewFlags2 = tostring(
	bit.bor(
		SF_NPC_ALWAYSTHINK,
		SF_NPC_FADE_CORPSE,
		--[[ SF_NPC_LONG_RANGE, ]]
		SF_NPC_NO_WEAPON_DROP
	)
)
-- -
--
function ResetPlayersValues(traceID, pl)
	-- print("ResetPlayersValues TraceID", traceID, pl)

	if (
		pl:IsValid() and
		pl:IsPlayer()
	) then
		---
		---- -
		pl:SetNWInt("money", 0)
		pl:SetNWInt("buildPoints", 0)

		pl:SetNWInt("classInt", -1)

		pl:SetNWString("classname", MBDGetClassNameForPlayerClass(-1, true))
		pl:SetNWString("classnameLobby", "No Class (Pick One)")

		pl:SetNWInt("killCount", 0)
	end
end
function maybeSpawnPlayerFromClass(traceID, pl, newClassInt, currClassInt, mustCompleteSpawnFromRespawnButtonLater)
	-- print("maybeSpawnPlayerFromClass TraceID", traceID, pl, newClassInt, currClassInt, mustCompleteSpawnFromRespawnButtonLater)

	-- Update values
	pl:SetNWInt("classInt", newClassInt)

	pl:SetNWString("classname", MBDGetClassNameForPlayerClass(newClassInt, true))
	pl:SetNWString("classnameLobby", string.upper(MBDGetClassNameForPlayerClass(newClassInt)))

	if newClassInt == -1 then
		pl:MBDStripPlayer()
		pl:MBDGivePlayer("1")

		-- To be sure
		timer.Simple(3, function()
			if pl and pl:IsValid() and pl:GetNWInt("classInt", -1) == -1 then
				pl:MBDStripPlayer()
				pl:MBDGivePlayer("2")
			end
		end)
	end

	-- - -
	-- If ( mustCompleteSpawnFromRespawnButtonLater ) player tries to respawn while spectating and game started, and allowed.
	-- ***Player needs to press the "Respawn Button" afterwards to actually spawn. Then it will enter the function underneath

	if !mustCompleteSpawnFromRespawnButtonLater then
		-- ---->>
		-- Check if Players can change their class...
		if pl:MBDIsNotAnAdmin(true) or !pl:MBDShouldGetTheAdminBenefits() then
			if pl:GetNWBool("isSpectating", false) then
				-- If player tries to respawn while spectating and game started and not allowed
				if GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() == -1 and GameStarted then
					ClientPrintAddTextMessage(pl, {Color(254, 81, 0), "You can't change your class, because Admin has disabled it."}) return end
			else
				-- - If the wave is not modulo 3 and player is not spectating
				if !pl:MBDPlayerCanChangeToNewClass(CurrentRoundWave, GameStarted) then ClientPrintAddTextMessage(pl, {Color(254, 81, 0), "(SERVER) You can only change class every three round! (", Color(254, 208, 0), "warning", Color(254, 81, 0), ")"}) return end
			end
		end
		-- Don't change class if the same class is selected... Just ignore
		if (currClassInt == newClassInt and currClassInt != -1 and GameStarted) then
			ClientPrintAddTextMessage(pl, {Color(254, 81, 0), "(", Color(0, 173, 254), "1", Color(254, 81, 0), ") You have already chosen the ", Color(81, 0, 254), MBDGetClassNameForPlayerClass(currClassInt, true), Color(254, 81, 0), " class... (", Color(254, 0, 46), "error", Color(254, 81, 0), ")"})

			return
		end

		---
		-- Strip the Player from the old equipment
		pl:MBDStripPlayer()
		pl:MBDGoIntoNormalMode("5", true, false, true)

		-- -- -
		-- This will only run if the Player has the current class... (will remove the Player from the "PlayersClassData")
		if (
			currClassInt == newClassInt and
			currClassInt != -1 and (
				!GameStarted or (
					pl:GetNWBool("isSpectating", false) and
					GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() >= 0 and
					GameStarted
				)
			)
		) then
			-- ---->>
			-- Reset table...
			for k, v in pairs(PlayersClassData) do
				--
				if (table.HasValue(v, pl:UniqueID())) then
					oldClassInt = v.ClassInt

					--
					-- DELETE Player from Table
					table.remove(PlayersClassData, k)

					-- Reset the PlayerValues
					pl:SetNWInt("classInt", -1)

					pl:SetNWString("classname", MBDGetClassNameForPlayerClass(-1, true))
					pl:SetNWString("classnameLobby", "No Class (Pick One)")

					-- Give the basics again (he was stripped)
					pl:MBDGivePlayer("3")
					--
					--
					-- ADJUST THE OLD VALUE IN PLAYER CLASSES AVAILABLE
					local _classNameOld = MBDGetClassNameForPlayerClass(oldClassInt)

					--
					for l,w in pairs(PlayerClassesAvailable) do
						--
						if l == _classNameOld then
							--
							-- Change this class TAKEN value... -1 from it
							pl:MBDChangeClassesTableValue("1", PlayerClassesAvailable, _classNameOld, false, true)

							--
							timer.Simple(0, function()
								-- SEND TO CLIENTs...
								net.Start("PlayerClassAmount")
									net.WriteTable(PlayerClassesAvailable)
								net.Broadcast()

								timer.Simple(0.15, function()
									net.Start("PlayersClassData")
										net.WriteTable(PlayersClassData)
									net.Broadcast()
								end)
							end)
						end
					end
		
					break
				end
			end

			return
		end

		-- 0=engineer 1=mechanic 2=medic 3=terminator
		local newClassName, oldClassInt = MBDGetClassNameForPlayerClass(newClassInt), nil

		local setNewPlayerClass = function(classNameID)
			local playerClassRef = PlayerClassesAvailable[classNameID]

			-- CHANGE +1 this value
			if playerClassRef.taken < playerClassRef.total then
				pl:MBDChangeClassesTableValue("2", PlayerClassesAvailable, classNameID, false)

				timer.Simple(0, function()
					-- SEND TO CLIENTs...
					net.Start("PlayerClassAmount")
						net.WriteTable(PlayerClassesAvailable)
					net.Broadcast()

					timer.Simple(0.15, function()
						-- Update the Players Lobby Spawn button text
						timer.Remove("UpdateSpawnButtonClassChosenText")
						timer.Create("UpdateSpawnButtonClassChosenText", 0.65, 1, function()
							net.Start("UpdateSpawnButtonClassChosenText")
								net.WriteString("")
							net.Send(pl)
						end)
					end)
				end)
			else
				-- THE TOTAL AMOUNT IS DUE...
				ClientPrintAddTextMessage(pl, {Color(81, 0, 254), string.upper(classNameID), Color(254, 81, 0), " class is full..."})

				return false
			end

			return true
		end
		local setNewPlayersClassData = function(traceID, newClassInt)
			-- print("\"setNewPlayersClassData\" TraceID:", traceID, newClassInt)

			if ((
				pl:GetNWBool("isSpectating", false) and
				GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() == -1
			) and GameStarted) then return false end

			local newClassName = MBDGetClassNameForPlayerClass(newClassInt)
			pl:MBDResetPlayerHealthToMax(false)
			
			table.Add(PlayersClassData, {
				{
					UniqueID 	= pl:UniqueID(),
					SteamID 	= pl:SteamID(),
					Name 		= pl:Name(),
					ClassInt	= newClassInt,
					ClassName	= newClassName
				}
			})

			local timer001 = "mbd:GivePlayerCorrectStuffTimer001"..pl:UniqueID()
			timer.Create(timer001, 1, 0, function()
				if pl and pl:IsValid() then
					timer.Remove(timer001) pl:MBDGivePlayerCorrectStuff(traceID, newClassInt)
				end
			end)
		end
		--
		--
		-- IF Player already exists in the PlayersClassData, don't add him again; just change the "ClassInt"
		for k,v in pairs(PlayersClassData) do
			--
			if (table.HasValue(v, pl:UniqueID())) then
				oldClassInt = v.ClassInt
				
				if (newClassInt != oldClassInt) then
					--
					-- DELETE OLD...
					table.remove(PlayersClassData, k)
					--
					--
					-- ADJUST THE OLD VALUE IN PLAYER CLASSES AVAILABLE
					local _classNameOld = MBDGetClassNameForPlayerClass(oldClassInt)

					--
					for l,w in pairs(PlayerClassesAvailable) do
						--
						if (l == _classNameOld) then
							--
							-- Change this class TAKEN value... -1 from it
							pl:MBDChangeClassesTableValue("3", PlayerClassesAvailable, _classNameOld, false, true)

							-- INCREASE THE "TAKE"-prop. for "PlayerClassesAvailable"
							setNewPlayerClass(newClassName)
							-- ADD NEW
							setNewPlayersClassData("1", newClassInt)

							break
						end
					end
				else
					--
					-- WARNING
					ClientPrintAddTextMessage(pl, {Color(254, 81, 0), "(", Color(0, 173, 254), "2", Color(254, 81, 0), ") You have already chosen the ", Color(81, 0, 254), MBDGetClassNameForPlayerClass(currClassInt, true), Color(254, 81, 0), " class... (", Color(254, 0, 46), "error", Color(254, 81, 0), ")"})
				end

				break
			else
				-- -
				-- If the Player have never chosen a class before
				setNewPlayerClass(newClassName)
				setNewPlayersClassData("2", newClassInt)
			end
		end
		--
		--
		--
		-- *First time* --
		if (#PlayersClassData == 0) then
			if !setNewPlayerClass(newClassName) then return false end
			setNewPlayersClassData("3", newClassInt)
		end
	end
end
function playerClass(len, pl)
	--
	-- A Player Class Changed
	newClassInt = net.ReadInt(3)

	if !pl:MBDPlayerCanChangeToNewClass(CurrentRoundWave, GameStarted) then return end

	-- -- -
	-- If player is Spectating
	if pl:GetNWBool("isSpectating", false) then
		-- ...and respawn is enabled =>> (when game ends, Players will go out of spectate mode auto.)
		if GameStarted and GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() > -1 then
			-- Change the players NWValues, but don't fully spawn them and don't register their current class
			maybeSpawnPlayerFromClass("1", pl, newClassInt, pl:GetNWInt("classInt", -1), true)
		elseif !GameStarted then
			-- Do respawn from Spectate mode (normal)
			maybeSpawnPlayerFromClass("2", pl, newClassInt, pl:GetNWInt("classInt", -1), false)
		end
	else
		-- Do respawn from Unspectate mode (normal)
		maybeSpawnPlayerFromClass("3", pl, newClassInt, pl:GetNWInt("classInt", -1), false)
	end
end
--------------
---
--
--
--[[ Include Custom Scripts ]]
-- TIMERS
--
AddCSLuaFile("timers/cl_timers.lua")
AddCSLuaFile("timers/timers.lua")
include("timers/timers.lua")
-- HOOKS
--
AddCSLuaFile("hooks/cl_hooks.lua")
AddCSLuaFile("hooks/hooks.lua")
include("hooks/hooks.lua")

HOOK_Initialize001()
-- SERVICE FOR THE GAME ITSELF (more related)
--
AddCSLuaFile("services/cl_game.service.lua")
AddCSLuaFile("services/game.service.shared.lua")
AddCSLuaFile("services/game.service.lua")
include("services/game.service.shared.lua")
include("services/game.service.lua")
-- SERVICE FOR CONNECTED PLAYERS/PLAYER CLASSES
--
AddCSLuaFile("services/cl_players_playerclasses.service.lua")
AddCSLuaFile("services/players_playerclasses.service.lua")
include("services/players_playerclasses.service.lua")
-- OTHER LOBBY STUFF
AddCSLuaFile("lobbymanager/lobby.lua")
include("lobbymanager/lobby.lua")
--
--
--
HOOK_Initialize002()
--
--
-- Make BaseClass available
--
DEFINE_BASECLASS( "gamemode_base" )

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( pl )

	player_manager.SetPlayerClass( pl, "player_sandbox" )

	BaseClass.PlayerSpawn( self, pl )
	
end


--[[---------------------------------------------------------
   Name: gamemode:OnPhysgunFreeze( weapon, phys, ent, player )
   Desc: The physgun wants to freeze a prop
-----------------------------------------------------------]]
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	
	-- Don't freeze persistent props (should already be froze)
	if ( ent:GetPersistent() ) then return false end

	BaseClass.OnPhysgunFreeze( self, weapon, phys, ent, ply )

	--ply:SendHint( "PhysgunUnfreeze", 0.3 )
	--ply:SuppressHint( "PhysgunFreeze" )
	
end


--[[---------------------------------------------------------
   Name: gamemode:OnPhysgunReload( weapon, player )
   Desc: The physgun wants to unfreeze
-----------------------------------------------------------]]
function GM:OnPhysgunReload( weapon, ply )

	local num = ply:PhysgunUnfreeze()
	
	if ( num > 0 ) then
		ply:SendLua( "GAMEMODE:UnfrozeObjects("..num..")" )
	end

	--ply:SuppressHint( "PhysgunReload" )

end


--[[---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
   Note: This is a shared function - the client will think they can 
	 damage the players even though they can't. This just means the 
	 prediction will show blood.
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage( ply, attacker )

	-- The player should always take damage in single player..
	if ( game.SinglePlayer() ) then return true end

	-- Global godmode, players can't be damaged in any way
	if ( cvars.Bool( "sbox_godmode", false ) ) then return false end

	-- No player vs player damage
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		return cvars.Bool( "sbox_playershurtplayers", true )
	end
	
	-- Default, let the player be hurt
	return true

end


--[[---------------------------------------------------------
   Show the search when f1 is pressed
-----------------------------------------------------------]]
function GM:ShowHelp( ply )

	ply:SendLua( "hook.Run( 'StartSearch' )" );
	
end


--[[---------------------------------------------------------
   Called once on the player's first spawn
-----------------------------------------------------------]]
function GM:PlayerInitialSpawn( ply )

	BaseClass.PlayerInitialSpawn( self, ply )
	
end


--[[---------------------------------------------------------
   Desc: A ragdoll of an entity has been created
-----------------------------------------------------------]]
function GM:CreateEntityRagdoll( entity, ragdoll )

	-- Replace the entity with the ragdoll in cleanups etc
	undo.ReplaceEntity( entity, ragdoll )
	cleanup.ReplaceEntity( entity, ragdoll )
	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerUnfrozeObject( )
-----------------------------------------------------------]]
function GM:PlayerUnfrozeObject( ply, entity, physobject )

	local effectdata = EffectData()
		effectdata:SetOrigin( physobject:GetPos() )
		effectdata:SetEntity( entity )
	util.Effect( "phys_unfreeze", effectdata, true, true )	
	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerFrozeObject( )
-----------------------------------------------------------]]
function GM:PlayerFrozeObject( ply, entity, physobject )

	if ( DisablePropCreateEffect ) then return end
	
	local effectdata = EffectData()
		effectdata:SetOrigin( physobject:GetPos() )
		effectdata:SetEntity( entity )
	util.Effect( "phys_freeze", effectdata, true, true )	
	
end


--
-- Who can edit variables?
-- If you're writing prop protection or something, you'll
-- probably want to hook or override this function.
--
function GM:CanEditVariable( ent, ply, key, val, editor )

	-- Only allow admins to edit admin only variables!
	if ( editor.AdminOnly ) then
		return ply:IsAdmin()
	end

	-- This entity decides who can edit its variables
	if ( isfunction( ent.CanEditVariables ) ) then
		return ent:CanEditVariables( ply )
	end

	-- default in sandbox is.. anyone can edit anything.
	return true

end
