-- Works like this:
--[[ 
    ->> A infitinte interval check if a respawn-button should appear in the Lobby based on some logic
    -> When a respawn button is created, it will countdown to "0" based on current server settings (-1 = no respawn button)
    -> When a respawn button is clicked, spawn the Player and Remove the respawn button
 ]]
-- SETTINGS --
local allowedToSpawnInstantly = false
local makeSpawnDBUtton = function()
    if respawnBtn and respawnBtn:IsValid() then respawnBtn:Remove() end

    respawnBtn = vgui.Create("DImageButton", container)
    respawnBtn:SetSize(185, 45 + 30)
    respawnBtn:SetPos(((150 * 5) + (5 * 7)), ScrH() - 65 - 25 / 2)

    local i = 1
    local animBackground = function() if i < 12 * 5 * 1.2 then i = i + 1 else i = nil end end
    respawnBtn.Paint = function(s, w, h)
        local xPos, yPos = s:GetPos()

        local backgroundColor = Color(60, 60, 60, 255) -- blackGray
        local textColor = Color(255, 255, 255, 245)
        local borderColor = currRespawnButtonBorderColor or Color(22, 236, 99, 255) -- mint
        if s:IsHovered() then backgroundColor = Color(30, 255, 141, 255) textColor = Color(0, 0, 0, 245) end

        if i then
            if i % 4 == 0 then
                backgroundColor = Color(60, 60, 60, 255) --[[ blackGray ]]
            else
                backgroundColor = Color(222, 252, 233, 255) --[[ lightMint ]]
                textColor = Color(60, 60, 60, 250)
            end animBackground()
        end

        local padding = 2
        local borderSize = 3
        local borderRadius = 25
        draw.RoundedBox(
            borderRadius + borderSize,
            0 + padding,
            0 + padding,
            w - padding * 2,
            h - padding * 2,
            borderColor
        )
        draw.RoundedBox(
            borderRadius,
            0 + borderSize + padding,
            0 + borderSize + padding,
            w - borderSize * 2 - padding * 2,
            h - borderSize * 2 - padding * 2,
            backgroundColor
        )
        -- -
        local extra_width, extra_height = getTextWidthAndHeight("lobbyHeader4", currRespawnButtonText)
        -- -
        draw.DrawText(
            currRespawnButtonText,
            "lobbyHeader4",
            w / 2 - extra_width / 2,
            h / 2 - extra_height / 2,
            textColor,
            TEXT_ALIGN_LEFT
        )

        if i then
            -- Write if admin
            if LocalPlayer():MBDShouldGetTheAdminBenefits(true) then
                local text = "Admin\n=\nInstant respawn"

                draw.DrawText(
                    text,
                    "lobbyHeader4",
                    w / 2,
                    h / 2 - 15,
                    Color(255, 0, 0),
                    TEXT_ALIGN_CENTER
                )
            end
        end

        draw.CustomCursor(s)
    end

    -- -
    -- For spawn button
	if theSpawnButtonIsComplete then
		SetTextSpawnButton(respawnBtn, "ok", "SPAWN AS "..string.upper(LocalPlayer():GetNWString('classname', 'NULL CLASS')))
    else SetTextSpawnButton(respawnBtn, "ok", "Loading...") end

	function respawnBtn:DoClick()
		-- Spawn/Respawn and remove self
        --- -- - >> >
        tryToSpawnPlayer(self)
    end
