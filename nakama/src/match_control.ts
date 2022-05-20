// @see https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/


// Declare a custom interface to type the object
interface HumansObject {
  [index: string]: object
}

enum OpCodes {
  updatePlayerState = 3,
  updateMatchState = 4,
  joinMatch = 5,
}

const commands: Function[] = [];

commands[OpCodes.updatePlayerState] = (data: any, state: nkruntime.MatchState) => {

  const name = data.name

  if (typeof state.humans[name] == "undefined" || state.humans[name] == null) {
    state.humans[name] = {}
  }

  if (data.pos) {
    state.humans[name].pos = {
      x: data.pos.x,
      y: data.pos.y
    }
  }

  if (data.dir) {
    state.humans[name].dir = {
      x: data.dir.x,
      y: data.dir.y
    }
  }

  state.humans[name].anim = data.anim
}

commands[OpCodes.updateMatchState] = (data: any, state: nkruntime.MatchState) => {

  // determine whether this is updating home or away based on user_id
  if (data.new_state) {
    if (state.home_team.user_id == data.user_id) {
      state.match_states.home = data.new_state
    } else if (state.away_team.user_id == data.user_id) {
      state.match_states.away = data.new_state
    }
  }
  
}

commands[OpCodes.joinMatch] = (data: any, state: nkruntime.MatchState) => {

}

// // helper object to append the opponent of a message's user id so we don't need to send 
// // back to the sender in cases it ca be avoided
// const appendOpponentUserId = (appendTo: string[], senderId: string, presences: nkruntime.Presence[]) => {
//   for (let i = 0; i < presences.length; i++) {
//     const presence = presences[i];
//     if (presence.userId != senderId) {
//       appendTo.push(senderId)
//     }
//   }
// }

const matchInit = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, params: { [key: string]: string }): { state: nkruntime.MatchState, tickRate: number, label: string } => {
  const state = {
    presences: {},
    home_team: null,
    away_team: null,
    humans: {},
    match_states: {
      home: null, // e.g. Foul
      away: null,
    }
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
  // let playerStateChangeUserIds: nkruntime.Presence[] = []
  let isPlayerStateChange = false

  // let matchStateChangeUserIds: nkruntime.Presence[] = []
  let isMatchStateChange = false

  const humans: HumansObject = {}

  // we'll build this up when we loop messages so we only transmit what's changed
  const playerStateChanges = {
    humans,
    ball: {},
  }

  // we'll build this up when we loop messages so we only transmit what's changed
  const matchStateChanges = {
    new_state: null,
    state_settings: {},
    is_clients_ready: false,
    match_states: state.match_states,
  }

  messages.forEach(message => {
    const opCode = message.opCode
    const decoded = JSON.parse(nk.binaryToString(message.data));

    const { presences } = state

    // Run boiler plate commands (state updates.)
    if (typeof commands[opCode] !== "undefined") {
      commands[opCode](decoded, state)
    }

    // if (opCode === OpCodes.updateMatchState) {
    //   logger.debug(JSON.stringify(decoded))
    //   logger.debug(JSON.stringify(state))
    // }

    if (opCode === OpCodes.joinMatch) {
      const { home_team, away_team } = state
      const matchJoinData = {
        presences,
        home_team,
        away_team,
      }

      const encoded = JSON.stringify(matchJoinData)

      dispatcher.broadcastMessage(OpCodes.joinMatch, encoded)

    } else if (opCode === OpCodes.updateMatchState) {

      // // this'll push other presences user ids other than the sender
      // matchStateChangeUserIds.push(...presences.filter((presence: nkruntime.Presence) => presence.userId != decoded.user_id))
      // matchStateChangeUserIds = matchStateChangeUserIds.filter((c, index) => {
      //   return chars.indexOf(c) === index;
      // });

      matchStateChanges.new_state = decoded.new_state
      matchStateChanges.state_settings = decoded.state_settings
      matchStateChanges.is_clients_ready = (state.match_states.home === state.match_states.away)

      // if all this op code does it broadcast state changes, then we don't need to if both are the same
      isMatchStateChange = true

    } else if (opCode === OpCodes.updatePlayerState) {

      const { name } = decoded
      playerStateChanges.humans[name] = state.humans[name]

      // // this'll push other presences user ids other than the sender
      // playerStateChangeUserIds.push(...presences.filter((presence: nkruntime.Presence) => presence.userId != decoded.user_id) //.map((presence: nkruntime.Presence) => presence.userId))
      // playerStateChangeUserIds = playerStateChangeUserIds.filter((c, index) => {
      //   return chars.indexOf(c) === index;
      // });

      isPlayerStateChange = true

    }
  })

  if (isPlayerStateChange) {
    const encoded = JSON.stringify(playerStateChanges)
    dispatcher.broadcastMessage(OpCodes.updatePlayerState, encoded)
  }

  if (isMatchStateChange) {
    const encoded = JSON.stringify(matchStateChanges)
    dispatcher.broadcastMessage(OpCodes.updateMatchState, encoded)
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

export const match: nkruntime.MatchHandler = {
  matchInit,
  matchJoinAttempt,
  matchJoin,
  matchLeave,
  matchLoop,
  matchTerminate,
  matchSignal
}