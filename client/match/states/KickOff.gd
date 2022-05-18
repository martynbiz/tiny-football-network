extends MatchBaseState

var team_to_start

var player_to_take
var player_to_take_direction

var sub_bench_position
var home_players
var home_players_running_to_position_i = 0

var away_players
var away_players_running_to_position_i = 0

# this is so that we only run from sub bench when match.current_interval changes 
var current_interval = null
var is_next_interval = true
var is_first_interval = true

enum Stages {
	WAITING_FOR_CLIENTS_READY,
	CHECK_FOR_PENDING_SUBS,
	INIT,
	CHECK_FOR_PENDING_SUBS,
	PLAYERS_RUNNING_TO_POSITION,
	SELECT_PLAYER_TO_TAKE,
	PLAYER_TO_TAKE_RUNNING_TO_BALL,
	READY,
	READY_USER_AI
}

func enter():
	stage = Stages.WAITING_FOR_CLIENTS_READY

	home_players_running_to_position_i = 0
	away_players_running_to_position_i = 0

	# Match onready may not have triggered
	sub_bench_position = owner.get_node("Pitch/SubBench").position

	# # kill any effects on the pitch 
	# while !owner.effects_instances.empty():
	# 	var effect_instance = owner.effects_instances.pop_front()
	# 	effect_instance.queue_free()

	# # any state that uses process_pending_subs needs to reset this to false
	# set_state_to_check_pending_subs(true)

