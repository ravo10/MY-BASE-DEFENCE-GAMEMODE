--
--
-- -- - =>> SERVICES more related to the whole game itself
--
-- Get Nice Weapon names from Server
net.Start("__NAME_Weapons_server")
net.SendToServer()
--
---
-- Get available things to buy from server
net.Receive("mbd_SendAvailableThingsThingsToBuy", function()
	local table = net.ReadTable()
	
	if table then availableThingsToBuy = table end

	firstLoadComplete = true
end)
--- - =>=> The ROUND have changed
net.Receive("RoundWaveChange", function()
	--
	currentRoundWave = net.ReadInt(15)
end)
--
---
--
--
--- The total amount of Enemies have changed
net.Receive("TotalAmountOfEnemies", function()
	--
	--- SET NEW countdowner message
	enemiesAliveTotal = net.ReadInt(9)
end)
net.Receive("PyramidStatus", function()
	--
	--- Set new Pyramid Status Message
	currentAmountOfDropsStatus = net.ReadString()
end)
--
--- Recives a notification from server
net.Receive("TellNotificationError", function()
	--
	--- 
	local _notification = net.ReadString()

	notification.AddLegacy(_notification, NOTIFY_ERROR, 3)
end)

-- --
-- Cancle a notification timer...
net.Receive("RemoveNotificationTimer", function()
	timer.Remove(net.ReadString())
end)

-- --
-- Show a notification  -- https://wiki.garrysmod.com/page/Enums/NOTIFY
net.Receive("NotificationReceivedFromServer", function()
	local NotificationReceived = net.ReadTable()

	-- Display
	showNotification(NotificationReceived.Text, NotificationReceived.Type, NotificationReceived.Time, 0, nil, true)
end)
---
-- Print Console Message
net.Receive("ClientPrintConsoleMessage", function()
	local MessageReceived = net.ReadString()

	-- Print
	if LocalPlayer() then chat.AddText(Color(0, 254, 208), MessageReceived) end
end)
-- Change spawn button text from Server
net.Receive("UpdateSpawnButtonClassChosenText", function()
	local maybeOwnText = net.ReadString()

	-- Change the spawn button text maybe
	if container and container:IsValid() then
		if !maybeOwnText or maybeOwnText == "" then
			SetTextSpawnButton(respawnBtn, "ok", "SPAWN AS "..string.upper(LocalPlayer():GetNWString('classname', 'NULL CLASS')))

			theSpawnButtonIsComplete = true
		else
			if maybeOwnText == "SPAWN AS ..." then theSpawnButtonIsComplete = false end

			SetTextSpawnButton(respawnBtn, "", maybeOwnText)
		end
	end
end)
-- Add text service
net.Receive("ClientPrintAddTextMessage", function()
	local array = net.ReadTable()

	if array then chat.AddText(unpack(array)) end
end)
-- - -
-- Play sound
sound.Add({
	name = "mysterybox_bo3_nani",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 100 },
	sound = "mysterybox_bo3/nani.wav"
})
sound.Add({
	name = "game_pyramid_drop_pickup",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 50,
	pitch = { 100 },
	sound = "game/pyramid_drop_pickup.wav"
})
sound.Add({
	name = "game_money_collected",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 43,
	pitch = { 100 },
	sound = "game/money_collected.wav"
})
sound.Add({
	name = "game_buildpoints_collected",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 43,
	pitch = { 100 },
	sound = "game/buildpoints_collected.wav"
})
sound.Add({
	name = "game_buybox_buysound",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 60,
	pitch = { 100 },
	sound = "game/buybox_buysound.wav"
})
sound.Add({
	name = "game_slow_breathing",
	channel = CHAN_STATIC,
	volume = 0.8,
	level = 41,
	pitch = { 100 },
	sound = "game/slow_breathing.wav"
})
sound.Add({
	name = "prop_spawn",
	channel = CHAN_STATIC,
	volume = 1,
	level = 45,
	pitch = { 100 },
	sound = "game/prop_spawn.wav"
})
sound.Add({
	name = "prop_spawning_error",
	channel = CHAN_STATIC,
	volume = 1,
	level = 45,
	pitch = { 100 },
	sound = "game/prop_spawn_error.wav"
})
net.Receive("SendLocalSoundToAPlayer", function()
	local soundStringKey = net.ReadString()

	LocalPlayer():StopSound(soundStringKey)
	LocalPlayer():EmitSound(soundStringKey)
end)

net.Receive("receive_mbd_howManyDropItemsPickedUpByPlayers", function()
	howManyDropItemsPickedUpByPlayers = net.ReadInt(12)
end)

