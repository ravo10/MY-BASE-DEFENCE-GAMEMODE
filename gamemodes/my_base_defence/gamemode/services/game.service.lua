
--
--
-- -- - =>> SERVICES more related to the whole game itself
--
---
---- KILLMODEL PROP SPAWN (RANDOM RELATIVE TO "PARENT")
function SpawnKillmodelProps( ent, killmodels, zExtra, noRandomColor, noRandomScaling )

	local entHasPhysObject = ent.GetPhysicsObject

	local entPhysObject if entHasPhysObject then

		local entPhysObject = ent:GetPhysicsObject()
		local ent_lowest_point, ent_highest_point = 10, 60
		if entPhysObject.GetAABB then ent_lowest_point, ent_highest_point = entPhysObject:GetAABB() end

		local ent_center_point = ent:WorldToLocal( ent:WorldSpaceCenter() )

		local destructionPropNewPos = entPhysObject:LocalToWorld( Vector(

			ent_center_point.x + math.random( -45, 45 ),
			ent_center_point.y + math.random( -45, 45 ),
			ent_highest_point.z + 22 + zExtra

		))

		net.Start( "mbd:SpawnDestructionProps" )

			net.WriteTable({
				destructionPropNewPos 		= destructionPropNewPos,
				killmodels 					= killmodels,
				parentPropAngles			= entPhysObject:GetAngles(),
				parentPropVelocity			= entPhysObject:GetVelocity(),
				parentPropAngleVelocity		= entPhysObject:GetAngleVelocity(),
				parentPropInertia			= entPhysObject:GetInertia(),
				noRandomColor				= noRandomColor,
				noRandomScaling				= noRandomScaling
			})

		net.Broadcast()
	
	end

end
-- --
--
-- Change the game status
net.Receive("ControlGameStatusCommand", function(len, pl)
	if (
		!pl:IsValid() or
		(
			pl:MBDIsNotAnAdmin(true)
		)
	) then return end

	local __Command = net.ReadString()

	RunConsoleCommand("mbd_game_status", __Command)
end)

--
-- A mechanic wants to but a fokkin car or airboat ..>>
net.Receive("MechanicWantsToBuyVehicle", function(len, pl)
	if (!pl:IsValid()) then return end
	local __Vehicle = net.ReadString()

	-- Check if is an SuperAdmin and he can get it for free or not
	if !pl:MBDShouldGetTheAdminBenefits() then
		if (
			pl:GetNWInt("classint", -1) != 1 -- Mechanic
		) then
			ClientPrintAddTextMessage(pl, {Color(0, 0, 0), "You have to be the MECHANIC class to buy a vehicle!"})

			return
		elseif (
			-- To little casshh
			(
				(
					__Vehicle == "Jeep" or
					__Vehicle == "Airboat"
				) and pl:GetNWInt("money", -1) < 7000
			) or
			(
				__Vehicle == "Jalopy" and
				pl:GetNWInt("money", -1) < 8000
			)
		) then
			local __PriceString = "7000"
			if (__Vehicle == "Jalopy") then __PriceString = "8000" end
			ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "You can not afford a ", Color(0, 0, 0), __Vehicle, Color(254, 208, 0), "... Costs ", Color(173, 254, 0),__PriceString.." ??B.D.", Color(254, 208, 0), "."})

			return
		elseif (
			pl:GetNWBool("HasOneVehicle", false) and (
				pl:MBDIsNotAnAdmin(true)
			)
		) then
			--
			ClientPrintAddTextMessage(pl, {Color(0, 0, 0), "You can only have one vehicle! You can sell your current one..."})

			return
		end
		----
		-- Buy
		if (
			__Vehicle == "Jeep" or
			__Vehicle == "Airboat"
		) then
			-- Jeep or Airboat
			pl:SetNWInt("money", pl:GetNWInt("money", -1) - 7000)
			ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "You bought a fokkin ", Color(254, 208, 0), __Vehicle, Color(0, 0, 0), " for", Color(173, 254, 0), " 7000 ??B.D.!"})
		else
			-- Jalopy
			pl:SetNWInt("money", pl:GetNWInt("money", -1) - 8000)
			ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "You bought a fokkin ", Color(254, 208, 0), __Vehicle, Color(0, 0, 0), " for", Color(173, 254, 0), " 8000 ??B.D.!"})
		end
	end

	timer.Simple(0.15, function()
		pl:SetNWBool("HasOneVehicle", true)
		pl:ConCommand("mbd_gm_spawnvehicle "..__Vehicle)
	end)
