local strictSetting = 1
if GetConVar("mbd_enableStrictMode"):GetInt() then
	strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
end

if strictSetting == 1 then
	-- STRICT MODE
	include( "contenticon.lua" )
	include( "postprocessicon.lua" )

	include( "contentcontainer.lua" )
	include( "contentsidebar.lua" )
	include( "contenttypes/custom.lua" )
	include( "contenttypes/entities.lua" )
	include( "contenttypes/dupes.lua" )
else
	-- NOT STRICT (normal SBOX)
	include( "contenticon.lua" )
	include( "postprocessicon.lua" )

	include( "contentcontainer.lua" )
	include( "contentsidebar.lua" )

	include( "contenttypes/custom.lua" )
	include( "contenttypes/npcs.lua" )
	include( "contenttypes/weapons.lua" )
	include( "contenttypes/entities.lua" )
	include( "contenttypes/postprocess.lua" )
	include( "contenttypes/vehicles.lua" )
	include( "contenttypes/saves.lua" )
	include( "contenttypes/dupes.lua" )

	include( "contenttypes/gameprops.lua" )
	include( "contenttypes/addonprops.lua" )
end

local PANEL = {}

AccessorFunc( PANEL, "m_pSelectedPanel", "SelectedPanel" )

function PANEL:Init()

	self:SetPaintBackground( false )

	self.CategoryTable = {}

	self.HorizontalDivider = vgui.Create( "DHorizontalDivider", self )
	self.HorizontalDivider:Dock( FILL )
	self.HorizontalDivider:SetLeftWidth( 192 )
	self.HorizontalDivider:SetLeftMin( 192 )
	self.HorizontalDivider:SetRightMin( 400 )
	self.HorizontalDivider:SetDividerWidth( 6 )
	--self.HorizontalDivider:SetCookieName( "SpawnMenuCreationMenuDiv" )

	self.ContentNavBar = vgui.Create( "ContentSidebar", self.HorizontalDivider )
	self.HorizontalDivider:SetLeft( self.ContentNavBar )

end

function PANEL:EnableModify()
	self.ContentNavBar:EnableModify()
end

function PANEL:EnableSearch( ... )
	self.ContentNavBar:EnableSearch( ... )
end

function PANEL:CallPopulateHook( HookName )

	hook.Call( HookName, GAMEMODE, self, self.ContentNavBar.Tree, self.OldSpawnlists )

end

function PANEL:SwitchPanel( panel )

	if ( IsValid( self.SelectedPanel ) ) then
		self.SelectedPanel:SetVisible( false )
		self.SelectedPanel = nil
	end

	self.SelectedPanel = panel

	self.HorizontalDivider:SetRight( self.SelectedPanel )
	self.HorizontalDivider:InvalidateLayout( true )

	self.SelectedPanel:SetVisible( true )
	self:InvalidateParent()

end

vgui.Register( "SpawnmenuContentPanel", PANEL, "DPanel" )

-- -- ---> >> >
-- Custom
local function CreateMBDPropsPanel()
	--- - --- >> >
	-- -- Create
	local ctrl = vgui.Create("SpawnmenuContentPanel")
	
	-- M.B.D. Desse to produserer Spawnlist (sjå i: custom.lua)
	-- -- --- >>
	hook.Call( "PopulatePropMenu", GAMEMODE ) 	-- Props in the menu
	ctrl:CallPopulateHook( "PopulateContent" ) 	-- The sidebar

	return ctrl

end

spawnmenu.AddCreationTab(
	"#mbdspawnmenu.category.defences",
	CreateMBDPropsPanel,
	"icon16/application_view_tile.png",
	-10,
	"Use these Props to Build your Base!"
)