net.Receive("receive_mbd_howManyDropItemsSpawnedAlready", function()
	howManyDropItemsSpawnedAlready = net.ReadInt(12)
end)

net.Receive("receive_mbd_attackRoundIsOn", function()
	attackRoundIsOn = net.ReadBool()

	-- RunConsoleCommand("stopsound")
end)

-- Particle effect
net.Receive("mbd_PlayParticleEffectClient", function()
	local particleEffectData = net.ReadTable()

	ParticleEffect(particleEffectData[1], particleEffectData[2], particleEffectData[3], particleEffectData[4])
end)
net.Receive("mbd_PlayParticleEffectAttachClient", function()
	local particleEffectData = net.ReadTable()
	
	ParticleEffectAttach(particleEffectData[1], particleEffectData[2], particleEffectData[3], particleEffectData[4])
end)
net.Receive("mbd_PlayParticleEffectStopClient", function()
	local ent = net.ReadEntity()

	if ent and ent:IsValid() then ent:StopParticles() end
end)

net.Receive("mbd_updateTheEnemyNPCTableThatNPCSpawnerUse", function()
	local enemyTable = net.ReadTable()

	allowedCombines = {}
	allowedZombies = {}

	-- Add
	for _,v in pairs(enemyTable.allowedCombines) do
		table.insert(allowedCombines, v)
	end
	for _,v in pairs(enemyTable.allowedZombies) do
		table.insert(allowedZombies, v)
	end
end)

-- Stop particles on Entity
net.Receive("mbd:StopParticleEffectOnEnt", function()
	local data = net.ReadTable()

	local entity = data[1]
	local particleName = data[2]
	
	if entity and entity:IsValid() then
		entity:StopParticlesNamed(particleName)
	end
end)

-- Stop particles on Entity
net.Receive("mbd:StatusOfSlowdowTime", function()
	local data = net.ReadTable()

	slowMotionKeyIsDown = data[1]
	slowMotionGameIsActivatedByPlayerSinglePlayer = data[2]
end)

-- Stop All sounds currently playing
net.Receive("mbd_stopAllSoundsClient", function()
	RunConsoleCommand("stopsound")
end)

-- Set the current client camera view
net.Receive("mbd:setCurrentCameraView", function()
	local newCurrentCameraView = net.ReadInt(5)

	currentCameraView = newCurrentCameraView
end)
-- Set current top View config.
net.Receive("mbd:onlyTopCameraViewIsAllowedClient", function()
	local onlyTopViewMaybe = net.ReadBool()

	onlyTopCameraViewIsAllowed = onlyTopViewMaybe
end)
-- Set current if allow top view config.
net.Receive("mbd:cameraTopViewIsAllowedClient", function()
	local ifCameraViewIsAllowedTopViewMaybe = net.ReadBool()

	cameraTopViewIsAllowed = ifCameraViewIsAllowedTopViewMaybe
end)

-- BuyBox Table
net.Receive("mbd:SetABuyBoxListClient", function()
	local listTableData = net.ReadTable()

	if LocalPlayer():MBDIsNotAnAdmin(false) then return end

	local type = listTableData.type
	local data = listTableData.data

	if type == "weapons" then
		MBDCompleteBuyBoxList_AllowedWeapons = data
	elseif type == "other" then
		MBDCompleteBuyBoxList_AllowedOther = data
	elseif type == "ammo" then
		MBDCompleteBuyBoxList_AllowedAmmo = data
	elseif type == "attachments" then
		MBDCompleteBuyBoxList_AllowedAttachments = data
	elseif type == "pricesWepCustom" then
		MBDCompleteBuyBoxList_PricesWepCustom = data
	elseif type == "pricesAtt" then
		MBDCompleteBuyBoxList_PricesAttachments = data
	elseif type == "pricesAmmo" then
		MBDCompleteBuyBoxList_PricesAmmunition = data
	elseif type == "pricesOther" then
		MBDCompleteBuyBoxList_PricesOther = data
	elseif type == "pricesAllCombined" then
		MBDCompleteBuyBoxList_AllPricesCombined = data
	end
end)

