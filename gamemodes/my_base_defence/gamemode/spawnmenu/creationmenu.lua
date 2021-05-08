-- For MBD:>>
local strictSetting = 1
if GetConVar("mbd_enableStrictMode"):GetInt() then
	strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
end

AddCSLuaFile( "creationmenu/manifest.lua" )
include( "creationmenu/manifest.lua" )

local PANEL = {}

--[[---------------------------------------------------------
	Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:Populate()
	self:SetFadeTime( 0 )

end

--[[---------------------------------------------------------
	Name: Paint
-----------------------------------------------------------]]
--- - 
-- MODIFIED FOR M.B.D.::
local function createTab(self, k, v)
	--
	-- Here we create a panel and populate it on the first paint
	-- that way everything is created on the first view instead of
	-- being created on load.
	--
	local pnl = vgui.Create( "Panel" )

	self:AddSheet( k, pnl, v.Icon, nil, nil, v.Tooltip )

	-- Populate the panel
	-- We have to add the timer to make sure g_Spawnmenu is available
	-- in case some addon needs it ready when populating the creation tab.
	timer.Simple( 0, function()
		local childpnl = v.Function()
		childpnl:SetParent( pnl )
		childpnl:Dock( FILL )
	end )
end
function PANEL:Populate()

	local tabs = spawnmenu.GetCreationTabs()

	for k, v in SortedPairsByMemberValue( tabs, "Order" ) do
		local tabName = string.lower(k)

		if string.match(tabName, "#spawnmenu") then
			if (
				string.match(tabName, ".category.entities")
				or string.match(tabName, ".category.dupes")
			) then
				-- Custom name ( mbd_autorun_shared.lua )
				k = string.sub(k, 2)
				k = "#mbd"..k

				tabName = string.lower(k)
			end
		end

		-- Insert allowed
		if strictSetting == 1 then
			if (
				tabName == "#mbdspawnmenu.category.defences" or
				tabName == "#mbdspawnmenu.category.entities" or
				tabName == "#mbdspawnmenu.category.dupes"
			) then createTab(self, tabName, v) end
		else
			if (
				tabName == "#mbdspawnmenu.category.defences" or
				tabName == "#mbdspawnmenu.category.entities" or
				tabName == "#mbdspawnmenu.category.dupes"
			) then createTab(self, tabName, v) else createTab(self, k, v) end
		end

	end

end

vgui.Register( "CreationMenu", PANEL, "DPropertySheet" )
