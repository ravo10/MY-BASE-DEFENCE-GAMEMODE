local strictSetting = 1
if GetConVar("mbd_enableStrictMode"):GetInt() then
	strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
end

local AddCustomizableNode = nil

local function SetupCustomNode( node, pnlContent, needsapp )

	node.CustomSpawnlist = !node.AddonSpawnlist -- Used to determine which nodes ContentSidebarToolBox can edit

	-- This spawnlist needs a certain app mounted before it will show up.
	-- MODDED
	if ( node and needsapp && needsapp != "" ) then
		node:SetVisible( IsMounted( needsapp ) )
		node.NeedsApp = needsapp
	end


	node.SetupCopy = function( self, copy )

		SetupCustomNode( copy, pnlContent, needsapp )

		self:DoPopulate()

		copy.PropPanel = self.PropPanel:Copy()

		if copy.PropPanel then
			copy.PropPanel:SetVisible( false )
			copy.PropPanel:SetTriggerSpawnlistChange( true )

			copy.DoPopulate = function() end
		end

	end

	if ( !node.AddonSpawnlist ) then
		node.OnModified = function()
			hook.Run( "SpawnlistContentChanged" )
		end

		node.DoRightClick = function( self )

			local menu = DermaMenu()
			if strictSetting == 0 then
				menu:AddOption( "Edit", function() self:InternalDoClick() hook.Run( "OpenToolbox" ) end )
				menu:AddOption( "New Category", function() AddCustomizableNode( pnlContent, "New Category", "", self ) self:SetExpanded( true ) hook.Run( "SpawnlistContentChanged" ) end )
				menu:AddOption( "Delete", function() node:Remove() hook.Run( "SpawnlistContentChanged" ) end )
			end

			menu:Open()

		end
	end

	node.DoPopulate = function( self )

		if !self then
			if ( IsValid( self.PropPanel ) ) then return end

			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( true )
		end

	end

	node.DoClick = function( self )

		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )

	end

end

local function ReadSpawnlists( node, parentid )

	local tab = {}
	tab.name		= node:GetText()
	tab.icon		= node:GetIcon()
	tab.parentid	= parentid
	tab.id			= SPAWNLIST_ID
	tab.version		= 3
	tab.needsapp	= node.NeedsApp

	node:DoPopulate()

	if ( IsValid( node.PropPanel ) ) then
		tab.contents = node.PropPanel:ContentsToTable()
	end

	if ( SPAWNLIST_ID > 0 ) then
		SPAWNLISTS[ string.format( "%03d", tab.id ) .. "-" .. tab.name ] = util.TableToKeyValues( tab )
	end

	SPAWNLIST_ID = SPAWNLIST_ID + 1

	if ( node.ChildNodes ) then

		for k, v in pairs( node.ChildNodes:GetChildren() ) do

			ReadSpawnlists( v, tab.id )

		end

	end

end

local function ConstructSpawnlist( node )

	SPAWNLIST_ID = 0
	SPAWNLISTS = {}

	ReadSpawnlists( node, 0 )
	local tab = SPAWNLISTS

	SPAWNLISTS = nil
	SPAWNLIST_ID = nil

	return tab

end

-- MBD : : THIS populates the side menu with a DTree for the spawnlist
local haveDeletedOldPanelDropdowns = false -- THIS modification has been made for stable 0.01, and there are
-- old code that hinders other dropdowns from appearing in strict mode; this is not removed yet.. Or may not be
AddCustomizableNode = function( pnlContent, name, icon, parent, needsapp )
	if !haveDeletedOldPanelDropdowns then haveDeletedOldPanelDropdowns = true parent:Clear() end

	local node = parent:AddNode( name, icon )
	node.AddonSpawnlist = parent.AddonSpawnlist

	SetupCustomNode( node, pnlContent, needsapp )

	return node

end

hook.Add("PopulateContent", "AddCustomContent", function(pnlContent, tree, node) MBDSavedPanelForSpawnmenu = { pnlContent, tree, node, AddCustomizableNode } end)

hook.Add( "OnSaveSpawnlist", "DoSaveSpawnlist", function()

	local Spawnlist = ConstructSpawnlist( CustomizableSpawnlistNode )

	spawnmenu.DoSaveToTextFiles( Spawnlist )

end )
