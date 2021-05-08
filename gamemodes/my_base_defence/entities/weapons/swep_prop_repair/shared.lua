AddCSLuaFile("shared.lua")

SWEP.PrintName      = "D E F A U L T"
SWEP.Author			= "ravo (Norway)"
SWEP.Contact		= ""
SWEP.Purpose		= "To repair a Prop (M.B.D. Gamemode)"
SWEP.Instructions   = [[
	Left-Click: Repair traced Prop (aim for middle)
	Right-Click: Super Strengthen the Prop (750 B.P.; aim for middle)

	Hold "Speed Bound" Key (def. Shift) while letting go of Left-Click to Point (hold "USE KEY" together, to show location).
	]]
if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID("vgui/mbd/swep_prop_repair/swep_prop_repair")
end

-- Table
function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "CanAddHealthAgain") -- Prevent adding health until ready again
    self:NetworkVar("Bool", 1, "PrimaryIsOn")
    self:NetworkVar("Bool", 2, "PlayFullSound")
    
    if SERVER then
        -- Table
        self.EffectPrimaryOnType = nil
        self.SetEffectPrimaryOnType = function(string, trace, ent, useTracePos)
            self.EffectPrimaryOnType = {string, trace, ent, useTracePos}
        end
        self.GetEffectPrimaryOnType = function()
            return self.EffectPrimaryOnType[1]
        end
        
        --- Set First Time
        self:SetPrimaryIsOn(false)
        self:SetCanAddHealthAgain(true)
        self:SetPlayFullSound(true)
    end
end

-- Skin:
-- swep_vehicle_repair = 0, swep_prop_repair = 1

SWEP.ViewModel	= "models/sweprepair/sweprepair.mdl"
SWEP.WorldModel	= "models/sweprepair_w/sweprepair_w.mdl"

SWEP.ShowViewModel  = true
SWEP.ShowWorldModel = false

-- Pre-cache models
-- -- -
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

SWEP.DrawCrosshair      = false
SWEP.DrawAmmo           = false

SWEP.HoldType           = "camera"

SWEP.ViewModelFOV = 84.221105527638
SWEP.ViewModelFlip      = false

SWEP.Slot               = 5 -- From 0 - 5
SWEP.SlotPos            = 1 -- From 0 - 128
SWEP.BounceWeaponIcon   = true

SWEP.UseHands		= false
SWEP.Spawnable		= false

SWEP.Weight	        = 1
SWEP.AutoSwitchTo   = false
SWEP.AutoSwitchFrom	= false

SWEP.Tool = {}

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"

SWEP.CanHolster             = true
SWEP.CanDeploy              = true

SWEP.ShouldDropOnDie        = false

-- Very important >>
SWEP.IronSightsPos  = Vector(0, 0, 0)
SWEP.IronSightsAng  = Vector(0, 0, 0)
local function GetOriginalViewmodelPosition() -- Original Position (The animation stop point is not perfect!!)
	local t = {}

    -- Adjust the viewmodel offset...
	t["Pos"] = Vector(0, -0.202, -8.643)
	t["Ang"] = Vector(15.477, 0, 0)
    

	return t
end
SWEP.IronSightsPos  = GetOriginalViewmodelPosition().Pos
SWEP.IronSightsAng  = GetOriginalViewmodelPosition().Ang

local SWEPOwner     = nil
local TypeOfSound   = nil

local function swepCleanUp(self)
    -- Clean up
    timer.Remove("mbd:SwepPropRepairAnimation001")
    timer.Remove("mbd:OwnerChangedSwepPropRepair001")
    timer.Remove("mbd:SwepPropRepair001")
    timer.Remove("mbd:animationFunctionToIdlePos")

    if self then self:SetPrimaryIsOn(false) end
end

