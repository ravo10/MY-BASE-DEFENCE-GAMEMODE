if engine.ActiveGamemode() == "my_base_defence" then
    AddCSLuaFile()

    if SERVER then return end

    local strictSetting = 1
    if GetConVar("mbd_enableStrictMode"):GetInt() then
        strictSetting = GetConVar("mbd_enableStrictMode"):GetInt()
    end

    -- Try and remove standard menu hooks
    hook.Remove( "DisplayOptions_MenuBar" )
    hook.Remove( "NPCOptions_MenuBar" )

    local function InstallSVCheatsEnable( pnl )
        local think = pnl.Think
        pnl.Think = function( s ) think( s ) if ( GetConVarNumber( "sv_cheats" ) != 0 ) then s:SetEnabled( true ) else s:SetEnabled( false ) end end
        pnl:SetToolTip( "#menubar.cheatstip" )
    end

    local function DisplayOptions( menubarControl )

        local m = menubarControl:AddOrGetMenu( "#mbdcontextmenu.menubar.DisplayOptions.title" )

        m:AddCVar( "#menubar.drawing.physgun_beam", "physgun_drawbeams", "1", "0" )
        m:AddCVar( "#menubar.drawing.physgun_halo", "physgun_halo", "1", "0" )
        m:AddCVar( "#menubar.drawing.freeze", "effects_freeze", "1", "0" )
        m:AddCVar( "#menubar.drawing.unfreeze", "effects_unfreeze", "1", "0" )

        m:AddSpacer()

        m:AddCVar( "#menubar.drawing.hud", "cl_drawhud", "1", "0" )
        m:AddCVar( "#menubar.drawing.toolhelp", "gmod_drawhelp", "1", "0" )
        m:AddCVar( "#menubar.drawing.toolui", "gmod_drawtooleffects", "1", "0" )
        m:AddCVar( "#menubar.drawing.world_tooltips", "cl_drawworldtooltips", "1", "0" )
        m:AddCVar( "#menubar.drawing.spawn_effect", "cl_drawspawneffect", "1", "0" )
        m:AddCVar( "#menubar.drawing.effect_rings", "cl_draweffectrings", "1", "0" )
        m:AddCVar( "#menubar.drawing.cameras", "cl_drawcameras", "1", "0" )
        m:AddCVar( "#menubar.drawing.thrusters", "cl_drawthrusterseffects", "1", "0" )

        m:AddSpacer()

        m:AddCVar( "#menubar.drawing.shadows", "r_shadows", "1", "0" )
        m:AddCVar( "#menubar.drawing.detailprops", "r_drawdetailprops", "1", "0" )

        m:AddSpacer()

        m:AddCVar( "#menubar.drawing.showfps", "cl_showfps", "1", "0" )

        local opt = m:AddCVar( "#menubar.drawing.minecraftify", "mat_showlowresimage", "1", "0", function() timer.Simple( 0.1, function() RunConsoleCommand( "mat_reloadallmaterials" ) end ) end )
        InstallSVCheatsEnable( opt )

        local opt = m:AddCVar( "#menubar.drawing.wireframe", "mat_wireframe", "1", "0" )
        InstallSVCheatsEnable( opt )

        m:AddSpacer()

        m:AddCVar( "#menubar.drawing.hints", "cl_showhints", "1", "0" )

    end
    local function NPCOptions( menubarControl )

        local m = menubarControl:AddOrGetMenu( "#mbdcontextmenu.menubar.NPCOptions.title" )

        m:AddCVar( "#menubar.npcs.disableai", "ai_disabled", "1", "0" )
        m:AddCVar( "#menubar.npcs.ignoreplayers", "ai_ignoreplayers", "1", "0" )
        m:AddCVar( "#menubar.npcs.keepcorpses", "ai_serverragdolls", "1", "0" )
        m:AddCVar( "#menubar.npcs.autoplayersquad", "npc_citizen_auto_player_squad", "1", "0" )

        if strictSetting == 0 then

            local wpns = m:AddSubMenu( "#menubar.npcs.weapon" )

            wpns:SetDeleteSelf( false )
            wpns:AddCVar( "#menubar.npcs.defaultweapon", "gmod_npcweapon", "" )
            wpns:AddCVar( "#menubar.npcs.noweapon", "gmod_npcweapon", "none" )
            wpns:AddSpacer()

            -- Sort the items by name, also has the benefit of deduplication
            local weaponsForSort = {}
            for _, v in pairs( list.Get( "NPCUsableWeapons" ) ) do
                weaponsForSort[ language.GetPhrase( v.title ) ] = v.class
            end

            for title, class in SortedPairs( weaponsForSort ) do
                wpns:AddCVar( title, "gmod_npcweapon", class )
            end

        end
    end
    
    timer.Create( "mbd_menubarRemover", 0.3, 10000, function()

        local menubarControl = menubar[ "Control" ]

        if menubarControl then

            timer.Remove("mbd_menubarRemover")

            for _, panelChild in pairs( menubarControl:GetChildren() ) do
                if panelChild and panelChild:IsValid() then panelChild:Remove() end
            end

            -- Can add some custom hooks here -->
            DisplayOptions( menubarControl )
            NPCOptions( menubarControl )

        end

    end )

end
