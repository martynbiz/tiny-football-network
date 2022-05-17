// @see https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/

const matchInit = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, params: { [key: string]: string }): { state: nkruntime.MatchState, tickRate: number, label: string } => {
  const state = {
    presences: {}
  }
  const tickRate = 10
  const label = "Match"
  return { state, tickRate, label };
};

const matchJoinAttempt = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, presence: nkruntime.Presence, metadata: { [key: string]: any }): { state: nkruntime.MatchState, accept: boolean, rejectMessage?: string | undefined } | null => {
  logger.debug('matchJoinAttempt');

  if (typeof state.presences[presence.userId] != 'undefined') {
    return { state, accept: false, rejectMessage: 'User is already logged in.'}
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
    state
  };
}

const matchLeave = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, presences: nkruntime.Presence[]): { state: nkruntime.MatchState } | null => {
  logger.debug('matchLeave');

  presences.forEach((presence) => {
    delete state.presences[presence.userId]
  });

  // for _, presense in ipairs(presences) do
  //     state.presences[presense.user_id] = nil
  //     state.home_team = nil
  //     state.away_team = nil
  // end
  // return state

  return {
    state
  };
}

const matchLoop = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, messages: nkruntime.MatchMessage[]): { state: nkruntime.MatchState } | null => {
  
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
    state
  };
}

const matchTerminate = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, graceSeconds: number): { state: nkruntime.MatchState } | null => {
  logger.debug('matchTerminate');
  return {
    state
  };
}

const matchSignal = (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: nkruntime.MatchState, data: string): { state: nkruntime.MatchState, data?: string } | null => {
  logger.debug('matchSignal');
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