end)

--
--- Player wants to drop his weapon >>
net.Receive("DropCurrentPlayerWeapon", function(len, pl)
	if (!pl:IsValid()) then return end
	---
	-- -->>
	--- -- Drop the weapon >
	pl:DropWeapon(pl:GetActiveWeapon())
end)

--
--- Player wants to spawn a prop >>
net.Receive("SpawnBlockerBlock", function(len, pl)
	if (!pl:IsValid()) then return end
	if (pl:MBDIsNotAnAdmin(true)) then return end

	--- !block => <size> (s/m/l) => <amount> (number)
	local strText 	= net.ReadString()

	local __Block 	= string.Split(strText, " ")
	local __Size 	= __Block[2]
	local __Amount 	= tonumber(__Block[3])
	------ --
	---
	--
	local __SpawnPos 	= pl:WorldToLocal(pl:GetPos())
	__SpawnPos.x 		= (__SpawnPos.x + 130)
	__SpawnPos.z 		= pl:OBBMaxs().z
	
	local __SizeString = nil
	if 		(__Size == "s") 	then __SizeString = "small"
	elseif 	(__Size == "m") 	then __SizeString = "medium"
	elseif 	(__Size == "l") 	then __SizeString = "large"
	end
	-- ---- -
	--
	--- --->>
	if !tonumber(__Amount) then ClientPrintAddTextMessage(pl, {Color(254, 81, 0), "Wrong format; type e.g: \"!bl m 5\""}) return end -- The player mixed up the chat command
	if (__Amount > 30) then __Amount = 30 end
	for i=1,__Amount do
		__SpawnPos.z 		= (__SpawnPos.z + (10 * i))
		local WorldSpawnPos = pl:LocalToWorld(__SpawnPos)

		local _BlockerEnt = ents.Create("mbd_blocker_"..__SizeString)
		_BlockerEnt:SetPos(WorldSpawnPos)

		_BlockerEnt:Spawn()
		_BlockerEnt:Activate()
		_BlockerEnt:SetCreator(pl)
		---
		-- Very important to set these here after spawn...
		_BlockerEnt:SetMaterial("models/Debug/debugmesh")
		_BlockerEnt:UseTriggerBounds(true, 3)
		_BlockerEnt:SetTrigger(true)
	end
end)

net.Receive("GetAdminPanelDataServer", function(len, pl)
	if pl:MBDIsNotAnAdmin(true) then return end

	local _Data = {
		mbd_countDownTimerAttack 						= GetConVar("mbd_countDownTimerAttack"):GetInt(),
		mbd_countDownTimerEnd 							= GetConVar("mbd_countDownTimerEnd"):GetInt(),
		mbd_roundWaveNumber 							= GetConVar("mbd_roundWaveNumber"):GetInt(),
		mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd	= GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt(),
		mbd_npcLimit 									= GetConVar("mbd_npcLimit"):GetInt(),
		mbd_superAdminsDontHaveToPay 					= GetConVar("mbd_superAdminsDontHaveToPay"):GetInt(),
		mbd_turnOffSirenSoundStartGame 					= GetConVar("mbd_turnOffSirenSoundStartGame"):GetInt(),
		mbd_respawnTimeBeforeCanSpawnAgain 				= GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt(),
		mbd_enableAutoScaleModelNPC 					= GetConVar("mbd_enableAutoScaleModelNPC"):GetInt()
	}

	-- Send to Client
	net.Start("AdminPanelDataClient")
		net.WriteTable(_Data)
	net.Send(pl)
end)

-- Delete an entity which is called from clientside...
net.Receive("RemoveAnEntity", function(len, pl)
	local ent = net.ReadEntity()

	if ent and ent:IsValid() and !ent:IsPlayer() then
		--
		ent:Remove()
	end
end)

