if engine.ActiveGamemode() == "my_base_defence" then -- Very important
    AddCSLuaFile()

    if SERVER or CLIENT then
        MBDCompleteBuyBoxList_AllowedWeapons = {
            engineer = {},
            mechanic = {},
            medic = {},
            terminator = {}
        }
        MBDCompleteBuyBoxList_AllowedOther = {
            engineer = {},
            mechanic = {},
            medic = {},
            terminator = {}
        }
        MBDCompleteBuyBoxList_AllowedAmmo = {}
        MBDCompleteBuyBoxList_AllowedAttachments = {}
        MBDCompleteBuyBoxList_PricesWepCustom = {}
        MBDCompleteBuyBoxList_PricesOther = {}

        MBDCompleteBuyBoxList_AllPricesCombined = {}
    end

    if SERVER then
        --
        ---- -
        -------------------- ---- ---
        -- *SETTINGS FOR PRICES * --
        ----------------------- -----
        -- -- -
        ---
        MBDPrices_Assault 		= {
            mbd_fas2_rk95 = 2000,
            mbd_fas2_g36c = 4000,
            mbd_fas2_an94 = 2000,
            mbd_fas2_ak47 = 4000,
            mbd_fas2_galil	= 2000,
            mbd_fas2_sg552	= 2500,
            mbd_fas2_ak12	= 1500,
            mbd_fas2_m4a1	= 1500,
            mbd_fas2_sg550	= 2500,
            mbd_fas2_famas	= 1500
        }
        MBDPrices_Sidearm 		= {
            mbd_fas2_deagle 	= 1000,
            mbd_fas2_p226 		= 500,
            mbd_fas2_ots33 		= 500,
            mbd_fas2_ragingbull = 1000,
            mbd_fas2_m1911		= 1000
        }
        MBDPrices_Meel 		= {
            mbd_fas2_machete 	= 300,
            mbd_fas2_dv2		= 200,
            weapon_stunstick 	= 600
        }
        MBDPrices_Explosive 	= {
            mbd_fas2_m67		= 3000,
            mbd_fas2_m79		= 5000,
            weapon_rpg			= 10000,
            grenade_helicopter 	= 270
        }
        MBDPrices_SubMachingun = {
            mbd_fas2_mp5sd6 = 800,
            mbd_fas2_mac11 	= 650,
            mbd_fas2_uzi	= 700,
            mbd_fas2_pp19	= 1000,
            mbd_fas2_mp5a5	= 950,
            mbd_fas2_mp5k	= 950
        }
        MBDPrices_Sniper 		= {
            mbd_fas2_m24	= 5000,
            mbd_fas2_m82	= 8000
        }
        MBDPrices_Rifle 		= {
            mbd_fas2_sks = 3000,
            mbd_fas2_m14 = 3500
        }
        MBDPrices_Shotgun 		= {
            mbd_fas2_m3s90	= 1200,
            mbd_fas2_rem870 = 1500,
            mbd_fas2_ks23		= 2000,
            mbd_fas2_toz34	= 3000
        }
        MBDPrices_CustomListAllWillOverWrite 		= {}
        MBDPrices_Other 		= {
            mbd_fas2_ammobox 	= 1000,
            mbd_fas2_ammocrate 	= 1000,
            mbd_fas2_ifak		= 300,
            item_suitcharger	= 3000,
            item_healthcharger	= 4000,
            item_healthkit		= 200,
            item_healthvial		= 100,
            item_battery		= 350,
            --[[ Actually ammo - For Medic ]]
            mbd_fas2_ammo_bandages = 430,
            mbd_fas2_ammo_hemostats = 680,
            mbd_fas2_ammo_quikclots = 760,
            mbd_fas2_ammo_medical = 1000 -- Everything (bunch of)
        }
        MBDPrices_Ammo 		= {
            mbd_fas2_ammo_357sig 	= 60,  --sidearm
            mbd_fas2_ammo_380acp 	= 130, --sub-machingun
            mbd_fas2_ammo_44mag 	= 120, --sidearm (heavy)
            mbd_fas2_ammo_45acp 	= 125, --sidearm/sub-machingun
            mbd_fas2_ammo_50ae 		= 120, --sidearm (heavy)
            mbd_fas2_ammo_50bmg 	= 250, --sniper (heavy)
            mbd_fas2_ammo_454casull = 120, --sidearm (heavy)
            mbd_fas2_ammo_10x25 		= 60,  --sidearm
            mbd_fas2_ammo_12gauge 		= 150, --shotgun
            mbd_fas2_ammo_23x75 		= 120, --unknow right now...
            mbd_fas2_ammo_40mm_he		= 300, --explosive
            mbd_fas2_ammo_40mm_smoke	= 200, --smoke
            mbd_fas2_ammo_545x39 		= 190, --assault
            mbd_fas2_ammo_556x45 		= 190, --assault
            mbd_fas2_ammo_762x39 		= 220, --assault/sniper/semi-auto rifle
            mbd_fas2_ammo_762x51 		= 220, --sniper/semi-auto rifle
            mbd_fas2_ammo_9x18 			= 125, --sidearm/sub-machingun
            mbd_fas2_ammo_9x19 			= 125,  --sidearm/sub-machingun
            item_ammo_pistol 				= 100,
            item_ammo_pistol_large 	= 100 * 4,
            item_ammo_357 			= 150, -- magnum (hl:2)
            item_ammo_357_large 	= 150 * 4, -- magnum (hl:2)
            item_ammo_ar2 			= 400,
            item_ammo_ar2_large 	= 400 * 4,
            item_ammo_ar2_altfire 	= 1200,
            item_ammo_crossbow 		= 800,
            item_box_buckshot 		= 200, -- shotgun (hl:2)
            item_ammo_smg1_grenade 	= 370,
            item_ammo_smg1 			= 200,
            item_ammo_smg1_large 	= 200 * 4,
            item_rpg_round 			= 2000 --explosive (hl:2)
        }
        MBDPrices_Attachments 	= {
            mbd_fas2_att_acog			= 600,
            mbd_fas2_att_compm4			= 450,
            mbd_fas2_att_c79			= 450,
            mbd_fas2_att_eotech			= 300,
            mbd_fas2_att_foregrip		= 200,
            mbd_fas2_att_harrisbipod	= 210,
            mbd_fas2_att_leupold		= 800,
            mbd_fas2_att_m2120mag		= 180,
            mbd_fas2_att_mp5k30mag		= 180,
            mbd_fas2_att_pso1			= 850,
            mbd_fas2_att_sg55x30mag		= 180,
            mbd_fas2_att_sks20mag		= 180,
            mbd_fas2_att_sks30mag		= 180,
            mbd_fas2_att_suppressor		= 700,
            mbd_fas2_att_tritiumsights	= 300,
            mbd_fas2_att_uziwoodenstock	= 260
        }
        -- - -
        -- - --- - Allowed classes - These are fallback tables
        -- - -
        -- Weapons
        MBDallowedWeaponClasses_Engineer = {
            "mbd_fas2_machete",
            "mbd_fas2_deagle",
            "mbd_fas2_rk95",
            "mbd_fas2_g36c",
            "mbd_fas2_uzi",
            "mbd_fas2_sks",
            "mbd_fas2_rem870",
            "mbd_fas2_ragingbull",
            "mbd_fas2_sg552",
            "mbd_fas2_ak47",
            "mbd_fas2_m67",
            "mbd_fas2_ks23",
            "mbd_fas2_pp19",
            "mbd_fas2_toz34",
            "weapon_rpg"
        }
        MBDallowedWeaponClasses_Mechanic = {
            "mbd_fas2_dv2",
            "mbd_fas2_p226",
            "mbd_fas2_m67",
            "mbd_fas2_an94",
            "mbd_fas2_m24",
            "mbd_fas2_galil",
            "mbd_fas2_sks",
            "mbd_fas2_m14",
            "mbd_fas2_mp5k",
            "mbd_fas2_rem870",
            "mbd_fas2_deagle",
            "mbd_fas2_sg552",
            "mbd_fas2_ak12",
            "mbd_fas2_ak47",
            "weapon_rpg"
        }
        MBDallowedWeaponClasses_Medic = {
            "mbd_fas2_machete",
            "mbd_fas2_ots33",
            "mbd_fas2_mp5sd6",
            "mbd_fas2_m3s90",
            "mbd_fas2_galil",
            "mbd_fas2_sks",
            "mbd_fas2_ak47",
            "mbd_fas2_uzi",
            "mbd_fas2_m4a1",
            "mbd_fas2_m1911",
            "mbd_fas2_sg550",
            "mbd_fas2_m79",
            "mbd_fas2_famas",
            "weapon_rpg"
        }
        MBDallowedWeaponClasses_Terminator = {
            "mbd_fas2_machete",
            "mbd_fas2_ragingbull",
            "mbd_fas2_m67",
            "mbd_fas2_mac11",
            "mbd_fas2_ak47",
            "mbd_fas2_m79",
            "mbd_fas2_ks23",
            "mbd_fas2_sks",
            "mbd_fas2_m4a1",
            "mbd_fas2_sg550",
            "mbd_fas2_ak12",
            "mbd_fas2_m1911",
            "mbd_fas2_famas",
            "mbd_fas2_toz34",
            "mbd_fas2_m82",
            "mbd_fas2_mp5a5",
            "weapon_rpg",
            "weapon_stunstick"
        }
        -- Other classes
        MBDallowedOtherClasses_Engineer = {
            "item_healthkit",
            "item_healthvial",
            "item_battery"
        }
        MBDallowedOtherClasses_Mechanic = {
            "mbd_fas2_ammobox",
            "item_healthkit",
            "item_healthvial",
            "item_battery"
        }
        MBDallowedOtherClasses_Medic = {
            "mbd_fas2_ifak",
            "mbd_fas2_ammo_bandages",
            "mbd_fas2_ammo_hemostats",
            "mbd_fas2_ammo_quikclots",
            "mbd_fas2_ammo_medical",
            "item_healthcharger",
            "item_healthkit",
            "item_healthvial",
            "item_battery"
        }
        MBDallowedOtherClasses_Terminator = {
            "mbd_fas2_ammobox",
            "mbd_fas2_ammocrate",
            "item_suitcharger",
            "item_healthkit",
            "item_healthvial",
            "item_battery"
        }

        -- -
        local function findCorrectWeaponGroupString(className)
            local checkThisTable = function(_table, _className, categoryString)
                for _ClassName,v in pairs(_table) do
                    if _ClassName == _className then return categoryString end
                end
        
                return nil
            end
        
            local shouldHaveFoundOne = nil
            -- These are the nice category names
            -- Are e.g. shown in the BuyBox
            shouldHaveFoundOne = (
                checkThisTable(MBDPrices_Assault, className, "Assault") or
                checkThisTable(MBDPrices_Sidearm, className, "Sidearm") or
                checkThisTable(MBDPrices_Meel, className, "Meel") or
                checkThisTable(MBDPrices_Explosive, className, "Explosive") or
                checkThisTable(MBDPrices_SubMachingun, className, "Sub-machingun") or
                checkThisTable(MBDPrices_Sniper, className, "Sniper") or
                checkThisTable(MBDPrices_Rifle, className, "Rifle") or
                checkThisTable(MBDPrices_Shotgun, className, "Shotgun") or
                checkThisTable(MBDPrices_Other, className, "Other") or
                checkThisTable(MBDPrices_Ammo, className, "Ammo") or
                checkThisTable(MBDPrices_Attachments, className, "Attachments") or
                checkThisTable(MBDPrices_CustomListAllWillOverWrite, className, "All Weapons")
            )
        
            if shouldHaveFoundOne then
                return shouldHaveFoundOne
            end
        
            return "N/A"
        end
        local function AddToNameFromList(_list)
            local temp_namesList = {}

            for EntKey,EntData in pairs(_list) do

                local className = EntData["ClassName"]
                -- Bug in Hl2 or something ?
                -- if className == "item_rpg_round" then className = "rpg_round" end
                temp_namesList[className] = EntData["PrintName"]

            end
            
            return temp_namesList
        end
        -- -
        -- This produces the table
        function makeABuyBoxCategoryBuyTable(tableID, playerClassNameString, namesTables)
            if not tableID or tableID == "" then print("\"makeABuyBoxCategoryBuyTable\": No tableID.") return end
            local _tempTable = {}

            -- Where the data will be stored based on the "tableID"
            local pricesTables = {}
            local CopyToPriceTableFromAnotherPriceTable = function(_table)
                for k,v in pairs(_table) do pricesTables[k] = v end
            end
            local CreatePriceTableFromAllowedClasses = function(_table)
                local _tempTable = {}

                for _ClassName,v in pairs(pricesTables) do
                    if table.HasValue(_table, _ClassName) then _tempTable[_ClassName] = v end
                end

                return _tempTable
            end

            -- For Weapons ...
            if tableID == "weapon" then
                -- Add to "pricesTables"
                if not MBDPrices_CustomListAllWillOverWrite or ( MBDPrices_CustomListAllWillOverWrite and #table.GetKeys(MBDPrices_CustomListAllWillOverWrite) <= 0 ) then
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_Assault)
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_Sidearm)
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_Meel)
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_Explosive)
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_SubMachingun)
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_Sniper)
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_Rifle)
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_Shotgun)
                else
                    CopyToPriceTableFromAnotherPriceTable(MBDPrices_CustomListAllWillOverWrite)
                end

                -- -- -
                -- Filter out what Weapon is allowed, based on the Player class
                if not playerClassNameString or playerClassNameString == "" then print("'makeABuyBoxCategoryBuyTable': No playerClassNameString") return end
                -- -
                --------------- --
                -- **SETTINGS** --
                -- Price Settings are above --
                ---------- -- --
                local MBDallowedWeaponClasses = {}
                if playerClassNameString == "engineer" then
                    MBDallowedWeaponClasses = MBDallowedWeaponClasses_Engineer
                    
                elseif playerClassNameString == "mechanic" then
                    MBDallowedWeaponClasses = MBDallowedWeaponClasses_Mechanic
                    
                elseif playerClassNameString == "medic" then
                    MBDallowedWeaponClasses = MBDallowedWeaponClasses_Medic
                    
                elseif playerClassNameString == "terminator" then
                    MBDallowedWeaponClasses = MBDallowedWeaponClasses_Terminator
                end

                -- Add only these weapons...
                -- Save
                pricesTables = CreatePriceTableFromAllowedClasses(MBDallowedWeaponClasses)
            elseif tableID == "ammo" then
                CopyToPriceTableFromAnotherPriceTable(MBDPrices_Ammo)
            elseif tableID == "attachment" then
                CopyToPriceTableFromAnotherPriceTable(MBDPrices_Attachments)
            elseif tableID == "other" then
                -- -- -
                -- Filter out what Weapon is allowed, based on the Player class
                if not playerClassNameString or playerClassNameString == "" then print("\"makeABuyBoxCategoryBuyTable\": No playerClassNameString") return end
                -- -
                --------------- --
                -- **SETTINGS** --
                -- Price Settings are above --
                ---------- -- --
                local MBDallowedOtherClasses = {}
                if playerClassNameString == "engineer" then
                    MBDallowedOtherClasses = MBDallowedOtherClasses_Engineer

                elseif playerClassNameString == "mechanic" then
                    MBDallowedOtherClasses = MBDallowedOtherClasses_Mechanic

                elseif playerClassNameString == "medic" then
                    MBDallowedOtherClasses = MBDallowedOtherClasses_Medic

                elseif playerClassNameString == "terminator" then
                    MBDallowedOtherClasses = MBDallowedOtherClasses_Terminator
                end

                -- Add only weapons to price table also
                CopyToPriceTableFromAnotherPriceTable(MBDPrices_Other)
                pricesTables = CreatePriceTableFromAllowedClasses(MBDallowedOtherClasses)
            end

            local _i = 1
            for _ClassName,v in pairs(pricesTables) do

                if namesTables[string.lower(_ClassName)] then
                    ---------------------------
                    --------------
                    -- T H E M O T H E R
                    ------------------------
                    ---------------------------
                    -- Might have a custom picture linked to itself
                    local __imagePathSearch = nil
                    local _fileTypesToCheck = {
                        ".png",
                        ".jpg"
                    }
                    ------- --- -
                    -- Find correct format if a picture exsist (three options ("_fileTypesToCheck"))
                    local _insertToTable = function()
                        -- -
                        -- -- -- T H E E E MOTHHRR (2.0)
                        table.insert(_tempTable, {
                            picture = (__imagePathSearch or ""),
                            name = namesTables[string.lower(_ClassName)],
                            price = tonumber(pricesTables[_ClassName]),
                            entClass = string.lower(_ClassName),
                            category = string.lower(findCorrectWeaponGroupString(_ClassName))
                        })
                    end

                    local function _checkFilPathImage(_fileType, index)
                        ---
                        -- Finished..
                        if index > #_fileTypesToCheck then
                            _insertToTable()

                            return
                        end
                        ---
                        __imagePathSearch = "---"
                        __imagePathSearch2 = "---"

                        -- Search in file system
                        -- Ammo maybe  
                        local classNameSearch = string.lower(_ClassName)
                        -- Exceptions... (bug HL2 or something)
                        if classNameSearch == "rpg_round" then
                            classNameSearch = "item_rpg_round"
                        end
                        __imagePathSearch = "materials/mbd_buybox/"..classNameSearch.._fileType
                        __imagePathSearch2 = "materials/entities/"..classNameSearch.._fileType

                        -- - -
                        -- - For wepage
                        if file.Exists(__imagePathSearch, "GAME") then
                            _insertToTable()

                            return
                        elseif file.Exists(__imagePathSearch2, "GAME") then
                            _insertToTable()

                            return
                        elseif (
                            string.match(string.lower(_ClassName), 'ammo') or
                            string.match(string.lower(namesTables[string.lower(_ClassName)]), 'ammo')
                        ) then
                            -- Fallback for ammo
                            -- Maybe ammo without unique picture
                            __imagePathSearch = "materials/mbd_buybox/ammo.png"

                            _insertToTable()

                            return
                        end

                        -- No found
                        -- Try with different extension
                        __imagePathSearch = nil
                        _checkFilPathImage(_fileTypesToCheck[index + 1], index + 1)
                    end
                    _checkFilPathImage(_fileTypesToCheck[1], 1)
            
                    if _i == table.Count(pricesTables) then
                        -- Done
                        return _tempTable
                    end
                else MsgC(Color(255, 0, 0), "\"makeABuyBoxCategoryBuyTable\": Could not find the name of => ", _ClassName, " ", v, "\n") end

                _i = (_i + 1)
            end
        end
        -- -- - ----------------
        -- Make BuyBox Menu ----
        -- - ----------- -------
        -- **To add a new weapon:
        -- >>> Add first a *Price* in the correct table => Then add the weapon *className* for the correct PlayerClass.
        -- --------- -
        -- Everything else is automated.
        function MBDSendAvailableThingsToBuyTable( pl, dontSendMessageToConsole )
            if AvailableThingsToBuy then
                if not dontSendMessageToConsole then MsgC(Color(0, 211, 15), "M.B.D.: Sending \"AvailableThingsToBuy\" (BuyBox) to all connected Players.\n") end

                net.Start("mbd_SendAvailableThingsThingsToBuy")
                    net.WriteTable(AvailableThingsToBuy)
                if not pl then net.Broadcast() elseif pl:IsValid() then net.Send( pl ) end
            end
        end

        local function MBDUpdateAvailableThingsToBuyForPlayersClient()
            -- - - -
            -- Add
            local enititiesList = list.Get("Weapon")
            table.Merge(enititiesList, list.Get("SpawnableEntities"))
            --- -
            -- So you know everything is loaded... Hopefully
            -- Try for 20 seconds
            local waitUntilNext = 0.1
            local tries = 20 / waitUntilNext
            local function checkIfValid()
                if tries >= 0 and (
                    not enititiesList or
                    not makeABuyBoxCategoryBuyTable
                ) then
                    tries = (tries - 1) timer.Simple(waitUntilNext, function() checkIfValid() end)
                elseif (
                    enititiesList and
                    makeABuyBoxCategoryBuyTable
                ) then
                    local wepAndOtherNamesCombined = AddToNameFromList(enititiesList)
                    timer.Simple(0.6, function()
                        local __AllAttachments = makeABuyBoxCategoryBuyTable("attachment", nil, wepAndOtherNamesCombined)

                        -- *FOR BUYBOX*
                        AvailableThingsToBuy = {
                                engineer = {
                                    attachments 	= makeABuyBoxCategoryBuyTable("attachments", nil, wepAndOtherNamesCombined),
                                    ammo 			= makeABuyBoxCategoryBuyTable("ammo", nil, wepAndOtherNamesCombined),
                                    other 			= makeABuyBoxCategoryBuyTable("other", "engineer", wepAndOtherNamesCombined),
                                    weapons 		= makeABuyBoxCategoryBuyTable("weapon", "engineer", wepAndOtherNamesCombined)
                                },
                                mechanic = {
                                    attachments 	= makeABuyBoxCategoryBuyTable("attachments", nil, wepAndOtherNamesCombined),
                                    ammo 			= makeABuyBoxCategoryBuyTable("ammo", nil, wepAndOtherNamesCombined),
                                    other 			= makeABuyBoxCategoryBuyTable("other", "mechanic", wepAndOtherNamesCombined),
                                    weapons 		= makeABuyBoxCategoryBuyTable("weapon", "mechanic", wepAndOtherNamesCombined)
                                },
                                medic = {
                                    attachments 	= makeABuyBoxCategoryBuyTable("attachments", nil, wepAndOtherNamesCombined),
                                    ammo 			= makeABuyBoxCategoryBuyTable("ammo", nil, wepAndOtherNamesCombined),
                                    other 			= makeABuyBoxCategoryBuyTable("other", "medic", wepAndOtherNamesCombined),
                                    weapons 		= makeABuyBoxCategoryBuyTable("weapon", "medic", wepAndOtherNamesCombined)
                                },
                                terminator = {
                                    attachments 	= makeABuyBoxCategoryBuyTable("attachments", nil, wepAndOtherNamesCombined),
                                    ammo 			= makeABuyBoxCategoryBuyTable("ammo", nil, wepAndOtherNamesCombined),
                                    other 			= makeABuyBoxCategoryBuyTable("other", "terminator", wepAndOtherNamesCombined),
                                    weapons 		= makeABuyBoxCategoryBuyTable("weapon", "terminator", wepAndOtherNamesCombined)
                            }
                        }
                        -- - -
                        AvailableThingsToBuy.engineer.attachments 	= __AllAttachments
                        AvailableThingsToBuy.mechanic.attachments 	= __AllAttachments
                        AvailableThingsToBuy.medic.attachments 		= __AllAttachments
                        AvailableThingsToBuy.terminator.attachments = __AllAttachments

                        -- --
                        -- -- - - Since there is a delay, send out the table to already connected Players ( the client will also request this on connect )
                        timer.Simple(1.5, MBDSendAvailableThingsToBuyTable)
                    end)
                end
            end checkIfValid()
        end
        --- -
        -- --
        -- Go ahead and check that all values are rounded for the price (since JSON file allows comma)
        local function ConvertToWholeNumber(tableOfPrices)
            for k,v in pairs(tableOfPrices) do tableOfPrices[k] = math.Round(tonumber(v)) end
        end
        local function FilterOutNotAllowed(_table, completePriceList, completeList)
            for entClass,entPrice in pairs(completePriceList) do
                -- If not in allowed, then "remove" the one from the Price table ( actually add allowed )
                if completeList and !_table[entClass] and table.HasValue(completeList, entClass) then _table[entClass] = tonumber(entPrice) end
            end
        end
        local function MakePriceFreeFromPriceToAllowed(_table, completeList)
            local allPricesKeys = table.GetKeys(_table)

            -- ...Add the free one ( the ones that is allowed and not added in Price table by the user )
            for _,classAllowed in pairs(completeList) do
                -- If not in Price table, then insert the Free one with price 0
                if !table.HasValue(allPricesKeys, classAllowed) or not isnumber(_table[classAllowed]) then _table[classAllowed] = 0 end
            end
        end

        -- This for when a Player writes a custom list
        function MBDWriteBuyBoxCustomizedListFromWithinTheGameOnly()
            local completeListAllWep = {}
            table.Add(completeListAllWep, MBDallowedWeaponClasses_Engineer)
            table.Add(completeListAllWep, MBDallowedWeaponClasses_Mechanic)
            table.Add(completeListAllWep, MBDallowedWeaponClasses_Medic)
            table.Add(completeListAllWep, MBDallowedWeaponClasses_Terminator)
            -- -
            local completeListOther = {}
            table.Add(completeListOther, MBDallowedOtherClasses_Engineer)
            table.Add(completeListOther, MBDallowedOtherClasses_Mechanic)
            table.Add(completeListOther, MBDallowedOtherClasses_Medic)
            table.Add(completeListOther, MBDallowedOtherClasses_Terminator)

            -- First time setup
            if !MBDPrices_CustomListAllWillOverWrite or #table.GetKeys(MBDPrices_CustomListAllWillOverWrite) <= 0 then
                table.Merge(MBDPrices_CustomListAllWillOverWrite, MBDPrices_Assault)
                table.Merge(MBDPrices_CustomListAllWillOverWrite, MBDPrices_Sidearm)
                table.Merge(MBDPrices_CustomListAllWillOverWrite, MBDPrices_Meel)
                table.Merge(MBDPrices_CustomListAllWillOverWrite, MBDPrices_Explosive)
                table.Merge(MBDPrices_CustomListAllWillOverWrite, MBDPrices_SubMachingun)
                table.Merge(MBDPrices_CustomListAllWillOverWrite, MBDPrices_Sniper)
                table.Merge(MBDPrices_CustomListAllWillOverWrite, MBDPrices_Rifle)
                table.Merge(MBDPrices_CustomListAllWillOverWrite, MBDPrices_Shotgun)
            end

            -- Convert the prices to free ones, if not in the prices table...
            MakePriceFreeFromPriceToAllowed(MBDPrices_CustomListAllWillOverWrite, completeListAllWep)
            MakePriceFreeFromPriceToAllowed(MBDPrices_Other, completeListOther)

            local newJSONTable = [[{
                "price": {
                    "weapons": {
                        "assault": {},
                        "sidearm": {},
                        "meel": {},
                        "explosive": {},
                        "subMachingun": {},
                        "sniper": {},
                        "rifle": {},
                        "shotgun": {},
                        "customListWillOverWriteTheAbove": ]]..MBDTableToJSON(MBDPrices_CustomListAllWillOverWrite)..[[
                    },
                    "other": ]]..MBDTableToJSON(MBDPrices_Other)..[[,
                    "ammo": ]]..MBDTableToJSON(MBDPrices_Ammo)..[[,
                    "attachments": ]]..MBDTableToJSON(MBDPrices_Attachments)..[[
                },
                "allowedWeapons": {
                    "engineer": ]]..MBDTableToJSON(MBDallowedWeaponClasses_Engineer, true)..[[,
                    "mechanic": ]]..MBDTableToJSON(MBDallowedWeaponClasses_Mechanic, true)..[[,
                    "medic": ]]..MBDTableToJSON(MBDallowedWeaponClasses_Medic, true)..[[,
                    "terminator": ]]..MBDTableToJSON(MBDallowedWeaponClasses_Terminator, true)..[[
                },
                "allowedOther": {
                    "engineer": ]]..MBDTableToJSON(MBDallowedOtherClasses_Engineer, true)..[[,
                    "mechanic": ]]..MBDTableToJSON(MBDallowedOtherClasses_Mechanic, true)..[[,
                    "medic": ]]..MBDTableToJSON(MBDallowedOtherClasses_Medic, true)..[[,
                    "terminator": ]]..MBDTableToJSON(MBDallowedOtherClasses_Terminator, true)..[[
                }
            }]]
            timer.Simple(0.3, function()
                -- Write a new file wiith the current data!
                local buyBoxFolder = "mbd-buybox"
                local theCustomConfigFileName = MBDRoot_folder_path.."/"..buyBoxFolder.."/buybox_custom_settings.json"
                file.Write(theCustomConfigFileName, newJSONTable)

                MBDCreateBuyBoxConfigFilesAndTablesSERVER(true)
            end)
        end

        -- -
        -- This is used for checking if the item the user wants to buy is valid/allowed ( from JSON/default settings )
        MBDWhitelistAllCurrentAllowedClasses = {}
        function MBDGenerateWhiteListForBuyBox(aCustomGeneratedListFromGameOption, ShouldUseCustomPriceTable)
            local MaybeInsertClassInWhitelist = function(classTable, isAPriceTable)
                if classTable then
                    for k,v in pairs(classTable) do
                        local className = v
                        if isAPriceTable then className = k end
    
                        if not table.HasValue(MBDWhitelistAllCurrentAllowedClasses, className) then
                            table.insert(MBDWhitelistAllCurrentAllowedClasses, className)
                        end
                    end
                end
            end
            local InsertClassInAllBuyBoxList_AllowedWeapons = function(playerClassName, classTable)
                table.Add(MBDCompleteBuyBoxList_AllowedWeapons[playerClassName], classTable)
            end
            local InsertClassInAllBuyBoxList_AllowedOther = function(playerClassName, classTable)
                table.Add(MBDCompleteBuyBoxList_AllowedOther[playerClassName], classTable)
            end
            local InsertClassSimple_AllowedAmmo = function(classTable)
                for className,_ in pairs(classTable) do
                    if not table.HasValue(MBDCompleteBuyBoxList_AllowedAmmo, className) then
                        table.insert(MBDCompleteBuyBoxList_AllowedAmmo, className)
                    end
                end
            end
            local InsertClassSimple_AllowedAttachments = function(classTable)
                for className,_ in pairs(classTable) do
                    if not table.HasValue(MBDCompleteBuyBoxList_AllowedAttachments, className) then
                        table.insert(MBDCompleteBuyBoxList_AllowedAttachments, className)
                    end
                end
            end
            local InsertClassSimple_PricesWepCustom = function(classTable)
                for className,Price in pairs(classTable) do
                    if not table.HasValue(MBDCompleteBuyBoxList_PricesWepCustom, className) then
                        table.insert(MBDCompleteBuyBoxList_PricesWepCustom, className)

                        -- Save here also
                        if ShouldUseCustomPriceTable then MBDPrices_CustomListAllWillOverWrite[className] = Price end
                    end
                end
            end
            local InsertClassSimple_PricesAttAmmoOther = function(_table, classTable)
                for className,_ in pairs(classTable) do
                    if not table.HasValue(_table, className) then
                        table.insert(_table, className)
                    end
                end
            end
            local InsertClassSimple_AllPricesCombined = function(classTable)
                for className,classPrice in pairs(classTable) do
                    if not MBDCompleteBuyBoxList_AllPricesCombined[className] then
                        MBDCompleteBuyBoxList_AllPricesCombined[className] = classPrice
                    end
                end
            end

            MaybeInsertClassInWhitelist(MBDallowedWeaponClasses_Engineer)
            MaybeInsertClassInWhitelist(MBDallowedWeaponClasses_Mechanic)
            MaybeInsertClassInWhitelist(MBDallowedWeaponClasses_Medic)
            MaybeInsertClassInWhitelist(MBDallowedWeaponClasses_Terminator)
            MaybeInsertClassInWhitelist(MBDallowedOtherClasses_Engineer)
            MaybeInsertClassInWhitelist(MBDallowedOtherClasses_Mechanic)
            MaybeInsertClassInWhitelist(MBDallowedOtherClasses_Medic)
            MaybeInsertClassInWhitelist(MBDallowedOtherClasses_Terminator)

            -- From the prices table... These do not have it's own allowed table, since they are availale to all classes
            MaybeInsertClassInWhitelist(MBDPrices_Ammo, true)
            MaybeInsertClassInWhitelist(MBDPrices_Attachments, true)

            ---- -
            -- ALLOWED WEAPONS
            MBDCompleteBuyBoxList_AllowedWeapons = {
                engineer = {},
                mechanic = {},
                medic = {},
                terminator = {}
            }
            InsertClassInAllBuyBoxList_AllowedWeapons("engineer", MBDallowedWeaponClasses_Engineer)
            InsertClassInAllBuyBoxList_AllowedWeapons("mechanic", MBDallowedWeaponClasses_Mechanic)
            InsertClassInAllBuyBoxList_AllowedWeapons("medic", MBDallowedWeaponClasses_Medic)
            InsertClassInAllBuyBoxList_AllowedWeapons("terminator", MBDallowedWeaponClasses_Terminator)
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "weapons",
                    data = MBDCompleteBuyBoxList_AllowedWeapons
                })
            net.Broadcast()
            ---- -
            -- ALLOWED OTHER
            MBDCompleteBuyBoxList_AllowedOther = {
                engineer = {},
                mechanic = {},
                medic = {},
                terminator = {}
            }
            InsertClassInAllBuyBoxList_AllowedOther("engineer", MBDallowedOtherClasses_Engineer)
            InsertClassInAllBuyBoxList_AllowedOther("mechanic", MBDallowedOtherClasses_Mechanic)
            InsertClassInAllBuyBoxList_AllowedOther("medic", MBDallowedOtherClasses_Medic)
            InsertClassInAllBuyBoxList_AllowedOther("terminator", MBDallowedOtherClasses_Terminator)
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "other",
                    data = MBDCompleteBuyBoxList_AllowedOther
                })
            net.Broadcast()
            ---- -
            -- ALLOWED AMMO
            MBDCompleteBuyBoxList_AllowedAmmo = {}
            InsertClassSimple_AllowedAmmo(MBDPrices_Ammo)
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "ammo",
                    data = MBDCompleteBuyBoxList_AllowedAmmo
                })
            net.Broadcast()
            ---- -
            -- ALLOWED ATTACHMENTS
            MBDCompleteBuyBoxList_AllowedAttachments = {}
            InsertClassSimple_AllowedAttachments(MBDPrices_Attachments)
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "attachments",
                    data = MBDCompleteBuyBoxList_AllowedAttachments
                })
            net.Broadcast()
            ---- -
            -- ALLOWED Wep Custom List ( always add... )
            MBDCompleteBuyBoxList_PricesWepCustom = {}
            if !ShouldUseCustomPriceTable then
                InsertClassSimple_PricesWepCustom(MBDPrices_Assault)
                InsertClassSimple_PricesWepCustom(MBDPrices_Sidearm)
                InsertClassSimple_PricesWepCustom(MBDPrices_Meel)
                InsertClassSimple_PricesWepCustom(MBDPrices_Explosive)
                InsertClassSimple_PricesWepCustom(MBDPrices_SubMachingun)
                InsertClassSimple_PricesWepCustom(MBDPrices_Sniper)
                InsertClassSimple_PricesWepCustom(MBDPrices_Rifle)
                InsertClassSimple_PricesWepCustom(MBDPrices_Shotgun)
            else
                InsertClassSimple_PricesWepCustom(MBDPrices_CustomListAllWillOverWrite)
            end
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "pricesWepCustom",
                    data = MBDCompleteBuyBoxList_PricesWepCustom
                })
            net.Broadcast()
            ---- -
            -- ALLOWED Att./Ammo/Other
            MBDCompleteBuyBoxList_PricesAttachments = {}
            InsertClassSimple_PricesAttAmmoOther(MBDCompleteBuyBoxList_PricesOther, MBDPrices_Attachments)
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "pricesAtt",
                    data = MBDCompleteBuyBoxList_PricesOther
                })
            net.Broadcast()
            MBDCompleteBuyBoxList_PricesAmmunition = {}
            InsertClassSimple_PricesAttAmmoOther(MBDCompleteBuyBoxList_PricesOther, MBDPrices_Ammo)
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "pricesAmmo",
                    data = MBDCompleteBuyBoxList_PricesOther
                })
            net.Broadcast()
            MBDCompleteBuyBoxList_PricesOther = {}
            InsertClassSimple_PricesAttAmmoOther(MBDCompleteBuyBoxList_PricesOther, MBDPrices_Other)
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "pricesOther",
                    data = MBDCompleteBuyBoxList_PricesOther
                })
            net.Broadcast()
            ---- -
            -- All Prices Combined... Used for Populating all Lists that need have a price!
            MBDCompleteBuyBoxList_AllPricesCombined = {}
            if !ShouldUseCustomPriceTable then
                InsertClassSimple_AllPricesCombined(MBDPrices_Assault)
                InsertClassSimple_AllPricesCombined(MBDPrices_Sidearm)
                InsertClassSimple_AllPricesCombined(MBDPrices_Meel)
                InsertClassSimple_AllPricesCombined(MBDPrices_Explosive)
                InsertClassSimple_AllPricesCombined(MBDPrices_SubMachingun)
                InsertClassSimple_AllPricesCombined(MBDPrices_Sniper)
                InsertClassSimple_AllPricesCombined(MBDPrices_Rifle)
                InsertClassSimple_AllPricesCombined(MBDPrices_Shotgun)
                InsertClassSimple_AllPricesCombined(MBDPrices_Other)
                InsertClassSimple_AllPricesCombined(MBDPrices_Attachments)
                InsertClassSimple_AllPricesCombined(MBDPrices_Ammo)
            else
                InsertClassSimple_AllPricesCombined(MBDPrices_CustomListAllWillOverWrite)
                InsertClassSimple_AllPricesCombined(MBDPrices_Other)
                InsertClassSimple_AllPricesCombined(MBDPrices_Attachments)
                InsertClassSimple_AllPricesCombined(MBDPrices_Ammo)
            end
            net.Start("mbd:SetABuyBoxListClient")
                net.WriteTable({
                    type = "pricesAllCombined",
                    data = MBDCompleteBuyBoxList_AllPricesCombined
                })
            net.Broadcast()

            -- 100 % finished
            timer.Simple(0.6, function()
                MBDUpdateAvailableThingsToBuyForPlayersClient()

                if aCustomGeneratedListFromGameOption then
                    net.Start("NotificationReceivedFromServer")
                        net.WriteTable({
                            Text 	= "An Admin updated the current BuyBox list!",
                            Type	= NOTIFY_GENERIC,
                            Time	= 3
                        })
                    net.Broadcast()
                end
            end)
        end

        -- - -
        -- - The SERVER (A USER) wants it's own weapons =>> If it exists in the data folder
        --- - 1. Edit the buybox_custom_settings.json to change
        -- - -
        -- Wait a little bit, so the Weapon list etc. from the servers are properly populated !!
        local buyBoxFolder = "mbd-buybox"
        if !file.Exists(MBDRoot_folder_path, "DATA") then file.CreateDir(MBDRoot_folder_path) end
        if !file.Exists(MBDRoot_folder_path.."/"..buyBoxFolder, "DATA") then file.CreateDir(MBDRoot_folder_path.."/"..buyBoxFolder) end

        function MBDCreateBuyBoxConfigFilesAndTablesSERVER(aCustomGeneratedListFromGameOption)
            local theCustomConfigFileName = MBDRoot_folder_path.."/"..buyBoxFolder.."/buybox_custom_settings.json"
            if !file.Exists(theCustomConfigFileName, "DATA") then
                file.Write(theCustomConfigFileName,
                    [[{
                        "price": {
                            "weapons": {
                                "assault": {},
                                "sidearm": {},
                                "meel": {},
                                "explosive": {},
                                "subMachingun": {},
                                "sniper": {},
                                "rifle": {},
                                "shotgun": {},
                                "customListWillOverWriteTheAbove": {}
                            },
                            "other": {},
                            "ammo": {},
                            "attachments": {}
                        },
                        "allowedWeapons": {
                            "engineer": [],
                            "mechanic": [],
                            "medic": [],
                            "terminator": []
                        },
                        "allowedOther": {
                            "engineer": [],
                            "mechanic": [],
                            "medic": [],
                            "terminator": []
                        }
                    }]]
                )
            end

            local latestVersionOfOriginalConfigFil = "2"
            local latestVersionOfOriginalConfigName = "--Just A Backup From Original Settings You Can Use--buybox_original_settings.json"
            local theOriginalConfigFileName = MBDRoot_folder_path.."/"..buyBoxFolder.."/"..latestVersionOfOriginalConfigName
            local function writeOriginalConfigFile()
                file.Delete(theOriginalConfigFileName)

                -- Write
                file.Write(theOriginalConfigFileName,
                    [[{
                        "version": ]]..latestVersionOfOriginalConfigFil..[[,
                        "price": {
                            "weapons": {
                                "assault": ]]..MBDTableToJSON(MBDPrices_Assault)..[[,
                                "sidearm": ]]..MBDTableToJSON(MBDPrices_Sidearm)..[[,
                                "meel": ]]..MBDTableToJSON(MBDPrices_Meel)..[[,
                                "explosive": ]]..MBDTableToJSON(MBDPrices_Explosive)..[[,
                                "subMachingun": ]]..MBDTableToJSON(MBDPrices_SubMachingun)..[[,
                                "sniper": ]]..MBDTableToJSON(MBDPrices_Sniper)..[[,
                                "rifle": ]]..MBDTableToJSON(MBDPrices_Rifle)..[[,
                                "shotgun": ]]..MBDTableToJSON(MBDPrices_Shotgun)..[[,
                                "customListWillOverWriteTheAbove": {}
                            },
                            "other": ]]..MBDTableToJSON(MBDPrices_Other)..[[,
                            "ammo": ]]..MBDTableToJSON(MBDPrices_Ammo)..[[,
                            "attachments": ]]..MBDTableToJSON(MBDPrices_Attachments)..[[
                        },
                        "allowedWeapons": {
                            "engineer": ]]..MBDTableToJSON(MBDallowedWeaponClasses_Engineer, true)..[[,
                            "mechanic": ]]..MBDTableToJSON(MBDallowedWeaponClasses_Mechanic, true)..[[,
                            "medic": ]]..MBDTableToJSON(MBDallowedWeaponClasses_Medic, true)..[[,
                            "terminator": ]]..MBDTableToJSON(MBDallowedWeaponClasses_Terminator, true)..[[
                        },
                        "allowedOther": {
                            "engineer": ]]..MBDTableToJSON(MBDallowedOtherClasses_Engineer, true)..[[,
                            "mechanic": ]]..MBDTableToJSON(MBDallowedOtherClasses_Mechanic, true)..[[,
                            "medic": ]]..MBDTableToJSON(MBDallowedOtherClasses_Medic, true)..[[,
                            "terminator": ]]..MBDTableToJSON(MBDallowedOtherClasses_Terminator, true)..[[
                        }
                    }]]
                )
            end
            if !file.Exists(theOriginalConfigFileName, "DATA") then
                writeOriginalConfigFile()
            end
            timer.Simple(0.15, function()
                local originalConfigFileRaw = file.Read(theOriginalConfigFileName, false)

                timer.Simple(2, function()
                    if !originalConfigFileRaw then MsgC(Color(255, 0, 0), "M.B.D.: Could not read original config file for BuyBox... Canceling further operations.") return end

                    -- ... Maybe update the original version
                    local originalConfigData = util.JSONToTable(originalConfigFileRaw)
                    if originalConfigData["version"] and tostring(originalConfigData["version"]) != tostring(latestVersionOfOriginalConfigFil) then
                        -- Write the newest
                        writeOriginalConfigFile()
                    end
                    -- Write a list of all weapons/items available one each start-up (cause it might change often)
                    -- -
                    if !file.Exists(MBDRoot_folder_path.."/server-lists/", "DATA") then file.CreateDir(MBDRoot_folder_path.."/server-lists/") end
                    -- -
                    local weaponList = {}
                    local temp_weaponList = list.Get("Weapon")
                    local weaponListFilePlacement = MBDRoot_folder_path.."/server-lists/all-weapons.json"
                    local attachmentsAmmoOtherList = {}
                    local temp_attachmentsAmmoOtherList = list.Get("SpawnableEntities")
                    local attachmentsAmmoOtherListFilePlacement = MBDRoot_folder_path.."/server-lists/all-attachments-ammo-other.json"
                    -- -
                    --
                    -- Delete
                    if file.Exists(weaponListFilePlacement, "DATA") then file.Delete(weaponListFilePlacement) end
                    if file.Exists(attachmentsAmmoOtherListFilePlacement, "DATA") then file.Delete(attachmentsAmmoOtherListFilePlacement) end
                    -- Write
                    temp_weaponList["AAAA-MBD"] = {
                        [1] = ".",
                        [3] = ".",
                        [2] = ".",
                        [4] = ".",
                        PrintName = "This file was created at: "..os.date("Time: %T Date: %D", os.time())
                    }
                    temp_attachmentsAmmoOtherList["AAAA-MBD"] = {
                        [1] = ".",
                        [3] = ".",
                        [2] = ".",
                        [4] = ".",
                        PrintName = "This file was created at: "..os.date("Time: %T Date: %D", os.time())
                    }
                    -- SORT
                    for id,data in SortedPairsByMemberValue(temp_weaponList, "PrintName", false) do
                        weaponList[id] = data
                    end
                    for id,data in SortedPairsByMemberValue(temp_attachmentsAmmoOtherList, "PrintName", false) do
                        attachmentsAmmoOtherList[id] = data
                    end
                    -- - --
                    -- -
                    ---
                    -- Weapons
                    local temp_WeaponList = {}
                    for key,data in SortedPairs(weaponList) do
                        table.insert(temp_WeaponList, [["]]..key..[[":]]..util.TableToJSON(data))
                    end
                    table.SortDesc(temp_WeaponList)
            
                    -- Write...
                    local newTableWeaponList = "{"..table.concat(table.Reverse(temp_WeaponList), ",").."}"
                    file.Write(weaponListFilePlacement, newTableWeaponList)
                    ---
                    -- Attachments/Ammo/Other
                    local temp_attachmentsAmmoOtherList = {}
                    for key,data in SortedPairs(attachmentsAmmoOtherList) do
                        table.insert(temp_attachmentsAmmoOtherList, [["]]..key..[[":]]..util.TableToJSON(data))
                    end
                    table.SortDesc(temp_attachmentsAmmoOtherList)
                    -- Write...
                    local newTableAttachmentList = "{"..table.concat(table.Reverse(temp_attachmentsAmmoOtherList), ",").."}"
                    file.Write(attachmentsAmmoOtherListFilePlacement, newTableAttachmentList)
                    -- - - - -
                    -- - -
                    -- Check the file... If anything in allowedWeapons or allowedOther, overwrite everything...
                    if file.Exists(theCustomConfigFileName, "DATA") then
                        local customConfigFileRaw = file.Read(theCustomConfigFileName, false)

                        local customConfigData = util.JSONToTable(customConfigFileRaw)

                        local classHasData = function(key, class)
                            if #table.GetKeys(customConfigData[key][class]) > 0 then return true end

                            return false
                        end

                        -- Check if going custom...
                        local timerID0 = "checkIfGoingCustom0"
                        timer.Create(timerID0, 0.5, 0, function()
                            if customConfigData then -- This will either be empty ( not customized ) or have something. Checks that underneath =>
                                timer.Remove(timerID0)
                                
                                if (
                                    (
                                        customConfigData["allowedWeapons"] and
                                        customConfigData["allowedOther"] and (
                                            classHasData("allowedWeapons", "engineer") or
                                            classHasData("allowedWeapons", "mechanic") or
                                            classHasData("allowedWeapons", "medic") or
                                            classHasData("allowedWeapons", "terminator") or
                                            classHasData("allowedOther", "engineer") or
                                            classHasData("allowedOther", "mechanic") or
                                            classHasData("allowedOther", "medic") or
                                            classHasData("allowedOther", "terminator")
                                        )
                                    )
                                ) then
                                    --
                                    MsgC(Color(0, 170, 255), "M.B.D.: (1 of 4) Custom BuyBox data detected. Writing custom BuyBox data...\n")

                                    local ShouldUseCustomPriceTable = aCustomGeneratedListFromGameOption or !MBDPrices_CustomListAllWillOverWrite or (
                                        MBDPrices_CustomListAllWillOverWrite and #table.GetKeys(MBDPrices_CustomListAllWillOverWrite) > 0
                                    ) or ( customConfigData["price"]["weapons"]["customListWillOverWriteTheAbove"] and #table.GetKeys(customConfigData["price"]["weapons"]["customListWillOverWriteTheAbove"]) > 0 )

                                    -- Create custom list based on the custom content!
                                    -- - - Lets' G O
                                    local SetPricesWep = function(key, _table) table.Merge(_table, customConfigData["price"]["weapons"][key]) end
                                    local SetPrices = function(key, _table) table.Merge(_table, customConfigData["price"][key]) end
                                    --
                                    local SetAllowedWep = function(key, _table) table.Add(_table, customConfigData["allowedWeapons"][key]) end
                                    local SetAllowedOther = function(key, _table) table.Add(_table, customConfigData["allowedOther"][key]) end

                                    -- -
                                    -- Prices (SAVE THE PRICE TABLE LATER ...)
                                    if !ShouldUseCustomPriceTable then
                                        MBDPrices_Assault = {}
                                        MBDPrices_Sidearm = {}
                                        MBDPrices_Meel = {}
                                        MBDPrices_Explosive = {}
                                        MBDPrices_SubMachingun = {}
                                        MBDPrices_Sniper = {}
                                        MBDPrices_Rifle = {}
                                        MBDPrices_Shotgun = {}
                                        SetPricesWep("assault", MBDPrices_Assault)
                                        SetPricesWep("sidearm", MBDPrices_Sidearm)
                                        SetPricesWep("meel", MBDPrices_Meel)
                                        SetPricesWep("explosive", MBDPrices_Explosive)
                                        SetPricesWep("subMachingun", MBDPrices_SubMachingun)
                                        SetPricesWep("sniper", MBDPrices_Sniper)
                                        SetPricesWep("rifle", MBDPrices_Rifle)
                                        SetPricesWep("shotgun", MBDPrices_Shotgun)
                                    else
                                        SetPricesWep("customListWillOverWriteTheAbove", MBDPrices_CustomListAllWillOverWrite)
                                    end

                                    -- Convert to whole number
                                    if !ShouldUseCustomPriceTable then
                                        ConvertToWholeNumber(MBDPrices_Assault)
                                        ConvertToWholeNumber(MBDPrices_Sidearm)
                                        ConvertToWholeNumber(MBDPrices_Meel)
                                        ConvertToWholeNumber(MBDPrices_Explosive)
                                        ConvertToWholeNumber(MBDPrices_SubMachingun)
                                        ConvertToWholeNumber(MBDPrices_Sniper)
                                        ConvertToWholeNumber(MBDPrices_Rifle)
                                        ConvertToWholeNumber(MBDPrices_Shotgun)
                                    else
                                        ConvertToWholeNumber(MBDPrices_CustomListAllWillOverWrite)
                                    end

                                    local completeListPriceWep = {}
                                    if !ShouldUseCustomPriceTable then
                                        table.Merge(completeListPriceWep, MBDPrices_Assault)
                                        table.Merge(completeListPriceWep, MBDPrices_Sidearm)
                                        table.Merge(completeListPriceWep, MBDPrices_Meel)
                                        table.Merge(completeListPriceWep, MBDPrices_Explosive)
                                        table.Merge(completeListPriceWep, MBDPrices_SubMachingun)
                                        table.Merge(completeListPriceWep, MBDPrices_Sniper)
                                        table.Merge(completeListPriceWep, MBDPrices_Rifle)
                                        table.Merge(completeListPriceWep, MBDPrices_Shotgun)
                                    else
                                        table.Merge(completeListPriceWep, MBDPrices_CustomListAllWillOverWrite)
                                    end
                                    -- -
                                    MBDPrices_Other = {}
                                    MBDPrices_Ammo = {}
                                    MBDPrices_Attachments = {}
                                    SetPrices("other", MBDPrices_Other)
                                    SetPrices("ammo", MBDPrices_Ammo)
                                    SetPrices("attachments", MBDPrices_Attachments)

                                    -- Convert to whole number
                                    ConvertToWholeNumber(MBDPrices_Other)
                                    ConvertToWholeNumber(MBDPrices_Ammo)
                                    ConvertToWholeNumber(MBDPrices_Attachments)
                                    -- -
                                    -- -- -
                                    -- Allowed (SAVE THE ALLOWED ONES NOW)
                                    MBDallowedWeaponClasses_Engineer = {}
                                    MBDallowedWeaponClasses_Mechanic = {}
                                    MBDallowedWeaponClasses_Medic = {}
                                    MBDallowedWeaponClasses_Terminator = {}
                                    SetAllowedWep("engineer", MBDallowedWeaponClasses_Engineer)
                                    SetAllowedWep("mechanic", MBDallowedWeaponClasses_Mechanic)
                                    SetAllowedWep("medic", MBDallowedWeaponClasses_Medic)
                                    SetAllowedWep("terminator", MBDallowedWeaponClasses_Terminator)
                                    local completeListAllWep = {}
                                    table.Add(completeListAllWep, MBDallowedWeaponClasses_Engineer)
                                    table.Add(completeListAllWep, MBDallowedWeaponClasses_Mechanic)
                                    table.Add(completeListAllWep, MBDallowedWeaponClasses_Medic)
                                    table.Add(completeListAllWep, MBDallowedWeaponClasses_Terminator)
                                    --
                                    MBDallowedOtherClasses_Engineer = {}
                                    MBDallowedOtherClasses_Mechanic = {}
                                    MBDallowedOtherClasses_Medic = {}
                                    MBDallowedOtherClasses_Terminator = {}
                                    SetAllowedOther("engineer", MBDallowedOtherClasses_Engineer)
                                    SetAllowedOther("mechanic", MBDallowedOtherClasses_Mechanic)
                                    SetAllowedOther("medic", MBDallowedOtherClasses_Medic)
                                    SetAllowedOther("terminator", MBDallowedOtherClasses_Terminator)
                                    local completeListOther = {}
                                    table.Add(completeListOther, MBDallowedOtherClasses_Engineer)
                                    table.Add(completeListOther, MBDallowedOtherClasses_Mechanic)
                                    table.Add(completeListOther, MBDallowedOtherClasses_Medic)
                                    table.Add(completeListOther, MBDallowedOtherClasses_Terminator)
                                    
                    
                                    MsgC(Color(0, 170, 255), "M.B.D.: (2 of 4) Done writing custom BuyBox data.\n")
                                    -- -
                                    -- Check if any weapons or other allowed does not have a Price, and will be free
                                    -- -
                                    -- Weapons
                                    MsgC(Color(0, 170, 255), "M.B.D.: (3 of 4) Handling the custom BuyBox data...\n")
                                    local classesAddedToOneTableWeaponPrice = {}
                                    local classesAddedToOneTableWeaponPriceFree = {}
                                    -- - -
                                    -- Weapons and Other
                                    local temp_completeListPriceWep = {}
                                    local temp_completeListPriceOther = {}
                                    local temp_completeListPriceCustom = {}

                                    if !ShouldUseCustomPriceTable then
                                        FilterOutNotAllowed(temp_completeListPriceWep, completeListPriceWep, completeListAllWep) -- Weapon
                                        FilterOutNotAllowed(temp_completeListPriceOther, MBDPrices_Other, completeListOther) -- Other
                                    else
                                        FilterOutNotAllowed(temp_completeListPriceCustom, MBDPrices_CustomListAllWillOverWrite, completeListAllWep) -- Custom ( wep. )
                                        FilterOutNotAllowed(temp_completeListPriceOther, MBDPrices_Other, completeListOther) -- Other
                                    end
                                    --
                                    -- -- -
                                    --
                                    timer.Simple(0.3, function()
                                        if !ShouldUseCustomPriceTable then
                                            MakePriceFreeFromPriceToAllowed(temp_completeListPriceWep, completeListAllWep) -- Weapon
                                            MakePriceFreeFromPriceToAllowed(temp_completeListPriceOther, completeListOther) -- Other
                                        else
                                            MakePriceFreeFromPriceToAllowed(temp_completeListPriceCustom, completeListAllWep) -- Custom ( wep. )
                                            MakePriceFreeFromPriceToAllowed(temp_completeListPriceOther, completeListOther) -- Other
                                        end

                                        timer.Simple(1.5, function()
                                            --- -- -
                                            -- - - Check if every class is valid (that the server has the values)
                                            -- .. AND Clean up up the non valid weapon classes for this server
                                            local serverWepListClasses = list.Get("Weapon")
                                            local serverOtherListClasses = list.Get("SpawnableEntities")

                                            local temp_completeListWep = {}
                                            local temp_completeListOther = {}
                                            local FilterOutOnlyAllowedWeapons = function(classType, _table)
                                                local temp_newFilteredValidData = {}
                                                local tableToCheckIn

                                                if classType then
                                                    if classType == "other" then tableToCheckIn = serverOtherListClasses
                                                    elseif classType == "weapon" then tableToCheckIn = serverWepListClasses end

                                                    local maxI = #_table
                                                    for i, entClass in pairs(_table) do
                                                        -- if entClass == "item_rpg_round" then entClass = "rpg_round" end

                                                        if tableToCheckIn[entClass] and !temp_newFilteredValidData[entClass] then
                                                            table.insert(temp_newFilteredValidData, entClass)
                                                        end if i == maxI then _table = temp_newFilteredValidData end
                                                    end
                                                end
                                            end
                                            FilterOutOnlyAllowedWeapons("weapon", MBDallowedWeaponClasses_Engineer)
                                            FilterOutOnlyAllowedWeapons("weapon", MBDallowedWeaponClasses_Mechanic)
                                            FilterOutOnlyAllowedWeapons("weapon", MBDallowedWeaponClasses_Medic)
                                            FilterOutOnlyAllowedWeapons("weapon", MBDallowedWeaponClasses_Terminator)

                                            FilterOutOnlyAllowedWeapons("other", MBDallowedOtherClasses_Engineer)
                                            FilterOutOnlyAllowedWeapons("other", MBDallowedOtherClasses_Mechanic)
                                            FilterOutOnlyAllowedWeapons("other", MBDallowedOtherClasses_Medic)
                                            FilterOutOnlyAllowedWeapons("other", MBDallowedOtherClasses_Terminator)

                                            -- Wait for the lists above to get loaded...
                                            timer.Simple(0.6, function()
                                                -- Save & Generate Whitelist
                                                if !ShouldUseCustomPriceTable then
                                                    MBDPrices_Assault = temp_completeListPriceWep
                                                    MBDPrices_Other = temp_completeListPriceOther
                                                else
                                                    MBDPrices_CustomListAllWillOverWrite = temp_completeListPriceCustom
                                                end

                                                MBDGenerateWhiteListForBuyBox(aCustomGeneratedListFromGameOption, ShouldUseCustomPriceTable)
                                                
                                                MsgC(Color(170, 255, 0), "M.B.D.: (4 of 4) Done handling the custom BuyBox data. Everything should be 100 % OK Finished.\n")
                                            end)
                                        end)
                                    end)
                                else
                                    MsgC(Color(170, 255, 0), "M.B.D.: (0) Not going custom with the BuyBox data.\n")

                                    -- Use the default settings
                                    MBDGenerateWhiteListForBuyBox(aCustomGeneratedListFromGameOption, ShouldUseCustomPriceTable)
                                end
                            end
                        end)
                    end
                end)
            end)
        end timer.Simple(9, MBDCreateBuyBoxConfigFilesAndTablesSERVER)
    end
end
