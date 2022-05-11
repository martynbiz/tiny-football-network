local match_control = {}

local nk = require("nakama")

-- local SPAWN_POSITION = {1800.0, 1280.0}
-- local SPAWN_HEIGHT = 463.15
-- local WORLD_WIDTH = 1500

-- Custom operation codes. Nakama specific codes are <= 0.
local OpCodes = {
    -- update_position = 1,
    -- update_input = 2,
    -- update_state = 3,
    -- update_jump = 4,
    join_match = 5,
    -- update_color = 6,
    -- initial_state = 7
}

-- Command pattern table for boiler plate updates that uses data and state.
local commands = {}

-- -- Updates the position in the game state
-- commands[OpCodes.update_position] = function(data, state)
--     local id = data.id
--     local position = data.pos
--     if state.positions[id] ~= nil then
--         state.positions[id] = position
--     end
-- end

-- -- Updates the horizontal input direction in the game state
-- commands[OpCodes.update_input] = function(data, state)
--     local id = data.id
--     local input = data.inp
--     if state.inputs[id] ~= nil then
--         state.inputs[id].dir = input
--     end
-- end

-- -- Updates whether a character jumped in the game state
-- commands[OpCodes.update_jump] = function(data, state)
--     local id = data.id
--     if state.inputs[id] ~= nil then
--         state.inputs[id].jmp = 1
--     end
-- end

-- Updates the character color in the game state once the player's picked a character
commands[OpCodes.join_match] = function(data, state)
    print("command for join_match running..")
    -- local id = data.id
    -- local color = data.col
    -- if state.colors[id] ~= nil then
    --     state.colors[id] = color
    -- end
end

-- -- Updates the character color in the game state after a player's changed colors
-- commands[OpCodes.update_color] = function(data, state)
--     local id = data.id
--     local color = data.col
--     if state.colors[id] ~= nil then
--         state.colors[id] = color
--     end
-- end

-- @see https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/

--[[
Called when a match is created as a result of nk.match_create().
Context represents information about the match and server, for information purposes. Format:
{
  env = {}, -- key-value data set in the runtime.env server configuration.
  execution_mode = "Match",
  match_id = "client-friendly match ID, can be shared with clients and used in match join operations",
  match_node = "name of the Nakama node hosting this match"
}
Params is the optional arbitrary second argument passed to `nk.match_create()`, or `nil` if none was used.
Expected return these values (all required) in order:
1. The initial in-memory state of the match. May be any non-nil Lua term, or nil to end the match.
2. Tick rate representing the desired number of match loop calls per second. Must be between 1 and 30, inclusive.
3. A string label that can be used to filter matches in listing operations. Must be between 0 and 256 characters long.
--]]
function match_control.match_init(context, params)
  local state = {
    presences = {},
    home_team = nil,
    away_team = nil,
    -- inputs = {},
    -- positions = {},
    -- jumps = {},
    -- colors = {},
    -- names = {}
  }
  local tickrate = 10
  local label = "Match"
  return state, tickrate, label
end

