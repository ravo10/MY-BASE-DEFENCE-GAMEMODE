--
--- Client TIMERS
--- ---
-- Remove Clientside Ragdolls
--

-- For countdown ( everything )
net.Receive("mbd:LobbyTimerStateChange", function()
    local stateData = net.ReadTable()

    local currState = stateData.state
    local currMessageString = stateData.messageString
    local currCountdownTimeTotalStart = stateData.countdownTimeTotalStart
    if currCountdownTimeTotalStart and tonumber(currCountdownTimeTotalStart) then currCountdownTimeTotalStart = tonumber(currCountdownTimeTotalStart) end

    local timerID001 = "mbd:CountdownTimer001"

    if ( currState == 0 or not currCountdownTimeTotalStart ) and currMessageString then
        timer.Remove(timerID001)

        -- Insert the countdown text only
        countDownerTime = currMessageString
    elseif currState == 1 and currMessageString and currCountdownTimeTotalStart then
        timer.Remove(timerID001)

        if isstring(currCountdownTimeTotalStart) then
            -- Time is i.e. "N/A"
            countDownerTime = currMessageString..currCountdownTimeTotalStart
        else
            -- Start a countdown timer at client side
            timer.Create(timerID001, 1, currCountdownTimeTotalStart, function()
                countDownerTime = currMessageString..timer.RepsLeft(timerID001)
            end)
        end
    end
end)