-- Someone Produced A Sound .. >> >
local HaveEmittedSound = false
net.Receive("APlayerWWantsToProduceASound", function(len, pl)
	local _Table = net.ReadTable()

	-- Local Variables
	local _Volume               = _Table.Volume
	local _Sound 				= _Table.Sound
	local _Pitch 				= _Table.Pitch
	local _SoundEntity 			= _Table.SoundEnt

	--- --- - SoundGarden
	-- Add/Emitt sound >>
	if !HaveEmittedSound then
		HaveEmittedSound = true

		----
		-- Custom Emit (on CLIENT side) >> >
		------
		-- For testing:
		--print("Sending Sound:", _Table.Sound, "Volume:", _Volume, "Sound Entity:", _SoundEntity)

		Entity_EmitLocalSoundEmitter("2",
			{
				Sound		= _Sound,
				Pitch		= _Pitch,
				SoundEnt 	= _SoundEntity,
				Volume		= _Volume
			},
			true
		)

		timer.Simple(0, function()
			_Sound 			= nil
			_Pitch 			= nil
			_SoundEntity 	= nil
			
			HaveEmittedSound = false
		end)
	end
end)
-- Spawn the Player from Respawn button
net.Receive("RespawnPlayerFromButton", function(len, pl)
	if pl and pl:IsValid() and pl:IsPlayer() then
		-- Remove "death" entities related to Player
		for k,v in pairs(ents.FindByName("mbd_d_prop")) do
			if v:GetOwner() == pl then if v and v:IsValid() then v:Remove() end end
		end

		-- Do respawn from Unspectate mode (normal)
		maybeSpawnPlayerFromClass("4", pl, pl:GetNWInt("classInt", -1), -1, false)

		--[[ local timerID001 = "mbd:respawnFromButton"..pl:UniqueID()
		timer.Remove(timerID001)
		timer.Create(timerID001, 0.5, 0, function()
			if !pl or ( pl and !pl:IsValid() ) then timer.Remove(timerID001) return end

			if pl:GetNWInt("classInt", -1) > -1 then
				timer.Remove(timerID001)

				timer.Simple(1, function()
					-- Spawn player
					pl:Spawn()
				end)
			end
		end) ]]
	end
end)
-- -
-- Send the information about spawn time
net.Receive("get_mbd_respawnTimeBeforeCanSpawnAgain", function(len, pl)
	net.Start("receive_mbd_respawnTimeBeforeCanSpawnAgain")
		net.WriteInt(GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt(), 12)
	net.Send(pl)
end)

-- -
-- Send the information about pyramid drops available
net.Receive("get_mbd_howManyDropItemsPickedUpByPlayers", function(len, pl)
	net.Start("receive_mbd_howManyDropItemsPickedUpByPlayers")
		net.WriteInt(GetConVar("mbd_howManyDropItemsPickedUpByPlayers"):GetInt(), 12)
	net.Send(pl)
end)
-- -
-- Send the information about pyramid drops already spawned
net.Receive("get_mbd_howManyDropItemsSpawnedAlready", function(len, pl)
	net.Start("receive_mbd_howManyDropItemsSpawnedAlready")
		net.WriteInt(GetConVar("mbd_howManyDropItemsSpawnedAlready"):GetInt(), 12)
	net.Send(pl)
end)
-- Stop particles on Entity
net.Receive("mbd:StopParticleEffectOnEnt", function(len, pl)
	local data = net.ReadTable()

	local entity = data[1]
	local particleName = data[2]
	
	if entity and entity:IsValid() then
		entity:StopParticles()
	end
end)

net.Receive("mbd:SetPlayerCurrentCameraView", function(len, pl)
	local currentCameraView = net.ReadInt(5)
	local isPlayerSpectating = pl:GetNWBool("isSpectating", false)

	if isPlayerSpectating then return end

	if !GameIsSinglePlayer then
		if currentCameraView == 4 and ( !CameraTopViewIsAllowed and !OnlyTopCameraViewIsAllowed ) then currentCameraView = 0 end
		if currentCameraView != 4 and OnlyTopCameraViewIsAllowed then currentCameraView = 4 end
	elseif currentCameraView > 4 then currentCameraView = 0 end

	-- OK
	pl:SetNWInt("playerCurrentCameraView", currentCameraView)

	-- Update at client side also
	net.Start("mbd:setCurrentCameraView")
		net.WriteInt(currentCameraView, 5)
	net.Send(pl)
end)
net.Receive("mbd:cameraTopViewIsAllowed", function(len, pl)
	local cameraTopViewIsAllowed = net.ReadBool()

	if pl:MBDIsAnAdmin(true) then
		CameraTopViewIsAllowed = cameraTopViewIsAllowed

		-- Tell clients
		net.Start("mbd:cameraTopViewIsAllowedClient")
			net.WriteBool(cameraTopViewIsAllowed)
		net.Broadcast()
	else pl:Kick("You are not an Admin.") end
end)
net.Receive("mbd:onlyTopCameraViewIsAllowed", function(len, pl)
	local onlyTopCameraViewIsAllowed = net.ReadBool()

	if pl:MBDIsAnAdmin(true) then
		OnlyTopCameraViewIsAllowed = onlyTopCameraViewIsAllowed
		local value = 0 if onlyTopCameraViewIsAllowed then value = 4 end

		-- Tell clients
		net.Start("mbd:onlyTopCameraViewIsAllowedClient")
			net.WriteBool(onlyTopCameraViewIsAllowed)
		net.Broadcast()
	else pl:Kick("You are not an Admin.") end
end)