if CLIENT then
    function SWEP:PostDrawViewModel(vm, pl, weapon)
        local hands = LocalPlayer():GetHands()
        if IsValid(hands) then hands:DrawModel() end
    end
    function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
        local propStatus = self:GetNWString("propStatus", "idle")
        if propStatus == "idle" then
            ViewModel:SetSkin(0)
        elseif propStatus == "good" then
            ViewModel:SetSkin(1)
        elseif propStatus == "worse" then
            ViewModel:SetSkin(2)
        elseif propStatus == "bad" then
            ViewModel:SetSkin(3)
        end
	end

	hook.Add("HUDPaint", "mbd:SWEPSight:PropRepair001", function()
		if !SWEPOwner or !SWEPOwner:IsValid() then return end

		local SWEPOwnerEyeTrace             = SWEPOwner:GetEyeTrace()
		local SWEPOwnerEyeTraceEnt          = SWEPOwnerEyeTrace.Entity

		if (
			SWEPOwner and
			SWEPOwner:IsValid() and
			SWEPOwner:IsPlayer() and
			SWEPOwnerEyeTraceEnt and
			SWEPOwnerEyeTraceEnt:IsValid() and
			SWEPOwner:GetActiveWeapon() and
			SWEPOwner:GetActiveWeapon():IsValid() and
			SWEPOwner:GetActiveWeapon():GetClass() == "swep_prop_repair" and (
				SWEPOwnerEyeTraceEnt:GetClass() == "prop_physics" or
				SWEPOwnerEyeTraceEnt:IsNPC()
			)
		) then
			local SWEPOwnerEyeTraceEntValidMBD = SWEPOwnerEyeTraceEnt:GetNWBool("IsAValidMBDPropOrVehicle", false)

			-- Show if everything is OK >> >
            if SWEPOwnerEyeTraceEntValidMBD or SWEPOwnerEyeTraceEnt:IsNPC() then
                PaintRepairToolIndicator(SWEPOwner, SWEPOwnerEyeTraceEnt)
            end
        elseif (
            SWEPOwner:GetActiveWeapon() and
			SWEPOwner:GetActiveWeapon():IsValid() and
			SWEPOwner:GetActiveWeapon():GetClass() == "swep_prop_repair"
        ) then
            local w = 5
            local h = 2

            -- -- - --
            -- Draw default aim
            local amount = 10
            local amount_i = 1
            local offsetPosEnd = 30
            local offsetPosStart = offsetPosEnd * -1
            local addPoint = offsetPosEnd * 2 / amount

            local alpha = 200

            local currOffsetPos = offsetPosStart
            local i2 = 0
            for i = 1, offsetPosEnd * 2 do
                if i2 == addPoint then
                    i2 = 0

                    -- Draw
                    if amount_i == 5 then
                        surface.SetDrawColor(22, 0, 120, alpha) -- DarkPurple
                    else
                        surface.SetDrawColor(148, 148, 148, alpha) -- lightGray
                    end
                    surface.DrawRect(
                        (ScrW() / 2 - (w / 2)) + currOffsetPos,
                        (ScrH() / 2 - (h / 2)),
                        w,
                        h
                    )

                    amount_i = amount_i + 1
                end

                currOffsetPos = currOffsetPos + 1
                i2 = i2 + 1
            end

            SWEPOwner:GetActiveWeapon():SetNWString("propStatus", "idle")
        end
	end)
    ---
	-- Placement of ViewModel
	function SWEP:GetViewModelPosition(EyePos, EyeAng)
		local Mul = 1.0

		local Offset = self.IronSightsPos

		if (self.IronSightsAng) then
			EyeAng = EyeAng * 1
			
			EyeAng:RotateAroundAxis(EyeAng:Right(), 	self.IronSightsAng.x * Mul)
			EyeAng:RotateAroundAxis(EyeAng:Up(), 		self.IronSightsAng.y * Mul)
			EyeAng:RotateAroundAxis(EyeAng:Forward(),   self.IronSightsAng.z * Mul)
		end

		local Right 	= EyeAng:Right()
		local Up 		= EyeAng:Up()
		local Forward 	= EyeAng:Forward()

		EyePos = EyePos + Offset.x * Right * Mul
		EyePos = EyePos + Offset.y * Forward * Mul
		EyePos = EyePos + Offset.z * Up * Mul
		
		return EyePos, EyeAng
	end

	--- -- ---  >> >
    -- Draw World Model
    local WorldModel = ClientsideModel(SWEP.WorldModel)

    -- Settings...
    WorldModel:SetNoDraw(true)

    function SWEP:DrawWorldModel()
        local _Owner = self:GetOwner()

        if _Owner and _Owner:IsValid() then
            local offsetVec = Vector(2.2, -13, 1.5)
            local offsetAng = Angle(-2, -70, -90)
            
            local boneid = _Owner:LookupBone("ValveBiped.Bip01_Head1")
            if !boneid then return end

            local matrix = _Owner:GetBoneMatrix(boneid)
            if !matrix then return end

            local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

            WorldModel:SetPos(newPos)
            WorldModel:SetAngles(newAng)
            WorldModel:SetModelScale(0.5)

            WorldModel:SetupBones()
        else
            WorldModel:SetPos(self:GetPos())
            WorldModel:SetAngles(self:GetAngles())
        end

        WorldModel:DrawModel()

        local propStatus = self:GetNWString("propStatus", "idle")
        if propStatus == "idle" then
            WorldModel:SetSkin(0)
        elseif propStatus == "good" then
            WorldModel:SetSkin(1)
        elseif propStatus == "worse" then
            WorldModel:SetSkin(2)
        elseif propStatus == "bad" then
            WorldModel:SetSkin(3)
        end
    end