end
--- -- -
net.Receive("gameIsAlreadyStarted", function() -- Very important
    gameStarted = true
end)
net.Receive("receive_mbd_respawnTimeBeforeCanSpawnAgain", function() -- This is only started inside "CreateACountdownToAllowRespawning"; do it like this to make it kind of async
    timeBeforePlayerCanSpawnSeconds = net.ReadInt(12)

    timer.Simple(0.15, function()
        -- Other situations...
        if timeBeforePlayerCanSpawnSeconds == -1 then return end
        timeBeforePlayerCanSpawnSeconds = timeBeforePlayerCanSpawnSeconds + 1

        local SpawnReady = function(_LobbyIsValidForBtn)
            timer.Remove("CountdownToRespawn001")
            
            if _LobbyIsValidForBtn then
                SetTextSpawnButton(respawnBtn, "ok", "SPAWN AS "..string.upper(LocalPlayer():GetNWString('classname', 'NULL CLASS')))

                theSpawnButtonIsComplete = true
            end
        end

        -- Create Countdow
        timer.Create("CountdownToRespawn001", 1, timeBeforePlayerCanSpawnSeconds, function()
            -- Show countdown inside the respawn button if existing...That the Lobby is open also
            local LobbyIsValidForBtn = container and container:IsValid()

            if (timeBeforePlayerCanSpawnSeconds - 1) == 0 or allowedToSpawnInstantly then
                SpawnReady(LobbyIsValidForBtn)

                return
            end

            -- -- VISUALLY -- --
            -- Update the text --
            repsLeftRespawnCountdown = timer.RepsLeft("CountdownToRespawn001")

            if repsLeftRespawnCountdown then
                if repsLeftRespawnCountdown == 3 then
                    surface.PlaySound("game/countdown_beep_halo.wav")
                end
                if repsLeftRespawnCountdown > 0 then
                    if LobbyIsValidForBtn then SetTextSpawnButton(respawnBtn, "countdown", "Ready in: "..repsLeftRespawnCountdown, true) end
                end
                if repsLeftRespawnCountdown == 0 then
                    SpawnReady(LobbyIsValidForBtn)
                end
            end
        end)
    end)
end)
--- - -
local function CreateACountdownToAllowRespawning()
    if theSpawnButtonIsComplete then return end
    if timer.Exists("CountdownToRespawn001") or repsLeftRespawnCountdown != nil then return end
    -- - -
    -- Request (must do it like this... since some Players on global server does not seem to be able to access it on client side ? )
    net.Start("get_mbd_respawnTimeBeforeCanSpawnAgain")
    net.SendToServer()
end
local function CreateSpawnButton()
	if !container or !container:IsValid() then return end
	-- -- - -> >>> >
    -- Create a New one
    makeSpawnDBUtton()
    
    CreateACountdownToAllowRespawning()
end

timer.Remove("RespawnButtonCreaterDestroyer001")
timer.Create("RespawnButtonCreaterDestroyer001", 0.3, 0, function()
    local pl = LocalPlayer()

    if (
        pl and
        pl:IsValid()
    ) then
        -- MORE SETTINGS --
        -- *** USE this one to write different situations (be very careful)
        local showRespawnButton = pl:GetNWBool("isSpectating", false) and gameStarted and GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() > -1
        allowedToSpawnInstantly = pl:MBDShouldGetTheAdminBenefits(true) and pl:GetNWBool("isSpectating", false)

        -- -- -
        -- -
        if (
            container and
            container:IsValid() and
            (!respawnBtn or !respawnBtn:IsValid())
            and (showRespawnButton or allowedToSpawnInstantly)
            and gameStarted
        ) then
            -- When Player opens lobby before respawn countdown was finished, it needs to be checked again..
            -- Or else nothing will show up ... .
            if repsLeftRespawnCountdown == 0 then
                theSpawnButtonIsComplete = true
            end

            -- Create the button
            --> But it will only be create if the Lobby-container is valid + no exisiting respawn button
            CreateSpawnButton()
        elseif (
            container and
            container:IsValid() and (
                (
                    !showRespawnButton and
                    theSpawnButtonIsComplete
                ) or (
                    GetConVar("mbd_respawnTimeBeforeCanSpawnAgain"):GetInt() < 1
                )
            )
        ) then
            theSpawnButtonIsComplete = false

            RemoveSpawnButton()
        end
    end
end)
