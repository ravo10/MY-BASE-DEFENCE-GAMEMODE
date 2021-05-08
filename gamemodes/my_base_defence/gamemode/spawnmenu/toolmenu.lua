
include( "toolpanel.lua" )

local PANEL = {}
local strictSetting = 1
if GetConVar("mbd_enableStrictMode"):GetInt() then
	strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
end

--[[---------------------------------------------------------
	Name: Paint
-----------------------------------------------------------]]
function PANEL:Init()

	self.ToolPanels = {}

	self:LoadTools()

	self:SetFadeTime( 0 )

end

--[[---------------------------------------------------------
	LoadTools
-----------------------------------------------------------]]
function PANEL:LoadTools()

	local tools = spawnmenu.GetTools()

	-- #spawnmenu.tools_tab, Options, Utilities

	for strName, pTable in pairs( tools ) do

		-- MBD MODDED
		if strictSetting == 1 then
			local label = string.lower(pTable["Label"])
			if (
				label == "#spawnmenu.tools_tab" or
				label == "options" or
				label == "utilities"
			) then self:AddToolPanel( strName, pTable ) end
		else
			self:AddToolPanel( strName, pTable )
		end

	end

end

--[[---------------------------------------------------------
	LoadTools
-----------------------------------------------------------]]
function PANEL:AddToolPanel( Name, ToolTable )

	-- I hate relying on a table's internal structure
	-- but this isn't really that avoidable.

	local function MaybeGetAssumedItIsALanguagePhrase(_string)
		if string.sub(_string, 1, 2) == "#" then _string = language.GetPhrase(_string) end

		return _string
	end

	-- -- - - -
	-- MBD MODDED
	if strictSetting == 1 then
		local newTablesMainTable = {}

		-- Will only accept these tool settings...
		-- Check The Panel Settings name >
		local mainReferenceTable = ToolTable.Items
		local mainReferenceTableLength = #mainReferenceTable

		timer.Create( "mbd_toolmenu_loading#" .. Name, 0.25, 10000, function()

			if LocalPlayer()[ "MBDIsNotAnAdmin" ] then

				timer.Remove( "mbd_toolmenu_loading#" .. Name )

				for mainKeyParent,aChildTable in pairs(mainReferenceTable) do
					local newTablesMainChildrenTable = {}
		
					-- Insert the essential values
					newTablesMainChildrenTable["ItemName"] = aChildTable["ItemName"]
					newTablesMainChildrenTable["Text"] = aChildTable["Text"]
		
					local access = true
					if (
						aChildTable["ItemName"] == "#mbdoptions.customizeList.category"
					) then if LocalPlayer():MBDIsNotAnAdmin(false) then access = false end end
		
					-- Check if the name is a valid one
					if access then
						local name0 = MaybeGetAssumedItIsALanguagePhrase(tostring(aChildTable["ItemName"]))
						local allName0PossibleAllowedKeys = table.GetKeys(MBDToolgunAndSettingsWhiteList)
						if table.HasValue(allName0PossibleAllowedKeys, name0) then
							-- Get all keys that are a number ( those tables )
							local checkTheseKeysInTable = {}
							for _,v in pairs(table.GetKeys(aChildTable)) do if tonumber(v) then table.insert(checkTheseKeysInTable, v) end end
							for k,childKey in pairs(checkTheseKeysInTable) do
		
								-- Check if it is a valid key
								local name1 = tostring(aChildTable[childKey]["ItemName"])
								local allName1PossibleAllowedKeys = MBDToolgunAndSettingsWhiteList[name0]
								if table.HasValue(allName1PossibleAllowedKeys, name1) then
									-- Add the table with a new number key to the new table
									table.insert(newTablesMainChildrenTable, aChildTable[childKey])
								end
		
								if k == #checkTheseKeysInTable then
									-- Done filtering, insert the category
									table.insert(newTablesMainTable, newTablesMainChildrenTable)
								end
							end
						end
					end
		
					if mainKeyParent == mainReferenceTableLength then
						-- -- -
						-- 100 % done - Insert this Category filtered table (e.g. Tools or Utilities)
						local Panel = vgui.Create( "ToolPanel" )
						Panel:SetTabID( Name )
						Panel:LoadToolsFromTable( newTablesMainTable )
		
						self:AddSheet( ToolTable.Label, Panel, ToolTable.Icon )
						self.ToolPanels[ Name ] = Panel
					end
				end

			end

		end )

	else
		-- Original code
		local Panel = vgui.Create( "ToolPanel" )
		Panel:SetTabID( Name )
		Panel:LoadToolsFromTable( ToolTable.Items )

		self:AddSheet( ToolTable.Label, Panel, ToolTable.Icon )
		self.ToolPanels[ Name ] = Panel
	end

end

--[[---------------------------------------------------------
	Name: Paint
-----------------------------------------------------------]]
function PANEL:Paint( w, h )

	DPropertySheet.Paint( self, w, h )

end

--[[---------------------------------------------------------
	Name: GetToolPanel
-----------------------------------------------------------]]
function PANEL:GetToolPanel( id )

	return self.ToolPanels[ id ]

end

vgui.Register( "ToolMenu", PANEL, "DPropertySheet" )
