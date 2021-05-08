AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

-- -- >>>
function ENT:SpawnFunction(pl, tr)
	if not tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal

	local ent = ents.Create("mbd_npc_spawner_all")
	ent:SetPos(SpawnPos + Vector(0, 0, 10))
	ent:SetAngles(
		Angle(180, pl:EyeAngles().y - 90, -180)
	)

	ent:Spawn()
	ent:Activate()

	return ent
end
function ENT:Initialize()
	self:SetName("mbd_ent")

	-- Sets what model to use
	self:SetUseType(SIMPLE_USE)
	self:SetModel("models/npcspawner/npcspawner.mdl")

	-- Put the Head on top (sub.-model)
	local head = self:FindBodygroupByName("head")
	self:SetBodygroup(head, 1)
	-- Add the Wood Panel Text (sub.-model)
	local wood_panel_text = self:FindBodygroupByName("wood_panel_text")
	self:SetBodygroup(wood_panel_text, 3)

	-- Physics stuff
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNotSolid(true)

	-- Init physics only on server, so it doesn't mess up physgun beam
	if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end

	-- Make prop to fall on spawn
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then phys:Wake() end

	-- NW Strings ( that needs to be accessed globally )
	self:SetNWString("NPCSpawnerScaleModelSettings", "off")
	self:SetNWInt("CurrentTotalAmountOfEnemiesSpawningThisWaveRound", 0)
