local strictSetting = 1
if GetConVar("mbd_enableStrictMode"):GetInt() then
	strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
end

if strictSetting == 1 then
	-- STRICT MODE
	--
	hook.Add( "PopulateEntities", "AddEntityContent", function( pnlContent, tree, node )
		timer.Create("mbd:PopulateEntitiesChecker001", (1 / 1000 * 3), 0, function()
			if (
				LocalPlayer() and
				(
					LocalPlayer():MBDIsAnAdmin(true)
				)
			) then
				timer.Remove("mbd:PopulateEntitiesChecker001")
				--
				local Categorised = {}
			
				-- Add this list into the tormoil
				local SpawnableEntities = list.Get( "SpawnableEntities" )
				if ( SpawnableEntities ) then
					for k, v in pairs( SpawnableEntities ) do

						-- Only ALLOW M.B.D. entities (and FA:S) (and HL:2)
						local __ClassName = string.lower(v.ClassName)
						if (
							string.match(__ClassName, "mbd_") or
							string.match(__ClassName, "mbd_fas2_") or (
								-- Some HL:2 Stuff (ALL)
								__ClassName == "item_ammo_pistol" or
								__ClassName == "item_ammo_pistol_large" or
								__ClassName == "item_ammo_357" or
								__ClassName == "item_ammo_357_large" or
								__ClassName == "item_ammo_ar2" or
								__ClassName == "item_ammo_ar2_large" or
								__ClassName == "item_ammo_ar2_altfire" or
								__ClassName == "item_ammo_crossbow" or
								__ClassName == "item_box_buckshot" or
								__ClassName == "item_ammo_smg1_grenade" or
								__ClassName == "item_ammo_smg1" or
								__ClassName == "item_ammo_smg1_large" or
								__ClassName == "rpg_round" or
								__ClassName == "item_rpg_round" or
								__ClassName == "weapon_stunstick" or
								__ClassName == "weapon_rpg" or
								__ClassName == "grenade_helicopter" or
								__ClassName == "item_suitcharger" or
								__ClassName == "item_healthcharger" or
								__ClassName == "item_healthkit" or
								__ClassName == "item_healthvial" or
								__ClassName == "item_suit" or
								__ClassName == "weapon_striderbuster" or
								__ClassName == "combine_mine" or
								__ClassName == "npc_grenade_frag"
							)
						) then
							if (
								(
									LocalPlayer():MBDIsAnAdmin(true)
								) and string.match(__ClassName, "mbd_")
							) then
								v.SpawnName = k
								v.Category = v.Category or "Other"
								Categorised[ v.Category ] = Categorised[ v.Category ] or {}
								table.insert( Categorised[ v.Category ], v )
							elseif LocalPlayer():MBDIsAnAdmin(false) then
								-- SUPERADMIN is the only one who can spawn weapons
								v.SpawnName = k
								v.Category = v.Category or "Other"
								Categorised[ v.Category ] = Categorised[ v.Category ] or {}
								table.insert( Categorised[ v.Category ], v )
							end
						end

					end
				end
				--
				--
				-- Add a tree node for each category
				--
				for CategoryName, v in SortedPairs( Categorised, true ) do

					-- Add a node to the tree
					local node = tree:AddNode( CategoryName, "icon16/bricks.png" )

					-- When we click on the node - populate it using this function
					node.DoPopulate = function( self )

						-- If we've already populated it - forget it.
						if ( self.PropPanel ) then return end

						-- Create the container panel
						self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
						self.PropPanel:SetVisible( false )
						self.PropPanel:SetTriggerSpawnlistChange( false )

						for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do

							-- Only ALLOW M.B.D. entities (and FA:S) (and HL:2)
							local __ClassName = string.lower(ent.ClassName)
							if (
								string.match(__ClassName, "mbd_") or
								string.match(__ClassName, "mbd_fas2_") or (
									-- Some HL:2 Stuff (ALL)
									__ClassName == "item_ammo_pistol" or
									__ClassName == "item_ammo_pistol_large" or
									__ClassName == "item_ammo_357" or
									__ClassName == "item_ammo_357_large" or
									__ClassName == "item_ammo_ar2" or
									__ClassName == "item_ammo_ar2_large" or
									__ClassName == "item_ammo_ar2_altfire" or
									__ClassName == "item_ammo_crossbow" or
									__ClassName == "item_box_buckshot" or
									__ClassName == "item_ammo_smg1_grenade" or
									__ClassName == "item_ammo_smg1" or
									__ClassName == "item_ammo_smg1_large" or
									__ClassName == "rpg_round" or
									__ClassName == "item_rpg_round" or
									__ClassName == "weapon_stunstick" or
									__ClassName == "weapon_rpg" or
									__ClassName == "grenade_helicopter" or
									__ClassName == "item_suitcharger" or
									__ClassName == "item_healthcharger" or
									__ClassName == "item_healthkit" or
									__ClassName == "item_healthvial" or
									__ClassName == "item_suit" or
									__ClassName == "weapon_striderbuster" or
									__ClassName == "combine_mine" or
									__ClassName == "npc_grenade_frag"
								)
							) then
								spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "entity", self.PropPanel, {
									nicename	= ent.PrintName or ent.ClassName,
									spawnname	= ent.SpawnName,
									material	= "entities/" .. ent.SpawnName .. ".png",
									admin		= --[[ ent.AdminOnly ]] true
								} )
							end

						end

					end

					-- If we click on the node populate it and switch to it.
					node.DoClick = function( self )

						self:DoPopulate()
						pnlContent:SwitchPanel( self.PropPanel )

					end

				end

				-- Select the first node
				local FirstNode = tree:Root():GetChildNode( 0 )
				if ( IsValid( FirstNode ) ) then
					FirstNode:InternalDoClick()
				end
			end

		end)

	end)
