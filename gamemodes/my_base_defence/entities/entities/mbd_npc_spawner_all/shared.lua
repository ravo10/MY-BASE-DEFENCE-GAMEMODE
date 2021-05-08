util.PrecacheModel("models/npcspawner/npcspawner.mdl")

ENT.Base            = "base_entity"  --garrysmod\gamemodes\base\entities\entities
ENT.Type            = "anim"
ENT.ClassName       = "mbd_npc_spawner_all"
ENT.Category        = "M.B.D."
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.PrintName		= "NPC Spawner (M.B.D.)"
ENT.Author			= "ravo (Norway)"
ENT.Contact			= "N/A"
ENT.Purpose			= "To spawn NPCs in the gamemode M.B.D."
ENT.Instructions	= "Place it wherever you want NPCs to spawn; they will pop out in-front of the prop. Press the \"USE_KEY\" to change NPC type."

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "StartNewAnimationSequence")
    self:NetworkVar("Bool", 1, "AnIntervalIsCurrentlyRunning")
    self:NetworkVar("Bool", 2, "OneNPCStriderSpawnedThisRound")
    self:NetworkVar("Bool", 3, "OneNPCCombineGunShipSpawnedThisRound")
    self:NetworkVar("Bool", 4, "OneNPCHelicopterSpawnedThisRound")
    
    self:NetworkVar("Int", 0, "ThisThinkRoundWave")
    self:NetworkVar("Int", 1, "IntervalIntensityThisRound")
    self:NetworkVar("Int", 2, "AmountOfEnemiesThisRound")
    self:NetworkVar("Int", 3, "CompensatorAmountOfEnemiesThisRound")
    self:NetworkVar("Int", 4, "CurrentZombiePos")
    self:NetworkVar("Int", 5, "CurrentCombinePos")
    self:NetworkVar("Int", 6, "LastTimeCheckedIfNPCsHaveAnEnemy")
    self:NetworkVar("Int", 7, "LastTimeCheckedIfAnyNPCsDontLikeEachOther")

    self:NetworkVar("String", 0, "SpawnType")
    
    -- First time setup
    if SERVER then
        -- BOOLEAN
        self:SetStartNewAnimationSequence(true)
        self:SetAnIntervalIsCurrentlyRunning(false)
        self:SetOneNPCStriderSpawnedThisRound(false)
        self:SetOneNPCCombineGunShipSpawnedThisRound(false)
        self:SetOneNPCHelicopterSpawnedThisRound(false)
        -- INT
        self:SetLastTimeCheckedIfNPCsHaveAnEnemy(CurTime())
        self:SetThisThinkRoundWave(0)
        self:SetIntervalIntensityThisRound(0)
        self:SetAmountOfEnemiesThisRound(0)
        self:SetCompensatorAmountOfEnemiesThisRound(0)
        self:SetCurrentZombiePos(1)
        self:SetCurrentCombinePos(1)
        -- STRING
        self:SetSpawnType("all")
    end
end