end

if SERVER then
	util.AddNetworkString("OwnerChangedSwepPropRepair")
	util.AddNetworkString("AnimationFunctionSwepPropRepair")
    util.AddNetworkString("SWEPRepairToolProp_TypeOfSound")
    
    function SWEP:OnDrop()
        self:SetModelScale(1)

        swepCleanUp(self)
    end
end
function totallyValidEnt(ent)
    if ent and ent:IsValid() then return true else return false end
end
if CLIENT then
	net.Receive("OwnerChangedSwepPropRepair", function()
		SWEPOwner = net.ReadEntity()
	end)
	net.Receive("AnimationFunctionSwepPropRepair", function()
        local Action = net.ReadString()

        -- Remove timers for animations..
        timer.Remove("mbd:animationFunctionToIdlePos")

        local _Weapon = LocalPlayer():GetWeapon("swep_prop_repair")

		if Action == "start" then
            if totallyValidEnt(_Weapon) then _Weapon:ResetSequenceInfo() end
            if totallyValidEnt(_Weapon) then _Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) end
		elseif Action == "end" then
            if totallyValidEnt(_Weapon) then _Weapon:ResetSequenceInfo() end
            if totallyValidEnt(_Weapon) then _Weapon:SendWeaponAnim(ACT_VM_LOWERED_TO_IDLE) end

            timer.Create("mbd:animationFunctionToIdlePos", 1.41, 1, function()
                if totallyValidEnt(_Weapon) then _Weapon:SendWeaponAnim(ACT_VM_IDLE) end
            end)
		elseif Action == "end_idle" then
            if totallyValidEnt(_Weapon) then _Weapon:ResetSequenceInfo() end
            if totallyValidEnt(_Weapon) then _Weapon:SendWeaponAnim(ACT_VM_IDLE) end
        elseif Action == "start_superProp" then
            if totallyValidEnt(_Weapon) then _Weapon:ResetSequenceInfo() end
            if totallyValidEnt(_Weapon) then _Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK) end
        end
	end)
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	
    local temp = {}

	for k,v in pairs(self.Tool) do
		temp[k]             = table.Copy(v)
		temp[k].SWEP        = self
		temp[k].Owner       = self.Owner
        temp[k].Weapon      = self.Weapon
        
		temp[k]:Init()
	end

    self.Tool = temp
end
function SWEP:Deploy()
	local _Owner = self:GetOwner()
	
	if SERVER then
		timer.Create("mbd:OwnerChangedSwepPropRepair001", 0.3, 1, function()
			timer.Remove("mbd:OwnerChangedSwepPropRepair001")

			net.Start("OwnerChangedSwepPropRepair")
				net.WriteEntity(_Owner)
			net.Send(_Owner)
		end)
	end

    return true
end
--
-- ICON
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	-- Lets get a sin wave to make it bounce
	local fsin = 0 if self.BounceWeaponIcon == true then fsin = math.sin(SysTime() * 30) * 2 end

	-- Adjust
	local size = 0.6
	local newWide = wide * size - 10
	local newTall = tall * size

	-- Draw that mother HUDer
	surface.SetDrawColor(255, 255, 255, 255)
    
    surface.SetTexture(self.WepSelectIcon)
    surface.DrawTexturedRect(
        (x + fsin) + newWide / 3 + 10 - 3,
        (y - fsin) + newTall / 3 - 5,
        newWide - fsin * 2,
        newTall + fsin
    )

	-- Draw weapon info. box
	self:PrintWeaponInfo(x + wide, y + tall, alpha)
