if engine.ActiveGamemode() == "my_base_defence" then -- Very important
	AddCSLuaFile()
	
	local strictSetting = 1
	if GetConVar("mbd_enableStrictMode"):GetInt() then
		strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
	end

	-- If the tool is not on whitelist, the use will not be able to equip the toolgun; it will be dropped!
	-- PrintTable(undo.GetTable())
	MBDToolgunAndSettingsWhiteListOnlyModelNames = {}
	-- Case Sensitive
	MBDToolgunAndSettingsWhiteList = {
		--[[ Tools ]]
		Constraints = {
			"rope",
			"weld"
		},
		Construction = {
			"duplicator",
			"lamp",
			"light",
			"nocollide",
			"remover"
		},
		Render = {
			"material",
			"paint"
		},
		Interior = {
			"mbd_door"
		},
		--[[ Options ]]
		["#mbdoptions.customizeList.category"] = {
			"mbd_customize_list_buybox",
			"mbd_customize_list_npcspawner"
		},
		--[[ Utilities ]]
		["FAS2 SWEPs"] = {
			"FAS2 Admin",
			"FAS2 Client"
		},
		Admin = {
			"Admin_Cleanup",
			"PhysgunSVSettings",
			"SandboxSettings",
			"ServerSettings"
		},
		User = {
			"User_Cleanup",
			"PhysgunSettings",
			"Undo"
		}
	}
	local newTableWhiteListToolGun = {}
	for k,v in pairs(MBDToolgunAndSettingsWhiteList) do
		newTableWhiteListToolGun[k] = {}
		for l,w in pairs(v) do table.insert(newTableWhiteListToolGun[k], w) table.insert(MBDToolgunAndSettingsWhiteListOnlyModelNames, w) end
	end
	MBDToolgunAndSettingsWhiteList = newTableWhiteListToolGun
end
