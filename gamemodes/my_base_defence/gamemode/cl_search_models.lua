
local totalCalls = 0
local expectedCalls = 1

local queuedSearch = {}

local function GetAllFiles( tab, folder, extension, path )

	totalCalls = totalCalls + 1

	local files, folders = file.Find( folder .. "*", path )

	if ( !files ) then
		MsgN( "Warning! Ignoring '" .. folder .. "' because we cannot search in it!"  )
		return
	end

	for k, v in pairs( files ) do

		if ( v:EndsWith( extension ) ) then
			table.insert( tab, ( folder .. v ):lower() )
		end

	end

	for k, v in pairs( folders ) do
		expectedCalls = expectedCalls + 1
		table.insert( queuedSearch, { tab, folder .. v .. "/", extension, path } )
	end

end

hook.Add( "Think", "sandbox_queued_search", function()
	if ( #queuedSearch < 1 ) then return end

	local call = queuedSearch[ 1 ]
	GetAllFiles( call[ 1 ], call[ 2 ], call[ 3 ], call[ 4 ] )
	table.remove( queuedSearch, 1 )

	if ( !timer.Exists( "search_models_update" ) || #queuedSearch < 1 ) then
		timer.Create( "search_models_update", 1, 1, function() hook.Run( "SearchUpdate" ) end )
	end
end )

hook.Add( "DrawOverlay","sandbox_search_progress", function()
	if ( !IsValid( g_SpawnMenu ) || !IsValid( g_SpawnMenu.SearchPropPanel ) || expectedCalls == 1 || totalCalls == expectedCalls ) then return end

	local pnl = g_SpawnMenu.SearchPropPanel
	if ( !g_SpawnMenu:IsVisible() || !pnl:IsVisible() ) then return end

	local x, y = pnl:LocalToScreen( 0, 0 )
	local maxw = pnl:GetWide()
	if ( pnl.VBar && pnl.VBar.Enabled ) then maxw = maxw - 20 end

	draw.RoundedBox( 0, x, y, maxw, 8, Color( 0, 0, 0, 200 ) )
	draw.RoundedBox( 0, x, y, maxw * ( totalCalls / expectedCalls ), 8, Color( 0, 128, 255, 200 ) )
end )

--
-- Model Search
--
local model_list = nil
search.AddProvider( function( str )

	str = str:PatternSafe()

	if ( model_list == nil ) then

		model_list = {}
		GetAllFiles( model_list, "models/", ".mdl", "GAME" )

	end

	local models = {}

	for k, v in pairs( model_list ) do
		local CONTINUE = false

		-- Don't search in the models/ bit of every model, because every model has this bit
		local modelpath = v
		if ( modelpath:StartWith( "models/" ) ) then modelpath = modelpath:sub( 8 ) end

		if ( modelpath:find( str ) ) then

			if ( IsUselessModel( v ) ) then CONTINUE = true end

			if !CONTINUE then local entry = {
				text = v:GetFileFromFilename(),
				func = function() RunConsoleCommand( "gm_spawn", v ) end,
				icon = spawnmenu.CreateContentIcon( "model", g_SpawnMenu.SearchPropPanel, { model = v } ),
				words = { v }
			}

			table.insert( models, entry ) end

		end

		if !CONTINUE then if ( #models >= 512 ) then break end end
	end

	return models

end, "props" )

--
-- Entity, vehicles
--
local function AddSearchProvider( listname, ctype, stype )
	search.AddProvider( function( str )

		str = str:PatternSafe()

		local results = {}
		local entities = {}

		for k, v in pairs( list.Get( listname ) ) do
			local CONTINUE = false

			if ( listname == "Weapon" && !v.Spawnable ) then CONTINUE = true end
			
			if !CONTINUE then v.ClassName = k
				v.PrintName = v.PrintName or v.Name
				v.ScriptedEntityType = ctype
				table.insert( entities, v ) end
		end

		for k, v in pairs( entities ) do
			local CONTINUE = false

			local name = v.PrintName
			local name_c = v.ClassName
			if ( !name && !name_c ) then CONTINUE = true end

			if !CONTINUE then if ( ( name && name:lower():find( str ) ) || ( name_c && name_c:lower():find( str ) ) ) then

				local entry = {
					text = v.PrintName or v.ClassName,
					icon = spawnmenu.CreateContentIcon( v.ScriptedEntityType or "entity", nil, {
						nicename = v.PrintName or v.ClassName,
						spawnname = v.ClassName,
						material = "entities/" .. v.ClassName .. ".png",

						admin = v.AdminOnly
					} ),
					words = { v }
				}

				table.insert( results, entry )

			end

			if ( #results >= 128 ) then break end end
		end

		table.SortByMember( results, "text", true )
		return results

	end, stype )
end

AddSearchProvider( "SpawnableEntities", "entity", "entities" )
AddSearchProvider( "Vehicles", "vehicle", "vehicles" )
AddSearchProvider( "NPC", "npc", "npcs" )
AddSearchProvider( "Weapon", "weapon", "weapons" )