if engine.ActiveGamemode() == "my_base_defence" then -- Very important
	AddCSLuaFile()
	
	local strictSetting = 1
	if GetConVar("mbd_enableStrictMode"):GetInt() then
		strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
	end

	-- M.B.D. Used for reference, so the loading of custom Spawnmenu can take a long time
	MBDSavedPanelForSpawnmenu = nil

	-- In HOOK EntityCreated, this is also used as a whitelist
	MBDcurrJSONFile001Data = nil
	MBDcurrJSONFile002Data = nil

	MBDPropWhiteList = nil

	MBDDataSpawnmenuDataIsWritten = false

	if CLIENT then
		function MBDWriteSpawnmenuClient()
			if not MBDSavedPanelForSpawnmenu then return end
			local pnlContent, tree, node, AddCustomizableNode = MBDSavedPanelForSpawnmenu[1], MBDSavedPanelForSpawnmenu[2], MBDSavedPanelForSpawnmenu[3], MBDSavedPanelForSpawnmenu[4]

			-- M.B.D. Denna styrer å vise mappen "Your Spawnlist" eller ikkje ...
			-- -- --- >> >
			local i0 = 0
			local firstPanel = nil
			local function PopulateTableProps(pnlContent, node, parentid, PropsList)
				local Props = PropsList
				if !Props then print("**Critical M.B.D. Error: A Props table is invalid/nil! Can not fill in the Spawnmenu with that. Ref.: "..parentid, PropsList) return end
	
				for FileName, Info in SortedPairs(Props) do
	
					-- if parentid != Info.parentid then continue end
	
					--- - -
					-- Add children to folder node... Aka. Props
					local childCategoryFolder = AddCustomizableNode(pnlContent, Info.name, Info.icon, node, Info.needsapp)
					childCategoryFolder:SetExpanded(true)
					childCategoryFolder.DoPopulate = function(self)
						if self.PropPanel then return end
	
						self.PropPanel = vgui.Create("ContentContainer", pnlContent)
						self.PropPanel:SetVisible(false)
						self.PropPanel:SetTriggerSpawnlistChange(true)
						-- - - -
						-- Models
						for i, object in SortedPairs(Info.contents) do
							local cp = spawnmenu.GetContentType(object.type) if cp then cp(self.PropPanel, object) end
						end
					end

					-- This loads the stuff for the user! ( I think )
					if IsValid(childCategoryFolder) then
						childCategoryFolder:InternalDoClick()

						if i0 == 0 then firstPanel = childCategoryFolder end
					end
					
					i0 = i0 + 1
				end
			end
			
			-- - -- ---
			-- Populate Spawnmenu >>> >
			PopulateTableProps(pnlContent, tree, 0, MBDcurrJSONFile001Data)
			PopulateTableProps(pnlContent, tree, 0, MBDcurrJSONFile002Data)
	
			timer.Simple(1.2, function()
				-- -- >> >
				-- Select the first panel
				if IsValid(firstPanel) then firstPanel:InternalDoClick() end
			end)
		end
	end
	-- -- ---
	-- - - THESE ARE STATIC....
	MBDTxtFileName001ID = "mbd-spawnlist/001-mbd-basic-props.lua" -- Must exsist
	MBDTxtFileName002ID = "mbd-spawnlist/002-mbd-builder-props.lua" -- Must exsist

	-- Some Functions
	local convertSpawnListToJSON
	local createJSONFileFromTable
	local createMachineTableFromJSON
	local createPropWhiteList

	if SERVER then
		util.AddNetworkString("mbd:ReadyToCreateClientPropListAfterFirstInit")
		util.AddNetworkString("mbd:SendTheSpawnListsToClient")
	end
	if CLIENT then
		net.Receive("mbd:SendTheSpawnListsToClient", function()
			local data = net.ReadTable()

			-- Save to client-side
			MBDcurrJSONFile001Data = data["MBDcurrJSONFile001Data"]
			MBDcurrJSONFile002Data = data["MBDcurrJSONFile002Data"]

			local timerID0 = "mbd:waitUntilTheMBDSavedPanelForSpawnmenuIsWritten0"
			timer.Create(timerID0, 0.5, 0, function()
				if MBDSavedPanelForSpawnmenu then
					timer.Remove(timerID0)
					
					MBDWriteSpawnmenuClient()
				end
			end)
		end)
	end

	if SERVER then
		-- The client will have to request the spawnlist on Connect
		function MBDSendTheSpawnListsToClients(pl)
			local newTabelToSend = { MBDcurrJSONFile001Data = MBDcurrJSONFile001Data, MBDcurrJSONFile002Data = MBDcurrJSONFile002Data }

			net.Start("mbd:SendTheSpawnListsToClient")
				net.WriteTable(newTabelToSend)
			net.Send(pl)
		end
		-- The .lua files that are pre-set within the gamemode ( the default ones that are used when needing to create a new JSON file the user can edit )
		convertSpawnListToJSON = function(txtFileName, folderPlace, modified)
			local txtFileSpawnList 	= file.Read(txtFileName, folderPlace)
		
			local nyString 	= string.gsub(txtFileSpawnList, [["		"]], [[":"]])		-- Ein verdi
			
			if modified then
				nyString		= string.gsub(nyString, "TableToKeyValues", "Spawnlist")
			else
				nyString		= string.gsub(nyString, "TableToKeyValues", txtFileName)
			end
		
			nyString 		= string.gsub(nyString, [[%c]], [[]]) 						-- Ta vekk all new line etc....
		
			nyString 		= string.gsub(nyString, [[""]], [[","]]) 					-- Komma
			nyString 		= string.gsub(nyString, [["{]], [[":{]]) 					-- Komma
			nyString 		= string.gsub(nyString, [[}"]], [[},"]]) 					-- Komma
		
			nyString 		= "{"..nyString.."}"										-- Wrap it
		
			-- The Table
			local SpawnListTable = util.JSONToTable(nyString)
		
			local TableLength = #SpawnListTable[txtFileName]["contents"]
		
			for k,v in pairs(SpawnListTable[txtFileName]["contents"]) do
				-- Very important, convert to number !
				--- - -
				if v["skin"] then v["skin"] = tonumber(v["skin"]) end
				
				if k == TableLength then
					-- Very important, convert to number !
					SpawnListTable[txtFileName]["parentid"] 	= tonumber(SpawnListTable[txtFileName]["parentid"])
					SpawnListTable[txtFileName]["id"] 			= tonumber(SpawnListTable[txtFileName]["id"])
					SpawnListTable[txtFileName]["version"] 		= tonumber(SpawnListTable[txtFileName]["version"])
		
					local newTable = {}
		
					if modified then
						SpawnListTable = SpawnListTable["Spawnlist"]
		
						newTable["Spawnlist"] 	= SpawnListTable["contents"]
						newTable["Icon"] 		= SpawnListTable["icon"]
						newTable["Name"] 		= SpawnListTable["name"]
					else newTable = SpawnListTable end
		
					return newTable
				end
			end
		end
		--- Human readable format ( what gets saved to the data folder )
		createJSONFileFromTable = function(txtLuaFileToConvert, targetFileNameJSON, ID)
			local MBDPropsTable = convertSpawnListToJSON(txtLuaFileToConvert, "LUA", false)
		
			local timerID0 = "mbd:SpawnMenuShadowFilesMaker1_00"..targetFileNameJSON
			local timerID1 = "mbd:SpawnMenuShadowFilesMaker1_01"..targetFileNameJSON
			local timerID3 = "mbd:SpawnMenuShadowFilesMaker1_02"..targetFileNameJSON
			-- -
			--- - -
			-- Go ahead and simplify the table...
			timer.Create(timerID0, 0.03, 0, function()
				if MBDPropsTable then
					timer.Remove(timerID0)
		
					for k,v in pairs(MBDPropsTable) do
						local mainKey = k
						local newTable = { parentid = "...", icon = "...", id = "...", contents = {}, name = "...", version = "..." }
			
						local i0 = 0
						local i0Max = #table.GetKeys(MBDPropsTable[mainKey])
						for l,w in pairs(v) do
							i0 = i0 + 1 newTable[l] = w
		
							if i0 >= i0Max then
								local propModels = {}
		
								local i1 = 0
								local i1Max = #table.GetKeys(newTable["contents"])
								for _,x in SortedPairs(newTable["contents"], false) do
									i1 = i1 + 1 table.insert(propModels, x["model"])
		
									if i1 >= i1Max then
										-- - -
										-- Go ahead and make a JSON file with current data ( first make a new table )
										newTable["contents"] = propModels
										local jsonFormat = util.TableToJSON(newTable, true)
										
										timer.Create(timerID1, 0.03, 0, function()
											if jsonFormat then
												timer.Remove(timerID1)
		
												file.Write(targetFileNameJSON, jsonFormat)
												timer.Create(timerID3, 0.03, 0, function()
													if file.Exists(targetFileNameJSON, "DATA") then
														timer.Remove(timerID3)

														-- Now create the machine table
														createMachineTableFromJSON(txtLuaFileToConvert, targetFileNameJSON, ID)
													end
												end)
											end
										end)
									end
								end
							end
						end
					end
				end
			end)
		end
		-- Create the actual spawnlist used by the server to write in the props etc.
		createMachineTableFromJSON = function (mainKeyID, targetFileNameJSON, ID)
			local currentHumanReadableJSON = file.Read(targetFileNameJSON, "DATA")
		
			local timerID0 = "mbd:SpawnMenuMachineFileMaker1_00"..ID
			local timerID1 = "mbd:SpawnMenuMachineFileMaker1_01"..ID
		
			-- -
			-- -- -
			-- Convert current JSON files to normal machine readable data.. ==>>
			timer.Create(timerID0, 0.03, 0, function()
				if currentHumanReadableJSON then
					timer.Remove(timerID0)
		
					-- -- -
					-- Create machine data
					local newTable = { [mainKeyID] = { parentid = "...", icon = "...", id = "...", contents = {}, name = "...", version = "..." } }
					local newPropTable = {}
					local machineReadableJSON = util.JSONToTable(currentHumanReadableJSON)
					
					timer.Create(timerID1, 0.03, 0, function()
						if machineReadableJSON then
							timer.Remove(timerID1)
		
							local i0 = 0
							local maxI0 = #table.GetKeys(newTable[mainKeyID])
							for k,v in pairs(machineReadableJSON) do
								i0 = i0 + 1 newTable[mainKeyID][k] = v
		
								if i0 >= maxI0 then
									local i1 = 0
									local maxI1 = #newTable[mainKeyID]["contents"]
		
									for k,v in pairs(newTable[mainKeyID]["contents"]) do
										i1 = i1 + 1 table.Add(newPropTable, { [k] = { type = "model", model = v } })
		
										-- - -
										-- Done 100 %
										if i1 >= maxI1 then
											-- Save
											newTable[mainKeyID]["contents"] = newPropTable
								
											-- Save 100 %
											if ID == "001" then MBDcurrJSONFile001Data = newTable
											elseif ID == "002" then MBDcurrJSONFile002Data = newTable end
										end
									end
								end
							end
						end
					end)
				end
			end)
		end
	end
	
	local TxtFileName001_inDataFolder = MBDRoot_folder_path.."/mbd-spawnlist/001-mbd-basic-props.json"
	local TxtFileName002_inDataFolder = MBDRoot_folder_path.."/mbd-spawnlist/002-mbd-builder-props.json"
	
	if SERVER then
		-- - - 
		-- Create all dirs. needed...
		if !file.Exists(MBDRoot_folder_path, "DATA") then file.CreateDir(MBDRoot_folder_path) end
		if !file.Exists(MBDRoot_folder_path.."/mbd-spawnlist", "DATA") then file.CreateDir(MBDRoot_folder_path.."/mbd-spawnlist") end
		
		----
		 -- Basic Props ( 001 )
		if !file.Exists(TxtFileName001_inDataFolder, "DATA") then
			createJSONFileFromTable(MBDTxtFileName001ID, TxtFileName001_inDataFolder, "001")
		else
			-- Write The Server Data ( that is used for Whitelist )
			createMachineTableFromJSON(MBDTxtFileName001ID, TxtFileName001_inDataFolder, "001")
		end
		----
		-- Build Props ( 002 )
		if !file.Exists(TxtFileName002_inDataFolder, "DATA") then
			createJSONFileFromTable(MBDTxtFileName002ID, TxtFileName002_inDataFolder, "002")
		else
			-- Write The Server Data ( that is used for Whitelist )
			createMachineTableFromJSON(MBDTxtFileName002ID, TxtFileName002_inDataFolder, "002")
		end
	end

	if SERVER or CLIENT then
		--- -
		--- - -
		-- Add all to whitelist table... Used for checking if allowed to spawn props; for e.g duplicates or normal spawing
		local addThisTableWithModelsToWhiteList = function(tableToAdd)
			if !MBDPropWhiteList then MBDPropWhiteList = {} end

			for _,v in pairs(tableToAdd) do
				if v and istable(v) then
					local propModel = v["model"]

					if propModel then table.insert(MBDPropWhiteList, string.lower(propModel)) end
				end
			end
		end

		local timerID0 = "mbd:spawnListCreation001"
		timer.Create(timerID0, 1, 0, function()
			if MBDcurrJSONFile001Data and MBDcurrJSONFile002Data then
				timer.Remove(timerID0)

				-- Add them to Whitelist ( server and client side )
				addThisTableWithModelsToWhiteList(MBDcurrJSONFile001Data[MBDTxtFileName001ID]["contents"])
				addThisTableWithModelsToWhiteList(MBDcurrJSONFile002Data[MBDTxtFileName002ID]["contents"])
			end
		end)

		function MBDCheckTheWhiteListTableForMatch(entModel, pl, includeEffects)
			local maxLength = #table.GetKeys(MBDPropWhiteList)
		
			for index,whiteListModel in pairs(MBDPropWhiteList) do
				if whiteListModel == string.lower(entModel) then
					if includeEffects then
						SendLocalSoundToAPlayer("prop_spawn", pl)
					end
					
					return true
				end
				if index == maxLength then
					-- This should only happen actually, if the client has modified his spawnlist table...
					if includeEffects then
						SendLocalSoundToAPlayer("prop_spawning_error", pl)

						net.Start("NotificationReceivedFromServer")
							net.WriteTable({
								Text	= "Prop is NOT whitelisted by server!",
								Type	= NOTIFY_ERROR,
								Time	= 0.85
							})
						net.Send(pl)
					end
					
					return false
				end
			end
		end
	end
end