-- Send lyd til alle clienter --
function Entity_EmitLocalSoundEmitter(trackID, dataTable, unReliable)
	-- print("Entity_EmitLocalSoundEmitter", trackID)

	net.Start("Entity_EmitLocalSoundEmitter", unReliable)
		net.WriteTable(dataTable)
	net.Broadcast()
end
--
-- If a client needs the list of nice names from here...
net.Receive("__NAME_Weapons_server", function(len, pl)
	local _timerID = "__NAME_Weapons_server001"..pl:UniqueID()
	timer.Create(_timerID, 0.15, (10 * 2), function()
		if (
			__NAME_Weapons and
			__NAME_AttachmentsAmmoOther
		) then
			timer.Remove(_timerID)

			local _Table = __NAME_Weapons
			table.Inherit(_Table, __NAME_AttachmentsAmmoOther)

			net.Start("__NAME_Weapons_client")
				net.WriteTable(_Table)
			net.Send(pl)
		end
	end)
end)

local function BuildNewBuyBoxTable(timerID002, tableID, newTableData, col3Data, extraDataType, extraData, simpleNewTable)
	if tableID == "MBDCompleteBuyBoxList_AllowedWeapons" then -- Simple table (no extra data)
		-- Never Extra Data
		local className = col3Data
		if className == "engineer" then
			MBDallowedWeaponClasses_Engineer = simpleNewTable
		elseif className == "mechanic" then
			MBDallowedWeaponClasses_Mechanic = simpleNewTable
		elseif className == "medic" then
			MBDallowedWeaponClasses_Medic = simpleNewTable
		elseif className == "terminator" then
			MBDallowedWeaponClasses_Terminator = simpleNewTable
		end
	elseif tableID == "MBDCompleteBuyBoxList_AllowedAttachments" then -- Price
		-- Never Extra Data
		MBDPrices_Attachments = newTableData
	elseif tableID == "MBDCompleteBuyBoxList_AllowedAmmo" then -- Price
		-- Maybe Extra Data (a StringID)
		MBDPrices_Ammo = newTableData
	elseif tableID == "MBDCompleteBuyBoxList_AllowedOther" then -- Simple table (no extra data) -- For removing only
		-- Maybe Extra Data (a StringID)
		local className = col3Data
		if className == "engineer" then
			MBDallowedOtherClasses_Engineer = simpleNewTable
		elseif className == "mechanic" then
			MBDallowedOtherClasses_Mechanic = simpleNewTable
		elseif className == "medic" then
			MBDallowedOtherClasses_Medic = simpleNewTable
		elseif className == "terminator" then
			MBDallowedOtherClasses_Terminator = simpleNewTable
		end
	elseif tableID == "MBDCompleteBuyBoxList_AllowedStuff" then -- Simple table (no extra data) (For adding: Att./Ammo/Other)
		if extraData == "Attachments" then MBDPrices_Attachments = newTableData
		elseif extraData == "Ammunition" then MBDPrices_Ammo = newTableData end
	elseif tableID == "MBDCompleteBuyBoxList_PricesWepCustom" then -- Price
		-- Always Extra Data (a PriceInt)
		MBDPrices_CustomListAllWillOverWrite = newTableData
	elseif tableID == "MBDCompleteBuyBoxList_PricesOther" then -- Price
		-- Always Extra Data (a PriceInt) (do a for loop, since it will only return new data related to the player class selected...)
		MBDPrices_Other = newTableData
	end

	timer.Create(timerID002, 3, 1, MBDWriteBuyBoxCustomizedListFromWithinTheGameOnly)
