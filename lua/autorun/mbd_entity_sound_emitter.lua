if engine.ActiveGamemode() == "my_base_defence" then -- Very important
    -- Made by: ravo (Norway) https:/steamcommunity.com/profiles/76561197997985841
    AddCSLuaFile()

    if SERVER then
        -- FUNCTIONS
        function MBDSetSoundAndEntity(Entity, SoundString, PitchString, Volume)
            if not SoundString or SoundString == "" then print("M.B.D Sound Emitter: Can not produce sound. Missing sound string input for: ", Entity, "Make sure it has one.") end

            net.Start("Entity_EmitLocalSoundEmitter")
                net.WriteTable({
                    Sound		= SoundString,
                    SoundEnt 	= Entity,
                    Pitch 		= PitchString,
                    Volume		= Volume or 1
                })
            net.Broadcast()
        end
        -- For Safe Removal
        function MBDRemoveEnt(ent)
            -- Very Important to delay removal!
            timer.Simple(0.3, function()
                if ent and ent:IsValid() then ent:Remove() end
            end)
        end
    end

end