end
--- -
local function IsValidEasterEggForSuperAdmin(pl)
    if SERVER then
        if pl:MBDShouldGetTheAdminBenefits() then return true else return false end
    end
end
local function IsNotValidEasterEggForSuperAdmin(pl)
    if SERVER then
        if !pl:MBDShouldGetTheAdminBenefits() then return true else return false end
    end
end
local function SendNotification(pl, message, type, time)
    if SERVER then
        net.Start("NotificationReceivedFromServer")
            net.WriteTable({
                Text 	= message,
                Type	= type,
                Time	= time
            })
        net.Send(pl)
    end
end
local function checkIfWitinHealingArea(ent, _Owner)
    if !ent or ( ent and !ent:IsValid() ) then return end
    
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
                -- Cancel...
                return false
            end

            return true
        end
    end
end
--
-- -
local avsluttAnimasjonEnd = function(self, owner)
    if SERVER then
        timer.Create("mbd:SwepPropRepairAnimation001", 2, 1, function()
            self:SetPrimaryIsOn(false)
            self.SetEffectPrimaryOnType(nil)
            owner:SetAnimation(PLAYER_IDLE)

            net.Start("AnimationFunctionSwepPropRepair", true)
                net.WriteString("end")
            net.Send(owner)
        end)
    end
end
local avsluttAnimasjonIdle = function(self, owner)
    if SERVER then
        timer.Create("mbd:SwepPropRepairAnimation001", 2, 1, function()
            self:SetPrimaryIsOn(false)
            self.SetEffectPrimaryOnType(nil)
            owner:SetAnimation(PLAYER_IDLE)

            net.Start("AnimationFunctionSwepPropRepair", true)
                net.WriteString("end_idle")
            net.Send(owner)
        end)
    end
end

