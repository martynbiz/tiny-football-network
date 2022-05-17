"use strict";
var InitModule = function (ctx, logger, nk, initializer) {
    initializer.registerRpc('healthcheck', rpcHealthcheck);
    initializer.registerRpc('get_match_id', rpcGetMatchId);
    logger.info("Hello World!");
    initializer.registerMatch("match_control", match);
};
function rpcHealthcheck(ctx, logger, nk, payload) {
    logger.info("healthcheck rpc called");
    return JSON.stringify({ success: true });
}
// @see https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/
var OpCodes;
(function (OpCodes) {
    OpCodes[OpCodes["updateDirection"] = 2] = "updateDirection";
    OpCodes[OpCodes["updateState"] = 3] = "updateState";
    OpCodes[OpCodes["joinMatch"] = 5] = "joinMatch";
})(OpCodes || (OpCodes = {}));
var commands = [];
commands[OpCodes.updateDirection] = function (data, state) {
    var name = data.name;
    if (typeof state.humans[name] == "undefined" || state.humans[name] == null) {
        state.humans[name] = {};
    }
    state.humans[name].dir = {
        x: data.dir.x,
        y: data.dir.y
    };
};
commands[OpCodes.updateState] = function (data, state) {
};
commands[OpCodes.joinMatch] = function (data, state) {
    var name = data.name;
    if (typeof state.humans[name] == "undefined" || state.humans[name] == null) {
        state.humans[name] = {};
    }
    state.humans[name].pos = {
        x: data.pos.x,
        y: data.pos.y
    };
    state.humans[name].anim = data.anim;
};
var matchInit = function (ctx, logger, nk, params) {
    var state = {
        presences: {},
        home_team: null,
        away_team: null,
        humans: {},
    };
    var tickRate = 10;
    var label = "Match";
    return { state: state, tickRate: tickRate, label: label };
};
var matchJoinAttempt = function (ctx, logger, nk, dispatcher, tick, state, presence, metadata) {
    logger.debug('matchJoinAttempt');
    if (typeof state.presences[presence.userId] != 'undefined') {
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
        var username = presence.username, userId = presence.userId;
        var team_name = username;
        if (typeof state.home_team == "undefined" || state.home_team == null) {
            state.home_team = {
                team_name: team_name,
                user_id: userId,
            };
        }
        else if (typeof state.away_team == "undefined" || state.away_team == null) {
            state.away_team = {
                team_name: team_name,
                user_id: userId,
            };
        }
    });
    return {
        state: state
    };
};
var matchLeave = function (ctx, logger, nk, dispatcher, tick, state, presences) {
    presences.forEach(function (presence) {
        var userId = presence.userId;
        delete state.presences[presence.userId];
        if (state.home_team.user_id == userId) {
            state.home_team = null;
        }
        else if (state.away_team.user_id == userId) {
            state.away_team = null;
        }
    });
    return {
        state: state
    };
};
var matchLoop = function (ctx, logger, nk, dispatcher, tick, state, messages) {
    // in the event of no messages, we'll not send anything to the clients
    var isStateChange = false;
    // we'll build this up when we loop messages so we only transmit what's changed
    var matchStateChanges = {
        humans: {},
        ball: {},
    };
    messages.forEach(function (message) {
        var opCode = message.opCode;
        var decoded = JSON.parse(nk.binaryToString(message.data));
        // Run boiler plate commands (state updates.)
        if (typeof commands[opCode] !== "undefined") {
            commands[opCode](decoded, state);
        }
        if (opCode === OpCodes.joinMatch) {
            var presences = state.presences, home_team = state.home_team, away_team = state.away_team;
            var matchJoinData = {
                presences: presences,
                home_team: home_team,
                away_team: away_team,
            };
            var encoded = JSON.stringify(matchJoinData);
            dispatcher.broadcastMessage(OpCodes.joinMatch, encoded);
        }
        else {
            var name_1 = decoded.name;
            logger.debug(name_1);
            matchStateChanges.humans[name_1] = state.humans[name_1];
            isStateChange = true;
        }
    });
    if (isStateChange) {
        var encoded = JSON.stringify(matchStateChanges);
        dispatcher.broadcastMessage(OpCodes.updateState, encoded);
    }
    return {
        state: state
    };
};
var matchTerminate = function (ctx, logger, nk, dispatcher, tick, state, graceSeconds) {
    return {
        state: state
    };
};
var matchSignal = function (ctx, logger, nk, dispatcher, tick, state, data) {
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
    var matches = nk.matchList(1);
    var currentMatch = matches[0];
    if (typeof currentMatch == "undefined") {
        var matchId = nk.matchCreate("match_control", { "invited": matches });
        return JSON.stringify(matchId);
    }
    else {
        return JSON.stringify(currentMatch.matchId);
    }
}