else
	-- NOT STRICT mode (normal SBOX)
	--
	hook.Add( "PopulateEntities", "AddEntityContent", function( pnlContent, tree, node )

		local Categorised = {}

		-- Add this list into the tormoil
		local SpawnableEntities = list.Get( "SpawnableEntities" )
		if ( SpawnableEntities ) then
			for k, v in pairs( SpawnableEntities ) do

				v.SpawnName = k
				v.Category = v.Category or "Other"
				Categorised[ v.Category ] = Categorised[ v.Category ] or {}
				table.insert( Categorised[ v.Category ], v )

			end
		end

		--
		-- Add a tree node for each category
		--
		for CategoryName, v in SortedPairs( Categorised ) do

			-- Add a node to the tree
			local node = tree:AddNode( CategoryName, "icon16/bricks.png" )

				-- When we click on the node - populate it using this function
			node.DoPopulate = function( self )

				-- If we've already populated it - forget it.
				if ( self.PropPanel ) then return end

				-- Create the container panel
				self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
				self.PropPanel:SetVisible( false )
				self.PropPanel:SetTriggerSpawnlistChange( false )

				for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do

					spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "entity", self.PropPanel, {
						nicename	= ent.PrintName or ent.ClassName,
						spawnname	= ent.SpawnName,
						material	= "entities/" .. ent.SpawnName .. ".png",
						admin		= ent.AdminOnly
					} )

				end

			end

			-- If we click on the node populate it and switch to it.
			node.DoClick = function( self )

				self:DoPopulate()
				pnlContent:SwitchPanel( self.PropPanel )

			end

		end

		-- Select the first node
		local FirstNode = tree:Root():GetChildNode( 0 )
		if ( IsValid( FirstNode ) ) then
			FirstNode:InternalDoClick()
		end

	end )
end
--
--
--
spawnmenu.AddCreationTab( "#spawnmenu.category.entities", function()
	
	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	ctrl:EnableSearch( "entities", "PopulateEntities" )
	ctrl:CallPopulateHook( "PopulateEntities" )

	return ctrl

end, "icon16/bricks.png", 20 )