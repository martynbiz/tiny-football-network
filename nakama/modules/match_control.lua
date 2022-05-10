local match_control = {}

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
        presences = {}
    }
    local tick_rate = 10
    local label = "Match"

    return state, tick_rate, label
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
    return state, data
end

return match_control