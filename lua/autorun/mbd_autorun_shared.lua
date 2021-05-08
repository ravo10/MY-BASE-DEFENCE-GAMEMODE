if engine.ActiveGamemode() == "my_base_defence" then -- Very important
	AddCSLuaFile()

	if SERVER or CLIENT then
		function MBDLerp(floatTime, floatFrom, floatTo)
			if not floatTime or not floatTime or not floatTo then return floatTo or 1 end

			return (1 - floatTime) * floatFrom + floatTime * floatTo
		end

		function MBDTableToJSON(_table, simpleObject)
			if _table and #table.GetKeys(_table) > 0 then
				if simpleObject then
					-- Restructure the table if needed... ( Sometimes index starts at 2 ?? A bug ?? )
					local newTab = {} for _,v in pairs(_table) do table.insert(newTab, v) end _table = newTab
				end

				local jsonData = util.TableToJSON(_table, true)
				return jsonData
			end
	
			if simpleObject then return "[]" else return [[{}]] end
		end

		local IgnoreTheseNPCClasses = {
			"npc_bullseye",
			"mbd_npc_bullseye",
			"npc_grenade_frag",
			--[[ These can spawn inst. from dead zombies... So don't remove them ]]
			"npc_headcrab",
			"npc_headcrab_black",
			"npc_headcrab_poison",
			"npc_headcrab_fast"
		}
		local IgnoreTheseNPCBullseyes = {
			"npc_bullseye",
			"mbd_npc_bullseye"
		}
		local IgnoreTheseNPCColorCheck = {
			"env_",
			"grenade",
			"instanced_scripted_scene",
			"npc_bullseye",
			"mbd_npc_bullseye",
			"mbd_healing_trigger",
			"mbd_prop_block_npc",
			"mbd_door_trigger"
		}
		function MBD_CheckIfCanContinueBecauseOfTheNPCClass(npcClass)
			if table.HasValue(IgnoreTheseNPCClasses, npcClass) then return false end
	
			return true
		end
		function MBD_CheckIfNotBullseyeEntity(npcClass)
			if table.HasValue(IgnoreTheseNPCBullseyes, npcClass) then return false end
	
			return true
		end
		function MBD_CheckIfColorNPCClass(npcClass)
			for _,v in pairs(IgnoreTheseNPCColorCheck) do if string.match(npcClass, v) then return true end end
	
			return false
		end

		function setEntColorNormal(ent, id)
			--print("CLIENT Nrml.: "..id, ent)
			if !ent:IsValid() or ent:IsNPC() or MBD_CheckIfColorNPCClass(ent:GetClass()) then return end
		
			ent:SetRenderMode(RENDERMODE_NORMAL)
			local _Color = ent:GetColor()
			ent:SetColor(Color(
				_Color.r,
				_Color.g,
				_Color.b,
				255
			))
		end
		function setEntColorTransparent(ent, id)
			--print("CLIENT Trans.: "..id, ent)
			if !ent:IsValid() or ent:IsNPC() or MBD_CheckIfColorNPCClass(ent:GetClass()) then return end
		
			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			local _Color = ent:GetColor()
			ent:SetColor(Color(
				_Color.r,
				_Color.g,
				_Color.b,
				0
			))
		end

		function GetCorrectEntForProps(ent)
			if !ent or !ent:IsValid() then return ent end

			local _Class = ent:GetClass()
			if (
				_Class == "mbd_door_trigger" or
				_Class == "mbd_hate_trigger" or
				_Class == "mbd_npc_bullseye" or
				_Class == "mbd_healing_trigger" or
				_Class == "mbd_prop_block_npc"
			) then
				-- Get Parent
				---
				local OriginalEnt = ent
				if _Class != "mbd_npc_bullseye" then
					ent = ent:GetParent()
				else
					ent = ent:GetNWEntity("mbd_npc_bullseye_parent", nil)
					if !ent or !ent:IsValid() then ent = OriginalEnt end
				end

				return ent
			elseif _Class == "npc_bullseye" then
				--
				--- Get Parent's Parent
				local OriginalEnt = ent
				ent = ent:GetParent():GetNWEntity("mbd_npc_bullseye_parent", nil)
				if !ent or !ent:IsValid() then ent = OriginalEnt end

				return ent
			end

			return ent
		end
	end

	if SERVER then
		function MBDDoUndoRemoveNullEntities(pl)
			local PlayerUndo = undo.GetTable()

			if ( !pl or ( pl and !pl:IsValid() ) ) then return false end
			
			local ownerIndex = pl:UniqueID()
			PlayerUndo[ ownerIndex ] = PlayerUndo[ ownerIndex ] or {}
			
			for index, undoPlayerTables in pairs(PlayerUndo[ ownerIndex ]) do

				if ( undoPlayerTables.Entities ) then
					for _, entity in pairs( undoPlayerTables.Entities ) do

						if ( !IsValid( entity ) --[[ Remove unvalid ones... Maybe the got exploded (oil barrel) ]] ) then
							-- Don't delete the entry completely so nothing new takes its place and ruin
							-- CC_UndoLast's logic (expecting newest entry be at highest index)
							PlayerUndo[ ownerIndex ][ index ] = {}

							net.Start( "Undo_Undone" )
								net.WriteInt( index, 16 )
							net.Send( pl )

						end

					end
				end

			end
		end
		function MBDDoUndo( undoTable, forceUpdateClientUndoList, onlyForceUpdateNoText )
			local PlayerUndo = undo.GetTable()

			if ( !undoTable or !undoTable.Owner or ( undoTable.Owner and !undoTable.Owner:IsValid() ) ) then return false end
	
			local count = 0
	
			-- Call each function
			if ( undoTable.Functions ) then
				for index, func in pairs( undoTable.Functions ) do
	
					func[ 1 ]( undoTable, unpack( func[ 2 ] ) )
					count = count + 1
	
				end
			end
	
			-- Force-update the client list
			if ( undoTable.Entities && forceUpdateClientUndoList ) then
				local ownerIndex = undoTable.Owner:UniqueID()
				PlayerUndo[ ownerIndex ] = PlayerUndo[ ownerIndex ] or {}
	
				for index, undoPlayerTables in pairs(PlayerUndo[ ownerIndex ]) do
	
					if ( undoPlayerTables.Entities ) then
						for _, entity in pairs( undoPlayerTables.Entities ) do
	
							-- Check each member for a match ( only needs one )
							for _, undoEntity in pairs( undoTable.Entities ) do

								if ( ( IsValid( entity ) && IsValid( undoEntity ) && ( entity == undoEntity ) ) or !IsValid( entity ) --[[ Remove unvalid ones... Maybe the got exploded (oil barrel) ]] ) then
									-- Don't delete the entry completely so nothing new takes its place and ruin
									-- CC_UndoLast's logic (expecting newest entry be at highest index)
									PlayerUndo[ ownerIndex ][ index ] = {}
	
									net.Start( "Undo_Undone" )
										net.WriteInt( index, 16 )
									net.Send( undoTable.Owner )
			
								end
			
							end
			
						end
					end
	
				end
			end
	
			-- Remove each entity in this undoTable
			if ( undoTable.Entities ) then
				for index, entity in pairs( undoTable.Entities ) do
	
					if ( IsValid( entity ) ) then
						entity:Remove()
						count = count + 1
					end
	
				end
			end
	
			if ( count > 0 and !onlyForceUpdateNoText ) then
				if ( undoTable.CustomUndoText ) then
					undoTable.Owner:SendLua( 'hook.Run("OnUndo","' .. undoTable.Name .. '","' .. undoTable.CustomUndoText .. '")' )
				else
					undoTable.Owner:SendLua( 'hook.Run("OnUndo","' .. undoTable.Name .. '")' )
				end
			end
	
			return count
	
		end
		function MBDSetConditionsForProp(ent, IsAVehicle, pl, PlayerCurrentBuildPoints, costOfProp)
			-- Set other conditions FOR THE PROP>>
			---
			local __ent_aabb_min, __ent_aabb_max = ent:GetPhysicsObject():GetAABB()
			local __ent_center = ent:WorldToLocal(ent:WorldSpaceCenter()) __ent_center.z = (__ent_center.z + 1)
			local __ent_angles = ent:WorldToLocalAngles(ent:GetAngles())
			-- INSERT A HITBOX...>>>
			-------
			--
			-- Set Solid Again (if i.e. duplicated) >> >
			timer.Simple(2, function()
				-- Set after 2 sec... If Player i.e. wants to spawn a prop on another prop !!
				if (
					ent and
					ent:IsValid() and
					!ent:GetNWBool("isBeingUsedByAPhysgun", false)
				) then
					ent:SetCollisionGroup(COLLISION_GROUP_BREAKABLE_GLASS) -- Veldig viktig for at NPC som skyter, skal kunne sjå igjennom objektet inn til hitbox
				end
			end)
			
			ent:AddEFlags(EFL_DONTWALKON)
			ent:AddEFlags(EFL_DONTBLOCKLOS) -- Veldig viktig for at NPC som skyter, skal kunne sjå igjennom objektet inn til hitbox
		
			local _PhysObjEnt = ent:GetPhysicsObject()
			if _PhysObjEnt:IsValid() then
				_PhysObjEnt:AddGameFlag(FVPHYSICS_DMG_SLICE)
				
				if !IsAVehicle then
					_PhysObjEnt:AddGameFlag(FVPHYSICS_MULTIOBJECT_ENTITY)
					_PhysObjEnt:AddGameFlag(FVPHYSICS_NO_SELF_COLLISIONS)
				end
			end
			----
			-- Rekkefølgen er viktig her ...
			local ent_bullseye = ents.Create("mbd_npc_bullseye")
		
			ent_bullseye:SetPos(ent:LocalToWorld(__ent_center))
			ent_bullseye:SetAngles(ent:LocalToWorldAngles(__ent_angles))
		
			ent_bullseye:SetName("mbd_prop_bullseye_target_parent")
			ent_bullseye:SetOwner(pl)
			ent_bullseye:SetCreator(pl)
			--
			-- Spawn
			ent_bullseye:Spawn()
			ent_bullseye:Activate()
		
			-- Set "Virtual" Parent
			ent_bullseye:SetNWEntity("mbd_npc_bullseye_parent", ent)
			--
			
			----
			--
			-- INSERT A TRIGGER BOUNDING BOX (RADIUS) FOR NPC HATE...>>>
			local ent_trigger = ents.Create("mbd_hate_trigger")
		
			ent_trigger:SetParent(ent)
			ent_trigger:SetName("mbd_prop_trigger_box")
			ent_trigger:SetOwner(pl)
			ent_trigger:SetCreator(pl)
		
			ent_trigger:Spawn()
			ent_trigger:Activate()
			--
		
			-- Very important to set it here after spawn...
			ent_trigger:UseTriggerBounds(true, (24 * 5))
			ent_trigger:SetTrigger(true)
		
			ent_trigger:SetNotSolid(true)
		
			-- --
			--
			-- Insert healing area
			local ent_healing_trigger = ents.Create("mbd_healing_trigger")
		
			ent_healing_trigger:SetParent(ent)
			ent_healing_trigger:SetName("mbd_prop_trigger_box_healing")
			ent_healing_trigger:SetOwner(pl)
			ent_healing_trigger:SetCreator(pl)
		
			ent_healing_trigger:Spawn()
			ent_healing_trigger:Activate()
			--
		
			-- Very important to set it here after spawn...
			ent_healing_trigger:UseTriggerBounds(true, (24 * 1.3))
			ent_healing_trigger:SetTrigger(true)
		
			ent_healing_trigger:SetNotSolid(true)
			
		
			if IsAVehicle then
				-- Set collison group >>
				ent:SetCollisionGroup(COLLISION_GROUP_NPC)
			end
			---- -
			---
			--
			ent:DeleteOnRemove(ent_bullseye)
			ent:DeleteOnRemove(ent_trigger)
		
			ent:SetName("mbd_"..pl:UniqueID().."AMainPropOrVehicle")
			ent:SetNWBool("IsAValidMBDPropOrVehicle", true)
		
			ent:SetCreator(pl)
		
			if (
				pl:IsPlayer() and
				!IsAVehicle
			) then
				--
				----
				-- ALLOWED TO BUY PROP
				------
				-- So the prop can not take damage before 1.5 seconds into spawn... (for saftey)
				if GameStarted and ( !pl:MBDShouldGetTheAdminBenefits() or pl:MBDIsNotAnAdmin(false) ) then
					--
					local total = (PlayerCurrentBuildPoints - costOfProp)
		
					--
					if (total < 0) then total = 0 end
		
					pl:SetNWInt("buildPoints", total)
				end
		
				-- Alowed to get damage...
				timer.Simple(1.5, function()
					--
					if ent:IsValid() then ent:SetNWBool("CanNotGetDamage", false) end
				end)
			end
			--
			setEntColorNormal(ent, "3")
		end
		function MBDAddSomeMBDStuffAVehicle(ent, ENTCLASS)
			if OnEntityCreatedTroubleShoot001 then print("MBDAddSomeMBDStuffAVehicle", ent, ENTCLASS) end
			
			-- SECURITY
			local allowedVechicles = {
				"prop_vehicle_jeep_old",
				"prop_vehicle_jeep",
				"prop_vehicle_airboat"
			}
			local pl = ent:GetCreator()
		
			if pl and pl:IsValid() then
				registerAnEntityForUndoLater("M.B.D. Player Vehicle ("..string.upper(ENTCLASS)..")", ent, pl)
		
				if GetConVar("mbd_enableStrictMode"):GetInt() == 1 then
					local isAWhitelistedVehicle = table.HasValue(allowedVechicles, ENTCLASS)
					if !isAWhitelistedVehicle then if ent and ent:IsValid() then undoEntityWithOwner(pl, ent, "Returned a Vehicle (blacklisted)") end return true end
				end
		
				-- All Vehicles have 3000 health
				ent:SetNWInt("healthTotal", 3000)
				ent:SetNWInt("healthLeft", 3000)
		
				-- -- Need to wait a little, so it gets loaded OK
				timer.Simple(1.5, function()
					if ent:IsValid() and pl and pl:IsValid() then
						ent:SetNWString("PlayerOwner", pl:UniqueID())
		
						MBDSetConditionsForProp(ent, true, pl)
					end
				end)
			else print("M.B.D. Error: Could not get Vehicle owner... Removed vehicle.") undoEntityWithOwner(nil, ent, "Returned a Vehicle (could not get owner)", true) end
		
			return false
		end
	end
end
