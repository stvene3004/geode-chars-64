
function do_kazotsky_kick(m, reqAct)
    local e = gStateExtras[m.playerIndex]
    local dancer = nearest_mario_state_to_object(m.marioObj)
    local isDancing = false
	
    if m.playerIndex ~= 0 or gPlayerSyncTable[m.playerIndex].geodeChar == 1 then return end

    if dancer ~= nil and dancer.playerIndex ~= 0 then
        local distCheck = dist_between_objects(m.marioObj, dancer.marioObj)
        if distCheck <= 200 then
            if m.action == reqAct and dancer.action == ACT_KAZOTSKY_KICK then
                --djui_chat_message_create(tostring(showIcon))
                if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
                    return set_mario_action(m, ACT_KAZOTSKY_KICK, 0)
                end
            end
        end

        if distCheck <= 200 and m.action == reqAct and dancer.action == ACT_KAZOTSKY_KICK then
            gPlayerSyncTable[dancer.playerIndex].showIcon = 1
        elseif distCheck > 200 or m.action ~= reqAct or gPlayerSyncTable[m.playerIndex].geodeChar == 1 then
            gPlayerSyncTable[dancer.playerIndex].showIcon = 0
        end
    end
end

function dance_check(m)
    if m.action == ACT_KAZOTSKY_KICK and
    (gPlayerSyncTable[m.playerIndex].geodeChar == 0 
    or gPlayerSyncTable[m.playerIndex].geodeChar == nil) then
        isDancing = true
    else
        isDancing = false
    end

    return isDancing
end

_G.GeodeChars64 = {
    dance_check = dance_check,
    customTaunt = false,
    kickAnim = 0,
    tauntStartAction = 0
}

_G.MilneExists = true
