if engine.ActiveGamemode() == "my_base_defence" then
    local metaTablePlayerRef = FindMetaTable("Player")

    -- To later check if weapon class is installed on server
    MBDLoadedServerWeaponClassList = nil
    timer.Simple( 5, function()

        local tempLoadedServerWeaponClassList = list.Get( "Weapon" )
        local tempLoadedServerWeaponClassListLength = #table.GetKeys( tempLoadedServerWeaponClassList )
        local newTable = {}

        local _i = 0
        for wepKey, wepTable in pairs( tempLoadedServerWeaponClassList ) do
            class = wepTable[ "ClassName" ] if not class then class = wepKey end

            newTable[ class ] = class

            _i = _i + 1 if _i == tempLoadedServerWeaponClassListLength then MBDLoadedServerWeaponClassList = newTable end
        end

    end )

    if SERVER or CLIENT then

        -- << FOR M.B.D. >> --
        function MBDGetClassNameForPlayerClass(classInt, NiceName, upperCase)
            local setName = function(className)
                if not NiceName then
                    if not upperCase then return string.lower(className) end

                    return string.upper(className)
                end

                return className
            end

            if (classInt == 0) then return setName("Engineer")
            elseif (classInt == 1) then return setName("Mechanic")
            elseif (classInt == 2) then return setName("Medic")
            elseif (classInt == 3) then return setName("Terminator") else return setName("No Class") end
        end
        function MBDGetClassIntFromClassName(className)
            className = string.lower(className)

            if (className == "engineer") then return 0
            elseif (className == "mechanic") then return 1
            elseif (className == "medic") then return 2
            elseif (className == "terminator") then return 3 else return -1 end
        end

        -- Lobby/Class System
        function metaTablePlayerRef:MBDChangeClassesTableValue(traceID, _table, className, doSetClassIntPly, decrease)
			-- print("\"MBDChangeClassesTableValue\" traceID:", traceID)

			if not _table then print("M.B.D.: (\"MBDChangeClassesTableValue\") Could not predict Classes, because table was nil. ID:", traceID) return end
			if not className then print("M.B.D.: (\"MBDChangeClassesTableValue\") Could not predict Classes, because class name was nil. ID:", traceID) return end

            local tableClassRef = _table[className]
            if not tableClassRef then print("M.B.D.: (\"MBDChangeClassesTableValue\") Could not predict Classes, because table class was nil. Ref.:", _table, className, "ID:", traceID) return end

			if decrease then
				if tableClassRef.taken > 0 then
					tableClassRef.taken = (tableClassRef.taken - 1)

					if doSetClassIntPly then self:SetNWInt("classInt", MBDGetClassIntFromClassName(className)) end
				end
			else
				if tableClassRef.taken < tableClassRef.total then
					tableClassRef.taken = (tableClassRef.taken + 1)

					if doSetClassIntPly then self:SetNWInt("classInt", MBDGetClassIntFromClassName(className)) end
				end
			end
        end
        function metaTablePlayerRef:RemoveFromClassSystem(classesAvailable, classData)
            -- RESET THE PLAYERCLASSES TABLE FOR WHAT THE CLASS THE PLAYER HAD and (+ 1 for taken)
            -- FIND the PLAYERS CLASS NAME
            local plUniqueID = nil
            if self and self:IsValid() then plUniqueID = self:UniqueID() else return end
            for k,v in pairs(classData) do
                if plUniqueID == v.UniqueID then
                    for l,w in pairs(classesAvailable) do
                        if v.ClassName == l then
                            --- RESET FOR PLAYER....
                            player.GetByUniqueID(v.UniqueID):MBDChangeClassesTableValue("4", classesAvailable, l, false, true)

                            -- REMOVE FROM TABLE...
                            table.remove(classData, k)

                            timer.Simple(0, function()
                                -- SEND TO CLIENTs...
                                net.Start("PlayerClassAmount")
                                    net.WriteTable(classesAvailable)
                                net.Broadcast()
                            end)

                            break
                        end
                    end
                end
            end
        end
        -- Admin Checking
        function metaTablePlayerRef:MBDIsAnAdmin(allowNormalAdmins)
            if not self or not self:IsValid() then return false end

            if not allowNormalAdmins then
                if self:IsSuperAdmin() then return true end
            else
                if self:IsSuperAdmin() or self:IsAdmin() then return true end
            end

            return false
        end
        function metaTablePlayerRef:MBDIsNotAnAdmin(checkIfNotSuperAdminOnly)
            if not self or not self:IsValid() then return false end
            
            if not checkIfNotSuperAdminOnly then
                if not self:IsSuperAdmin() then return true end
            else
                if not self:IsSuperAdmin() and not self:IsAdmin() then return true end
            end

            return false
        end
        function metaTablePlayerRef:MBDShouldGetTheAdminBenefits(allowNormalAdmins)
            if !allowNormalAdmins then allowNormalAdmins = false end
            if GetConVar("mbd_superAdminsDontHaveToPay"):GetInt() == 1 and self:MBDIsAnAdmin(allowNormalAdmins) then return true end

            return false
        end
        function metaTablePlayerRef:MBDPlayerCanChangeToNewClass(theCurrentWave, gameStarted)
            local currentWave = theCurrentWave if !currentWave then currentWave = 0 end

            if (
                !gameStarted or (
                    currentWave == 0 or currentWave % 3 == 0 --[[ Every third wave ]] or self:MBDShouldGetTheAdminBenefits(true)
                ) or (
                    ( self:GetNWBool("isSpectating") and GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() > -1 )
                )
            ) then return true end

            return false
        end
        -- Validity
        function metaTablePlayerRef:MBDIsPlayerValidInGame()
            if (
                (
                    self:GetNWBool("isSpectating", false) and
                    GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() == -1 and
                    GameStarted
                ) or self:GetNWInt("classInt", -1) == -1
            ) then return false else return true end
        end
        function metaTablePlayerRef:MBDGiveStuffFirstRoundStart()
            if not self:MBDIsPlayerValidInGame() then return end
            --
            -- BUILD POINTS
            if (self:GetNWInt("classInt", -1) == 0) then -- engineer
                self:SetNWInt("buildPoints", 930)
            else
                self:SetNWInt("buildPoints", 760)
            end
            --
            -- MONEY
            if (self:GetNWInt("classInt", -1) == 1) then -- mechanic
                self:SetNWInt("money", 3000)
            else
                self:SetNWInt("money", 2000)
            end
        end
        -- On Wave Round End
        function metaTablePlayerRef:MBDGiveBuildPointsOnRoundWaveEnd()
            if !self:MBDIsPlayerValidInGame() then return end
        
            if (self:GetNWInt("classInt", -1) == 0) then -- engineer
                self:SetNWInt("buildPoints", (self:GetNWInt("buildPoints") + 108))
            else
                self:SetNWInt("buildPoints", (self:GetNWInt("buildPoints") + 90))
            end
        end
        function metaTablePlayerRef:MBDGiveMoneyOnRoundWaveEnd()
            if !self:MBDIsPlayerValidInGame() then return end
        
            if (self:GetNWInt("classInt", -1) == 1) then -- mechanic
                self:SetNWInt("money", (self:GetNWInt("money") + 900))
            else
                self:SetNWInt("money", (self:GetNWInt("money") + 600))
            end
        end
        function metaTablePlayerRef:MBDGiveHealthOnRoundWaveEnd()
            if !self:MBDIsPlayerValidInGame() then return end
        
            timer.Simple(0.5, function()
                if ((self:Health() + 50) > self:GetMaxHealth()) then
                    self:SetHealth(self:GetMaxHealth())
                else
                    self:SetHealth(self:Health() + 50)
                end
            end)
        end
        -- Health
        function metaTablePlayerRef:MBDSetPlayerHealthToMax(healthAmount)
            self:SetMaxHealth(healthAmount)
        end
        function metaTablePlayerRef:MBDResetPlayerHealthToMax(giveHealth)
            local prevMaxHealth = self:GetMaxHealth()
            
            timer.Simple(0.5, function()
                if (self:GetNWInt("classInt", -1) == 3) then -- terminator
                    self:MBDSetPlayerHealthToMax(995)
                elseif (self:GetNWInt("classInt", -1) == 2) then -- medic
                    self:MBDSetPlayerHealthToMax(800)
                else
                    self:MBDSetPlayerHealthToMax(600)
                end
        
                --
                if (giveHealth) then
                    self:SetHealth(self:GetMaxHealth())
                else
                    -- -- IF the class now chosen have a lower max-health...
                    if (
                        prevMaxHealth > self:GetMaxHealth() and
                        self:Health() > self:GetMaxHealth()
                    ) then
                        -- TAKE OFF HEALTH BASED ON THE PREV. percentage of maxhealth to health
                        self:SetHealth(
                            self:GetMaxHealth() / (prevMaxHealth / self:Health())
                        )
                    end
                end
            end)
        end
        function metaTablePlayerRef:MBDResetPlayerHealthToOriginal()
            timer.Simple(0.5, function()
                self:MBDSetPlayerHealthToMax(100)
                self:SetHealth(100)
            end)
        end
    end
    if SERVER then

        local function CheckIfWeaponClassExistsOnServer( wepClass )

            if MBDLoadedServerWeaponClassList and MBDLoadedServerWeaponClassList[ wepClass ] then return true end

            return false

        end

        -- Get metadata for Players
        function metaTablePlayerRef:MBDStripPlayer()
            self:StripWeapons()
            self:StripAmmo()
        end
        -- Basic Weapons
        function metaTablePlayerRef:MBDGivePlayerDefaultNotClassRelated(traceID)
            -- print("\"metaTablePlayerRef:MBDGivePlayerDefaultNotClassRelated\" traceID:", traceID)
            
            -- Hent klassen via NWVariabel, og gi tilsvarende våpen
                self:Give( "gmod_tool" )
                self:Give( "weapon_physgun" )
                self:Give( "weapon_physcannon" )

                self:Give( "swep_prop_repair")
                if self:IsSuperAdmin() then self:Give( "swep_vehicle_repair" ) end

                self:Give( "weapon_fists" )

                self:SwitchToDefaultWeapon()
        end
        --=>> SET SPECTATOR MODE (AND RESET VALUES...)
        -- SPECTATOR MODE
        function metaTablePlayerRef:MBDGoIntoSpectatorMode(traceID)
            -- print("\"MBDGoIntoSpectatorMode\" Comes from: ", traceID)

            self:SetNWBool("isSpectating", true)

            local spectate = function()
                self:SetNotSolid(true)
                makeEveryNPC_NeutralAgainsPlayer(self)

                self:Spectate(OBS_MODE_ROAMING)

                self:MBDStripPlayer()
            end spectate()

            -- Be 100 % sure...
            timer.Simple(0.6, function()
                if self and self:IsValid() and self:GetNWBool("isSpectating") then spectate() end

                timer.Simple(0.6, function()
                    if self and self:IsValid() and self:GetNWBool("isSpectating") then spectate() end
                end)
            end)
        end
        -- UNSET SPECTATOR MODE
        function metaTablePlayerRef:MBDGoIntoNormalMode(traceID, noTimer, shouldNotGive, spawnFromFunction)
            -- print("\"MBDGoIntoNormalMode\" Comes from: ", traceID)

            local unspectate = function()
                self:SetNWBool("isSpectating", false)

                self:SetNotSolid(false)
                makeEveryNPC_HateAgainsPlayer(self)

                self:Spectate(OBS_MODE_NONE)
                self:UnSpectate()
                
                if not GameStarted or spawnFromFunction then self:Spawn() end

                -- GIVE BASICS..
                if not shouldNotGive then self:MBDGivePlayerDefaultNotClassRelated("7") end
            end

            if noTimer then unspectate() else
                -- VERY IMPORTANT to have this timer delay... (otherwise it will cause buffer overflow...)
                timer.Simple(0.6, unspectate)
            end
        end
        -- A PLAYER CHANGED HIS CLASS
        local GiveSlowly local function giveAmmo(pl, amount, ammoType)
            if !pl or !pl:IsValid() then return end

            pl:GiveAmmo(amount, ammoType, true)
        end
        function metaTablePlayerRef:MBDGivePlayerCorrectStuffClassRelated(traceID, newClassInt)
            -- print("MBDGivePlayerCorrectStuffClassRelated TraceID:", traceID, self, newClassInt)
        
            local rifleAmmoAmount = 61
            local shotgunAmmoAmount = 16
            local pistolAmmoAmount = 21

            local SWEPClasses = {}
            local SWEPClassesFull = {}
            local ammo = {}

            -- Give player his class weapons
            local i = 1 GiveSlowly = function(_table, classInt)
                local swepClass = _table[i] i = i + 1

                -- Settings:
                local WaitTime = 0.6 -- Seconds
                
                if self and self:IsValid() and self:GetNWInt("classInt", -1) == classInt and swepClass then self:Give(swepClass) end
                -- Wait a little...
                timer.Simple(WaitTime, function()
                    if !self or ( self and !self:IsValid() ) then return end

                    if self:GetNWInt("classInt", -1) == -1 then
                        -- Stop - Strip and give default
                        self:MBDStripPlayer()
                        self:MBDGivePlayerDefaultNotClassRelated("5")
                    elseif _table and i <= #_table then GiveSlowly(_table, classInt) end
                end)
            end
            local GivePlayerSWEP = function( tableSWEPClasses ) GiveSlowly(tableSWEPClasses, newClassInt) end
            local MaybeGivePlayerFallbackSWEPClass = function ( wepClassMain, wepClassFallback )

                -- Check if it exists on server...
                if GetConVar( "mbd_alwaysGiveFallbackSweps" ):GetInt() <= 0 and CheckIfWeaponClassExistsOnServer( wepClassMain ) then

                    return { wepClassMain, false }

                end

                return { wepClassFallback, true }

            end
            local MaybeGivePlayerFallbackAmmoTypes = function ( ammoTypes )

                local newAmmoTypeTable = {}

                for _, ammoDataWithFallbackKeyAndAmmoType in pairs( ammoTypes ) do

                    -- [ amount, originalAmmoType, 'SWEPClasses' KEY ID, Fallback Ammo Type ]
                    if (

                        SWEPClassesFull[ ammoDataWithFallbackKeyAndAmmoType[ 3 ] ] and
                        istable( SWEPClassesFull[ ammoDataWithFallbackKeyAndAmmoType[ 3 ] ] ) and
                        SWEPClassesFull[ ammoDataWithFallbackKeyAndAmmoType[ 3 ] ][ 1 ] and
                        SWEPClassesFull[ ammoDataWithFallbackKeyAndAmmoType[ 3 ] ][ 2 ]

                    ) then

                        -- Use the fallback ammo type
                        table.insert( newAmmoTypeTable, { ammoDataWithFallbackKeyAndAmmoType[ 1 ], ammoDataWithFallbackKeyAndAmmoType[ 4 ] } )

                    else table.insert( newAmmoTypeTable, { ammoDataWithFallbackKeyAndAmmoType[ 1 ], ammoDataWithFallbackKeyAndAmmoType[ 2 ] } ) end

                end

                return newAmmoTypeTable

            end

            -- Try for 20 seconds
            local waitUntilNext = 0.1
            local tries = 20 / waitUntilNext
            local function checkIfValid()
                if tries >= 0 and (
                    !self.MBDStripPlayer or
                    !self.MBDGivePlayerDefaultNotClassRelated or
                    !self.Give or
                    !giveAmmo
                ) then tries = (tries - 1) timer.Simple(waitUntilNext, function() checkIfValid() end) elseif (
                    self.MBDStripPlayer and
                    self.MBDGivePlayerDefaultNotClassRelated and
                    self.Give and
                    giveAmmo
                ) then
                    -- Strip again for security...
                    self:MBDStripPlayer()
                    self:MBDGivePlayerDefaultNotClassRelated("6")
                    -- -- -
                    ---
                    --- GIVE PLAYER..
                    --

                    if (newClassInt == 0) then
                        local swepClasses = {
                            -- SIDE ARMS
                            --[[ MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_machete", "weapon_stunstick" ), ]]
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_deagle", "weapon_357" ),
                            -- MAIN
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_rk95", "weapon_ar2" ),
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_g36c", nil ),
                            MaybeGivePlayerFallbackSWEPClass( "weapon_slam", "weapon_slam" )
                        }

                        for _, classData in pairs( swepClasses ) do

                            table.insert( SWEPClasses, classData[ 1 ] )
                            table.insert( SWEPClassesFull, classData )

                        end

                        -- ENGINEER

                        -- Ammo --
                        local ammoTypes = {
                            { pistolAmmoAmount, ".50 AE", 2, "357" },
                            { rifleAmmoAmount, "7.62x39MM", 3, "AR2" },
                            { rifleAmmoAmount, "5.56x45MM", nil, nil }
                        }

                        ammo = MaybeGivePlayerFallbackAmmoTypes( ammoTypes )
                    elseif (newClassInt == 1) then
                        local swepClasses = {
                            -- SIDE ARMS
                            --[[ MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_dv2", "weapon_crowbar" ), ]]
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_p226", "weapon_pistol" ),
                            -- MAIN
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_m67", "weapon_frag" ), -- grenade
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_an94", "weapon_ar2" ),
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_m24", "weapon_crossbow" ),
                            -- UTILITIES
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_ammobox", "weapon_bugbait" ),
                            -- Tools
                            MaybeGivePlayerFallbackSWEPClass( "swep_vehicle_repair", nil )
                        }
                        
                        for _, classData in pairs( swepClasses ) do

                            table.insert( SWEPClasses, classData[ 1 ] )
                            table.insert( SWEPClassesFull, classData )

                        end

                        -- MECHANIC

                        -- Ammo --
                        local ammoTypes = {
                            { pistolAmmoAmount, ".357 SIG", 2, "Pistol" },
                            { rifleAmmoAmount, "5.45x39MM", 4, "AR2" },
                            { pistolAmmoAmount, "7.62x51MM", 5, "XBowBolt" }
                        }

                        ammo = MaybeGivePlayerFallbackAmmoTypes( ammoTypes )
                    elseif (newClassInt == 2) then
                        local swepClasses = {
                            -- SIDE ARMS
                            --[[ MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_machete", "weapon_stunstick" ), ]]
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_ots33", "weapon_pistol" ),
                            -- MAIN
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_mp5sd6", "weapon_smg1" ),
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_m3s90", "weapon_shotgun" ),
                            -- UTILITIES
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_ifak", "weapon_medkit" )
                        }
                        
                        for _, classData in pairs( swepClasses ) do

                            table.insert( SWEPClasses, classData[ 1 ] )
                            table.insert( SWEPClassesFull, classData )

                        end
                        
                        -- MEDIC

                        -- Ammo --
                        local ammoTypes = {
                            { pistolAmmoAmount, "9x18MM", 2, "Pistol" },
                            { rifleAmmoAmount, "9x19MM", 3, "SMG1" },
                            { pistolAmmoAmount, "12 Gauge", 4, "Buckshot" }
                        }

                        ammo = MaybeGivePlayerFallbackAmmoTypes( ammoTypes )
                    elseif (newClassInt == 3) then
                        local swepClasses = {
                            -- SIDE ARMS
                            --[[ MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_machete", "weapon_stunstick" ), ]]
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_ragingbull", "weapon_357" ),
                            -- MAIN
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_m67", "weapon_frag" ), -- grenade
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_rem870", "weapon_shotgun" ),
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_mac11", "weapon_smg1" ),
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_ak47", "weapon_ar2" ),
                            -- UTILITIES
                            MaybeGivePlayerFallbackSWEPClass( "mbd_fas2_ammobox", nil )
                        }
                        
                        for _, classData in pairs( swepClasses ) do

                            table.insert( SWEPClasses, classData[ 1 ] )
                            table.insert( SWEPClassesFull, classData )

                        end
                        
                        -- THE TERMINATOR

                        -- Ammo --
                        local ammoTypes = {
                            { pistolAmmoAmount, ".454 Casull", 2, "357" },
                            { pistolAmmoAmount, "12 Gauge", 4, "Buckshot" },
                            { rifleAmmoAmount, ".380 ACP", 5, "SMG1" },
                            { rifleAmmoAmount, "7.62x39MM", 6, "AR2" }
                        }

                        ammo = MaybeGivePlayerFallbackAmmoTypes( ammoTypes )
                    end

                    -- Give
                    -- SWEPS
                    GivePlayerSWEP( SWEPClasses )
                    -- Ammo
                    for _, ammoData in pairs( ammo ) do giveAmmo( self, ammoData[ 1 ], ammoData[ 2 ] ) end
                    --
                    -- Send new data to CLIENTS
                    net.Start("PlayersClassData")
                        net.WriteTable(PlayersClassData)
                    net.Broadcast()
                end
            end checkIfValid()
        end
        -- Remove all doors created with the MBD door tool
        function metaTablePlayerRef:MBDRemoveAllRelatedDoors()
            if !self or !self:IsValid() then return end
        
            -- Remove doors Player might have created (because when tool is )
            for _,_Door in pairs(ents.FindByName("mbd_prop_door_trigger")) do
                if !self or !self:IsValid() then self = _Door:GetOwner() end
        
                if (
                    _Door and
                    _Door:IsValid() and
                    _Door:GetOwner() == self
                ) then
                    -- Remove door
                    -- LOGIC COPIED FROM THE "mbd_door" TOOL --
                    local _parentEnt = _Door:GetParent()
        
                    _Door:Remove()
        
                    timer.Simple(0.1, function()
                        if !_parentEnt or !_parentEnt:IsValid() then return end
        
                        _parentEnt:SetRenderMode(RENDERMODE_NORMAL)
                        local OriginalColor = string.Split(_parentEnt:GetNWString("OriginalColor"), ",")
                        OriginalColor = {
                            r = tonumber(OriginalColor[1]),
                            g = tonumber(OriginalColor[2]),
                            b = tonumber(OriginalColor[3])
                        }
                        _parentEnt:SetColor(
                            Color(
                                OriginalColor.r,
                                OriginalColor.g,
                                OriginalColor.b,
                                255
                            )
                        )
                        _parentEnt:SetNWString("OriginalColor", "") -- Reset
        
                        _parentEnt:SetNotSolid(false)
                    end)
        
                    -- Everything OK
                    _parentEnt:SetNWBool("hasAMBDDoor", false)
                end
            end
        end
    end
end
