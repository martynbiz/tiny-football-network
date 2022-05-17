// @see https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/

// Declare a custom interface to type the object
interface HumansObject {
  [index: string]: object
}

enum OpCodes {
  updateDirection = 2,
  updateState = 3,
  joinMatch = 5,
}

const commands: Function[] = [];

commands[OpCodes.updateDirection] = (data: any, state: nkruntime.MatchState) => {
  const name = data.name

  if (typeof state.humans[name] == "undefined" || state.humans[name] == null) {
    state.humans[name] = {}
  }

  state.humans[name].dir = {
      x: data.dir.x,
      y: data.dir.y
  }
}

commands[OpCodes.updateState] = (data: any, state: nkruntime.MatchState) => {
  const name = data.name

  if (typeof state.humans[name] == "undefined" || state.humans[name] == null) {
    state.humans[name] = {}
  }

  state.humans[name].pos = {
      x: data.pos.x,
      y: data.pos.y
  }

  state.humans[name].anim = data.anim
}

commands[OpCodes.joinMatch] = (data: any, state: nkruntime.MatchState) => {
  
}

const matchInit = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, params: { [key: string]: string }): { state: nkruntime.MatchState, tickRate: number, label: string } => {
  const state = {
    presences: {},
    home_team: null,
    away_team: null,
    humans: {},
  }
  const tickRate = 10
  const label = "Match"
  return { state, tickRate, label };
};

const matchJoinAttempt = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, presence: nkruntime.Presence, metadata: { [key: string]: any }): { state: nkruntime.MatchState, accept: boolean, rejectMessage?: string | undefined } | null => {
  logger.debug('matchJoinAttempt');

  if (typeof state.presences[presence.userId] != 'undefined') {
    return { state, accept: false, rejectMessage: 'User is already logged in.' }
  }

  return {
    state,
    accept: true
  };
}

const matchJoin = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, presences: nkruntime.Presence[]): { state: nkruntime.MatchState } | null => {
  logger.debug('matchJoin');

  presences.forEach((presence) => {
    state.presences[presence.userId] = presence

    const { username, userId } = presence
    const team_name = username

    if (typeof state.home_team == "undefined" || state.home_team == null) {
      state.home_team = {
        team_name,
        user_id: userId,
      }
    } else if (typeof state.away_team == "undefined" || state.away_team == null) {
      state.away_team = {
        team_name,
        user_id: userId,
      }
    }
  });

  return {
    state
  };
}

const matchLeave = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, presences: nkruntime.Presence[]): { state: nkruntime.MatchState } | null => {
  presences.forEach((presence) => {
    const { userId } = presence
    delete state.presences[presence.userId]
    if (state.home_team.user_id == userId) {
      state.home_team = null
    } else if (state.away_team.user_id == userId) {
      state.away_team = null
    }
  });

  return {
    state
  };
}

const matchLoop = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, messages: nkruntime.MatchMessage[]): { state: nkruntime.MatchState } | null => {

  // in the event of no messages, we'll not send anything to the clients
  let isStateChange = false

    const humans: HumansObject = {}

    // we'll build this up when we loop messages so we only transmit what's changed
    const matchStateChanges = {
      humans,
      ball: {},
    }

  messages.forEach(message => {
    const opCode = message.opCode
    const decoded = JSON.parse(nk.binaryToString(message.data));

    // Run boiler plate commands (state updates.)
    if (typeof commands[opCode] !== "undefined") {
      commands[opCode](decoded, state)
    }

    if (opCode === OpCodes.joinMatch) {
      const { presences, home_team, away_team } = state
      const matchJoinData = {
        presences,
        home_team,
        away_team,
      }

      const encoded = JSON.stringify(matchJoinData)

      dispatcher.broadcastMessage(OpCodes.joinMatch, encoded)
    } else {
      const { name } = decoded
      matchStateChanges.humans[name] = state.humans[name]
      isStateChange = true
    }
  })

  if (isStateChange) {
    const encoded = JSON.stringify(matchStateChanges)
    dispatcher.broadcastMessage(OpCodes.updateState, encoded)
  }

  return {
    state
  };
}

const matchTerminate = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, graceSeconds: number): { state: nkruntime.MatchState } | null => {
  return {
    state
  };
}

const matchSignal = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, data: string): { state: nkruntime.MatchState, data?: string } | null => {
  return {
    state,
    data
  };
}

const match: nkruntime.MatchHandler = {
  matchInit,
  matchJoinAttempt,
  matchJoin,
  matchLeave,
  matchLoop,
  matchTerminate,
  matchSignal
}