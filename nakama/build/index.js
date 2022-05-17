"use strict";
var InitModule = function (ctx, logger, nk, initializer) {
    initializer.registerRpc('healthcheck', rpcHealthcheck);
    initializer.registerRpc('match_rpc', rpcGetMatchId);
    logger.info("Hello World!");
    initializer.registerMatch("match_control", match);
};
function rpcHealthcheck(ctx, logger, nk, payload) {
    logger.info("healthcheck rpc called");
    return JSON.stringify({ success: true });
}
// @see https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/
var matchInit = function (ctx, logger, nk, params) {
    logger.debug('matchInit');
    var state = {
        presences: {}
    };
    var tickRate = 10;
    var label = "Match";
    return { state: state, tickRate: tickRate, label: label };
};
var matchJoinAttempt = function (ctx, logger, nk, dispatcher, tick, state, presence, metadata) {
    logger.debug('matchJoinAttempt');
    if (typeof state.presences[presence.userId] == 'undefined') {
        return { state: state, accept: false, rejectMessage: 'User is already logged in.' };
    }
    return {
        state: state,
        accept: true
    };
};
var matchJoin = function (ctx, logger, nk, dispatcher, tick, state, presences) {
    logger.debug('matchJoin');
    presences.forEach(function (presence) {
        state.presences[presence.userId] = presence;
    });
    //       -- TODO we'll store team data in storage, use username for now
    //       local team_name = presense.username
    //       if state.home_team == nil then
    //           state.home_team = {}
    //           state.home_team["team_name"] = team_name
    //           state.home_team["user_id"] = presense.user_id
    //       elseif state.away_team == nil then
    //           state.away_team = {}
    //           state.away_team["team_name"] = team_name
    //           state.away_team["user_id"] = presense.user_id
    //       end
    return {
        state: state
    };
};
var matchLeave = function (ctx, logger, nk, dispatcher, tick, state, presences) {
    logger.debug('matchLeave');
    presences.forEach(function (presence) {
        delete state.presences[presence.userId];
    });
    // for _, presense in ipairs(presences) do
    //     state.presences[presense.user_id] = nil
    //     state.home_team = nil
    //     state.away_team = nil
    // end
    // return state
    return {
        state: state
    };
};
var matchLoop = function (ctx, logger, nk, dispatcher, tick, state, messages) {
    logger.debug('matchLoop');
    // -- in the event of no messages, we'll not send anything to the clients
    // local is_state_change = false 
    // -- we'll build this up when we loop messages
    // local match_state_data = {
    //     humans = {},
    //     ball = {},
    //     tick = tick,
    // }
    // for _, message in ipairs(messages) do
    //     local op_code = message.op_code
    //     local decoded = nk.json_decode(message.data)
    //     -- Run boiler plate commands (state updates.)
    //     local command = commands[op_code]
    //     if command ~= nil then
    //         commands[op_code](decoded, state)
    //     end
    //     -- A client has joined the match, broadcast to other player that they have been paired 
    //     if op_code == OpCodes.join_match then
    //         -- local object_ids = {
    //         --     {
    //         --         collection = "player_data",
    //         --         key = "position_" .. decoded.nm,
    //         --         user_id = message.sender.user_id
    //         --     }
    //         -- }
    //         -- local objects = nk.storage_read(object_ids)
    //         -- local position
    //         -- for _, object in ipairs(objects) do
    //         --     position = object.value
    //         --     if position ~= nil then
    //         --         state.positions[message.sender.user_id] = position
    //         --         break
    //         --     end
    //         -- end
    //         -- if position == nil then
    //         --     state.positions[message.sender.user_id] = {
    //         --         ["x"] = SPAWN_POSITION[1],
    //         --         ["y"] = SPAWN_POSITION[2]
    //         --     }
    //         -- end
    //         -- state.names[message.sender.user_id] = decoded.nm
    //         -- local data = {
    //         --     ["pos"] = state.positions,
    //         --     ["inp"] = state.humans,
    //         --     ["col"] = state.colors,
    //         --     ["nms"] = state.names
    //         -- }
    //         -- local encoded = nk.json_encode(data)
    //         -- dispatcher.broadcast_message(OpCodes.initial_state, encoded, {message.sender})
    //         local match_join_data = {}
    //         match_join_data["presences"] = state.presences
    //         match_join_data["home_team"] = state.home_team
    //         match_join_data["away_team"] = state.away_team
    //         local encoded = nk.json_encode(match_join_data)
    //         dispatcher.broadcast_message(OpCodes.join_match, encoded)
    //     else
    //         local name = decoded.name
    //         match_state_data.humans[name] = state.humans[name]
    //         is_state_change = true 
    //     end
    // end
    // if is_state_change then
    //     local encoded = nk.json_encode(match_state_data)
    //     dispatcher.broadcast_message(OpCodes.update_state, encoded)
    //     -- local data = {
    //     --     ["humans"] = state.humans
    //     -- }
    //     -- local encoded = nk.json_encode(data)
    //     -- dispatcher.broadcast_message(OpCodes.update_state, encoded)
    //     -- for _, input in pairs(state.humans) do
    //     --     input.jmp = 0
    //     -- end
    // end
    return {
        state: state
    };
};
var matchTerminate = function (ctx, logger, nk, dispatcher, tick, state, graceSeconds) {
    logger.debug('matchTerminate');
    return {
        state: state
    };
};
var matchSignal = function (ctx, logger, nk, dispatcher, tick, state, data) {
    logger.debug('matchSignal');
    return {
        state: state,
        data: data
    };
};
var match = {
    matchInit: matchInit,
    matchJoinAttempt: matchJoinAttempt,
    matchJoin: matchJoin,
    matchLeave: matchLeave,
    matchLoop: matchLoop,
    matchTerminate: matchTerminate,
    matchSignal: matchSignal
};
function rpcGetMatchId(ctx, logger, nk, payload) {
    var matchId = nk.matchCreate("match_control", {});
    return matchId;
    // logger.info("getmatchid rpc called");
    // // local matches = nakama.match_list()
    // // local current_match = matches[1]
    // const matches: nkruntime.Match[] = nk.matchList(10);
    // const currentMatch = matches[0]
    // if (typeof currentMatch == "undefined") {
    //     const matchId = nk.matchCreate("lobby", { "invited": matches })
    //     return matchId;
    // } else {
    //     return currentMatch.matchId
    // }
    // -- TODO if no current match, create one; otherwise, join a pending one that doesn't include this user
    // -- print("looping matches...", type(matches))
    // -- -- for i,match in ipairs(matches) do
    // --     print(i,matches[i])
    // -- end
    // -- print("END")
    // if current_match == nil then
    //     return nakama.match_create("match_control", {})
    // else
    //     return current_match.match_id
    // end
    // return JSON.stringify({success: true});
}
