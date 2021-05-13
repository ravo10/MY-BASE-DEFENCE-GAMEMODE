if engine.ActiveGamemode() == "my_base_defence" then -- Very important
	AddCSLuaFile()

    if SERVER then

        util.AddNetworkString("bo3Ravo:SpawnDestructionProps")

        function mbd_Bo3Ravo_SpawnKillmodelProps( ent, killmodels, zExtra, randomColor, noRandomScaling )

            local entHasPhysObject = ent.GetPhysicsObject

            local entPhysObject if entHasPhysObject then

                local entPhysObject = ent:GetPhysicsObject()
                local ent_lowest_point, ent_highest_point = 10, 60
                if entPhysObject.GetAABB then ent_lowest_point, ent_highest_point = entPhysObject:GetAABB() end

                local ent_center_point = ent:WorldToLocal( ent:WorldSpaceCenter() )

                local destructionPropNewPos = entPhysObject:LocalToWorld( Vector(

                    ent_center_point.x + math.random( -45, 45 ),
                    ent_center_point.y + math.random( -45, 45 ),
                    ent_highest_point.z + zExtra

                ))

                net.Start( "bo3Ravo:SpawnDestructionProps" )

                    net.WriteTable({
                        destructionPropNewPos 		= destructionPropNewPos,
                        killmodels 					= killmodels,
                        parentPropAngles			= entPhysObject:GetAngles(),
                        parentPropVelocity			= entPhysObject:GetVelocity(),
                        parentPropAngleVelocity		= entPhysObject:GetAngleVelocity(),
                        parentPropInertia			= entPhysObject:GetInertia(),
                        randomColor                 = randomColor,
                        noRandomScaling				= noRandomScaling
                    })

                net.Broadcast()
            
            end

        end

    end

    if CLIENT then

        -- Spawn descruction props
        local function changeAlphaColorAndMaybeRemovePropLoop( destructionProp, howFastItFadesFor, howManyTimesItCountsFor )
            
            if destructionProp and destructionProp:IsValid() then

                if ( destructionProp:GetNWInt( "mbd_downCounter", 0 ) <= howManyTimesItCountsFor / 2 ) then

                    local killmodelFarge = destructionProp:GetColor()

                    destructionProp:SetColor( Color( killmodelFarge.r, killmodelFarge.g, killmodelFarge.b, ( destructionProp:GetNWFloat( "mbd_alphaDegrader", 0 ) ) ) )
                    destructionProp:SetNWFloat( "mbd_alphaDegrader", math.Clamp( destructionProp:GetNWFloat( "mbd_alphaDegrader", 0 ) - ( 255 / howManyTimesItCountsFor ) - 3, 0, 255 ) )

                end

                -- Remove when invisible
                if ( destructionProp:GetNWFloat( "mbd_alphaDegrader", 0 ) <= 0 ) then destructionProp:Remove() end

                if destructionProp:IsValid() then

                    destructionProp:SetNWInt( "mbd_downCounter", destructionProp:GetNWInt( "mbd_downCounter", 0 ) - 1 )

                    timer.Simple( howFastItFadesFor, function() changeAlphaColorAndMaybeRemovePropLoop( destructionProp, howFastItFadesFor, howManyTimesItCountsFor ) end )

                end

            end

        end
        local function produserOydelegelseProppen( destructionProp, parentPropAngles, parentPropVelocity, parentPropAngleVelocity, parentPropInertia )

            destructionProp:SetAngles( Angle(

                parentPropAngles.p * math.random( 0, 360 ),
                parentPropAngles.y * math.random( 0, 360 ),
                parentPropAngles.r * math.random( 0, 360 )

            ) )

            destructionProp:Spawn()
            destructionProp:SetRenderMode( RENDERMODE_TRANSALPHA )

        end
        net.Receive( "bo3Ravo:SpawnDestructionProps", function()

            local destructionData = net.ReadTable()

            local entPhysObject = destructionData[ "entPhysObject" ]
            local destructionPropNewPos = destructionData[ "destructionPropNewPos" ]

            local parentPropAngles = destructionData[ "parentPropAngles" ]
            local parentPropVelocity = destructionData[ "parentPropVelocity" ]
            local parentPropAngleVelocity = destructionData[ "parentPropAngleVelocity" ]
            local parentPropInertia = destructionData[ "parentPropInertia" ]

            local randomColor = destructionData[ "randomColor" ]
            local noRandomScaling = destructionData[ "noRandomScaling" ]

            for i = 1, 6 do

                for _, modelName in pairs( destructionData[ "killmodels" ] ) do

                    local destructionProp = ents.CreateClientProp( modelName )
                    if not noRandomScaling then destructionProp:SetModelScale( 0.85 * ( math.random( 5, 10 ) / 10 ) ) end
                    destructionProp:SetPos( destructionPropNewPos )
                    produserOydelegelseProppen( destructionProp, parentPropAngles, parentPropVelocity, parentPropAngleVelocity, parentPropInertia )

                    -- Set timer to animate fading for kill props
                    local howFastItFadesFor = math.random( 1, 8 ) / 100
                    local howManyTimesItCountsFor = math.random( 150, 900 )

                    destructionProp:SetNWFloat( "mbd_alphaDegrader", 255 )
                    destructionProp:SetNWInt( "mbd_downCounter", howManyTimesItCountsFor - howManyTimesItCountsFor / 3 )

                    if randomColor then
                        
                        local randomColor = ColorToHSV( ColorRand( false ) )
                        destructionProp:SetColor( HSVToColor( randomColor, 1, 1 ) )

                    else

                        destructionProp:SetColor( Color( 99, 61, 24) )

                    end

                    destructionProp:SetModelScale( 0, 6.2 )

                    changeAlphaColorAndMaybeRemovePropLoop( destructionProp, howFastItFadesFor, howManyTimesItCountsFor )

                end

            end

        end )

    end

end