function SWEP:PrimaryAttack()
	timer.Remove("mbd:SwepPropRepairAnimation001")

	local _Owner    = self.Owner
    local _Weapon   = self.Weapon

    local _Trace = _Owner:GetEyeTrace()

    _Weapon:SetNextPrimaryFire(CurTime() + 1.8)

    if SERVER then _Trace.Entity = GetCorrectEntForProps(_Trace.Entity) end
    local ent = _Trace.Entity

   if ent and ent:IsValid() then
        local totalHealth	= ent:GetNWInt("healthTotal", -1)
        local leftHealth	= ent:GetNWInt("healthLeft", -1)

        -- Animation
        if SERVER and leftHealth < totalHealth then
            self:SetPrimaryIsOn(true)
            _Owner:SetAnimation(PLAYER_ATTACK1)

            net.Start("AnimationFunctionSwepPropRepair", true)
                net.WriteString("start")
            net.Send(_Owner)

            avsluttAnimasjonEnd(self, _Owner)
        end
    else avsluttAnimasjonEnd(self, _Owner) end
    -- -- -
    -- -
    --
    if !ent or !ent:IsValid() then self:SetPrimaryIsOn(false) avsluttAnimasjonIdle(self, _Owner) return false end

    -- Make it damage NPCs that are not NPC Bullseye a little
    if SERVER and ent:IsNPC() and MBD_CheckIfNotBullseyeEntity(ent:GetClass()) then
         -- Check that the distance is OK >>
        local PosOwner  = _Owner:GetPos()
        local PosEnt    = ent:GetPos()

        local _Distance = PosOwner:Distance(Vector(PosEnt.x, PosEnt.y, PosOwner.z))
        if _Distance > 60 then self:SetPrimaryIsOn(false) avsluttAnimasjonIdle(self, _Owner) return false end
        
        local d = DamageInfo()

        if (
            -- Easter Egg
            IsValidEasterEggForSuperAdmin(_Owner)
        ) then d:SetDamage(1000) else d:SetDamage(3) end
        d:SetAttacker(_Owner)
        d:SetInflictor(_Weapon)
        d:SetDamageType(DMG_CLUB)

        ent:TakeDamageInfo(d)

        local t = math.random(1, 2)
        local sound = ""
        if t == 1 then TypeOfSound = "bang1" else TypeOfSound = "bang2" end

        if SERVER then self.SetEffectPrimaryOnType({"BloodImpact", _Trace, ent, false}) end
        
        net.Start("SWEPRepairToolProp_TypeOfSound")
            net.WriteString(TypeOfSound)
        net.Send(_Owner)
    
        return true
    end

    if !checkIfWitinHealingArea(ent, _Owner) then self:SetPrimaryIsOn(false) avsluttAnimasjonIdle(self, _Owner) return end

    local _Class = ent:GetClass()
    if _Class != "prop_physics" then return false end

    -- Heal
    local HealthLeft 	= ent:GetNWInt("healthLeft", -1)
    local HealthTotal 	= ent:GetNWInt("healthTotal", -1)

    if HealthLeft == -1 or HealthTotal == -1 then return false end

    if HealthLeft >= HealthTotal then
        self:SetPrimaryIsOn(false)
        avsluttAnimasjonIdle(self, _Owner)

        -- Sound Emit
		if !timer.Exists("mbd:SwepPropRepair001") then
            TypeOfSound = "full"
            
            if SERVER then
                net.Start("SWEPRepairToolProp_TypeOfSound")
                    net.WriteString(TypeOfSound)
                net.Send(_Owner)
            end
            --
            --- -- ->
            timer.Create("mbd:SwepPropRepair001", math.random(5, 10) / 10, 1, function()
                timer.Remove("mbd:SwepPropRepair001")
            end)
        end

        return false
    else avsluttAnimasjonEnd(self, _Owner) end

    if (
        HealthLeft 	== -1 or
        HealthTotal == -1 or
        !self:GetCanAddHealthAgain() or
        !_Owner:IsValid()
    ) then return false end

    if HealthLeft < HealthTotal then
        self:SetCanAddHealthAgain(false)
        -- Add Health
        -- -- ->>
        local newHealth = HealthLeft + 80
        if _Owner:GetNWInt("classInt", -1) == 0 or _Owner:IsSuperAdmin() then newHealth = HealthLeft + 160 end -- Engineer
        if newHealth > HealthTotal then newHealth = HealthTotal end

        if SERVER then ent:SetNWInt("healthLeft", newHealth) end

        timer.Simple(0.65, function()
            --
            --- OK again >>
            self:SetCanAddHealthAgain(true)
        end)
    end
    
    -- Sound Emit
    if !timer.Exists("mbd:SwepPropRepair001") then
        TypeOfSound = "healing"
        if SERVER then self.SetEffectPrimaryOnType({"StunstickImpact", nil, ent, true}) end

       if SERVER then
            net.Start("SWEPRepairToolProp_TypeOfSound")
                net.WriteString(TypeOfSound)
            net.Send(_Owner)
        end
        --
        --- -- ->
        timer.Create("mbd:SwepPropRepair001", 0.33, 1, function()
            timer.Remove("mbd:SwepPropRepair001")
        end)
    end

    return true
