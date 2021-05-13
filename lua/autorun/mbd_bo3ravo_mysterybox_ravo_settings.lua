if engine.ActiveGamemode() == "my_base_defence" then -- Very important
	AddCSLuaFile()

    if SERVER then

        util.AddNetworkString("mbd_mysteryBox:setServerConVar")

        net.Receive("mbd_mysteryBox:setServerConVar", function(len, pl)
            if not pl:IsAdmin() then return end
    
            local data = net.ReadTable()
            local conVarId = data[ "conVarId" ]
            local value = data[ "value" ]
            
            -- Set server convar
            GetConVar( conVarId ):SetInt( value )
            
        end)

    end

    if CLIENT then

        list.Set( "DesktopWindows", "mbd_Bo3RavoNorwayMysteryBoxExtraSettingsPanel", {

            title		= "Mystery Box (M.B.D.) [ Admin ]",
            icon		= "icon64/tool.png",
            width		= 960,
            height		= 700,
            onewindow	= true,
            init		= function( icon, window )

                if not LocalPlayer():IsAdmin() then return end

                window:SetSize( math.min( ScrW() - 16, window:GetWide() ), math.min( ScrH() - 16, window:GetTall() ) )
                window:Center()

                local sheet = window:Add( "DPropertySheet" )
                sheet:Dock( FILL )

                local PanelSelect = sheet:Add( "DPanelSelect" )
                sheet:AddSheet( "ConVar", PanelSelect, "icon16/application_xp_terminal.png" )

                local controls1 = PanelSelect:Add( "DPanel" )
                controls1:Dock( FILL )
                controls1:DockPadding( 8, 8, 8, 8 )

                -- Convenience function to quickly add items
                local function addItemBoolean( text, conVarId, paddingTop )

                    if not LocalPlayer():IsAdmin() then return end

                    local RulePanel = controls1:Add( "DPanel" ) -- Create container for this item
                    RulePanel:Dock( TOP ) -- Dock it
                    if paddingTop then RulePanel:DockMargin( 0, paddingTop, 0, 0 ) else RulePanel:DockMargin( 0, 2, 0, 0 ) end
                
                    local ImageCheckBox = RulePanel:Add( "ImageCheckBox" ) -- Create checkbox with image
                    ImageCheckBox:SetMaterial( "icon16/accept.png" ) -- Set its image
                    ImageCheckBox:SetWidth( 24 ) -- Make the check box a bit wider than the image so it looks nicer
                    ImageCheckBox:Dock( LEFT ) -- Dock it
                    ImageCheckBox:SetChecked( GetConVar( conVarId ):GetInt() > 0 )

                    local function checkBoxChange()

                        local isChecked = ImageCheckBox:GetChecked()

                        net.Start( "mbd_mysteryBox:setServerConVar" )

                            if isChecked then
                                net.WriteTable( {
                                    conVarId = conVarId,
                                    value = 1
                                } )
                            else
                                net.WriteTable( {
                                    conVarId = conVarId,
                                    value = 0
                                } )
                            end

                        net.SendToServer()

                    end

                    ImageCheckBox.OnReleased = checkBoxChange

                    local DLabel = RulePanel:Add( "DLabel" ) -- Create text
                    DLabel:SetText( text ) -- Set the text
                    DLabel:Dock( FILL ) -- Dock it
                    DLabel:DockMargin( 5, 0, 0, 0 ) -- Move the text to the right a little
                    DLabel:SetTextColor( Color( 0, 0, 0 ) ) -- Set text color to black
                    DLabel:SetMouseInputEnabled( true ) -- We must accept mouse input

                    DLabel.DoClick = function()

                        ImageCheckBox:SetChecked( not ImageCheckBox:GetChecked() )
                        checkBoxChange()

                    end

                    return ImageCheckBox

                end
                local function addItemDynamicInt( text, conVarId, paddingTop, min, max )

                    if not LocalPlayer():IsAdmin() then return end

                    local RulePanel = controls1:Add( "DPanel" ) -- Create container for this item
                    RulePanel:Dock( TOP ) -- Dock it
                    if paddingTop then RulePanel:DockMargin( 0, paddingTop, 0, 0 ) else RulePanel:DockMargin( 0, 2, 0, 0 ) end
                
                    local DNumSlider = RulePanel:Add( "DNumSlider" ) -- Create checkbox with image
                    DNumSlider:SetSize( 200, 10 )
                    DNumSlider:Dock( LEFT ) -- Dock it
                    DNumSlider:DockMargin( -80, 0, 0, 0 )
                    DNumSlider:SetDecimals( 3 )
                    DNumSlider:SetConVar( conVarId )
                    DNumSlider:SetMin( min )
                    DNumSlider:SetMax( max )

                    local DLabel = RulePanel:Add( "DLabel" ) -- Create text
                    DLabel:SetText( text ) -- Set the text
                    DLabel:Dock( FILL ) -- Dock it
                    DLabel:DockMargin( 0, 0, 0, 0 ) -- Move the text to the right a little
                    DLabel:SetTextColor( Color( 0, 0, 0 ) ) -- Set text color to black
                    DLabel:SetMouseInputEnabled( true ) -- We must accept mouse input

                    return DNumSlider

                end

                -- Adding items
                -- Boolean values -- Dynamic values
                local MysteryBoxTotalHealth = addItemDynamicInt( "Mystery Box Health for Future Mystery Boxes ( value <= 0, will give infinite health ) ( default: 0 )", "mbd_mysterybox_bo3_ravo_MysteryBoxTotalHealth", nil, 0, 10000 )

                local exchangeWeapons = addItemBoolean( "Exchange Weapon ( default: ON )", "mbd_mysterybox_bo3_ravo_exchangeWeapons", 10 )
                
                local disableAllParticlesEffects = addItemBoolean( "Disable Particles for Future Mystery Boxes ( default: OFF )", "mbd_mysterybox_bo3_ravo_disableAllParticlesEffects" )

                local teddybearGetChance_TotallyCustomValueAllowed = addItemBoolean( "Teddybear Probability - Custom Value Allowed? ( default: OFF )", "mbd_mysterybox_bo3_ravo_teddybearGetChance_TotallyCustomValueAllowed", 10 )
                local teddybearGetChance = addItemDynamicInt( "Teddybear Probability ( value > 0, will give no teddybear. Lower == More Likely ) ( when \"Custom Value Allowed\" is set to 'OFF', it will adjust automatically )", "mbd_mysterybox_bo3_ravo_teddybearGetChance", nil, -100, 1 )

                local hideAllNotificationsFromMysteryBox = addItemBoolean( "Hide Notifications ( default: OFF )", "mbd_mysterybox_bo3_ravo_hideAllNotificationsFromMysteryBox", 10 )

            end
        } )
    
    end

end
