local world_control = {}

-- TODO see auth multipler docs page 

function world_control.init_match(context, params)
    local state = {
        presenses = {}
    }
    local tick_rate = 10
    local label = "Game world"

    return state, tick_rate, label
end

function world_control.match_join_attempt(context, dispatcher, tick, state, presense, metadata)
    if state.presenses[presense.user_id] ~= nil then
        return state, false, "User is already logged in."
    end
    return state, true
end

function world_control.match_join(context, dispatcher, tick, state, presenses)
    for _, presense in ipairs(presenses) do
        state.presenses[presense.user_id] = presense
    end
    return state
end

function world_control.match_leave(context, dispatcher, tick, state, presenses)
    for _, presense in ipairs(presenses) do
        state.presenses[presense.user_id] = nil
    end
    return state
end

function world_control.match_loop(context, dispatcher, tick, state, messages)
    return state
end

function world_control.match_terminate(context, dispatcher, tick, state, grace_seconds)
    
end

return world_control