end
function SWEP:SecondaryAttack()
    timer.Remove("mbd:SwepPropRepairAnimation001")
    
    -- Superstrengthen the prop (add more total health and fill up health left to)
    --- -
    local _Owner    = self.Owner
    local _Weapon   = self.Weapon

    local _Trace    = _Owner:GetEyeTrace()

    _Weapon:SetNextSecondaryFire(CurTime() + 3)
    -- -- -
    -- -
    --
    if SERVER then _Trace.Entity = GetCorrectEntForProps(_Trace.Entity) end
    local ent = _Trace.Entity

	if !ent or !ent:IsValid() then return false end
	
	-- Check that the distance is OK >>
    local PosOwner  = _Owner:GetPos()
    local PosEnt    = ent:GetPos()

    -- Make it damage NPCs that are not NPC Bullseye a little
    if SERVER and ent:IsNPC() and MBD_CheckIfNotBullseyeEntity(ent:GetClass()) then
        local _Distance = PosOwner:Distance(Vector(PosEnt.x, PosEnt.y, PosOwner.z))
        if _Distance > 60 then return false end

        if ent and ent:IsValid() then
            -- Animation
            _Owner:SetAnimation(PLAYER_ATTACK1)
    
            if SERVER then
                net.Start("AnimationFunctionSwepPropRepair", true)
                    net.WriteString("start_superProp")
                net.Send(_Owner)
            end
    
            avsluttAnimasjonIdle(self, _Owner)
        else avsluttAnimasjonIdle(self, _Owner) end
        
        local d = DamageInfo()

        if (
            -- Easter Egg
            IsValidEasterEggForSuperAdmin(_Owner)
        ) then d:SetDamage(2000) else d:SetDamage(12) end
        d:SetAttacker(_Owner)
        d:SetInflictor(_Weapon)
        d:SetDamageType(DMG_CLUB)

        ent:TakeDamageInfo(d)

        local t = math.random(1, 2)
        local sound = ""
        if t == 1 then sound = "swep/metal_bang1.wav" else sound = "swep/metal_bang2.wav" end
        if CLIENT then
            MBDSetSoundAndEntity(
                _Owner,
                sound,
                "100, 110"
            )
		end
		if SERVER then self.SetEffectPrimaryOnType({"BloodImpact", _Trace, ent, false}) end
    
        return true
    end

    if !checkIfWitinHealingArea(ent, _Owner) then return end

    local IsAlreadyUpgraded = ent:GetNWBool("ThisPropIsUpgradedHealth", false)
    return timer.Simple(0.1, function()
        if SERVER then
            if (
                IsAlreadyUpgraded and
                (
                    (
                        IsNotValidEasterEggForSuperAdmin(_Owner)
                    ) or !_Owner:IsSuperAdmin()
                )
            ) then
                -- Notify
                SendNotification(
                    _Owner,
                    "This Prop is already Super Strong!",
                    NOTIFY_ERROR,
                    4
                )
            
                return false
            end

            -- - Add Health
            --- -- > >>
            -- Check if Player has enough build points>>>
            local PlayerCurrentBP = _Owner:GetNWInt("buildPoints", -1)

            return timer.Simple(0.2, function()
                -- Cancel
                local costForUpgrade = 750
                if (
                    (
                        (
                            IsNotValidEasterEggForSuperAdmin(_Owner)
                        ) or !_Owner:IsSuperAdmin()
                    ) and PlayerCurrentBP < costForUpgrade
                ) then
                    -- Notify
                    SendNotification(
                        _Owner,
                        "You need atleast 750 B.P. to make it Super Strong!",
                        NOTIFY_ERROR,
                        4
                    )
                    
                    return false
                end

                -- OK >> Add New Max Health to Prop, and Add Health
                -- - -->>
                local HealthTotalProp   = ent:GetNWInt("healthTotal", -1)
                local HealthLeftProp    = ent:GetNWInt("healthLeft", -1)
                
                return timer.Simple(0.2, function()
                    if HealthTotalProp == -1 or HealthLeftProp == -1 then return false end

                    if ent and ent:IsValid() then
                        -- Animation
                        _Owner:SetAnimation(PLAYER_ATTACK1)
                
                        if SERVER then
                            net.Start("AnimationFunctionSwepPropRepair", true)
                                net.WriteString("start_superProp")
                            net.Send(_Owner)
                        end
                
                        avsluttAnimasjonIdle(self, _Owner)
                    else avsluttAnimasjonIdle(self, _Owner) end

                    -- Increase locally
                    local AddThisHealth = 2000
                    if _Owner:GetNWInt("classInt", -1) == 0 then AddThisHealth = 3000 end -- Engineer
                    if _Owner:IsSuperAdmin() then AddThisHealth = 5000 end
                    HealthTotalProp = HealthTotalProp   + AddThisHealth
                    HealthLeftProp  = HealthLeftProp    + AddThisHealth

                    -- Save globally
                    ent:SetNWInt("healthTotal", HealthTotalProp)
                    ent:SetNWInt("healthLeft",  HealthLeftProp)
                    ent:SetNWInt("propIsAddedSuperStrongNumberTimes", ent:GetNWInt("propIsAddedSuperStrongNumberTimes", 0) + 1)

                    -- Tell Player... >>
                    -- Notify
                    if (
                        IsValidEasterEggForSuperAdmin(_Owner)
                    ) then
                        -- SuperAdmin
                        SendNotification(
                            _Owner,
                            "Super Strengthened Prop (added "..AddThisHealth.." Health)!",
                            NOTIFY_GENERIC,
                            5
                        )
                    else
                        SendNotification(
                            _Owner,
                            "Super Strengthened Prop (added "..AddThisHealth.." Health)! Cost you "..costForUpgrade.." B.P.",
                            NOTIFY_GENERIC,
                            5
                        )
                    end

                    -- If not SuperAdmin, take some B.P.
                    --- --
                    if (
                        (
                            IsNotValidEasterEggForSuperAdmin(_Owner)
                        ) or !_Owner:IsSuperAdmin()
                    ) then _Owner:SetNWInt("buildPoints", (PlayerCurrentBP - costForUpgrade)) end

                    -- Mark it as upgraded, so you can not upgrade it more....
                    ent:SetNWBool("ThisPropIsUpgradedHealth", true)
                    
                    return true
                end)
            end)
        end
    end)