--[[
Called when a user attempts to join the match using the client's match join operation.
Context represents information about the match and server, for information purposes. Format:
{
  env = {}, -- key-value data set in the runtime.env server configuration.
  execution_mode = "Match",
  match_id = "client-friendly match ID, can be shared with clients and used in match join operations",
  match_node = "name of the Nakama node hosting this match",
  match_label = "the label string returned from match_init",
  match_tick_rate = 1 -- the tick rate returned by match_init
}
Dispatcher exposes useful functions to the match. Format:
{
  broadcast_message = function(op_code, data, presences, sender),
    -- numeric message op code
    -- a data payload string, or nil
    -- list of presences (a subset of match participants) to use as message targets, or nil to send to the whole match
    -- a presence to tag on the message as the 'sender', or nil
  match_kick = function(presences)
    -- a list of presences to remove from the match
  match_label_update = function(label)
    -- a new label to set for the match
}
Tick is the current match tick number, starts at 0 and increments after every match_loop call. Does not increment with
calls to match_join_attempt, match_join, match_leave, match_terminate, or match_signal.
State is the current in-memory match state, may be any Lua term except nil.
Presence is the user attempting to join the match. Format:
{
  user_id: "user unique ID",
  session_id: "session ID of the user's current connection",
  username: "user's unique username",
  node: "name of the Nakama node the user is connected to"
}
Metadata is an optional set of arbitrary key-value pairs received from the client. These may contain information
the client wishes to supply to the match handler in order to process the join attempt, for example: authentication or
match passwords, client version information, preferences etc. Format:
{
  key: "value"
}
Expected return these values (all required) in order:
1. An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
2. Boolean true if the join attempt should be allowed, false otherwise.
--]]
function match_control.match_join_attempt(context, dispatcher, tick, state, presense, metadata)
    
    -- checks..
    
    -- check if player is already logged into the game 
    if state.presences[presense.user_id] ~= nil then
        return state, false, "User is already logged in."
    end

    -- default return 
    return state, true
end

--[[
Called when one or more users have successfully completed the match join process after their match_join_attempt returns
`true`. When their presences are sent to this function the users are ready to receive match data messages and can be
targets for the dispatcher's `broadcast_message` function.
Context represents information about the match and server, for information purposes. Format:
{
  env = {}, -- key-value data set in the runtime.env server configuration.
  execution_mode = "Match",
  match_id = "client-friendly match ID, can be shared with clients and used in match join operations",
  match_node = "name of the Nakama node hosting this match",
  match_label = "the label string returned from match_init",
  match_tick_rate = 1 -- the tick rate returned by match_init
}
Dispatcher exposes useful functions to the match. Format:
{
  broadcast_message = function(op_code, data, presences, sender),
    -- numeric message op code
    -- a data payload string, or nil
    -- list of presences (a subset of match participants) to use as message targets, or nil to send to the whole match
    -- a presence to tag on the message as the 'sender', or nil
  match_kick = function(presences)
    -- a list of presences to remove from the match
  match_label_update = function(label)
    -- a new label to set for the match
}
Tick is the current match tick number, starts at 0 and increments after every match_loop call. Does not increment with
calls to match_join_attempt, match_join, match_leave, match_terminate, or match_signal.
State is the current in-memory match state, may be any Lua term except nil.
Presences is a list of users that have joined the match. Format:
{
  {
    user_id: "user unique ID",
    session_id: "session ID of the user's current connection",
    username: "user's unique username",
    node: "name of the Nakama node the user is connected to"
  },
  ...
}
Expected return these values (all required) in order:
1. An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
--]]
function match_control.match_join(context, dispatcher, tick, state, presences)
    for _, presense in ipairs(presences) do
        state.presences[presense.user_id] = presense

        -- TODO we'll store team data in storage, use username for now
        local team_name = presense.username 
    
        if state.home_team == nil then 
            state.home_team = {}
            state.home_team["team_name"] = team_name
        elseif state.away_team == nil then 
            state.away_team = {}
            state.away_team["team_name"] = team_name
        end
    end
    return state
end