end
-- Update a custom server lists
net.Receive("mbd:update:CustomSettingsTable", function(len, pl)
	local settingTable = net.ReadTable()

	local timerID001 = "mbd:update:CustomSettingsTable001"
	local timerID002 = "mbd:update:CustomSettingsTable002"
	timer.Remove(timerID001)
	timer.Remove(timerID002)

	if pl:MBDIsNotAnAdmin(false) then return end

	-- Always
	local type = settingTable.type
	local tableID = settingTable.tableID
	local newTableData = settingTable.newTableData

	-- Maybe (for col3Data, price and entites that are not SWEP/Wep)
	local col3Data = settingTable.col3Data
	local extraDataType = settingTable.extraDataType
	local extraData = settingTable.extraData

	local makeSimpelTable = function()
		local newTable = {}
		for NPCKey,_ in pairs(newTableData) do table.insert(newTable, NPCKey) end

		return newTable
	end
	local simpleNewTable = makeSimpelTable()

	-- Create new List
	if type == "npcspawner" then
		if tableID == "allowedCombines" then
			allowedCombines = simpleNewTable
		elseif tableID == "allowedZombies" then
			allowedZombies = simpleNewTable
		end

		timer.Create(timerID001, 3, 1, MBDWriteNPCSpawnerNPCsCusmoizedListFromWithinTheGameOnly)
	elseif type == "buybox" then
		BuildNewBuyBoxTable(timerID002, tableID, newTableData, col3Data, extraDataType, extraData, simpleNewTable)
	end
end)

function SendLocalSoundToAPlayer(soundString, pl)
	net.Start("SendLocalSoundToAPlayer")
		net.WriteString(soundString)
	net.Send(pl)
end

--
-- If an Admin want to change some settings from the quick panel
net.Receive("mbd_QuickSettingsSetServer", function(len, pl)
	local settingID = net.ReadString() if pl:MBDIsNotAnAdmin(true) then return end

	local disablePyramids = function()
		GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):SetInt(-1)
	end
	local enablePyramids = function()
		if GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):GetInt() < 3 then
			GetConVar("mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd"):SetInt(3)
		end
	end

	-- Set settings:
	if settingID == "game_0" then
		-- Regular Game
		disablePyramids()
		GetConVar("mbd_countDownTimerAttack"):SetInt(30)
		GetConVar("mbd_countDownTimerEnd"):SetInt(300)
	elseif settingID == "game_1" then
		-- Fast Game
		disablePyramids()
		GetConVar("mbd_countDownTimerAttack"):SetInt(10)
		GetConVar("mbd_countDownTimerEnd"):SetInt(90)
	elseif settingID == "game_2" then
		-- Slow Game
		disablePyramids()
		GetConVar("mbd_countDownTimerAttack"):SetInt(60)
		GetConVar("mbd_countDownTimerEnd"):SetInt(500)
	elseif settingID == "pyramid_0" then
		-- Regular Pyramid
		enablePyramids()
		GetConVar("mbd_countDownTimerAttack"):SetInt(30)
		GetConVar("mbd_countDownTimerEnd"):SetInt(300)
	elseif settingID == "pyramid_1" then
		-- Fast Pyramid
		enablePyramids()
		GetConVar("mbd_countDownTimerAttack"):SetInt(10)
		GetConVar("mbd_countDownTimerEnd"):SetInt(90)
	elseif settingID == "pyramid_2" then
		-- Slow Pyramid
		enablePyramids()
		GetConVar("mbd_countDownTimerAttack"):SetInt(60)
		GetConVar("mbd_countDownTimerEnd"):SetInt(500)
	elseif settingID == "endGame" then
		-- End Game
		endGame()
	elseif settingID == "startGame" then
		-- Start Game
		startGame()
	elseif settingID == "nextWave" then
		if !GameStarted then return end

		-- Next Wave
		timer.Remove("mbd:nextRoundCountdown001")
		timer.Remove("mbd:RoundCreator001")

		nextRoundWave(true)
		nextRoundStart(true)
	elseif settingID == "speed+" then
		-- Increase Game Frame Speed (min 1 max 5 - Loop)
		local newSpeed = game.GetTimeScale() + 1

		if newSpeed < 1 then newSpeed = 1
		elseif newSpeed > 5 then newSpeed = 1 end

		GetConVar("mbd_currentGameSpeedSetReadOnly"):SetInt(newSpeed)

		game.SetTimeScale(newSpeed)

		-- Tell everyone
		for k,v in pairs(player.GetAll()) do
			ClientPrintAddTextMessage(v, {Color(0, 255, 182), "Game ", Color(182, 0, 255), "Speed", Color(0, 255, 182), " changed to: ", Color(255, 0, 73), newSpeed, Color(0, 255, 182), " !"})
		end
	elseif settingID == "wave+" then
		-- Increase Wave
		nextRoundWave(true)
	elseif settingID == "endWave" then
		if !GameStarted or !AttackRoundIsOn then return end

		-- End current wave
		timer.Remove("mbd:nextRoundCountdown001")
		timer.Remove("mbd:RoundCreator001")

		currentRoundEnd(true, true)
	end
