function rpcHealthcheck(ctx, logger, nk, payload) {
  logger.info("healthcheck rpc called");
  return JSON.stringify({
    success: true
  });
}

function rpcGetMatchId(ctx, logger, nk, payload) {
  var matches = nk.matchList(1);
  var currentMatch = matches[0];

  if (typeof currentMatch == "undefined") {
    var matchId = nk.matchCreate("match_control", {
      "invited": matches
    });
    return JSON.stringify(matchId);
  } else {
    return JSON.stringify(currentMatch.matchId);
  }
}

var OpCodes;

(function (OpCodes) {
  OpCodes[OpCodes["updatePlayerState"] = 3] = "updatePlayerState";
  OpCodes[OpCodes["updateMatchState"] = 4] = "updateMatchState";
  OpCodes[OpCodes["joinMatch"] = 5] = "joinMatch";
})(OpCodes || (OpCodes = {}));

var commands = [];

commands[OpCodes.updatePlayerState] = function (data, state) {
  var name = data.name;

  if (typeof state.humans[name] == "undefined" || state.humans[name] == null) {
    state.humans[name] = {};
  }

  if (data.pos) {
    state.humans[name].pos = {
      x: data.pos.x,
      y: data.pos.y
    };
  }

  if (data.dir) {
    state.humans[name].dir = {
      x: data.dir.x,
      y: data.dir.y
    };
  }

  state.humans[name].anim = data.anim;
};

commands[OpCodes.updateMatchState] = function (data, state) {
  if (state.home_team.user_id == data.user_id) {
    state.match_states.home = data.name;
  } else if (state.away_team.user_id == data.user_id) {
    state.match_states.away = data.name;
  }
};

commands[OpCodes.joinMatch] = function (data, state) {};

var matchInit = function matchInit(ctx, logger, nk, params) {
  var state = {
    presences: {},
    home_team: null,
    away_team: null,
    humans: {},
    match_states: {
      home: null,
      away: null
    }
  };
  var tickRate = 10;
  var label = "Match";
  return {
    state: state,
    tickRate: tickRate,
    label: label
  };
};

var matchJoinAttempt = function matchJoinAttempt(ctx, logger, nk, dispatcher, tick, state, presence, metadata) {
  logger.debug('matchJoinAttempt');

  if (typeof state.presences[presence.userId] != 'undefined') {
    return {
      state: state,
      accept: false,
      rejectMessage: 'User is already logged in.'
    };
  }

  return {
    state: state,
    accept: true
  };
};

var matchJoin = function matchJoin(ctx, logger, nk, dispatcher, tick, state, presences) {
  presences.forEach(function (presence) {
    state.presences[presence.userId] = presence;
    var username = presence.username,
        userId = presence.userId;
    var team_name = username;

    if (typeof state.home_team == "undefined" || state.home_team == null) {
      state.home_team = {
        team_name: team_name,
        user_id: userId
      };
    } else if (typeof state.away_team == "undefined" || state.away_team == null) {
      state.away_team = {
        team_name: team_name,
        user_id: userId
      };
    }
  });
  return {
    state: state
  };
};

var matchLeave = function matchLeave(ctx, logger, nk, dispatcher, tick, state, presences) {
  presences.forEach(function (presence) {
    var userId = presence.userId;
    delete state.presences[presence.userId];

    if (state.home_team.user_id == userId) {
      state.home_team = null;
    } else if (state.away_team.user_id == userId) {
      state.away_team = null;
    }
  });
  return {
    state: state
  };
};

var matchLoop = function matchLoop(ctx, logger, nk, dispatcher, tick, state, messages) {
  var isPlayerStateChange = false;
  var isMatchStateChange = false;
  var humans = {};
  var matchStateChanges = {
    humans: humans,
    ball: {}
  };
  messages.forEach(function (message) {
    var opCode = message.opCode;
    var decoded = JSON.parse(nk.binaryToString(message.data));
    var presences = state.presences;

    if (typeof commands[opCode] !== "undefined") {
      commands[opCode](decoded, state);
    }

    if (opCode === OpCodes.joinMatch) {
      var home_team = state.home_team,
          away_team = state.away_team;
      var matchJoinData = {
        presences: presences,
        home_team: home_team,
        away_team: away_team
      };
      var encoded = JSON.stringify(matchJoinData);
      dispatcher.broadcastMessage(OpCodes.joinMatch, encoded);
    } else if (opCode === OpCodes.updateMatchState) {
      isMatchStateChange = true;
    } else if (opCode === OpCodes.updatePlayerState) {
      var name_1 = decoded.name;
      matchStateChanges.humans[name_1] = state.humans[name_1];
      isPlayerStateChange = true;
    }
  });

  if (isPlayerStateChange) {
    var encoded = JSON.stringify(matchStateChanges);
    dispatcher.broadcastMessage(OpCodes.updatePlayerState, encoded);
  }

  if (isMatchStateChange) {
    var isClientsReady = state.match_states.home === state.match_states.home;
    var encoded = JSON.stringify({
      is_clients_ready: isClientsReady
    });
    dispatcher.broadcastMessage(OpCodes.updateMatchState, encoded);
  }

  return {
    state: state
  };
};

var matchTerminate = function matchTerminate(ctx, logger, nk, dispatcher, tick, state, graceSeconds) {
  return {
    state: state
  };
};

var matchSignal = function matchSignal(ctx, logger, nk, dispatcher, tick, state, data) {
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

var InitModule = function InitModule(ctx, logger, nk, initializer) {
  initializer.registerRpc('healthcheck', rpcHealthcheck);
  initializer.registerRpc('get_match_id', rpcGetMatchId);
  initializer.registerMatch("match_control", match);
  logger.info("Hello World!");
};

!InitModule && InitModule.bind(null);
