"use strict";
var InitModule = function (ctx, logger, nk, initializer) {
    initializer.registerRpc('healthcheck', rpcHealthcheck);
    logger.info("Hello World!");
};
function rpcHealthcheck(ctx, logger, nk, payload) {
    logger.info("healthcheck rpc called");
    return JSON.stringify({ success: true });
}
// @see https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/
var matchInit = function (ctx, logger, nk, params) {
    return {
        state: {},
        tickRate: 1,
        label: ""
    };
};
var matchJoinAttempt = function (ctx, logger, nk, dispatcher, tick, state, presence, metadata) {
    return {
        state: state,
        accept: true
    };
};
var matchJoin = function (ctx, logger, nk, dispatcher, tick, state, presences) {
    return {
        state: state
    };
};
var matchLeave = function (ctx, logger, nk, dispatcher, tick, state, presences) {
    return {
        state: state
    };
};
var matchLoop = function (ctx, logger, nk, dispatcher, tick, state, messages) {
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
    logger.debug('Lobby match signal received: ' + data);
    return {
        state: state,
        data: data
    };
};
// Register the match handler
initializer.registerMatch('match_control', {
    matchInit: matchInit,
    matchJoinAttempt: matchJoinAttempt,
    matchJoin: matchJoin,
    matchLoop: matchLoop,
    matchLeave: matchLeave,
    matchTerminate: matchTerminate,
    matchSignal: matchSignal
});