end)

--[[ 

	- Bebi doll kan bli ??ydelagt... | Kan det vere s??nn?? Morosom effekt??
	- Legg til kryss knapp p?? toolbox | OK
	- 3. unknown - addons/my_base_defence/gamemodes/my_base_defence/entities/weapons/mbd_swep_repair_tool.lua:165 | Veit ikkje....
	- Legg til Dupe. st??tte med lagring (bruke det gamele dupe systemet) | OK (legger til hindring av spawning av props om den ikkje er p?? list i strict mode) | OK
	- Legg til s??nn oljet??nne kan eksplodera; koster 1000 bp elns | OK !!
	- NPC Spawner klikke? Vil ikkje spawne fleire fiender n??r runden auker?? Var etter ein runde p?? server... | Veit ikkje.... Kanskje ikkje ein feil...
	- Kan bruke d??r verkt??y p?? andre spelarar...| OK
	- Fix s??nn n??r du er for n??reme ein prop, s?? vil ikkje du kunne sikta... | OK... Flytter berre NPC bullseye vekk n??r spelar kjem for n??rme
	- Fix s??nn du ikkje kan oppgradera prop, om du har venstre knappen iinne ; ; Skift til shift knapp !! | OK
	- Med physgun, kan holde inne ein knapp for ?? gjer den no kollide | OK (bruker R-knappen)
	- NPC hitbox kunne ha vert betre... hindrer ?? kunne skyte p?? n??rme hold... pr??ve annen kollisjonsgruppe.. | OK, flytta berre boxen n??r spelar kom innanfor... Flytta den og framfor NPC !!
	  kanskje gjere s??nn at berre NPC kan skade hitbox... | OK... Ignorerer spelar-skade... Men skal da ve slik?
	  - 1. unknown - addons/my_base_defence/gamemodes/my_base_defence/gamemode/lobbymanager/cl_lobby.lua:303 | Trur ikkje dette eigentleg er ein feil... ?
	-----------------
	- Fix s??nn du kan helbrede kor som helst innanfor ein radius(sphere) p?? ein prop | OK!
	- Fix s??nn at d??rer ikkje kan f?? ny d??r... | OK
	- Fix lyden... Er ikkje lyd p?? effekta | Kanskje OK NO ?
	- Av og til kjem da sveise gnist n??r du berre ser p?? ting... | Veit ikkje... Kanskje fiksa no...
	- Legg til prop limit for ein spelar? | NJaaa...
	- Legg til s??nn du kan sj?? livet til andre spelarar | OK!
	- Null modell etter d??d for Spelar av og til?? | OK
	- Lobby respawn (efter d??d) viser ikkje for vanlig spelar ?? | OK!
	- Kan ikkje velge klasse efter spelar d??d; | Veit ikkje.... Kanskje fiksa?
	- Pr??v ?? forbetre s??nn ein zombie kan sl?? hitbox (at den ikkje d?? flytter seg vekk...) | Trengs eigentelg ikkje... Kan sj?? p?? da om du kjede deg
	- For sikkeheitsskold, ta ?? strip alt fr?? spelar p?? spelar d??d (v??pen og ammo) | OK
	- Gjer s??nn Spelarar tar litt meir skade til vanlig av ting (scaleDamage) | OK
	- Dobbelsjekk att NPC bullseye kan bli hata av ein fiende p?? ny runde... | OK
	- Slett alle d??rer ein spelar har laga p?? Spelar d??d | OK
	-----------------
	- Legg til varsel for at du har lagt til ein spelar p?? ein d??r | OK
	- Test at bil kan bli skada av NPC (hitbox) | OK
	- Visst ein npc blir spawna n??r det er pause, frys NPCen | OK
	- GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() funke ikkje lokal hos andre spelarar (m?? hentast fr?? server) | OK (trur det berre er litt delay... veit ikkje)
	- Gjer s??nn at spectating spelarar kan sj?? andre sitt namn etc. over hovuded til andre spelarar ... berre ikkje seg sj??lv | Skal eigentleg fungera... Men lagg til nokon ekstra "stats" i lobby
	- Reset gnist for fikse verkt??y n??r du g??r vekk fr?? prop-zonen | OK
	- Du kan berre kj??pe maks 10 ting i l??pet av 1 min | OK
	- Legg til sveiselyd som lyd for prop verkt??y | OK!!
	- Gjer s??nn at det er 20 prosent sjanse for at krabbe-zombie kan spawne health kit | OK
	- Sjekk at du f??r varsel om mindre skalerte NPCar... | OK
	- Merka at klasse ikkje alltid endra seg hos klient p?? forandring | OK (trur det er fiksa no; laga ein laste-funksjon rundt)
	- For sikkeheitsskold, ta ?? strip alt fr?? spelar p?? kjapp klasse-endring... | OK (trur eg)
	- Legg til spinnande tekst over buybox og npc spawner (kanskje statisk) | OK
	- Fiks s??nn admin panel lukker seg visst ein ny ein opner | OK
	- Resett og t??m din klasse efter d??d p??... "TERMINATOR class is full..." hos klient -->
	  N??r du klikker p?? spawn-knapp, s?? er klassen full ---> Trur det er problem at info. ikkje blei sendt til server hmmrr.. | OK... M?? nett testast p?? server med fleire folk
	- Sjekk n??r ein spelar joiner ein server som har starta, kvifor Spelar f??r opp "in lobby"?
	  skulle ha f??tt opp "in game" + respawn knapp... | M?? testast p?? server med fleire enn ein person
	  -->> Spawna som ein dokke (spectate mode) => F??r ikkje opp respawn-knapp (n??r eg skulle ha f??tt da opp) | OK trur eg
	- Legg til strider kvar 3 runde (kan sl?? av og p??) og skaler opp skade den mottar (kanskje scalere ned modell? Og p?? spelarar??) | OK
	- St??rre skala p?? NPC (skal >= 2.8 = meir liv) | OK
	- Bila kan skada andre Players (/fix) | Hmm, trur da kan ve s??nn (m?? ve litt risiko)
	- Fiks at du av og til ikkje kan f?? v??pen fr?? buybox (gir ikkje v??penet du kj??per?? e.g. rpg) | OK
	- Kom ikkje inn i spectator modus etter Spelar d??d (n??r du trykker p?? Spawn knappen).. berre "isSpectating"... (med fleire folk??) | OK
	- Lobby classe endring m?? sikrast meir (ikkje kan velga)(andre kunne velge classe som eigentleg var full...) | Veit ikkje heilt... Fiksa at den kunne g?? i minus...
	- Lag "mystery box" | OK
	-- 
		- Gjer s??nn tekst forsvinner (kan ikkje ta) n??r du har tatt v??pen | OK
		- Legg til s??nn boxen kan ta skade og bli ??ydelagt? | OK (har 1000 liv)
		- Legg til s??nn det koster 500 bd for ikkje-admin | OK
		- Kanskje gjer det meir sannsynlig ?? f?? bamse | OK
		- Gjer s??nn v??penet tenker og f??lger posisjonen ogs?? | OK!!
		- Legg til s??nn fint namn fr?? e.g. HL2 V??pen kan kome opp (list.get("Weapon")) | OK
	--
	---------------
	--------------- Beta 2.0 forandringer:: (skal p?? WorkShop) ---------------
	- Added a respawn option after Player death
	- Fixed and tuned the hitbox for props
	- Fixed bugs for the door tool
	- Fixed some bugs for showing the Players in the lobby
	- Added so you can heal a prop within a radius, instead of the distance to the center of the prop
	- Added name (random color), kills and class + health text above each Player
	- Fixed getting a roller mine model after death on global server...
	- Added so you can now make a prop no-collideable while holding it with a phys.gun, by pressing and holding "R"
	- Added so oil barrels can explode (does cost more now)
	- Added the close button again for the buybox
	- Fixed the NPC spawner, so you can have several NPC Spawners if you want (duplicate them)
	- Added more notifications when interesting stuff happens
	- Added so you get more ammo for weapons on fresh spawn
	- Removed so it is only one proper sound effect for a "round end"; it got kind of annoying
	- Should have fixed issue with repair tools effects (sparks) can get stuck
	- Added new sound effect for repair tools (welding sound)
	- Added so there is only a 25 % chance that the zombie torso will spawn a health vial
	- Added so NPCs can be auto.-scaled (bigger or smaller) when a new wave/round begins; this can be more challenging or easier for the Player
	- Added "floating" description text to the NPC Spawner and BuyBox
	- Fixed some more lobby bugs
	- Added RPG launcher as weapon (costs allot)
	- Added more difficult NPC(s) every three round
	- Remade the BuyBox Algorithm code (so it is very simple to add more weapons...)
	- Added mysterybox! Thanks "Hoff" for making the model/animation; based on this, but heavly modified for M.B.D.
	- Added the possibility to have icons in the BuyBox menu
	- Added icons for FA:S 2 in the weapons menu
	- Legg til kanskje s??nn kvar 3 runde s?? kjem da ny "mystery box" der den ugyldige (fikk bamse) no er; kanskje
	  ikkje slette, men gjere usynlig/inaktiv berre... S?? kan admin slette den med toolgun visst han vil | (kan fiksast til stable versjon)
	- Tekst kom ikkje opp p?? global server (over anna spelar; berre meg) | Skal vere OK no
	- Fiks tekst Vinkel + weapon classe tekst ikkje gyldig (mystery box) | Klasse-tekst fiksa...
	- Legg til s??nn du kan spawne NPC Spawner og BuyBox fr?? meny?? VIKTIGVIKTIG | OK
	- Legg til s??nn da spawne nye mystery boxa kvar 3 runde elns | OK (gjort litt annleis; auto. timer)
	-- MYSTERY BOX:: E ein glitch i modellen trur eg... Kan henge seg opp ved l??sen... E.g. raketta fr?? rocket launcher.. Kan eg fikse dette?? | OK!
	- Legg til notifikasjon n??r du har gitt spelar e.g. peng (!g :) | OK
	- Legg til gunship kvar tredje runde | OK!
	- Fiks at ikkje sikte (attachments) i buybox | OK
	- Du f??r ikkje granata og ammobox? | OK... fiksa granat i allefall!
	- Fiks at lyd fr?? sveising ikkje blir h??yrt om 5 meter vekke elns | OK (m?? testes)
	- Menyen i "ikkje strict mode" f??r ikkje opp alle verkt??y (toolgun)? | Hmm, kanskje det trenger server restart? - Ja, ser ut som det
	- Nokon spelarar f??r ikkje lyd (eg fikk) | OK (laga litt nytt system; enklare og betre)
	- Legg til s??nn du kan sl?? av ?? f?? ekstra vanskelige fiendar kvar 3 runde | OK
	- Ingen partikkel-effekt p?? sveising... | OK! (hadde flytta klientkode til serverside...... n??r eg flytta om p?? lydemitter-koden)
	------------------------------------------------------------------------
	---------------- --------------
	-- IKKJE KRITISKE FEIL --
	- Effekt fr?? Prop/Vehicle fikser verkt??y kan blir "stuck" (stor gnist) | (kan fiksast til stable versjon)
	- Legg til s??nn du kan droppe v??pen med Shift + middle mouse knapp | (kan fiksast til stable versjon)
	- Legg til s??nn v??pen som ligger p?? bakken blir sletta etterkvart | (kan fiksast til stable versjon)
	- Legg til s??nn du kan velge klasse med "!medic", "!terminator" etc. | (kan fiksast til stable versjon)
	- Legg til visning om det er med meir avanserte fiendar med eller ikkje (admin panel) | 

	- Slett gamle helikopter (og strider?) | 
	- Legg til timer s??nn sveisegnist ikkje heng seg opp |
	- Lobbyen henger seg opp p?? klasse av og te | 
	- Kvar runde, sjekk kor mange NPC som er i live | 
	- Lobbyen "klikke" for ein admin, kan ikkje | 

	SJ?? HERR!! Kan vere til vanskeligheitsgrad? Er nytt...
	--  Fixes made so mods and players can adjust Half-Life: Source NPC difficulty settings via their console variables (sk_*)
	- Kanskje juster mindre partikkel effekt for boks i MBD (for optimasjon) | 
	----------------
 ]]