func physics_process(delta):

	# # We have a penalties event, so if we start the match and start_interval is penalties 
	# # then we should go immedientely to that state 
	# if owner.start_interval == Constants.Intervals.PENALTIES:
	# 	owner.state_change_to("Penalties")
	
	var ball = owner.ball
	home_players = owner.get_players("Home")
	away_players = owner.get_players("Away")
	
	match stage:
		Stages.WAITING_FOR_CLIENTS_READY:

			if owner.is_clients_ready():
				stage = Stages.INIT

		Stages.INIT:
			
			# just encase subs changed the camera, put i here 
			# TODO might move this when we add subs back in, see old footy repo
			owner.set_camera_drone_target(ball)

			# disable collision shapes so that they don't bump into each other
			set_players_collision_shape_disabled(true, true)

			# next interval ?
			if current_interval != owner.current_interval:
				current_interval = owner.current_interval
				is_next_interval = true
				is_first_interval = (owner.current_interval == Constants.Intervals.FIRST_HALF)

			# reset ball in center of pitch
			ball.position = owner.pitch_center_position
			ball.apply_friction(delta)
			ball.set_disabled(true)
			ball.visible = true
			# owner.unset_player_in_possession()

			# # in the event of a goal scored (or chopped off offside)
			# ball.is_in_top_net_area = false
			# ball.is_in_bottom_net_area = false
			
			# # set ref position 
			# set_ref_run_target_relative_to_ball()

			# init match 
			# owner.set_camera_drone_target(ball)
			owner.unset_selected_player()

			# # set it to "0 mins"
			# owner.update_match_time()

			# load new player positions for kick off
			owner.load_player_positions("Home", owner.away_formation, "KickOff")
			owner.load_player_positions("Away", owner.away_formation, "KickOff")

			# hide all players initially, and cheer players running out
			if is_next_interval:
				
				pass

				# # first kick off?
				# if is_first_interval and owner.start_interval != Constants.Intervals.PENALTIES:
				# 	owner.list_players_popup.load_player_names()
				# 	owner.list_players_popup.popup()

				# # cheer players running out 
				# Sounds.play_sound(Constants.Sounds.CROWD_CHEER)

			# otherwise just run back to position 
			else:
				for players in [home_players, away_players]:
					for player in players:
						# player.set_state_to_run()
						player.state_machine.change_to("Run")
						player.run_to(player.player_position)

				# give enough time to run back 
				start_timer(3)

			stage = Stages.CHECK_FOR_PENDING_SUBS

		Stages.CHECK_FOR_PENDING_SUBS:

			# # this'll change state to subs if pending subs exist, otherwise it'll move to
			# # the next stage given as an argument 
			# process_pending_subs(Stages.PLAYERS_RUNNING_TO_POSITION)
			
			# # just encase subs changed the camera, put i here 
			# owner.set_camera_drone_target(ball)
			
			# skip - not needed when above code in uncommented
			stage = Stages.PLAYERS_RUNNING_TO_POSITION

		Stages.PLAYERS_RUNNING_TO_POSITION:

			# don't stagger runs if same interval e.g. after goal 
			if !is_next_interval:
				if is_players_in_position() or timer_is_stopped():
					stage = Stages.SELECT_PLAYER_TO_TAKE

			# if new interval, we'll stagger the runs from the sub bench to appear as 
			# thought the players are running from the tunnel 
			else:

				# stop when there are no more players
				if is_last_player_running_to_position():

					# move the next stage when players in pos or timer has stopped
					if is_players_in_position() or timer_is_stopped():
						stage = Stages.SELECT_PLAYER_TO_TAKE
						
						# # this may already be hidden 
						# hide_subs_hud()

				# make the players run out one at a time
				elif timer_is_stopped():
					
					# run from sub bench in twos (home player and away player)
					if home_players_running_to_position_i < home_players.size():
						var home_player = home_players[home_players_running_to_position_i]
						player_run_position_from_sub_bench(home_player)
					if away_players_running_to_position_i < away_players.size():
						var away_player = away_players[away_players_running_to_position_i]
						player_run_position_from_sub_bench(away_player)

					# if !is_first_interval:
					# 	get_tree().paused = true

					# prep for next player 
					home_players_running_to_position_i += 1
					away_players_running_to_position_i += 1
					start_timer(0.2)

					# if at limit, set a timer here, we won't come back into this branch 
					if is_last_player_running_to_position():
						start_timer(3)

			update_timer(delta)

		Stages.SELECT_PLAYER_TO_TAKE:

			# disable collision shapes so that they don't bump into each other
			set_players_collision_shape_disabled(false)

			# # for ai vs ai to hide list_players_popup
			# if owner.user_teams.empty():
			# 	if timer_is_stopped():
			# 		owner.list_players_popup.hide()
			# 		pass
			# 	else:
			# 		update_timer(delta)

			# # keep players waiting while player list is up
			# if owner.list_players_popup.visible:
			# 	return

			# # if it's the first half this'll be hidden 
			# owner.hud_score_container.visible = true
			
			ball.set_disabled(false)

			# player_to_take = ball.get_closest_player_to_ball(delta, team_to_start)
			player_to_take = owner.get_closest_outfield_player_to_ball(team_to_start)
			player_to_take.run_to(ball, 3)

			# this is just a time out encase pip isn't assigned
			start_timer(5)

			stage = Stages.PLAYER_TO_TAKE_RUNNING_TO_BALL

		Stages.PLAYER_TO_TAKE_RUNNING_TO_BALL:

			var player_to_take_direction = -owner.get_shooting_direction(player_to_take)

			if ball.player_in_possession == player_to_take:
				player_to_take.run_to(null)
				player_to_take.set_direction(player_to_take_direction)
				start_timer(1)
				# Sounds.play_sound(Constants.Sounds.REF_WHISTLE)

				# if Constants.ALLOW_REPLAYS and Options.get_option("replays_enabled"):
				# 	owner.replay_manager.start_recording(true)

				stage = Stages.READY
				
			# We use timer_is_stopped to give wall players a little time to 
			if timer_is_stopped():
				player_to_take.position = ball.position
				# ball.set_player_in_possession(player_to_take)
				# Sounds.play_sound(Constants.Sounds.REF_WHISTLE)

				# if Constants.ALLOW_REPLAYS and Options.get_option("replays_enabled"):
				# 	owner.replay_manager.start_recording(true)
				
				stage = Stages.READY
				
			update_timer(delta)
		
		Stages.READY:

			is_next_interval = false

			# for online matches we won't force the user to kick, or ai
			if owner.is_online:
				if timer_is_stopped():
					if player_to_take.is_computer:
						var home_or_away = player_to_take.get_home_or_away()
						var closest_player = owner.get_closest_outfield_player_to_ball(home_or_away)
						var direction_to_closest_player = player_to_take.position.direction_to(closest_player.position)
						direction_to_closest_player = Utils.clamp_direction(direction_to_closest_player)

						var fire_press_power = 0.25
						player_to_take.kick_ball(fire_press_power, direction_to_closest_player)

					else:
						start_timer(3)
						stage = Stages.READY_USER_AI
					
			update_timer(delta)

		# this is just so the user doesn't take ages... or the game crashes
		Stages.READY_USER_AI:

			if timer_is_stopped():
				var fire_press_power = 0.25
				player_to_take.kick_ball(fire_press_power, player_to_take.direction)
				
			update_timer(delta)

func is_last_player_running_to_position():
	var is_last_home_player_running_to_position = home_players_running_to_position_i >= home_players.size()
	var is_last_away_player_running_to_position = away_players_running_to_position_i >= away_players.size()
	return is_last_home_player_running_to_position and is_last_away_player_running_to_position

func player_run_position_from_sub_bench(player):
	if player.is_sent_off:
		# player.hide_off_camera()
		pass
	else:
		player.position = sub_bench_position
		player.visible = true
		# player.set_state_to_run()
		player.state_machine.change_to("Run")
		player.run_to(player.player_position)