-- Spawn descruction props
local function changeAlphaColorAndMaybeRemovePropLoop( destructionProp, howFastItFadesFor, howManyTimesItCountsFor )
	
	if destructionProp and destructionProp:IsValid() then

		if ( destructionProp:GetNWInt( "mbd_downCounter", 0 ) <= howManyTimesItCountsFor / 2 ) then

			local killmodelFarge = destructionProp:GetColor()

			destructionProp:SetColor( Color( killmodelFarge.r, killmodelFarge.g, killmodelFarge.b, ( destructionProp:GetNWFloat( "mbd_alphaDegrader", 0 ) ) ) )
			destructionProp:SetNWFloat( "mbd_alphaDegrader", math.Clamp( destructionProp:GetNWFloat( "mbd_alphaDegrader", 0 ) - ( 255 / howManyTimesItCountsFor ) - 3, 0, 255 ) )

		end

		-- Remove when invisible
		if ( destructionProp:GetNWFloat( "mbd_alphaDegrader", 0 ) <= 0 ) then destructionProp:Remove() end

		if destructionProp:IsValid() then

			destructionProp:SetNWInt( "mbd_downCounter", destructionProp:GetNWInt( "mbd_downCounter", 0 ) - 1 )

			timer.Simple( howFastItFadesFor, function() changeAlphaColorAndMaybeRemovePropLoop( destructionProp, howFastItFadesFor, howManyTimesItCountsFor ) end )

		end

	end

end
local function produserOydelegelseProppen( destructionProp, parentPropAngles, parentPropVelocity, parentPropAngleVelocity, parentPropInertia )

	destructionProp:SetAngles( Angle(

		parentPropAngles.p * math.random( 0, 360 ),
		parentPropAngles.y * math.random( 0, 360 ),
		parentPropAngles.r * math.random( 0, 360 )

	) )

	destructionProp:Spawn()
	destructionProp:SetRenderMode( RENDERMODE_TRANSALPHA )

end
net.Receive( "mbd:SpawnDestructionProps", function()

	local destructionData = net.ReadTable()

	local entPhysObject = destructionData[ "entPhysObject" ]
	local destructionPropNewPos = destructionData[ "destructionPropNewPos" ]

	local parentPropAngles = destructionData[ "parentPropAngles" ]
	local parentPropVelocity = destructionData[ "parentPropVelocity" ]
	local parentPropAngleVelocity = destructionData[ "parentPropAngleVelocity" ]
	local parentPropInertia = destructionData[ "parentPropInertia" ]

	for i = 1, 3 do
		
		for _, modelName in pairs( destructionData[ "killmodels" ] ) do

			local destructionProp = ents.CreateClientProp( modelName )
			destructionProp:SetModelScale( 0.85 * ( math.random( 5, 10 ) / 10 ) )
			destructionProp:SetPos( destructionPropNewPos )
			produserOydelegelseProppen( destructionProp, parentPropAngles, parentPropVelocity, parentPropAngleVelocity, parentPropInertia )
	
			-- Set timer to animate fading for kill props
			local howFastItFadesFor = math.random( 1, 8 ) / 100
			local howManyTimesItCountsFor = math.random( 150, 900 )
	
			destructionProp:SetNWFloat( "mbd_alphaDegrader", 255 )
			destructionProp:SetNWInt( "mbd_downCounter", howManyTimesItCountsFor - howManyTimesItCountsFor / 3 )
	
			local randomColor = ColorToHSV( ColorRand( false ) )
	
			destructionProp:SetColor( HSVToColor( randomColor, 1, 1 ) )
			destructionProp:SetModelScale( 0, 6.2 )
	
			changeAlphaColorAndMaybeRemovePropLoop( destructionProp, howFastItFadesFor, howManyTimesItCountsFor )
	
		end

	end

end )

