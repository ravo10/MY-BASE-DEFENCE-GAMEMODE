if engine.ActiveGamemode() == "my_base_defence" then
    local metaTablePlayerRef = FindMetaTable("Player")
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
                self:SetNWInt("buildPoints", 54)
            else
                self:SetNWInt("buildPoints", 27)
            end
            --
            -- MONEY
            if (self:GetNWInt("classInt", -1) == 1) then -- mechanic
                self:SetNWInt("money", 2000)
            else
                self:SetNWInt("money", 1000)
            end
        end
        -- On Wave Round End
        function metaTablePlayerRef:MBDGiveBuildPointsOnRoundWaveEnd()
            if !self:MBDIsPlayerValidInGame() then return end
        
            if (self:GetNWInt("classInt", -1) == 0) then -- engineer
                self:SetNWInt("buildPoints", (self:GetNWInt("buildPoints") + 18))
            else
                self:SetNWInt("buildPoints", (self:GetNWInt("buildPoints") + 9))
            end
        end
        function metaTablePlayerRef:MBDGiveMoneyOnRoundWaveEnd()
            if !self:MBDIsPlayerValidInGame() then return end
        
            if (self:GetNWInt("classInt", -1) == 1) then -- mechanic
                self:SetNWInt("money", (self:GetNWInt("money") + 1700))
            else
                self:SetNWInt("money", (self:GetNWInt("money") + 1000))
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
        -- Get metadata for Players
        function metaTablePlayerRef:MBDStripPlayer()
            self:StripWeapons()
            self:StripAmmo()
        end
        -- Basic Weapons
        function metaTablePlayerRef:MBDGivePlayer(traceID)
            -- print("\"metaTablePlayerRef:MBDGivePlayer\" traceID:", traceID)
            
            -- Hent klassen via NWVariabel, og gi tilsvarende våpen
                self:Give("gmod_tool")
                self:Give("weapon_physgun")
                self:Give("weapon_physcannon")

                self:Give("swep_prop_repair")
                if self:IsSuperAdmin() then self:Give("swep_vehicle_repair") end

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
                if not shouldNotGive then self:MBDGivePlayer("7") end
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
        function metaTablePlayerRef:MBDGivePlayerCorrectStuff(traceID, newClassInt)
            -- print("MBDGivePlayerCorrectStuff TraceID:", traceID, self, newClassInt)
        
            local rifleAmmoAmount = 61
            local shotgunAmmoAmount = 16
            local pistolAmmoAmount = 21

            -- Give player his class weapons
            local i = 1 GiveSlowly = function(_table, classInt)
                local swepClass = _table[i] i = i + 1

                -- Settings:
                local WaitTime = 0.6 -- Seconds
                
                if self and self:IsValid() and self:GetNWInt("classInt", -1) == classInt then self:Give(swepClass) end
                -- Wait a little...
                timer.Simple(WaitTime, function()
                    if !self or ( self and !self:IsValid() ) then return end

                    if self:GetNWInt("classInt", -1) == -1 then
                        -- Stop - Strip and give default
                        self:MBDStripPlayer()
                        self:MBDGivePlayer("5")
                    elseif _table and i <= #_table then GiveSlowly(_table, classInt) end
                end)
            end
            local GivePlayerSWEP = function(tableSWEPClasses) GiveSlowly(tableSWEPClasses, newClassInt) end

            -- Try for 20 seconds
            local waitUntilNext = 0.1
            local tries = 20 / waitUntilNext
            local function checkIfValid()
                if tries >= 0 and (
                    !self.MBDStripPlayer or
                    !self.MBDGivePlayer or
                    !self.Give or
                    !giveAmmo
                ) then tries = (tries - 1) timer.Simple(waitUntilNext, function() checkIfValid() end) elseif (
                    self.MBDStripPlayer and
                    self.MBDGivePlayer and
                    self.Give and
                    giveAmmo
                ) then
                    -- Strip again for security...
                    self:MBDStripPlayer()
                    self:MBDGivePlayer("6")
                    -- -- -
                    ---
                    --- GIVE PLAYER..
                    --
                    if (newClassInt == 0) then
                        -- ENGINEER
                        GivePlayerSWEP(
                            {
                                -- SIDE ARMS
                                "mbd_fas2_machete",
                                "mbd_fas2_deagle",
                                -- MAIN
                                "mbd_fas2_rk95",
                                "mbd_fas2_g36c"
                            }
                        )
        
                        -- Ammo --
                        giveAmmo(self, pistolAmmoAmount, ".50 AE")
                        giveAmmo(self, rifleAmmoAmount, "7.62x39MM")
                        giveAmmo(self, rifleAmmoAmount, "5.56x45MM")
                        
                    elseif (newClassInt == 1) then
                        -- MECHANIC
                        GivePlayerSWEP(
                            {
                                -- SIDE ARMS
                                "mbd_fas2_dv2",
                                "mbd_fas2_p226",
                                -- MAIN
                                "mbd_fas2_m67",
                                "mbd_fas2_an94",
                                "mbd_fas2_m24",
                                -- UTILITIES
                                "mbd_fas2_ammobox",
                                -- Tools
                                "swep_vehicle_repair"
                            }
                        )
        
                        -- Ammo --
                        giveAmmo(self, pistolAmmoAmount, ".357 SIG")
                        giveAmmo(self, rifleAmmoAmount, "5.45x39MM")
                        giveAmmo(self, pistolAmmoAmount, "7.62x51MM")
        
                    elseif (newClassInt == 2) then
                        -- MEDIC
                        GivePlayerSWEP(
                            {
                                -- SIDE ARMS
                                "mbd_fas2_machete",
                                "mbd_fas2_ots33",
                                -- MAIN
                                "mbd_fas2_mp5sd6",
                                "mbd_fas2_m3s90",
                                -- UTILITIES
                                "mbd_fas2_ifak"
                            }
                        )
        
                        -- Ammo --
                        giveAmmo(self, pistolAmmoAmount, "9x18MM")
                        giveAmmo(self, rifleAmmoAmount, "9x19MM")
                        giveAmmo(self, pistolAmmoAmount, "12 Gauge")
                        
                    elseif (newClassInt == 3) then
                        -- THE TERMINATOR
                        GivePlayerSWEP(
                            {
                                -- SIDE ARMS
                                "mbd_fas2_machete",
                                "mbd_fas2_ragingbull",
                                -- MAIN
                                "mbd_fas2_m67", -- grenade
                                "mbd_fas2_rem870",
                                "mbd_fas2_mac11",
                                "mbd_fas2_ak47",
                                -- UTILITIES
                                "mbd_fas2_ammobox"
                            }
                        )
        
                        -- Ammo --
                        giveAmmo(self, pistolAmmoAmount, ".454 Casull")
                        giveAmmo(self, pistolAmmoAmount, "12 Gauge")
                        giveAmmo(self, rifleAmmoAmount, ".380 ACP")
                        giveAmmo(self, rifleAmmoAmount, "7.62x39MM")
                    end
                    
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
