if engine.ActiveGamemode() == "my_base_defence" then -- Very important
    AddCSLuaFile()

    -- Important to update, to visually notify users
    MBDTextCurrentVersion = "Stable 0.0.2051"
    MBDRoot_folder_path = "my_base_defence" -- Used for custom spawn lists etc.

    if CLIENT then
        -- For Custom List Panel
        language.Add("mbdoptions.customizeList.category", "M.B.D. Lists (Admin)")
        language.Add("mbdoptions.customizeList.npcspawner", "NPC Spawner")
        language.Add("mbdoptions.customizeList.buybox", "BuyBox")

        language.Add("mbdoptions.customizeList.npcspawner.settingsPanel.AddNPCCombine", "Add to NPC Group: Combine")
		language.Add("mbdoptions.customizeList.npcspawner.settingsPanel.RemoveNPCCombine", "Remove from NPC Group: Combine")
		language.Add("mbdoptions.customizeList.npcspawner.settingsPanel.AddNPCZombie", "Add to NPC Group: Zombie")
		language.Add("mbdoptions.customizeList.npcspawner.settingsPanel.RemoveNPCZombie", "Remove from NPC Group: Zombie")
		--
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.RemoveWep", "Remove: SWEPs (not £Price)")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.AddWep", "Add: SWEPs (not £Price)")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.RemoveOther", "Remove: Other Entities (not £Price)")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.AddOther", "Add: Other Entities (not £Price)")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.RemoveAtt", "Remove: Attachments (not £Price)")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.RemoveAmmo", "Remove: Ammunition (not £Price)")

		language.Add("mbdoptions.customizeList.buybox.settingsPanel.AddStuff", "Add Entities (+£Price) (all classes):")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.RemoveWepPrice", "£Price: Remove SWEPs (all classes)")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.AddWepPrice", "£Price: Add SWEPs (all classes)")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.RemoveOtherPrice", "£Price: Remove Other Entities (all classes)")
		language.Add("mbdoptions.customizeList.buybox.settingsPanel.AddOtherPrice", "£Price: Add Other Entities (all classes)")

		-- For spawnmenu
		language.Add("mbdspawnmenu.category.defences", "M.B.D. Defences")
		language.Add("mbdspawnmenu.category.entities", "M.B.D. Entities")
        language.Add("mbdspawnmenu.category.dupes", "M.B.D. Dupes")

        -- For context menu
        language.Add("mbdcontextmenu.menubar.DisplayOptions.title", "M.B.D. Drawing")
        language.Add("mbdcontextmenu.menubar.NPCOptions.title", "M.B.D. NPC")
        --- -
        -- Build a Control Panel For M.B.D. Lists
        hook.Add("PopulateToolMenu", "mbd:CustomizeSettingsListMen001", function()
            local ListTotalWidth = 285
            local ListHeightSingleView = (ScrH() - 150) / 2
            local ListHeightTextHeader = 50

            local ListBuyBoxHeightSingleView0 = (ScrH() - 150) / 6
            local ListBuyBoxHeightTextHeader0 = 50

            local DListAttAmmoOtherTable = {}
            local DListAllowedPanels = {}
            local DListPriceRemovePanels = {}

            local GetClassFromName = function(name, stuffFullList, isNPCSpawnerView)
                for NPCKey,NPCData in pairs(stuffFullList) do
                    if isNPCSpawnerView then
                        if NPCData["Name"] == name then return NPCKey end
                    else
                        if NPCData["PrintName"] == name then return NPCKey end
                    end
                end

                return ""
            end

            local UpdateSettingsList = function(type, tableID, newTableData, col3Data, extraDataType, extraData, pricesView)
                if col3Data then col3Data = string.lower(col3Data) end
                if pricesView then
                    col3Data = col3Data or string.lower(GetConVar("mbd_customize_list_buybox_classname"):GetString())
                else
                    col3Data = col3Data or "N/A"
                end

                net.Start("mbd:update:CustomSettingsTable")
                    net.WriteTable({
                        type = type,
                        tableID = tableID,
                        newTableData = newTableData,
                        col3Data = col3Data,
                        extraDataType = extraDataType,
                        extraData = extraData
                    })
                net.SendToServer()

                SendPlayerAMessageAndSoundForCurrentAction("Custom list ( "..string.upper(type).." ) sent to server...", "sent_to_server", 3)
            end
            local UpdateTableData = function(type, tableID, willUseTheClassNameSettingAsCol3, panel, remove, col1, col2, col3, col4, extraDataType, extraData, stuffFullList, isNPCSpawnerView, pricesView, specialPriceAdderListView)
                if panel and panel:IsValid() and col1 and col2 then
                    if !extraDataType then extraDataType = false end

                    -- Find the correct line index to edit
                    local col3Data
                    local lineIndex
                    local newTableData = {}
                    for _lineIndex,lineView in pairs(panel:GetLines()) do
                        local currLineCol1 = lineView:GetColumnText(1)
                        local currLineCol2 = lineView:GetColumnText(2)
                        local currLineCol3 if col3 then currLineCol3 = lineView:GetColumnText(3) end
                        if !remove and willUseTheClassNameSettingAsCol3 then
                            col3 = string.upper(GetConVar("mbd_customize_list_buybox_classname"):GetString())
                        end
                        local currLineCol4 if col4 then currLineCol4 = lineView:GetColumnText(4) end

                        if pricesView then
                            if col1 == currLineCol1 then
                                if !col3 then col3 = col2 end

                                if col3 then
                                    if string.upper(currLineCol3) == string.upper(col3) then
                                        if col4 then
                                            if string.upper(currLineCol4) == string.upper(col4) then
                                                col3Data = currLineCol3
                                                lineIndex = _lineIndex break
                                            end
                                        else
                                            col3Data = currLineCol3
                                            lineIndex = _lineIndex break
                                        end
                                    end
                                else lineIndex = _lineIndex break end
                            end
                        else
                            if col1 == currLineCol1 and col2 == currLineCol2 then
                                if col3 then
                                    if string.upper(currLineCol3) == string.upper(col3) then
                                        col3Data = currLineCol3
                                        lineIndex = _lineIndex break
                                    end
                                else lineIndex = _lineIndex break end
                            end
                        end
                    end

                    timer.Simple(0.3, function()
                        if panel and panel:IsValid() then
                            if remove then
                                -- Remove
                                if lineIndex and panel:GetLine(lineIndex) then
                                    panel:RemoveLine(lineIndex)

                                    local findPriceLineThatMatchesClass = function(_panel)
                                        local className = col2

                                        local priceLineIndex
                                        for _lineIndex,lineView in pairs(_panel:GetLines()) do
                                            local currLineCol1 = lineView:GetColumnText(1)
                                            local currLineCol2 = lineView:GetColumnText(2)
                                            local currLineCol3 = lineView:GetColumnText(3)

                                            if currLineCol1 == col1 then
                                                if currLineCol3 == className then
                                                    priceLineIndex = _lineIndex break
                                                end
                                            end
                                        end

                                        return priceLineIndex
                                    end
                                    local maybeRemoveFromPricesList = function(_table, _panel)
                                        local tableToCheck = {}
                                        table.Add(tableToCheck, _table["engineer"])
                                        table.Add(tableToCheck, _table["mechanic"])
                                        table.Add(tableToCheck, _table["medic"])
                                        table.Add(tableToCheck, _table["terminator"])

                                        local className = string.upper(col2)
                                        local amountOfMatches = 0
                                        for k,v in pairs(tableToCheck) do
                                            if string.upper(v) == className then amountOfMatches = amountOfMatches + 1 end
                                            if amountOfMatches > 1 then return end
                                        end

                                        -- Remove from DList Panel, since it needs to be in the allowed list to show up in Price list... (the price will still be there)
                                        local priceLineIndexToRemove = findPriceLineThatMatchesClass(_panel)
                                        _panel:RemoveLine(priceLineIndexToRemove)

                                        SendPlayerAMessageAndSoundForCurrentAction("Removed \""..col1.."\" from £Price list also (no one has it as allowed).", "remove", 6)
                                    end

                                    -- Check if the Remove panel (£Price) needs to be updated aswell... If no classes has the ent.
                                    -- in their allowed list
                                    if tableID == "MBDCompleteBuyBoxList_AllowedWeapons" then
                                        -- Weapons
                                        maybeRemoveFromPricesList(MBDCompleteBuyBoxList_AllowedWeapons, DListPriceRemovePanels[1])
                                    elseif tableID == "MBDCompleteBuyBoxList_AllowedOther" then
                                        -- Other Entities
                                        maybeRemoveFromPricesList(MBDCompleteBuyBoxList_AllowedOther, DListPriceRemovePanels[2])
                                    end

                                    SendPlayerAMessageAndSoundForCurrentAction("Removed \""..col1.."\" from list.", "remove", 6)
                                else MsgC(Color(255, 0, 0), "M.B.D.: Could not remove line... It was nil. Ref.: \""..col1.."\" & \""..col2.."\"\n") return end
                            else
                                -- Add ( currently no logic for col4 here )
                                if !lineIndex then
                                    col3Data = string.upper(GetConVar("mbd_customize_list_buybox_classname"):GetString())
                                    if willUseTheClassNameSettingAsCol3 then col3 = col3Data end

                                    if extraDataType and ( pricesView or specialPriceAdderListView ) then
                                        if pricesView or specialPriceAdderListView then
                                            col3 = col2

                                             -- Don't add not allowed stuff...
                                            local temp_completeAllowedListAll = {}
                                            local completeAllowedListAll = {}
                                            if pricesView then
                                                table.Add(temp_completeAllowedListAll, DListAllowedPanels[1]:GetLines())
                                                table.Add(temp_completeAllowedListAll, DListAllowedPanels[2]:GetLines())
                                                table.foreach(temp_completeAllowedListAll, function(k,v)
                                                    table.insert(completeAllowedListAll, v:GetColumnText(2))
                                                end)
                                            end

                                            if pricesView and !table.HasValue(completeAllowedListAll, col3) then
                                                SendPlayerAMessageAndSoundForCurrentAction("Add \""..col1.."\" to allowed SWEPs first.", "error", 6)
                                                return
                                            else
                                                -- Delete the old maybe ( overwrite )
                                                table.foreach(panel:GetLines(), function(k,v)
                                                    local _col1 = v:GetColumnText(1)
                                                    local _col2 = v:GetColumnText(2)
                                                    local _col3 = v:GetColumnText(3)

                                                    if _col1 == col1 and _col3 == col3 then
                                                        panel:RemoveLine(k)

                                                        -- Overwrite if needed (delete the old one)...
                                                        SendPlayerAMessageAndSoundForCurrentAction("Overwriting £Price for \""..col1.."\".", nil, 6)
                                                    end
                                                end)
                                            end
                                        end

                                        if col3 then
                                            local _col2 = extraData
                                            local _col3 = col3
                                            if specialPriceAdderListView then
                                                _col2 = GetConVar("mbd_customize_list_buybox_price_2"):GetInt()
                                                _col3 = col2
                                            end

                                            panel:AddLine(col1, _col2, _col3)
                                        else
                                            panel:AddLine(col1, extraData)
                                        end
                                    else
                                        if col3 then panel:AddLine(col1, col2, col3)
                                        else panel:AddLine(col1, col2) end
                                    end
                                    SendPlayerAMessageAndSoundForCurrentAction("Added \""..col1.."\" to a list.", "added", 3)
                                else
                                    -- Already exists
                                    surface.PlaySound("game/buildpoints_collected.wav")

                                    return
                                end
                            end

                            -- Create the new table from the new list, and send to the server ( the DList was editied above )
                            local CreateTheNewTabelForTheCustomListAndSend = function()
                                for _lineIndex,lineView in pairs(panel:GetLines()) do
                                    local currLineCol1 = lineView:GetColumnText(1)
                                    local currLineCol2 = lineView:GetColumnText(2)
                                    local currLineCol3 if col3 then currLineCol3 = lineView:GetColumnText(3) end

                                    local priceAdd = function() newTableData[currLineCol3] = tonumber(currLineCol2) end
                                    local normalAdd = function(checkClassNameMatch)
                                        if checkClassNameMatch then
                                            if !remove then
                                                if string.upper(currLineCol3) != string.upper(GetConVar("mbd_customize_list_buybox_classname"):GetString()) then return end
                                            else
                                                if string.upper(currLineCol3) != string.upper(col3) then return end
                                            end
                                        end

                                        if extraDataType then newTableData[GetClassFromName(currLineCol1, stuffFullList, isNPCSpawnerView)] = extraData or false
                                        else newTableData[currLineCol2] = extraData or false end
                                    end

                                    if currLineCol3 then if pricesView or specialPriceAdderListView then priceAdd() else normalAdd(true) end else normalAdd() end
                                end

                                local timerID001 = "mbd:UpdateAList001" timer.Remove(timerID001)
                                timer.Create(timerID001, 2, 1, function()
                                    UpdateSettingsList(type, tableID, newTableData, col3Data, extraDataType, extraData, pricesView)
                                end)
                            end timer.Simple(0.3, CreateTheNewTabelForTheCustomListAndSend)
                        end
                    end)
                end
            end
            local MakeListView = function(simpleList, tableID, willUseTheClassNameSettingAsCol3, isNPCSpawnerView, extraDataType, DListRemoveList, primFunctionString, specialPricesView, willHave4Cols, pos, extraY, cpanel, col1, col2, col3, col4, needsThreeColsClassName, type, customRawTable, NiceNameField, stuffFullList, pricesView, specialPriceAdderListView)
                local _DListView = vgui.Create("DListView", cpanel)

                _DListView:SetPos(3, ListHeightSingleView * pos + ListHeightTextHeader + extraY)
                _DListView:SetSize(ListTotalWidth, ListHeightSingleView - ListHeightTextHeader + 20)

                _DListView:SetMultiSelect(true)
                _DListView:AddColumn(col1)
                _DListView:AddColumn(col2)
                if primFunctionString == "remove" and needsThreeColsClassName then _DListView:AddColumn(col3) end
                if specialPricesView and willHave4Cols then _DListView:AddColumn(col4) end

                if primFunctionString == "add" then
                    _DListView.OnRowSelected = function(panel, lineIndex, line)
                        if LocalPlayer():MBDIsNotAnAdmin(false) then return end

                        local colText_col1 = line:GetColumnText(1)
                        local colText_col2 = line:GetColumnText(2)
                        local colText_col3 if needsThreeColsClassName then colText_col3 = line:GetColumnText(3) end
                        local colText_col4 if specialPricesView and willHave4Cols then
                            line:GetColumnText(4)
                        end

                        local extraData = nil if extraDataType then
                            if pricesView then extraData = GetConVar("mbd_customize_list_buybox_price_1"):GetInt()
                            else extraData = GetConVar("mbd_customize_list_buybox_entType"):GetString() end
                        end

                        -- Find the right DList, if att./ammo/other
                        if extraData then
                            if extraData == "Attachments" then DListRemoveList = DListAttAmmoOtherTable[1]
                            elseif extraData == "Ammunition" then DListRemoveList = DListAttAmmoOtherTable[2]
                            elseif extraData == "Other" then DListRemoveList = DListAttAmmoOtherTable[3] end
                        end

                        -- Add to View & JSON file
                        if DListRemoveList and DListRemoveList:IsValid() and not table.HasValue(DListRemoveList:GetLines(), colText_col1)then
                            UpdateTableData(type, tableID, willUseTheClassNameSettingAsCol3, DListRemoveList, false, colText_col1, colText_col2, colText_col3, colText_col4, extraDataType, extraData, stuffFullList, isNPCSpawnerView, pricesView, specialPriceAdderListView)
                        else MsgC(Color(255, 0, 0), "M.B.D.: \"DListRemoveList\" was nil... Could not remove line. Ref.: \""..colText_col1.."\" & \""..colText_col2.."\"\n") end
                    end
                elseif primFunctionString == "remove" then
                    _DListView.OnRowSelected = function(panel, lineIndex, line)
                        if LocalPlayer():MBDIsNotAnAdmin(false) then return end

                        local colText_col1 = line:GetColumnText(1)
                        local colText_col2 = line:GetColumnText(2)
                        local colText_col3 if needsThreeColsClassName then colText_col3 = line:GetColumnText(3) end
                        local colText_col4 if specialPricesView and willHave4Cols then
                            line:GetColumnText(4)
                        end

                        local extraData = nil if extraDataType then
                            if pricesView then extraData = tonumber(colText_col2) else extraData = "N/A" end
                        end

                        -- Remove from View & JSON file
                        if not table.HasValue(_DListView:GetLines(), colText_col1) then
                            UpdateTableData(type, tableID, willUseTheClassNameSettingAsCol3, _DListView, true, colText_col1, colText_col2, colText_col3, colText_col4, extraDataType, extraData, stuffFullList, isNPCSpawnerView, pricesView, specialPriceAdderListView)
                        end
                    end
                end

                return _DListView
            end
            local AddATitle = function(title, pos, extraY, cpanel, primFunctionString)
                local _DLable = vgui.Create("DLabel", cpanel)

                _DLable:SetColor(Color(0, 113, 229))
                if primFunctionString == "remove" then _DLable:SetColor(Color(229, 60, 0)) end
                _DLable:SetPos(3, ListHeightSingleView * pos + 10 + extraY)
                _DLable:SetSize(ListTotalWidth, ListHeightTextHeader)
                
                _DLable:SetFont("quickMenuButtons2")
                _DLable:SetText(title)

                return _DLable
            end

            local getAPhrase = function(type, id)
                return language.GetPhrase("mbdoptions.customizeList."..type..".settingsPanel."..id)
            end

            local makeAllowedField = function(cpanel, needsThreeColsClassName, tableID, willUseTheClassNameSettingAsCol3, specialPricesView, specialPriceAdderListView, willHave4Cols, isNPCSpawnerView, extraDataType, allowedTable, simpleList, removeTitle, addTitle, startPos, extraY, extraTitleY, stuffFullList, NiceNameFieldMain, ClassNameFieldMain, NiceNameField, pricesView, pricesTable)
                -- "NiceNameField" is only used for scriped entites field, and i usally always "t". But now we use "list.Get("SpawnableEntities")" instead
                -- Remove Stuff ( from current settings list )
                local addedNPCList = false -- Remove
                local allNPCList = false -- Add

                local type = "buybox"
                if isNPCSpawnerView then type = "npcspawner" end
                if removeTitle then
                    local name2 = "Class Name"
                    local name3 = "Ply. Class"
                    local name4

                    if isNPCSpawnerView then name2 = "NPC Key" end
                    if pricesView then
                        if specialPricesView then if willHave4Cols then name4 = name3 end end
                        name3 = name2
                        name2 = "Price (£B.D.)"
                    end

                    addedNPCList = MakeListView(simpleList, tableID, willUseTheClassNameSettingAsCol3, isNPCSpawnerView, extraDataType, nil, "remove", specialPricesView, willHave4Cols, 0 + startPos, extraY, cpanel, "Name", name2, name3, name4, needsThreeColsClassName, type, allowedTable, NiceNameField, stuffFullList, pricesView, specialPriceAdderListView)
                    local addedNPCLabel = AddATitle(removeTitle, 0 + startPos, extraY + extraTitleY, cpanel, "remove")
                    -- Get and Show
                    if simpleList then
                        for col3Data,className in pairs(allowedTable) do
                            if stuffFullList and stuffFullList[className] then
                                local field0 = stuffFullList[className][NiceNameFieldMain]
                                local field2 = string.upper(col3Data)
                                local field3 = field2
                                if ClassNameFieldMain then
                                    if pricesView then
                                        field2 = stuffFullList[className][ClassNameFieldMain]
                                    end
                                end
                                if NiceNameField then
                                    field0 = stuffFullList[className][NiceNameField][NiceNameFieldMain]
                                    if ClassNameFieldMain then
                                        if pricesView then
                                            field2 = stuffFullList[className][NiceNameField][ClassNameFieldMain]
                                        end
                                    end
                                end
                                local field1 = className
                                if specialPricesView and willHave4Cols then field2 = field1 end
                                if pricesView then field1 = pricesTable[className] end

                                if needsThreeColsClassName then
                                    if specialPricesView and willHave4Cols then
                                        addedNPCList:AddLine(field0, field1, field2, field3)
                                    else
                                        addedNPCList:AddLine(field0, field1, field2)
                                    end
                                else
                                    addedNPCList:AddLine(field0, field1)
                                end
                            end
                        end
                    else
                        for col3Data,classData in pairs(allowedTable) do
                            for _,stuffClass in pairs(classData) do
                                if stuffFullList and stuffFullList[stuffClass] then
                                    local field0 = stuffFullList[stuffClass][NiceNameFieldMain]
                                    local field2 = string.upper(col3Data)
                                    local field3 = field2
                                    if ClassNameFieldMain then
                                        if pricesView then
                                            field2 = stuffFullList[stuffClass][ClassNameFieldMain]
                                        end
                                    end
                                    if NiceNameField then
                                        field0 = stuffFullList[stuffClass][NiceNameField][NiceNameFieldMain]
                                        if ClassNameFieldMain then
                                            if pricesView then
                                                field2 = stuffFullList[stuffClass][NiceNameField][ClassNameFieldMain]
                                            end
                                        end
                                    end
                                    local field1 = stuffClass
                                    if specialPricesView and willHave4Cols then field2 = field1 end
                                    if pricesView then field1 = pricesTable[stuffClass] end

                                    if needsThreeColsClassName then
                                        if specialPricesView and willHave4Cols then
                                            addedNPCList:AddLine(field0, field1, field2, field3)
                                        else
                                            addedNPCList:AddLine(field0, field1, field2)
                                        end
                                    else
                                        addedNPCList:AddLine(field0, field1)
                                    end
                                end
                            end
                        end
                    end

                    addedNPCLabel:MoveToFront()
                end

                --- -
                -- Add Stuff ( all available )
                if addTitle then
                    local name2 = "Class Name"
                    local name3 = "Ply. Class"
                    if isNPCSpawnerView then name2 = "NPC Key" end
                    if pricesView then name3 = name2 end
                    allNPCList = MakeListView(simpleList, tableID, willUseTheClassNameSettingAsCol3, isNPCSpawnerView, extraDataType, addedNPCList, "add", specialPricesView, willHave4Cols, 1 + startPos, extraY, cpanel, "Name", name2, name3, name4, needsThreeColsClassName, type, allowedTable, NiceNameField, stuffFullList, pricesView, specialPriceAdderListView)
                    local allNPCLabel = AddATitle(addTitle, 1 + startPos, extraY + extraTitleY, cpanel, "add")

                    -- Get All Available Stuff on Server
                    if not ClassNameFieldMain then
                        for StuffKey,StuffData in SortedPairs(stuffFullList) do
                            local field0 = StuffData[NiceNameFieldMain]
                            local field1 = StuffKey
                            if NiceNameField then
                                field0 = StuffData[NiceNameField][NiceNameFieldMain]
                                field1 = StuffData[NiceNameField]
                            end
                            allNPCList:AddLine(field0, field1)
                        end
                    else
                        for StuffKey,StuffData in SortedPairs(stuffFullList) do
                            local field0 = StuffData[NiceNameFieldMain]
                            local field1 = StuffData
                            if NiceNameField then
                                field0 = StuffData[NiceNameField][NiceNameFieldMain]
                                field1 = StuffData[NiceNameField]
                            end
                            if ClassNameFieldMain then field1 = field1[ClassNameFieldMain] end
                            allNPCList:AddLine(field0, field1)
                        end
                    end

                    allNPCLabel:MoveToFront()
                end

                return { addedNPCList, allNPCList }
            end

            --- -
            -- NPC Spawner
            spawnmenu.AddToolMenuOption("Options", "#mbdoptions.customizeList.category", "mbd_customize_list_npcspawner", "#mbdoptions.customizeList.npcspawner", "", "", function(cpanel)
                -- NPCs ( Combine )
                if allowedCombines and MBDCompleteCurrNPCList then makeAllowedField(cpanel, false, "allowedCombines", false, false, false, false, true, false, allowedCombines, true, getAPhrase("npcspawner", "RemoveNPCCombine"), getAPhrase("npcspawner", "AddNPCCombine"), 0, 0, 0, MBDCompleteCurrNPCList, "Name") end
                -- NPCs ( Zombie )
                if allowedZombies and MBDCompleteCurrNPCList then makeAllowedField(cpanel, false, "allowedZombies", false, false, false, false, true, false, allowedZombies, true, getAPhrase("npcspawner", "RemoveNPCZombie"), getAPhrase("npcspawner", "AddNPCZombie"), 2, 0, 0, MBDCompleteCurrNPCList, "Name") end

                local signature = vgui.Create("DForm", cpanel)
                signature:SetLabel("License")
                signature:SetPos(3, ListHeightSingleView * 4 + 25)
                signature:SetSize(ListTotalWidth, ListHeightTextHeader)
                signature:ControlHelp("ravo Norway (2020) - All rights reserved")
                signature:Toggle()
            end)
            -- --
            -- BuyBox
            spawnmenu.AddToolMenuOption("Options", "#mbdoptions.customizeList.category", "mbd_customize_list_buybox", "#mbdoptions.customizeList.buybox", "", "", function(cpanel)
                local StuffListWep = list.Get("Weapon")
                local StuffListOther = list.Get("SpawnableEntities")

                timer.Simple(0.15, function()
                    local newStuffListFilteredWep = {}
                    local newStuffListFilteredOther = {}
                    for dataKey,dataTable in SortedPairs(StuffListWep) do
                        if (
                            dataTable.ClassName
                            and not string.match(string.lower(dataTable.ClassName), "_base")
                            and not string.match(string.lower(dataTable.ClassName), "gmod_")
                        ) then
                            newStuffListFilteredWep[dataKey] = dataTable
                        end
                    end
                    for dataKey,dataTable in SortedPairs(StuffListOther) do
                        newStuffListFilteredOther[dataKey] = dataTable
                    end

                    timer.Simple(0.15, function()
                        StuffListWep = newStuffListFilteredWep
                        StuffListOther = newStuffListFilteredOther

                        -- ADD!
                        local size0 = 30
                        local extraY0 = size0 + 10
                        local DComboBoxClassName = vgui.Create("DComboBox", cpanel)
                        DComboBoxClassName:SetPos(3, size0)
                        DComboBoxClassName:SetSize(ListTotalWidth, size0)
                        DComboBoxClassName:SetValue(GetConVar("mbd_customize_list_buybox_classname"):GetString())
                        DComboBoxClassName:AddChoice("Engineer")
                        DComboBoxClassName:AddChoice("Mechanic")
                        DComboBoxClassName:AddChoice("Medic")
                        DComboBoxClassName:AddChoice("Terminator")
                        DComboBoxClassName.OnSelect = function(self, index, value)
                            GetConVar("mbd_customize_list_buybox_classname"):SetString(value)
                        end

                        -- Prices
                        -- Option for price when ADDING ( field )
                        local DermaNumSlider = vgui.Create("DNumSlider", cpanel)
                        DermaNumSlider:SetPos(3, ListHeightSingleView * 0 + ListHeightTextHeader + extraY0 / 4 - 3)
                        DermaNumSlider:SetSize(ListTotalWidth, size0)
                        DermaNumSlider:SetText("Add-er £Price (ID #1)")
                        DermaNumSlider:SetMin(0)
                        DermaNumSlider:SetMax(10000)
                        DermaNumSlider:SetDecimals(0)
                        DermaNumSlider:SetConVar("mbd_customize_list_buybox_price_1")
                        extraY0 = extraY0 / 2 + size0 + 10

                        -- Weapons
                        if MBDCompleteBuyBoxList_AllowedWeapons then
                            DListAllowedPanels[1] = makeAllowedField(cpanel, true, "MBDCompleteBuyBoxList_AllowedWeapons", true, false, false, false, false, false, MBDCompleteBuyBoxList_AllowedWeapons, false, getAPhrase("buybox", "RemoveWep"), getAPhrase("buybox", "AddWep"), 0, extraY0, 0, StuffListWep, "PrintName", "ClassName")[1]
                        end
                        if MBDCompleteBuyBoxList_PricesWepCustom and MBDCompleteBuyBoxList_AllPricesCombined then
                            DListPriceRemovePanels[1] = makeAllowedField(cpanel, true, "MBDCompleteBuyBoxList_PricesWepCustom", false, false, false, false, false, true, MBDCompleteBuyBoxList_PricesWepCustom, true, getAPhrase("buybox", "RemoveWepPrice"), getAPhrase("buybox", "AddWepPrice"), 2, extraY0, 0, StuffListWep, "PrintName", "ClassName", nil, true, MBDCompleteBuyBoxList_AllPricesCombined)[1]
                       end
                       -- Other Entities
                       local otherTableEntities = StuffListOther
                       table.Merge(otherTableEntities, StuffListWep)

                        if MBDCompleteBuyBoxList_AllowedOther then
                            DListAllowedPanels[2] = makeAllowedField(cpanel, true, "MBDCompleteBuyBoxList_AllowedOther", true, false, false, false, false, false, MBDCompleteBuyBoxList_AllowedOther, false, getAPhrase("buybox", "RemoveOther"), getAPhrase("buybox", "AddOther"), 4, extraY0, 0, otherTableEntities, "PrintName", "ClassName")[1]
                        end
                        if MBDCompleteBuyBoxList_PricesOther and MBDCompleteBuyBoxList_AllPricesCombined then
                            DListPriceRemovePanels[2] = makeAllowedField(cpanel, true, "MBDCompleteBuyBoxList_PricesOther", false, false, false, false, false, true, MBDCompleteBuyBoxList_PricesOther, true, getAPhrase("buybox", "RemoveOtherPrice"), getAPhrase("buybox", "AddOtherPrice"), 6, extraY0, 0, otherTableEntities, "PrintName", "ClassName", nil, true, MBDCompleteBuyBoxList_AllPricesCombined)[1]
                        end

                        -- Att. & Ammo
                        extraY0 = extraY0 + 10
                        if MBDCompleteBuyBoxList_AllowedAttachments then
                            DListAttAmmoOtherTable[1] = makeAllowedField(cpanel, true, "MBDCompleteBuyBoxList_AllowedAttachments", false, true, false, false, false, false, MBDCompleteBuyBoxList_AllowedAttachments, true, getAPhrase("buybox", "RemoveAtt"), nil, 8, extraY0, 0, StuffListOther, "PrintName", "ClassName", nil, true, MBDCompleteBuyBoxList_AllPricesCombined)[1]
                        end
                        if MBDCompleteBuyBoxList_AllowedAmmo then
                            DListAttAmmoOtherTable[2] = makeAllowedField(cpanel, true, "MBDCompleteBuyBoxList_AllowedAmmo", false, true, false, false, false, false, MBDCompleteBuyBoxList_AllowedAmmo, true, getAPhrase("buybox", "RemoveAmmo"), nil, 9, extraY0, 0, StuffListOther, "PrintName", "ClassName", nil, true, MBDCompleteBuyBoxList_AllPricesCombined)[1]
                        end

                        -- ADDer Dropdown to choose which field... (att., ammo or other)
                        local DComboBoxType = vgui.Create("DComboBox", cpanel)
                        DComboBoxType:SetPos(3, ListHeightSingleView * 10 + ListHeightTextHeader + extraY0)
                        DComboBoxType:SetSize(ListTotalWidth, size0)
                        DComboBoxType:SetValue(GetConVar("mbd_customize_list_buybox_entType"):GetString())
                        DComboBoxType:AddChoice("Attachments")
                        DComboBoxType:AddChoice("Ammunition")
                        -- DComboBoxType:AddChoice("Other")
                        DComboBoxType.OnSelect = function(self, index, value)
                            GetConVar("mbd_customize_list_buybox_entType"):SetString(value)
                        end
                        -- Prices
                        -- Option for price when ADDING ( field )
                        local DermaNumSlider2 = vgui.Create("DNumSlider", cpanel)
                        DermaNumSlider2:SetPos(3, ListHeightSingleView * 10 + ListHeightTextHeader + extraY0 + size0)
                        DermaNumSlider2:SetSize(ListTotalWidth, size0)
                        DermaNumSlider2:SetText("Add-er £Price (ID #2)")
                        DermaNumSlider2:SetMin(0)
                        DermaNumSlider2:SetMax(10000)
                        DermaNumSlider2:SetDecimals(0)
                        DermaNumSlider2:SetConVar("mbd_customize_list_buybox_price_2")
                        extraY0 = extraY0 + size0 * 3
                        if MBDCompleteBuyBoxList_AllowedOther then
                             makeAllowedField(cpanel, false, "MBDCompleteBuyBoxList_AllowedStuff", true, false, true, false, false, true, MBDCompleteBuyBoxList_AllowedOther, false, nil, getAPhrase("buybox", "AddStuff"), 9, extraY0, (size0 / 2 - 15) * -1, StuffListOther, "PrintName", "ClassName")
                        end

                        local signature = vgui.Create("DForm", cpanel)
                        signature:SetLabel("License")
                        signature:SetPos(3, ListHeightSingleView * 11 + ListHeightTextHeader + extraY0 - size0 + 3)
                        signature:SetSize(ListTotalWidth, ListHeightTextHeader)
                        signature:ControlHelp("ravo Norway (2020) - All rights reserved")
                        signature:Toggle()

                        DComboBoxClassName:MoveToFront()
                        DComboBoxType:MoveToFront()
                        DermaNumSlider:MoveToFront()
                        DermaNumSlider2:MoveToFront()
                    end)
                end)
            end)
        end)
    end
    
    local strictSetting = 1
	if GetConVar("mbd_enableStrictMode"):GetInt() then
		strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
    end

    -- NET.Receive
    if CLIENT then
        --- - --- -
        -- Get nice weapon names
        function mbd_bo3_ravo_getNiceWeaponNames()
            __NAME_Weapons = {}

            for _,WepData in pairs(list.Get("Weapon")) do
                if (
                    WepData.ClassName and
                    WepData.PrintName and
                    WepData.Category
                ) then
                    __NAME_Weapons[string.lower(WepData.ClassName)] = WepData.PrintName.." ("..WepData.Category..")"
                elseif (
                    WepData.ClassName and
                    WepData.PrintName
                ) then
                    __NAME_Weapons[string.lower(WepData.ClassName)] = WepData.PrintName
                end
            end
        end
        net.Receive("Entity_EmitLocalSoundEmitter", function()
            local _Table = net.ReadTable()
            
            local EntitySoundEmitter = LocalPlayer()

            local _Volume               = _Table.Volume
            local _SoundEntity          = _Table.SoundEnt
            local VirtualParentPlayer   = LocalPlayer()
            if (
                _SoundEntity and
                _SoundEntity:IsValid() and
                VirtualParentPlayer and
                VirtualParentPlayer:IsValid()
            ) then
                -- Set Volume Based On Distance (Z-pos) (algorithm)
                --
                local VirtualParentPlayerPos 	= VirtualParentPlayer:GetPos()
                local _SoundEntityPos 			= _SoundEntity:GetPos()

                -- Get
                local _Dist         = VirtualParentPlayerPos:Distance(_SoundEntityPos)
                local _DistMeter 	= (_Dist / (33 * 2)) -- Looks to be about correct..

                -- Set

                -- Above 3 "meters", then start dropping Volume 0.24 every 2 meter >>
                if _DistMeter > 3 then
                    local _Percent = ((_DistMeter - 3) / 2) -- The Difference

                    _Percent = (_Percent * 0.24)
                    if _Percent < 10 then _Volume = (_Volume - (_Percent / 10)) else _Volume = 0 end
                end

                _Volume = math.Round(_Volume, 2)

                if _Volume <= 0 then return end
            end

            if not EntitySoundEmitter or not EntitySoundEmitter:IsValid() then print("Failed to get the Sound Emitter Entity...") return end

            -- Player sound ! >>
            local _Pitch = 100
            if _Table.Pitch then
                _Pitch = string.Split(_Table.Pitch, ",")

                local _PitchValue   = nil 
                local _PitchTable   = {}
                if not tonumber(_Pitch[1]) then _Pitch[1] = 100 end
                if not tonumber(_Pitch[2]) then _Pitch[2] = 100 end
                
                for i=_Pitch[1],_Pitch[2] do
                    --
                    table.insert(_PitchTable, i)
                end
                _PitchValue = _PitchTable[math.random(1, #_PitchTable)] -- The Pitch level
            end

            EntitySoundEmitter:EmitSound(
                _Table.Sound,
                100,             -- DB; You can lower or increase this (but it might break the balance)
                _PitchValue,     -- Default Pitch is 100
                _Volume,
                CHAN_AUTO
            )

            -- For testing:
            -- print("Playing Sound:", _Table.Sound, "Volume:", _Volume, "Sound Entity:", _SoundEntity)
        end)

        function SendPlayerAMessageAndSoundForCurrentAction(notificationText, type, time)
            local notifyType = NOTIFY_GENERIC

            -- Play Sound & Set other stuff needed
            if type then
                if type == "error" then
                    surface.PlaySound("game/prop_spawn_error.wav")
                    notifyType = NOTIFY_ERROR
                elseif type == "sent_to_server" then
                    surface.PlaySound("game/mbd_clean_up_everything.wav")
                elseif type == "added" then
                    notifyType = NOTIFY_HINT
                    surface.PlaySound("game/lobby_menu_class_pick.wav")
                elseif type == "remove" then
                    notifyType = NOTIFY_HINT
                    surface.PlaySound("game/lobby_menu_class_pick_minus.wav")
                end
            end

            notification.AddLegacy(notificationText, notifyType, time)
        end
    end

    if SERVER then
		-- CONFIGURE HOOKS IN STRICT MODE! Only allow these ( Maybe better performance, if user has a sh*t ton of addons mounted )
        if strictSetting == 1 then
            timer.Simple(3, function()
                MsgC(Color(255, 213, 0), "M.B.D. Hook Removal: In STRICT MODE, will remove uneeded hooks for better performance...\n")

                local exludeTheseHooksNamesTable = {
                    "OnViewModelChanged"
                }
                local allowTheseHooksAndIDsTable = {
                    AllowPlayerPickup = {
                        "MBD_FAS2_AllowPlayerPickup"
                    },
                    EntityNetworkedVarChanged = {
                        "NetworkedVars"
                    },
                    EntityRemoved = {
                        "Constraint Library - ConstraintRemoved",
                        "mbd:EntityRemoved001",
                        "DoDieFunction",
                        "nocollide_fix",
                        "ULibEntRemovedCheck"
                    },
                    EntityTakeDamage = {
                        "MBD_FAS2_EntityTakeDamage",
                        "mbd:EntDamage001",
                        "ULibEntDamagedCheck"
                    },
                    GetFallDamage = {
                        "mbd:GetFallDamage001"
                    },
                    InitPostEntity = {
                        "PersistenceInit"
                    },
                    Initialize = {
                        "mbd:Initialize001",
                        "mbd:Initialize002",
                        "mbd:Initialize019",
                        "ULibLoadBans",
                        "UTeamInitialize",
                        "ULXDoCfg",
                        "XGUI_InitServer",
                        "ULibPluginUpdateChecker",
                        "ULXInitialize",
                        "finitialize_"
                    },
                    KeyPress = {
                        "mbd:KeyPress001"
                    },
                    KeyRelease = {
                        "mbd:KeyRelease001"
                    },
                    LoadGModSave = {
                        "LoadGModSave"
                    },
                    Move = {
                        "MBD_FAS2_Move",
                        "mbd:OnMove001"
                    },
                    OnEntityCreated = {
                        "mbd:OnEntityCreated001",
                        "mbd:OnEntityCreatedShared001",
                        "map_sethelinpcnode"
                    },
                    OnNPCKilled = {
                        "mbd:OnNPCKilled001"
                    },
                    OnPhysgunFreeze = {
                        "mbd:PhysgunOnFreezeLadder001"
                    },
                    PersistenceLoad = {
                        "PersistenceLoad"
                    },
                    PersistenceSave = {
                        "PersistenceSave"
                    },
                    PhysgunDrop = {
                        "mbd:PhysgunPickup001",
                        "ulxPlayerDropJailCheck",
                        "ulxPlayerDrop"
                    },
                    PhysgunPickup = {
                        "bo3Ravo:DisableTakingTheWeaponInTheMysteryBox",
                        "bo3Ravo:PhysgunPickupMysteryBoxRavo001",
                        "mbd:DisableTakingTheWeaponInTheMysteryBox",
                        "mbd:PhysgunPickup001",
                        "mbd:PhysgunPickupLadder001",
                        "mbd:PhysgunPickupMysteryBoxRavo001",
                        "ULibEntPhysCheck",
                        "ulxPlayerPickupJailCheck",
                        "ulxPlayerPickup"
                    },
                    PlayerButtonDown = {
                        "mbd:PlayerButtonDown001"
                    },
                    PlayerCanPickupWeapon = {
                        "SCKPickup"
                    },
                    PlayerDeath = {
                        "mbd:PlayerDeath001",
                        "ULXCheckFireDeath",
                        "ULXCheckMaulDeath",
                        "ULXLogDeath",
                        "ULXCheckDeath"
                    },
                    PlayerDisconnected = {
                        "mbd:PlayerDisconnected001",
                        "xgui_ply_disconnect",
                        "ULXMaulDisconnectedCheck",
                        "ULXLogDisconnect",
                        "ulxSlotsDisconnect",
                        "ULXVoteDisconnect",
                        "ULibUCLDisconnect",
                        "ULXJailDisconnectedCheck",
                        "ULXRagdollDisconnectedCheck"
                    },
                    PlayerInitialSpawn = {
                        "PlayerAuthSpawn",
                        "bo3ravo_MysteryBox_PlayerInitialSpawn001",
                        "mbd_MysteryBox_PlayerInitialSpawn001",
                        "mbd:PlayerInitialSpawn001",
                        "ULXLogInitialSpawn",
                        "ULibSendAuthToClients",
                        "UTeamInitialSpawn",
                        "ULXWelcome",
                        "showMotd",
                        "sendAutoCompletes",
                        "ULibSendRegisteredPlugins",
                        "ULXDoCfg"
                    },
                    PlayerNoClip = {
                        "DisableNoclip",
                        "mbd:GetFallDamage001",
                        "ULibNoclipCheck"
                    },
                    PlayerSpawn = {
                        "MBD_FAS2_PlayerSpawn",
                        "mbd:PlayerSpawn001",
                        "UTeamSpawnAuth",
                        "ULXRagdollSpawnCheck"
                    },
                    PlayerTick = {
                        "TickWidgets"
                    },
                    PostDrawEffects = {
                        "RenderWidgets"
                    },
                    ScaleNPCDamage = {
                        "mbd:ScaleNPCDamage001"
                    },
                    SetupMove = {
                        "mbd:SetupMove001"
                    },
                    ShutDown = {
                        "SavePersistenceOnShutdown",
                        "ULXLogShutDown"
                    },
                    VehicleMove = {
                        "mbd:PlayerTick001"
                    }
                }
                local amountOfHooksRemoved = 0
                for hookName, hookIDTable in pairs(hook.GetTable()) do
                
                    if not table.HasValue(exludeTheseHooksNamesTable, hookName) then
                        for hookID, _ in pairs(hookIDTable) do
                
                            for hookAllowedName, hookAllowedIDTable in pairs(allowTheseHooksAndIDsTable) do
                
                                if hookName == hookAllowedName then -- All possible hook names should have been added...
                                    
                                    -- Remove those hooks who are not in the allowed table
                                    if not table.HasValue(hookAllowedIDTable, hookID) then
                                        hook.Remove(hookName, hookID)

                                        MsgC(Color(255, 85, 0), "...M.B.D. Hook Removal: ("..amountOfHooksRemoved..") Removed hook ("..hookName..") \""..hookID.."\".\n")
                                        amountOfHooksRemoved = amountOfHooksRemoved + 1
                                    end
                                end
                    
                            end
                
                        end
                    end
                
                end
                if amountOfHooksRemoved == 0 then MsgC(Color(170, 255, 0), "M.B.D. Hook Removal Finished: No hooks was removed.\n") else
                    MsgC(Color(170, 255, 0), "M.B.D. Hook Removal Finished: "..amountOfHooksRemoved.." hook"..(function() if amountOfHooksRemoved != 1 then return "s" end return "" end)().." was removed.\n")
                end
            end)
		end
    end

    -- HOOKS
    if SERVER then
        -- THIS LOGIC IS FOR MYSTERY BOX
        hook.Add("PlayerInitialSpawn", "mbd_MysteryBox_PlayerInitialSpawn001", function(pl)
            if pl and pl:IsValid() then
                pl:SendLua([[mbd_bo3_ravo_getNiceWeaponNames()]])
            end
        end)
        -----------------------------
        -- M.B.D Allowed Weapons --
        -------------------------------
        local tempAllowedWeapons = {}
        local hl2StandardWeapons = {
            weapon_pistol = "models/weapons/w_Pistol.mdl",
            weapon_smg = "models/weapons/w_smg1.mdl",
            weapon_shotgun = "models/weapons/w_shotgun.mdl",
            weapon_ar2 = "models/weapons/w_IRifle.mdl",
            weapon_rpg = "models/weapons/w_rocket_launcher.mdl",
            weapon_crossbow = "models/weapons/w_crossbow.mdl",
            weapon_frag = "models/weapons/w_grenade.mdl",
            weapon_357 = "models/weapons/w_357.mdl",
            weapon_crowbar = "models/weapons/w_crowbar.mdl",
            weapon_slam = "models/weapons/w_slam.mdl",
            weapon_stunstick = "models/weapons/w_stunbaton.mdl"
        }
        --- -- -
        ------- -- -

        -- For like BuyBox-table with class as key
        local addWeaponTableWithClassAsKey = function(_table)
            for classKey,_ in pairs(_table) do
                table.insert(tempAllowedWeapons, classKey)
            end
        end
        -- For whatever else with class as the value
        local addWeaponTableWithClassAsValue = function(_table)
            for _,classKey in pairs(_table) do
                table.insert(tempAllowedWeapons, classKey)
            end
        end
        -- This is the table where the final weapons data must end
        -- (remember to add the: "VModel" and "WModel" field (this should be automated; look under "Add Weapons" (Initialize)). Table looks like 'list.Get("Weapon")')
        mbd_allowedWeaponsMysteryBox = {}

        ------------------
        -- Add Weapons --
        ----------- -----
        timer.Simple(1.3, function()
            -- Add all FA:S 2 Weapons
            for k,v in pairs(list.Get("Weapon")) do
                local _WepClass = string.lower(v.ClassName)

                if (
                    _WepClass ~= "mbd_swep_repair_tool" and
                    _WepClass ~= "swep_construction_kit" and
                    _WepClass ~= "swep_vehicle_repair" and
                    _WepClass ~= "swep_prop_repair"
                ) then
                    if not string.match(_WepClass, "_base") then
                        local _t = {}
                        _t[_WepClass] = v
        
                        addWeaponTableWithClassAsKey(_t)
                    end
                end
            end
            -- HL:2 Weapons
            addWeaponTableWithClassAsKey(hl2StandardWeapons)
            --- -
            -- Add custom Weapons Class Key(s) (maybe weapons that the BuyBox does not have)
            -- Only valid weapons will be added (this is automated)
            addWeaponTableWithClassAsValue({
                "weapon_class_here"
            })
            --- -
            -- Get all valid weapons
            local weaponsTableAll = list.Get("Weapon")

            local _i = 1
            for _,dataTable in pairs(weaponsTableAll) do
                if table.HasValue(tempAllowedWeapons, string.lower(dataTable.ClassName)) then
                    table.insert(mbd_allowedWeaponsMysteryBox, dataTable)
                end

                if _i == table.Count(weaponsTableAll) then
                    -- Now insert all the models to the table...
                    local _newTable = {}

                    local _j = 1
                    for _,weaponsTable in pairs(mbd_allowedWeaponsMysteryBox) do
                        local _entVModel = nil
                        local _entWModel = nil

                        -- Spawn a temp. entity, get the model and delete
                        -- -
                        local _entClass = string.lower(weaponsTable.ClassName)
                        local tempEnt = ents.Create(_entClass)

                        local IsHL2Weapon = false

                        -- Set
                        -- Standard HL2-weapons
                        for classKey,Model in pairs(hl2StandardWeapons) do
                            if string.lower(classKey) == _entClass then
                                IsHL2Weapon = true

                                _entWModel = Model
                            end
                        end
                        -- FA:S 2 Weapons
                        if string.match(_entClass, "mbd_fas2_") then
                            local _t = tempEnt:GetTable()

                            _entVModel = _t.VM
                            _entWModel = _t.WM
                            if _t.WorldModel then _entWModel = _t.WorldModel end -- Very important
                        elseif not IsHL2Weapon then
                            -- Other
                            _entVModel = tempEnt:GetWeaponViewModel()
                            _entWModel = tempEnt:GetWeaponWorldModel()
                        end
                        if tempEnt and tempEnt:IsValid() then tempEnt:Remove() end

                        local tempTable = weaponsTable
                        tempTable["VModel"] = _entVModel
                        tempTable["WModel"] = _entWModel

                        table.insert(_newTable, tempTable)

                        ------------
                        -- Done --
                        ----------------
                        if _j == table.Count(mbd_allowedWeaponsMysteryBox) then --[[ Something can happend here ]] end

                        _j = (_j + 1)
                    end
                end

                _i = (_i + 1)
            end
        end)
        --------------------
        function makeEveryNPC_NeutralAgainsPlayer(pl)
            --
            --
            for k,v in pairs(ents.FindByClass("npc_*")) do
                -- MAKE "NEUTRAL, NOT HATE"
                timer.Simple(0.3, function()
                    if pl and pl:IsValid() and v and v:IsValid() and v.AddEntityRelationship then v:AddEntityRelationship(pl, D_NU, 99) end
                end)
            end
        end
        function makeEveryNPC_HateAgainsPlayer(pl)
            --
            for k,v in pairs(ents.FindByClass("npc_*")) do
                -- MAKE HATE
                if v:IsValid() and pl:IsValid() and v.AddEntityRelationship then v:AddEntityRelationship(pl, D_HT, 99) end
            end
        end
        function makeEveryNPC_NeutralEveryPlayerSpecating()
            --
            for k,v in pairs(ents.FindByClass("npc_*")) do
                for l,w in pairs(player.GetAll()) do
                    -- MAKE "NEUTRAL, NOT HATE"
                    if (w:GetNWBool("isSpectating", false)) then
                        if v:IsValid() and w:IsValid() and v.AddEntityRelationship then v:AddEntityRelationship(w, D_NU, 99) end
                    end
                end
            end
        end
        function makeEveryNPC_HateEveryPlayerNotSpectating()
            --
            for k,v in pairs(ents.FindByClass("npc_*")) do
                for l,w in pairs(player.GetAll()) do
                    -- MAKE HATE
                    if (!w:GetNWBool("isSpectating", true)) then
                        if v:IsValid() and w:IsValid() and v.AddEntityRelationship then v:AddEntityRelationship(w, D_HT, 99) end
                    end
                end
            end
        end
        function makeEveryNPC_NeutralEveryPlayer()
            --
            for k,v in pairs(ents.FindByClass("npc_*")) do
                for l,w in pairs(player.GetAll()) do
                    -- MAKE "NEUTRAL, NOT HATE"
                    if v:IsValid() and w:IsValid() and v.AddEntityRelationship then v:AddEntityRelationship(w, D_NU, 99) end
                end
            end
        end
        function makeEveryNPC_HateEveryPlayer()
            --
            for k,v in pairs(ents.FindByClass("npc_*")) do
                for l,w in pairs(player.GetAll()) do
                    -- MAKE HATE
                    if v:IsValid() and w:IsValid() and v.AddEntityRelationship then v:AddEntityRelationship(w, D_HT, 99) end
                end
            end
        end
        --------------------
        hook.Add("Initialize", "mbd:Initialize019", function()
            -- SERVER
            util.AddNetworkString("APlayerWWantsToProduceASound")
            -- CLIENT
            util.AddNetworkString("Entity_EmitLocalSoundEmitter")
            util.AddNetworkString("MBDSetSoundEmitter")
        end)
    end
end
