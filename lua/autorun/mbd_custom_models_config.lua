if engine.ActiveGamemode() == "my_base_defence" then -- Very important
	AddCSLuaFile()

	MBDCustomKeyToModelNPCs = {
		MBDNPCZombie = {
			originalModel = "models/zombie/Classic.mdl",
			splitModel = "models/zombie/Classic_split.mdl"
		},
		MBDNPCZombine = {
			originalModel = "models/zombie/Zombie_Soldier.mdl",
			splitModel = "models/zombie/Zombie_Soldier_split.mdl"
		},
		MBDNPCCombineElite = {
			originalModel = "models/combine/Combine_Super_Soldier.mdl",
			splitModel = "models/combine/Combine_Super_Soldier_split.mdl"
		},
		MBDNPCShotgunSoldier = {
			originalModel = "models/combine/Combine_Soldier.mdl",
			splitModel = "models/combine/Combine_Soldier_split.mdl"
		},
		MBDNPCCombineS = {
			originalModel = "models/combine/Combine_Soldier.mdl",
			splitModel = "models/combine/Combine_Soldier_split.mdl"
		},
		MBDNPCCombinePrison = {
			originalModel = "models/combine/Combine_Soldier_PrisonGuard.mdl",
			splitModel = "models/combine/Combine_Soldier_PrisonGuard_split.mdl"
		},
		MBDNPCPrisonShotgunner = {
			originalModel = "models/combine/Combine_Soldier_PrisonGuard.mdl",
			splitModel = "models/combine/Combine_Soldier_PrisonGuard_split.mdl"
		}
	}
	MBDCustomKeyToModelNPCsKeys = {}
	for NPCKey,_ in pairs(MBDCustomKeyToModelNPCs) do table.insert(MBDCustomKeyToModelNPCsKeys, NPCKey) end

	function MBDGETCorrectNPCModel(NPCModel)
		NPCModel = string.lower(NPCModel)
	
		for NPCKey,NPCData in pairs(MBDCustomKeyToModelNPCs) do

			if NPCModel == string.lower(NPCData.originalModel) then return NPCData.splitModel end
	
		end

		return NPCModel
	end

	function MBDCheckIfIsGameOwned(folder)
		for k,GameData in pairs(engine.GetGames()) do
			if GameData["folder"] == folder then return GameData["owned"] end
		end

		return false
	end

	-- Register "new" NPC with the gore models
	--- -
	-- Half-Life 2: Episode 1 Only !
	if MBDCheckIfIsGameOwned("episodic") then
		if IsMounted("episodic") then
			-- ZombineSoldier
			list.Set("NPC", "MBDNPCZombine", {
				Name = "M.B.D. Zombie Soldier",
				Category = "Zombies + Enemy Aliens (M.B.D.)",
				Class = "npc_zombine",
				Model = MBDCustomKeyToModelNPCs["MBDNPCZombine"].splitModel,
				KeyValues = {
					SquadName = "zombies"
				}
			})
		end
	end

	-- Zombie
	list.Set("NPC", "MBDNPCZombie", {
		Name = "M.B.D. Zombie",
		Category = "Zombies + Enemy Aliens (M.B.D.)",
		Class = "npc_zombie",
		Model = MBDCustomKeyToModelNPCs["MBDNPCZombie"].splitModel,
		KeyValues = {
			SquadName = "zombies"
		}
	})
	-- CombineElite
	list.Set("NPC", "MBDNPCCombineElite", {
		SpawnFlags = 16384,
		Name = "M.B.D. Combine Elite",
		Category = "Combine (M.B.D.)",
		Weapons = {
			"weapon_ar2"
		},
		Class = "npc_combine_s",
		Model = MBDCustomKeyToModelNPCs["MBDNPCCombineElite"].splitModel,
		KeyValues = {
			SquadName = "zombies",
			Numgrenades = 10
		}
	})
	-- ShotgunSoldier
	list.Set("NPC", "MBDNPCShotgunSoldier", {
		Skin = 1,
		Name = "M.B.D. Shotgun Soldier",
		Category = "Combine (M.B.D.)",
		Weapons = {
			"weapon_shotgun"
		},
		Class = "npc_combine_s",
		Model = MBDCustomKeyToModelNPCs["MBDNPCShotgunSoldier"].splitModel,
		KeyValues = {
			SquadName = "overwatch",
			Numgrenades = 5
		}
	})
	-- npc_combine_s
	list.Set("NPC", "MBDNPCCombineS", {
		Name = "M.B.D. Combine Soldier",
		Category = "Combine (M.B.D.)",
		Weapons = {
			"weapon_smg1",
			"weapon_ar2"
		},
		Class = "npc_combine_s",
		Model = MBDCustomKeyToModelNPCs["MBDNPCCombineS"].splitModel,
		KeyValues = {
			SquadName = "overwatch",
			Numgrenades = 5
		}
	})
	-- CombinePrison
	list.Set("NPC", "MBDNPCCombinePrison", {
		Name = "M.B.D. Prison Guard",
		Category = "Combine (M.B.D.)",
		Weapons = {
			"weapon_smg1",
			"weapon_ar2"
		},
		Class = "npc_combine_s",
		Model = MBDCustomKeyToModelNPCs["MBDNPCCombinePrison"].splitModel,
		KeyValues = {
			SquadName = "novaprospekt",
			Numgrenades = 5
		}
	})
	-- PrisonShotgunner
	list.Set("NPC", "MBDNPCPrisonShotgunner", {
		Skin = 1,
		Name = "M.B.D. Prison Shotgun Guard",
		Category = "Combine (M.B.D.)",
		Weapons = {
			"weapon_shotgun"
		},
		Class = "npc_combine_s",
		Model = MBDCustomKeyToModelNPCs["MBDNPCPrisonShotgunner"].splitModel,
		KeyValues = {
			SquadName = "novaprospekt",
			Numgrenades = 5
		}
	})

	-- Save the list
	MBDCompleteCurrNPCList = list.Get("NPC")
end