end
function SWEP:Holster(wep)
    swepCleanUp(self)
    if not IsFirstTimePredicted() then return end
    
    return true
end
-- - >> >
local ASoundIsPlaying = false
if CLIENT then
    net.Receive("SWEPRepairToolProp_TypeOfSound", function()
        TypeOfSound = net.ReadString()
    end)
end
function SWEP:Think()
    if CLIENT then
        local Ent = GetCorrectEntForProps(LocalPlayer():GetEyeTrace().Entity)

        if Ent and Ent:IsValid() then
            -- local _Owner = Ent:GetNWEntity("PlayerOwnerEnt", nil)

            -- Health for Prop/Vehicle
            local totalHealth	= Ent:GetNWInt("healthTotal", -1)
            local leftHealth	= Ent:GetNWInt("healthLeft", -1)

            local plyWep = self.Weapon

            if (totalHealth != -1 and leftHealth != -1) and string.match(Ent:GetClass(), "prop") and !Ent:IsNPC() and !Ent:IsVehicle() then
                -- Change the body-group of SWEP...
                if plyWep && plyWep:IsValid() then
                    local _Color = getCorrectHealthColor(((leftHealth / totalHealth) * 100), {
                        Color(189, 235, 8, 245), -- YellowGreen (not max health, but OK)
                        Color(227, 120, 8, 200), -- Orange
                        Color(235, 47, 8, 200) -- Red
                    })

                    if _Color.r == 113 then
                        -- 100%
                        plyWep:SetNWString("propStatus", "good")
                    elseif _Color.r == 189 then
                        -- Almost 100%
                        plyWep:SetNWString("propStatus", "good")
                    elseif _Color.r == 227 then
                        -- Bad
                        plyWep:SetNWString("propStatus", "worse")
                    elseif _Color.r == 235 then
                        -- Very bad
                        plyWep:SetNWString("propStatus", "bad")
                    end
                end
            end
        end
    end
    if SERVER then
        if self:GetPrimaryIsOn() then
            -- Play animation..
            local effectTable = self.GetEffectPrimaryOnType()
            if effectTable then
                if effectTable[4] and self.Owner and self.Owner:IsValid() then
                    local eyeTrace = self.Owner:GetEyeTrace()
                    if eyeTrace.Entity and eyeTrace.Entity:IsValid() then effectTable[2] = eyeTrace end
                end

                if checkIfWitinHealingArea(effectTable[3], self.Owner) then WeaponHitEffect(effectTable[1], effectTable[2], effectTable[3], effectTable[4]) end
            end
        end
        --- -
        -- --  >> >> >
        if !ASoundIsPlaying and TypeOfSound then
            ASoundIsPlaying = true

            timer.Simple(0.03, function()
                if TypeOfSound == "full" and self:GetPlayFullSound() then
                    self:SetPlayFullSound(false)

                    local soundTypeString = math.random( 1, 4 )
                    local soundString = "swep/prop_ok0.wav"
                    if soundTypeString == 4 then soundString = "swep/prop_ok2.wav" end

                    MBDSetSoundAndEntity(
                        self,
                        soundString,
                        "100, 110",
                        3
                    )

                    timer.Simple( math.random( 3, 6 ), function() self:SetPlayFullSound(true) end )
                elseif TypeOfSound == "healing" then
                    MBDSetSoundAndEntity(
                        self,
                        "swep/welding.wav",
                        "100, 105"
                    )
                -- Hitting lika NPC ors
                elseif TypeOfSound == "bang1" then
                    MBDSetSoundAndEntity(
                        self,
                        "swep/metal_bang1.wav",
                        "100, 110"
                    )
                elseif TypeOfSound == "bang2" then
                    MBDSetSoundAndEntity(
                        self,
                        "swep/swep/metal_bang2.wav",
                        "100, 110"
                    )
                end
    
                -- Reset
                timer.Simple(0.02, function()
                    TypeOfSound = nil
    
                    ASoundIsPlaying = false
                end)
            end)
        end
    end
end