--[[
Called when one or more users have left the match for any reason, including connection loss.
Context represents information about the match and server, for information purposes. Format:
{
  env = {}, -- key-value data set in the runtime.env server configuration.
  execution_mode = "Match",
  match_id = "client-friendly match ID, can be shared with clients and used in match join operations",
  match_node = "name of the Nakama node hosting this match",
  match_label = "the label string returned from match_init",
  match_tick_rate = 1 -- the tick rate returned by match_init
}
Dispatcher exposes useful functions to the match. Format:
{
  broadcast_message = function(op_code, data, presences, sender),
    -- numeric message op code
    -- a data payload string, or nil
    -- list of presences (a subset of match participants) to use as message targets, or nil to send to the whole match
    -- a presence to tag on the message as the 'sender', or nil
  match_kick = function(presences)
    -- a list of presences to remove from the match
  match_label_update = function(label)
    -- a new label to set for the match
}
Tick is the current match tick number, starts at 0 and increments after every match_loop call. Does not increment with
calls to match_join_attempt, match_join, match_leave, match_terminate, or match_signal.
State is the current in-memory match state, may be any Lua term except nil.
Presences is a list of users that have left the match. Format:
{
  {
    user_id: "user unique ID",
    session_id: "session ID of the user's current connection",
    username: "user's unique username",
    node: "name of the Nakama node the user is connected to"
  },
  ...
}
Expected return these values (all required) in order:
1. An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
--]]
function match_control.match_leave(context, dispatcher, tick, state, presences)
    for _, presense in ipairs(presences) do
        state.presences[presense.user_id] = nil
        state.home_team = nil
        state.away_team = nil
    end
    return state
end

--[[
Called on an interval based on the tick rate returned by match_init.
Context represents information about the match and server, for information purposes. Format:
{
  env = {}, -- key-value data set in the runtime.env server configuration.
  executionMode = "Match",
  match_id = "client-friendly match ID, can be shared with clients and used in match join operations",
  match_node = "name of the Nakama node hosting this match",
  match_label = "the label string returned from match_init",
  match_tick_rate = 1 -- the tick rate returned by match_init
}
Dispatcher exposes useful functions to the match. Format:
{
  broadcast_message = function(op_code, data, presences, sender),
    -- numeric message op code
    -- a data payload string, or nil
    -- list of presences (a subset of match participants) to use as message targets, or nil to send to the whole match
    -- a presence to tag on the message as the 'sender', or nil
  match_kick = function(presences)
    -- a list of presences to remove from the match
  match_label_update = function(label)
    -- a new label to set for the match
}
Tick is the current match tick number, starts at 0 and increments after every match_loop call. Does not increment with
calls to match_join_attempt, match_join, match_leave, match_terminate, or match_signal.
State is the current in-memory match state, may be any Lua term except nil.
Messages is a list of data messages received from users between the previous and current ticks. Format:
{
  {
    sender = {
      user_id: "user unique ID",
      session_id: "session ID of the user's current connection",
      username: "user's unique username",
      node: "name of the Nakama node the user is connected to"
    },
    op_code = 1, -- numeric op code set by the sender.
    data = "any string data set by the sender" -- may be nil.
  },
  ...
}
Expected return these values (all required) in order:
1. An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
--]]
function match_control.match_loop(context, dispatcher, tick, state, messages)
    for _, message in ipairs(messages) do
        local op_code = message.op_code

        local decoded = nk.json_decode(message.data)

        -- Run boiler plate commands (state updates.)
        local command = commands[op_code]
        if command ~= nil then
            commands[op_code](decoded, state)
        end

        -- A client has selected a character and is spawning. Get or generate position data,
        -- send them initial state, and broadcast their spawning to existing clients.
        if op_code == OpCodes.join_match then

            -- local object_ids = {
            --     {
            --         collection = "player_data",
            --         key = "position_" .. decoded.nm,
            --         user_id = message.sender.user_id
            --     }
            -- }

            -- local objects = nk.storage_read(object_ids)

            -- local position
            -- for _, object in ipairs(objects) do
            --     position = object.value
            --     if position ~= nil then
            --         state.positions[message.sender.user_id] = position
            --         break
            --     end
            -- end

            -- if position == nil then
            --     state.positions[message.sender.user_id] = {
            --         ["x"] = SPAWN_POSITION[1],
            --         ["y"] = SPAWN_POSITION[2]
            --     }
            -- end

            -- state.names[message.sender.user_id] = decoded.nm

            -- local data = {
            --     ["pos"] = state.positions,
            --     ["inp"] = state.inputs,
            --     ["col"] = state.colors,
            --     ["nms"] = state.names
            -- }

            -- local encoded = nk.json_encode(data)
            -- dispatcher.broadcast_message(OpCodes.initial_state, encoded, {message.sender})

            local data = {}
            -- data["id"] = message.data.id
            data["presences"] = state.presences
            data["home_team"] = state.home_team
            data["away_team"] = state.away_team

            local encoded = nk.json_encode(data)

            dispatcher.broadcast_message(OpCodes.join_match, encoded)
        end
    end

    -- local data = {
    --     ["pos"] = state.positions,
    --     ["inp"] = state.inputs
    -- }
    -- local encoded = nk.json_encode(data)

    -- dispatcher.broadcast_message(OpCodes.update_state, encoded)

    -- for _, input in pairs(state.inputs) do
    --     input.jmp = 0
    -- end

    return state