net.Receive( "mbd:SpawnNPCBodyParts", function()

	local destructionData = net.ReadTable()

	local npc = destructionData[ "npc" ]
	local npcModel = destructionData[ "npcModel" ]
	local bodygroupName = destructionData[ "bodygroupName" ]
	local parentModelScale = destructionData[ "npcModelScale" ]

	local pos, ang = destructionData[ "pos" ], destructionData[ "ang" ]
	local attacker = destructionData[ "attacker" ]
	local damageForce = destructionData[ "damageForce" ]

	local function setNWBoolNPC( id ) if npc and npc:IsValid() then npc:SetNWBool( id, true ) end end

	-- DYNAMIC
	local bodypartModel

	if npcModel == string.lower("models/zombie/Classic_split.mdl") then
		if bodygroupName == "HEAD" then
			bodypartModel = "models/zombie/classic_head.mdl"
			npc:SetNWBool("alreadySpawnedBodyGroup_HEAD", true)
		end
		if bodygroupName == "LEFTARM" then
			bodypartModel = "models/zombie/classic_leftarm.mdl"
			npc:SetNWBool("alreadySpawnedBodyGroup_LEFTARM", true)
		end
		if bodygroupName == "RIGHTARM" then
			bodypartModel = "models/zombie/classic_rightarm.mdl"
			npc:SetNWBool("alreadySpawnedBodyGroup_RIGHTARM", true)
		end
		if bodygroupName == "LEFTLEG" then
			bodypartModel = "models/zombie/classic_leftleg.mdl"
			npc:SetNWBool("alreadySpawnedBodyGroup_LEFTLEG", true)
		end
		if bodygroupName == "RIGHTLEG" then
			bodypartModel = "models/zombie/classic_rightleg.mdl"
			npc:SetNWBool("alreadySpawnedBodyGroup_RIGHTLEG", true)
		end
	elseif npcModel == string.lower("models/zombie/Zombie_Soldier_split.mdl") then
		if bodygroupName == "LEFTARM" then
			bodypartModel = "models/zombie/soldier_leftarm.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_LEFTARM" )
		end
		if bodygroupName == "RIGHTARM" then
			bodypartModel = "models/zombie/soldier_rightarm.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_RIGHTARM" )
		end
		if bodygroupName == "LEFTLEG" then
			bodypartModel = "models/zombie/soldier_leftleg.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_LEFTLEG" )
		end
		if bodygroupName == "RIGHTLEG" then
			bodypartModel = "models/zombie/soldier_rightleg.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_RIGHTLEG" )
		end
	elseif npcModel == string.lower("models/combine/Combine_Super_Soldier_split.mdl") then
		if bodygroupName == "HEAD" then
			bodypartModel = "models/combine/super_soldier_head.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_HEAD" )
		end
		if bodygroupName == "LEFTARM" then
			bodypartModel = "models/combine/super_soldier_leftarm.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_LEFTARM" )
		end
		if bodygroupName == "RIGHTARM" then
			bodypartModel = "models/combine/super_soldier_rightarm.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_RIGHTARM" )
		end
		if bodygroupName == "LEFTLEG" then
			bodypartModel = "models/combine/super_soldier_leftleg.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_LEFTLEG" )
		end
		if bodygroupName == "RIGHTLEG" then
			bodypartModel = "models/combine/super_soldier_rightleg.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_RIGHTLEG" )
		end
	elseif npcModel == string.lower("models/combine/Combine_Soldier_split.mdl") then
		if bodygroupName == "HEAD" then
			bodypartModel = "models/combine/soldier_head.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_HEAD" )
		end
		if bodygroupName == "LEFTARM" then
			bodypartModel = "models/combine/soldier_leftarm.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_LEFTARM" )
		end
		if bodygroupName == "RIGHTARM" then
			bodypartModel = "models/combine/soldier_rightarm.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_RIGHTARM" )
		end
		if bodygroupName == "LEFTLEG" then
			bodypartModel = "models/combine/soldier_leftleg.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_LEFTLEG" )
		end
		if bodygroupName == "RIGHTLEG" then
			bodypartModel = "models/combine/soldier_rightleg.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_RIGHTLEG" )
		end
	elseif npcModel == string.lower("models/combine/Combine_Soldier_PrisonGuard_split.mdl") then
		if bodygroupName == "HEAD" then
			bodypartModel = "models/combine/soldier_prisonguard_head.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_HEAD" )
		end
		if bodygroupName == "LEFTARM" then
			bodypartModel = "models/combine/soldier_prisonguard_leftarm.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_LEFTARM" )
		end
		if bodygroupName == "RIGHTARM" then
			bodypartModel = "models/combine/soldier_prisonguard_rightarm.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_RIGHTARM" )
		end
		if bodygroupName == "LEFTLEG" then
			bodypartModel = "models/combine/soldier_prisonguard_leftleg.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_LEFTLEG" )
		end
		if bodygroupName == "RIGHTLEG" then
			bodypartModel = "models/combine/soldier_prisonguard_rightleg.mdl"
			setNWBoolNPC( "alreadySpawnedBodyGroup_RIGHTLEG" )
		end
	end

	-- Create bodypart
	local bodypart = ents.CreateClientProp( bodypartModel )

	bodypart:SetPos( pos )
	bodypart:SetAngles( ang )

	bodypart:Spawn()
	bodypart:SetRenderMode( RENDERMODE_TRANSALPHA )

	-- Scale!
	bodypart:SetModelScale( parentModelScale )

	local physObj = bodypart:GetPhysicsObject()
	if physObj and physObj:IsValid() then physObj:AddVelocity( damageForce / 5 ) end

	-- Set timer to animate fading for kill props
	local howFastItFadesFor = math.random( 10, 20 ) / 1000 -- How fast it fades away
	local howManyTimesItCountsFor = math.random( 400, 700 ) -- How long it will be alive for ( higher = more )

	bodypart:SetNWFloat( "mbd_alphaDegrader", 255 )
	bodypart:SetNWInt( "mbd_downCounter", howManyTimesItCountsFor - howManyTimesItCountsFor / 3 )

	changeAlphaColorAndMaybeRemovePropLoop( bodypart, howFastItFadesFor, howManyTimesItCountsFor )

end )
