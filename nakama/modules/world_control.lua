local world_control = {}

-- TODO see auth multipler docs page 

function world_control.match_init(context, params)
    local state = {
        presences = {}
    }
    local tick_rate = 10
    local label = "Game world"

    return state, tick_rate, label
end

function world_control.match_join_attempt(context, dispatcher, tick, state, presense, metadata)
    
    -- checks..
    
    -- check if player is already logged into the game 
    if state.presences[presense.user_id] ~= nil then
        return state, false, "User is already logged in."
    end

    -- default return 
    return state, true
end

function world_control.match_join(context, dispatcher, tick, state, presences)
    for _, presense in ipairs(presences) do
        state.presences[presense.user_id] = presense
    end
    return state
end

function world_control.match_leave(context, dispatcher, tick, state, presences)
    for _, presense in ipairs(presences) do
        state.presences[presense.user_id] = nil
    end
    return state
end

function world_control.match_loop(context, dispatcher, tick, state, messages)
    return state
end

function world_control.match_terminate(context, dispatcher, tick, state, grace_seconds)
    return state
end

function world_control.match_signal(context, dispatcher, tick, state, data)
    return state, data
end

return world_control