end

--[[
Called when the server begins a graceful shutdown process. Will not be called if graceful shutdown is disabled.
Context represents information about the match and server, for information purposes. Format:
{
  env = {}, -- key-value data set in the runtime.env server configuration.
  executionMode = "Match",
  match_id = "client-friendly match ID, can be shared with clients and used in match join operations",
  match_node = "name of the Nakama node hosting this match",
  match_label = "the label string returned from match_init",
  match_tick_rate = 1 -- the tick rate returned by match_init
}
Dispatcher exposes useful functions to the match. Format:
{
  broadcast_message = function(op_code, data, presences, sender),
    -- numeric message op code
    -- a data payload string, or nil
    -- list of presences (a subset of match participants) to use as message targets, or nil to send to the whole match
    -- a presence to tag on the message as the 'sender', or nil
  match_kick = function(presences)
    -- a list of presences to remove from the match
  match_label_update = function(label)
    -- a new label to set for the match
}
Tick is the current match tick number, starts at 0 and increments after every match_loop call. Does not increment with
calls to match_join_attempt, match_join, match_leave, match_terminate, or match_signal.
State is the current in-memory match state, may be any Lua term except nil.
Grace Seconds is the number of seconds remaining until the server will shut down.
Expected return these values (all required) in order:
1. An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
--]]
function match_control.match_terminate(context, dispatcher, tick, state, grace_seconds)
    print("match_control.match_terminate")
    return state
end

--[[
Called when the match handler receives a runtime signal.
Context represents information about the match and server, for information purposes. Format:
{
  env = {}, -- key-value data set in the runtime.env server configuration.
  executionMode = "Match",
  match_id = "client-friendly match ID, can be shared with clients and used in match join operations",
  match_node = "name of the Nakama node hosting this match",
  match_label = "the label string returned from match_init",
  match_tick_rate = 1 -- the tick rate returned by match_init
}
Dispatcher exposes useful functions to the match. Format:
{
  broadcast_message = function(op_code, data, presences, sender),
    -- numeric message op code
    -- a data payload string, or nil
    -- list of presences (a subset of match participants) to use as message targets, or nil to send to the whole match
    -- a presence to tag on the message as the 'sender', or nil
  match_kick = function(presences)
    -- a list of presences to remove from the match
  match_label_update = function(label)
    -- a new label to set for the match
}
Tick is the current match tick number, starts at 0 and increments after every match_loop call. Does not increment with
calls to match_join_attempt, match_join, match_leave, match_terminate, or match_signal.
State is the current in-memory match state, may be any Lua term except nil.
Data is arbitrary input supplied by the runtime caller of the signal.
Expected return these values (all required) in order:
1. An (optionally) updated state. May be any non-nil Lua term, or nil to end the match.
1. Arbitrary data to return to the runtime caller of the signal. May be a string, or nil.
--]]
function match_control.match_signal(context, dispatcher, tick, state, data)
    print("match_control.match_signal")
    return state, data
end

return match_control