end
--
-- Functions (+ Algoritims)
--
function ENT:GETCalculateAmountOfEnemiesThisRound()
	local AmountOfActivePlayers = 0
	local __AllPlayers = player.GetAll()

	if #__AllPlayers > 0 then
		for k, v in pairs(__AllPlayers) do
			if !v:GetNWBool("isSpectating", true) then
				-- If Player is not spectating..>>
				-- --->>
				AmountOfActivePlayers = (AmountOfActivePlayers + 1)
			end
			--- -
			--
			if (k == #__AllPlayers) then
				-- Done
				--
				---
				--- FORMULA: f(x)=(((180players)/(3))/(spawners))/(1+e^(-0.75x+n))
	
				local a = AmountOfActivePlayers
				local b = #ents.FindByClass("mbd_npc_spawner_all")
				local x = CurrentRoundWave
	
				local eulersConstant = 2.71828
				local n = 5
	
				-- Check if min.-value...
				if (a <= 0) then a = 0 end
				if (b <= 0) then b = 1 end
				if (x <= 0) then x = 1 end
	
				local __v = math.Round(
					( (180 * a / (3)) / (b) ) / ( 1 + (math.pow(eulersConstant, -0.75 * x + n)) )
				)
	
				-- Save the total amount globally, so it can be
				-- retrived and added together for absolute total amount later
				self:SetNWInt("CurrentTotalAmountOfEnemiesSpawningThisWaveRound", __v)
	
				return __v
			end
		end
	else return 0 end
end
function ENT:GETCalculateIntervalIntensityThisRound()
	local Time = GetConVar("mbd_countDownTimerEnd"):GetInt()
	--
	---
	if self:GetAmountOfEnemiesThisRound() == 0 then self:SetAmountOfEnemiesThisRound(1) end

	-- Decrease time a little, so all NPCs have time to spawn
	Time = Time / 1.3

	local intensity = (Time / self:GetAmountOfEnemiesThisRound())
	if intensity < 1 then return 1 else return math.Round(intensity) end
end
function ENT:ResetForNewRound()
	timer.Remove("mbd:NPCSpawnerAll001:"..self:EntIndex())
	--
	---
	self:SetAnIntervalIsCurrentlyRunning(false)
	--
	self:SetIntervalIntensityThisRound(0)
	self:SetAmountOfEnemiesThisRound(0)

	self:SetOneNPCStriderSpawnedThisRound(false)
	self:SetOneNPCCombineGunShipSpawnedThisRound(false)
	self:SetOneNPCHelicopterSpawnedThisRound(false)
	--
	local PosLimit = 9
	if (self:GetCurrentZombiePos() >= PosLimit) then self:SetCurrentZombiePos(1) end
	if (self:GetCurrentCombinePos() >= PosLimit) then self:SetCurrentCombinePos(1) end

	-- Set a random setting for the scale of the zombies this round...
	local _typeOfScaleSetting = math.Round(math.random(0, 2))
	if _typeOfScaleSetting == 0 then
		self:SetNWString("NPCSpawnerScaleModelSettings", "off")
	elseif _typeOfScaleSetting == 1 then
		self:SetNWString("NPCSpawnerScaleModelSettings", "smaller")
	elseif _typeOfScaleSetting == 2 then
		self:SetNWString("NPCSpawnerScaleModelSettings", "bigger")
	end

	self:SetNWInt("CurrentTotalAmountOfEnemiesSpawningThisWaveRound", 0)
end
--
-- Some of this code-logic is borrowed from GMod Source Code, and modified by the M.B.D. Creator>>>
--
function ENT:BuildNPCAndSpawn(NPCsTableKey, WorldPos, OwnSpawnflags, npcType)
	local NPCData = table.Copy(MBDCompleteCurrNPCList)[NPCsTableKey] -- The key, not always the entity class
	local Position = WorldPos
	local Normal = Position:GetNormal()

	if !NPCData then MsgC(Color(255, 0, 0), "M.B.D.: Could not get NPC data to spawn a NPC!\n") return nil end

	-- Equipment (e.g. weapon)
	--
	local Equipment = nil
	if NPCData.Weapons then
		Equipment = math.Round(math.random(1, #NPCData.Weapons))
		Equipment = NPCData.Weapons[Equipment]
	end

	-- Spawnflags
	--
	local SpawnFlags = OwnSpawnflags

	-- Create NPC
	local NPC = ents.Create( NPCData.Class )
	if ( !IsValid( NPC ) ) then MsgC(Color(255, 128, 0), "M.B.D.: Could not spawn NPC; it was invalid.\n") return end

	--
	-- Offset the position
	--
	local Offset = NPCData.Offset or 32
	NPC:AdjustVectorPositionForNPCToAValidOne(Position, Normal, Offset)

	--
	-- Rotate to MBD Spawner
	local Angles = self:GetAngles()

	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 90

	if ( NPCData.Rotate ) then Angles = Angles + NPCData.Rotate end

	NPC:SetAngles( Angles )

	--
	-- This NPC has a special model we want to define
	--
	--
	--- --->
	if ( NPCData.Model ) then
		NPC:SetModel( NPCData.Model )
	end

	--
	-- This NPC has a special texture we want to define
	--
	if ( NPCData.Material ) then
		NPC:SetMaterial( NPCData.Material )
	end

	--
	-- Spawn Flags
	--
	if ( NPCData.SpawnFlags ) then SpawnFlags = bit.bor( SpawnFlags, NPCData.SpawnFlags ) end
	if ( NPCData.TotalSpawnFlags ) then SpawnFlags = NPCData.TotalSpawnFlags end
	if ( SpawnFlagsSaved ) then SpawnFlags = SpawnFlagsSaved end
	NPC:SetKeyValue( "spawnflags", SpawnFlags )
	NPC.SpawnFlags = SpawnFlags

	--
	-- Optional Key Values
	--
	if ( NPCData.KeyValues ) then
		for k, v in pairs( NPCData.KeyValues ) do
			NPC:SetKeyValue( k, v )
		end
	end

	--
	-- This NPC has a special skin we want to define
	--
	if ( NPCData.Skin ) then
		NPC:SetSkin( NPCData.Skin )
	end

	-- Set relationships to other classes!
	NPC:MBDNPCLikeAllOtherNPCClassesInMergedNPCsTable()

	--
	-- What weapon should this mother be carrying
	--

	-- Check if this is a valid entity from the list, or the user is trying to fool us.
	local validWeapon = false
	for _, v in pairs( list.Get( "NPCUsableWeapons" ) ) do
		if v.class == Equipment then validWeapon = true break end
	end

	-- Set a random weapon (from available ones) >>
	if (Equipment && validWeapon) then
		-- GOGOGOG>>>
		NPC:SetKeyValue( "additionalequipment", Equipment )
		NPC.Equipment = Equipment
	end

	--- -
	-- One last check that the limit is not reached..
	local _AllNPCsNumber = MBDFindOutHowManyValidNPCsOnMapNumberNPCSpawnerDynamic()
	timer.Simple(0.3, function()
		if NPC:IsValid() and ( !GameStarted or !AttackRoundIsOn or _AllNPCsNumber > GetConVar("mbd_npcLimit"):GetInt() ) then NPC:Remove() return nil elseif NPC:IsValid() then
			-- OK
			--- - -
			--- Spawn effect
			MBDDoPropSpawnedEffect( NPC )

			NPC:SetRenderMode( RENDERMODE_GLOW)
            NPC:SetColor( Color(230, 0, 0, 160) ) -- Red
            NPC:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

			NPC:Spawn()
			NPC:Activate()
			NPC:SetCreator(self:GetCreator())
			NPC:SetName("NPCSpawnerNPC")

			-- Set the model again!! Sometimes (like e.g. NPC Zombie/Zombine, the model gets reset...)
			if NPCData.Model then NPC:SetModel( NPCData.Model ) end
			-- Maybe SCALE Model
			local NPCModelScale = MBDMaybeScaleNPCModel(self, NPC, false, Position, Normal, Offset)

			-- Some important stuff
			NPC:CapabilitiesAdd(CAP_USE) -- Can open doors/push buttons/pull levers
			NPC:CapabilitiesAdd(CAP_AUTO_DOORS) -- Can trigger auto doors
			NPC:CapabilitiesAdd(CAP_OPEN_DOORS) -- Can open manual doors
			NPC:CapabilitiesAdd(CAP_MOVE_SHOOT) -- Tries to shoot weapon while moving
			-- NPC:CapabilitiesAdd(CAP_MOVE_CLIMB) -- Climb ladders Maybe doesn't work for combines
			NPC:CapabilitiesAdd(CAP_MOVE_GROUND) -- Walk/Run
			NPC:CapabilitiesAdd(CAP_MOVE_JUMP) -- Jump/Leap
			NPC:CapabilitiesAdd(CAP_DUCK) -- Cover and Reload ducking
			NPC:CapabilitiesAdd(CAP_AIM_GUN) -- Use arms to aim gun, not just body

			if ( NPCData.Health ) then
				NPC:SetHealth( NPCData.Health )
			end

			-- Body groups
			if ( NPCData.BodyGroups ) then
				for k, v in pairs( NPCData.BodyGroups ) do
					NPC:SetBodygroup( k, v )
				end
			end

			--
			-- -
			-- - - Try to check for 5 seconds if the NPC is in the world, and try to get it out of world to valid position, or remove it..
			NPC:SetNWInt("isInWorldMins_index", 1)
			NPC:SetNWInt("isInWorldMins_index", 1)

			NPC:SetNWBool("isInWorldMins", false)
			NPC:SetNWBool("isInWorldMaxs", false)

			NPC:SetNWString("lastFinishedWorldPositionsPlacements", "")

			NPC:SetNWBool("NPCIsInWorld", false)

			NPC:SetNWInt("respawnTimeCurTime", CurTime())
			NPC:SetNWInt("LastNPCValidCheckCurTime", CurTime())

			-- Some fixes...
			if NPC:GetClass() == "npc_combinegunship" then
				-- For some reason, the npc_combinegunship can spawn with the helichopter model...
				NPC:SetModel("models/gunship.mdl")
			end

			-- Define next position
			if npcType == "zombie" then
				self:SetCurrentZombiePos(self:GetCurrentZombiePos() + 1)
				if self:GetCurrentZombiePos() >= GetConVar("mbd_npcSpawnerMaxNPCRowCount"):GetInt() then self:SetCurrentZombiePos(1) end
			elseif npcType == "combine" then
				self:SetCurrentCombinePos(self:GetCurrentCombinePos() + 1)
				if self:GetCurrentCombinePos() >= GetConVar("mbd_npcSpawnerMaxNPCRowCount"):GetInt() then self:SetCurrentCombinePos(1) end
			end
		end
	end)
end
function ENT:ConfigureAndInitializeNPCBeforeAndAfter(npcType) -- ZOMBIE or COMBINE
	local GetValidVectorPositionForNPC = function()
		local thisLocalPos = self:WorldToLocal(self:GetPos())
	
		local posX = 0
		local posY = 0
		local posZ = 20

		-- Set the postition as it would be by default...
		local ResetNextNPCPos = function()
	
			if npcType == "combine" then
	
				self:SetCurrentCombinePos(1)
	
			elseif npcType == "zombie" then
	
				self:SetCurrentZombiePos(1)
	
			end
		end
		local SetNextNPCPos = function()
			if npcType == "combine" then
	
				if self:GetCurrentCombinePos() == 1 then posY = 30 end
				posY = ( 60 + posY ) * self:GetCurrentZombiePos()
				posX = posX + math.random(-10, 10)
				if (
					NPCTableKey == "npc_combinegunship" or
					NPCTableKey == "npc_helicopter"
				) then posZ = ( 130 * 6 ) end
	
			elseif npcType == "zombie" then
	
				if self:GetCurrentZombiePos() == 1 then posY = 30 end
				posY = ( 60 + posY ) * self:GetCurrentZombiePos()
				posX = posX + math.random(-10, 10)
	
			end
		end
		local GetCurrentWorldPos = function()
			return self:LocalToWorld(Vector(
				thisLocalPos.x + posX,
				thisLocalPos.y + posY,
				thisLocalPos.z + posZ
			))
		end

		-- Maybe manipulate the limit, so the NPC won't get stuck in world
		local x, y, z = ( self:OBBCenter().x ), ( self:OBBMaxs().y ), ( self:OBBMaxs().z - 40 ) posZ = z
		local startPosTraceLimit = self:LocalToWorld( Vector(x, y, z) )
		local endPosTraceLimit = startPosTraceLimit + (self:GetAngles() + Angle(0, 100, 0)):Forward() * 3000
		endPosTraceLimit = Vector(endPosTraceLimit.x, endPosTraceLimit.y, startPosTraceLimit.z)

		-- Draw a trace line to find maximum valid spawn point from the NPC Spawner Head (X & Y)
		local traceLimit = util.TraceLine({
			start = startPosTraceLimit,
			endpos = endPosTraceLimit,
			filter = function(ent) if ent:IsWorld() then return true end end
		})

		local traceLimitPos = traceLimit.HitPos
		local traceLimitPosNormal = traceLimit.HitPos:GetNormal() * 100
		traceLimitPos = traceLimitPos - Vector(traceLimitPosNormal.x, traceLimitPosNormal.y, 0)

		SetNextNPCPos()

		-- Maybe re-configure NPC Position (X & Y)
		if traceLimit.Hit then
			local currentWorldPos = GetCurrentWorldPos()

			local outSideLimitX = false
			local outSideLimitY = false
	
			if traceLimitPos.x > 0 then
				if currentWorldPos.x > traceLimitPos.x then outSideLimitX = true end
			elseif traceLimitPos.x < 0 then
				if currentWorldPos.x < traceLimitPos.x then outSideLimitX = true end
			end

			if traceLimitPos.y > 0 then
				if currentWorldPos.y > traceLimitPos.y then outSideLimitY = true end
			elseif traceLimitPos.y < 0 then
				if currentWorldPos.y < traceLimitPos.y then outSideLimitY = true end
			end

			if outSideLimitX and outSideLimitY then
				ResetNextNPCPos()
				SetNextNPCPos()
			end
		end

		return GetCurrentWorldPos()
	end

	if ( #allowedCombines == 0 and npcType == "combine" ) or npcType == "zombie" then
		if self:GetSpawnType() == "combine" then return end
		--
		-- SPAWN A ZOMBIE
		local NPCTableKey = allowedZombies[math.Round(math.random(1, #allowedZombies))]
		
		--
		-- Spawnflags
		--
		local OwnSpawnflags = MBDNewFlags2
		if (NPCTableKey == "npc_zombie_torso") then
			-- 25 % chance that the zombie torso will get this spawnflag (will spawn e.g./i.e. a health vial)
			local _chance001 = math.random(0, 100)

			if (_chance001 >= 0 and _chance001 <= 25) then
				OwnSpawnflags = MBDNewFlags1
			end
		end
		
		-- Create NPC!
		local NPC = self:BuildNPCAndSpawn( NPCTableKey, GetValidVectorPositionForNPC(self), OwnSpawnflags, npcType )
	elseif ( #allowedZombies == 0 and npcType == "zombie" ) or npcType == "combine" then
		if self:GetSpawnType() == "zombie" then return end
		--
		-- SPAWN A COMBINE
		local NPCTableKey = allowedCombines[math.Round(math.random(1, #allowedCombines))]
		
		if (
			GetConVar("mbd_enableHardEnemiesEveryThreeRound"):GetInt() >= 1 and
			CurrentRoundWave != 0 and
			(CurrentRoundWave % 3) == 0
		) then
			-- **SPECIAL ROUND
			-- Spawn ONE Strider NPC per NPC Spawner instead of the Random one...
			if !self:GetOneNPCStriderSpawnedThisRound() then
				self:SetOneNPCStriderSpawnedThisRound(true)

				NPCTableKey = "npc_strider"
			elseif (
				!self:GetOneNPCCombineGunShipSpawnedThisRound() or
				!self:GetOneNPCHelicopterSpawnedThisRound()
			) then
				self:SetOneNPCCombineGunShipSpawnedThisRound(true)
				self:SetOneNPCHelicopterSpawnedThisRound(true)

				-- Pick a random one... (could change later)
				local _ir = math.Round(math.random(0, 2))

				if _ir >= 0 and _ir < 2 then NPCTableKey = "npc_combinegunship"
				elseif _ir == 2 then NPCTableKey = "npc_helicopter" end
			end
		end
		
		--
		-- Spawnflags
		local OwnSpawnflags = MBDNewFlags2
		if (NPCTableKey == "npc_metropolice") then OwnSpawnflags = MBDNewFlags0
		elseif string.match(NPCTableKey, "npc_combine") then OwnSpawnflags = MBDNewFlags0 end

		-- Create NPC!
		local NPC = self:BuildNPCAndSpawn( NPCTableKey, GetValidVectorPositionForNPC(self), OwnSpawnflags, npcType )
	else
		-- This should never happen
		MsgC(Color(255, 0, 0), "M.B.D. Could not spawn any NPCs. None of the NPC tables where populated.\n")
	end
end

function ENT:GravGunPickupAllowed(pl)
	if (
		pl:MBDIsAnAdmin(true)
	) then return true else return false end
end
function ENT:SetAndCountDownToNextAnimationPlay(sec, animationSequence)
	timer.Remove("mbd:CountDownToAnimationDone"..self:EntIndex())

	self:SetStartNewAnimationSequence(false)
	self:ResetSequence(animationSequence)

	timer.Create("mbd:CountDownToAnimationDone"..self:EntIndex(), sec, 1, function()
		self:SetStartNewAnimationSequence(true)
	end)
end
--
--- THINK
--
function ENT:Think()
	if timerCountDownIsOn then timer.UnPause("mbd:NPCSpawnerAll001:"..self:EntIndex()) end
	--- Animation
	if self:GetStartNewAnimationSequence() and (!AttackRoundIsOn or !GameStarted) then
		self:SetAndCountDownToNextAnimationPlay(1, "idle")
	elseif self:GetStartNewAnimationSequence() and AttackRoundIsOn and GameStarted then
		self:SetAndCountDownToNextAnimationPlay(5.6, "active")
	end
	--- ----
	if ( -- Ignore; just continue to check...
		!GameStarted or
		!AttackRoundIsOn
	) then
		self:ResetForNewRound()
		if !GameStarted then
			self:SetCurrentZombiePos(1)
			self:SetCurrentCombinePos(1)
		end
		---- -
		self:NextThink(CurTime() + 0.1)
		return true
	end
	--
	---
	---- Start an interval to spawn NPCs...
	if !self:GetAnIntervalIsCurrentlyRunning() then
		self:SetAnIntervalIsCurrentlyRunning(true)

		self:SetAmountOfEnemiesThisRound(self:GETCalculateAmountOfEnemiesThisRound())
		self:SetIntervalIntensityThisRound(self:GETCalculateIntervalIntensityThisRound())

		if (
			 self:GetIntervalIntensityThisRound() and
			self:GetAmountOfEnemiesThisRound()
		) then
			local NPCSpawnerAll001Index = 0
			timer.Remove("mbd:NPCSpawnerAll001:"..self:EntIndex())

			-- Notify about scale model setting (if any)
			local scaleModelSettings = self:GetNWString("NPCSpawnerScaleModelSettings", "off")
			if scaleModelSettings != "off" and GetConVar("mbd_enableAutoScaleModelNPC"):GetInt() == 1 then
				for _,_Player in pairs(player.GetAll()) do
					net.Start("NotificationReceivedFromServer")
						net.WriteTable({
							Text 	= "NPC's are under a "..string.upper(scaleModelSettings).." SPELL this wave",
							Type	= NOTIFY_GENERIC,
							Time	= 4.5
						})
					net.Send(_Player)
				end
			end

			timer.Create("mbd:NPCSpawnerAll001:"..self:EntIndex(), self:GetIntervalIntensityThisRound(), self:GetAmountOfEnemiesThisRound(), function()
				if !self or !self:IsValid() then
					timer.Remove("mbd:NPCSpawnerAll001:"..self:EntIndex())

					print("M.B.D. Warning: The NPC Spawner could not be found.")

					return
				end
				-- Pause
				if !timerCountDownIsOn then timer.Pause("mbd:NPCSpawnerAll001:"..self:EntIndex()) end

				if !AttackRoundIsOn then
					timer.Remove("mbd:NPCSpawnerAll001:"..self:EntIndex())

					return
				end
				local _AllNPCsNumber = MBDFindOutHowManyValidNPCsOnMapNumberNPCSpawnerStatic()
				if _AllNPCsNumber < GetConVar("mbd_npcLimit"):GetInt() then -- Maximum number of enemies at one time..
					if spawnType == "zombie" then
						self:ConfigureAndInitializeNPCBeforeAndAfter('zombie')
					elseif spawnType == "combine" then
						self:ConfigureAndInitializeNPCBeforeAndAfter('combine')
					else
						-- Choose one random...
						local rand = math.random(0, 1)
						
						if rand == 0 then
							self:ConfigureAndInitializeNPCBeforeAndAfter('zombie')
						else
							self:ConfigureAndInitializeNPCBeforeAndAfter('combine')
						end
					end
				end
				--
				--- -- Round is over
				NPCSpawnerAll001Index = (NPCSpawnerAll001Index + 1)
				if (NPCSpawnerAll001Index >= self:GetAmountOfEnemiesThisRound()) then self:ResetForNewRound() end
			end)
		end
	end

	if SERVER then
		-- Check if any NPCs need a new Enemy ( every nine seconds )
		if CurTime() - self:GetLastTimeCheckedIfAnyNPCsDontLikeEachOther() >= 9 then
			-- FINN EIN BETRE LØYSING...
			self:SetLastTimeCheckedIfAnyNPCsDontLikeEachOther(CurTime())

			local allNPCSpawnerNPCs = GETAllValidNPCsWithinTheNPCTable()
			for _,npc in pairs(allNPCSpawnerNPCs) do

				self:SetLastTimeCheckedIfNPCsHaveAnEnemy(CurTime())
				npc:MBDSetRandomPlayerTargetForNPC()

			end
		end
	end

	self:NextThink(CurTime() + 0.1)
	return true
end
--
--- Change SPAWN TYPE...
--
function ENT:Use(activator, caller, useType, value)
	if caller:MBDIsNotAnAdmin(true) then return false end

	-- Add the Wood Panel Text (sub.-model)
	local wood_panel_text = self:FindBodygroupByName("wood_panel_text")

	if (self:GetSpawnType() == 'all') then
		-- Set to Zombies only...
		self:SetSpawnType("zombie")
		self:SetBodygroup(wood_panel_text, 2)
		-- self:SetColor(Color(235, 16, 0, 255)) -- red = 'zombie'
	elseif (self:GetSpawnType() == 'zombie') then
		-- Set to Combines only...
		self:SetSpawnType("combine")
		self:SetBodygroup(wood_panel_text, 1)
		-- self:SetColor(Color(0, 121, 235, 255)) -- blue = 'combine'
	elseif (self:GetSpawnType() == 'combine') then
		-- Set to All
		self:SetSpawnType("all")
		self:SetBodygroup(wood_panel_text, 3)
		-- self:SetColor(Color(0, 0, 0, 255)) -- black = 'all'
	end

	return true
end
--
--- On remove...
--
function ENT:OnRemove()
	timer.Remove("mbd:CountDownToAnimationDone"..self:EntIndex())
	timer.Remove("mbd:NPCSpawnerAll001:"..self:EntIndex())
end
