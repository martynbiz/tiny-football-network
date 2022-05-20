extends BaseScreen

onready var state_machine = $StateMachine

onready var pitch = $Pitch 
onready var pitch_sub_bench_position = pitch.get_node("SubBench").position
onready var pitch_by_kick_top_right_position = pitch.get_node("ByKickTopRight").position
onready var pitch_by_kick_top_left_position = pitch.get_node("ByKickTopLeft").position
onready var pitch_by_kick_bottom_right_position = pitch.get_node("ByKickBottomRight").position
onready var pitch_by_kick_bottom_left_position = pitch.get_node("ByKickBottomLeft").position
onready var pitch_top_right_position = pitch.get_node("TopRight").position
onready var pitch_top_left_position = pitch.get_node("TopLeft").position
onready var pitch_top_goal_center_position = pitch.get_node("TopGoalCenter").position
onready var pitch_bottom_goal_center_position = pitch.get_node("BottomGoalCenter").position
onready var pitch_top_penalty_spot_position = pitch.get_node("TopPenaltySpot").position
onready var pitch_center_position = pitch.get_node("Center").position
onready var pitch_bottom_penalty_spot_position = pitch.get_node("BottomPenaltySpot").position
onready var pitch_bottom_right_position = pitch.get_node("BottomRight").position
onready var pitch_bottom_left_position = pitch.get_node("BottomLeft").position

onready var pitch_ysort = $YSort
onready var ball = pitch_ysort.get_node("Ball")

onready var camera_drone = $CameraDrone

onready var player_positions = $Pitch/PlayerPositions

# this is used when we need to wait on both clients to give their ready e.g. start match
var is_clients_ready = false
# var clients_ready = [false, false]

# team config (tactics etc)
var home_formation = "442"
var home_play_style = "NormalPlay"
var away_formation = "442"
var away_play_style = "NormalPlay"

# compared during init to see if any color clashes 
var home_team_shirt = "Home"
var away_team_shirt = "Home" # the home shirt of the away team

var top_team
var team_to_start
var initial_team_to_start

# we'll use this for syncing state updates
var current_frame := 0

var current_interval = Constants.Intervals.FIRST_HALF
var start_interval = current_interval

# can be adjusted when weather/pitch conditions change 
var player_friction = 500
var ball_friction = 90

var selected_player = {
	"Home": null,
	"Away": null,
}

# network props
var is_online := false

var send_player_updates = false

# teams that the client app is in control of
var client_app_user_teams := []

# TODO user controlled teams
var user_teams := ["Home"] # TODO []

# var last_state_update_received

var team_in_possession

var user_controllers = [Controllers.ControllerTypes.KEYS, null] # TODO [null, null]

func _ready():

	# set controllers 
	Controllers.set_user_controllers(user_controllers)
	
	# set online flag so we know whether we need to send state updates 
	# do this early as it is relied upon by change_state to send updates
	is_online = !!_get_screen_setting("is_online")

	# random top team
	top_team = "Home" # rand_home_or_away() # "Away"

	# coin toss to start 
	initial_team_to_start = "Home" # TODO get_random_home_or_away()
	team_to_start = initial_team_to_start

	# this method will send an update to the server too
	change_state("KickOff", {
		"team_to_start": team_to_start,
	})

	_set_player_textures()
	
	# # TODO testing - presence of match_data will tells is it's not scene only
	# var match_data = get_match_data()

	client_app_user_teams = _get_client_app_user_teams()

	# will change dependant on weather and pitch etc
	ball.ball_friction = ball_friction

	ball.connect("set_player_in_possession", self, "_on_Ball_set_player_in_possession")
	ball.connect("unset_player_in_possession", self, "_on_Ball_unset_player_in_possession")

	print("client_app_user_teams: ", client_app_user_teams)
	
	# set player properties on load 
	for player in get_players():
		player.player_friction = player_friction

		# used for run states whether to use input or server state updates
		player.is_computer = !user_teams.has(player.get_home_or_away())

		# onload hide players and set collisions to disabled
		player.visible = false
		player.set_collision_shape_disabled(true, true)

		# set is same team as user 
		player.is_same_team_as_user = user_teams.has(player.get_home_or_away()) 
		
		player.connect("send_direction_update", self, "_on_Player_send_direction_update")
		player.connect("send_player_state_update", self, "_on_Player_send_player_state_update")
		player.connect("is_idle", self, "_on_Player_is_idle")
		player.connect("kick_ball", self, "_on_Player_kick_ball")
		player.connect("ball_collection_area_body_entered", self, "_on_Player_ball_collection_area_body_entered")
		# player.connect("set_player_in_possession", self, "_on_Player_set_player_in_possession")

	# # TODO this is just to intialise for testing, later set as closest player to ball
	# if client_app_user_teams.has("Home"):
	# 	set_selected_player(home_player_2)
	# elif client_app_user_teams.has("Away"):
	# 	set_selected_player(away_player_2)

	# set_clients_ready()
	is_clients_ready = !is_online

	ServerConnection.connect("player_state_updated", self, "_on_ServerConnection_player_state_updated")
	ServerConnection.connect("match_state_updated", self, "_on_ServerConnection_match_state_updated")

func _physics_process(delta):
	current_frame += 1

	send_player_updates = is_state("NormalPlay") and is_online

	# # test whether menu button is pressed for either home or away 
	# if Controllers.is_menu_button_pressed(true):
	# 	menu_popup.is_home_team = true
	# 	show_menu()

	# elif Controllers.is_menu_button_pressed(false):
	# 	menu_popup.is_home_team = false
	# 	show_menu()

	# handle fire button 
	var player_in_possession = ball.player_in_possession
	if player_in_possession and player_in_possession.is_client_app_controlled:

		# # we currently only need to check for double tap if the ball is in shooting range
		# # as we will use this to lob the keeper
		# var detect_double_tap = ball.is_in_shooting_zone()

		var fire_press_power = Controllers.get_fire_press_power(player_in_possession.is_home_team, false, delta)
		
		if fire_press_power:

			# calulate distance and height
			player_in_possession.kick_ball(fire_press_power)

			fire_press_power = 0


func is_state(state_name):
	return state_machine.state and state_machine.state.name == state_name

# func set_clients_ready():
	
# 	# both to false initially
# 	is_clients_ready = false
# 	# clients_ready = [false, false]

# 	# if an online match, then set this client to true and broadcast to the opp
# 	var client_app_user_teams = _get_client_app_user_teams()
	
# 	if client_app_user_teams.has("Home"):
# 		clients_ready[0] = true

# 	if client_app_user_teams.has("Away"):
# 		clients_ready[1] = true

## Called once during changing of intervals
## @param {enum Constants.Intervals} 
func swap_halves(current_interval):
	
	# change top team 
	if top_team == "Home":
		top_team = "Away"
	else:
		top_team = "Home"
	
	# change team to kick off
	match current_interval:
		Constants.Intervals.FIRST_HALF, Constants.Intervals.ET_FIRST_HALF:
			if initial_team_to_start == "Home":
				team_to_start = "Away"
			else:
				team_to_start = "Home"

		Constants.Intervals.SECOND_HALF, Constants.Intervals.ET_SECOND_HALF:
			team_to_start = initial_team_to_start

func get_goal_center_position(home_or_away):
	if top_team == home_or_away:
		return pitch_top_goal_center_position
	else:
		return pitch_bottom_goal_center_position

func set_selected_player(player):
	var home_or_away = player.get_home_or_away()

	# deselect current selected_player if any
	unset_selected_player(home_or_away)
	
	# set selected_player
	selected_player[home_or_away] = player
	player.is_selected = true
	# selected_player[home_or_away].set_cursor(Constants.CursorTypes.NORMAL_PLAY)
	player.match_fitness_progress_bar.visible = (Constants.ALLOW_MATCH_FITNESS and Options.get_option("show_player_fitness"))

func unset_selected_player(home_or_away = null):
	
	# deselect home, away or both selected players vars
	var home_or_away_array = Utils.get_home_or_away_array(home_or_away)
	for home_or_away in home_or_away_array:
		if selected_player[home_or_away] != null:
			selected_player[home_or_away] = null

	# not sure why, but sometimes cursor still shows. This just ensures that 
	# no player of this side has a cursor
	for player in get_players(home_or_away):
		player.set_cursor(null)
		player.is_selected = false
		player.match_fitness_progress_bar.visible = false

## Will return whether this client user is home or away 
## @return {String|null} Home|Away, or null if watching ai vs ai 
func _get_client_app_user_teams():
	
	# passed from screen_settings during load_screen
	var match_data = get_match_data()
	
	# match data may not be set when running scene alone
	if is_online: 
	
		var user_id = ServerConnection.get_user_id()
		
		if (match_data.home_team.user_id == user_id):
			return ["Home"]
		elif (match_data.away_team.user_id == user_id):
			return ["Away"]

	# local matches
	else:
		return ["Home", "Away"]

## set shirt color, pattern, shorts etc 
func _set_player_textures():

	# TODO e.g. away_team_data = match_data.away_team_data
	var home_team_data = {
		"home_shirt_color": "Blue",
		"home_shirt_pattern": "None",
		"home_shirt_pattern_color": "White",
		"home_shorts_color": "White",
		"away_shirt_color": "White",
		"away_shirt_pattern": "None",
		"away_shirt_pattern_color": "White",
		"away_shorts_color": "White",
		"formation": "442",
	}
	var away_team_data = {
		"home_shirt_color": "Red",
		"home_shirt_pattern": "None",
		"home_shirt_pattern_color": "White",
		"home_shorts_color": "White",
		"away_shirt_color": "White",
		"away_shirt_pattern": "None",
		"away_shirt_pattern_color": "White",
		"away_shorts_color": "White",
		"formation": "442",
	}

	# set formations from teams table
	if home_team_data.formation:
		home_formation = home_team_data.formation
	if away_team_data.formation:
		away_formation = away_team_data.formation
	
	# decide shirt colors
	var shirt_color_combos = [
		Textures.create_shirt_combo(home_team_data, away_team_data, ["Home", "Home"]),
		Textures.create_shirt_combo(home_team_data, away_team_data, ["Home", "Away"]),
		Textures.create_shirt_combo(home_team_data, away_team_data, ["Away", "Home"]),
		Textures.create_shirt_combo(home_team_data, away_team_data, ["Away", "Away"])
	]

	var team_shirts_array = Textures.get_best_combo_team_shirts_array(shirt_color_combos)
	home_team_shirt = team_shirts_array[0]
	away_team_shirt = team_shirts_array[1]

	var home_shirt_color
	var home_shirt_pattern
	var home_shirt_pattern_color
	var home_shorts_color

	var away_shirt_color
	var away_shirt_pattern
	var away_shirt_pattern_color
	var away_shorts_color

	if home_team_shirt == "Home":
		home_shirt_color = home_team_data.home_shirt_color
		home_shirt_pattern_color = home_team_data.home_shirt_pattern_color
		home_shirt_pattern = home_team_data.home_shirt_pattern
		home_shorts_color = home_team_data.home_shorts_color
	elif home_team_shirt == "Away":
		home_shirt_color = home_team_data.away_shirt_color
		home_shirt_pattern_color = home_team_data.away_shirt_pattern_color
		home_shirt_pattern = home_team_data.away_shirt_pattern
		home_shorts_color = home_team_data.away_shorts_color
	
	if away_team_shirt == "Home":
		away_shirt_color = away_team_data.home_shirt_color
		away_shirt_pattern_color = away_team_data.home_shirt_pattern_color
		away_shirt_pattern = away_team_data.home_shirt_pattern
		away_shorts_color = away_team_data.home_shorts_color
	elif away_team_shirt == "Away":
		away_shirt_color = away_team_data.away_shirt_color
		away_shirt_pattern_color = away_team_data.away_shirt_pattern_color
		away_shirt_pattern = away_team_data.away_shirt_pattern
		away_shorts_color = away_team_data.away_shorts_color

	var home_shirt_color_texture = Textures.get_shirt_texture(home_shirt_color)
	var home_shirt_pattern_texture = Textures.get_shirt_texture(home_shirt_pattern_color, home_shirt_pattern)
	var home_shorts_color_texture = Textures.get_shorts_texture(home_shorts_color)

	var away_shirt_color_texture = Textures.get_shirt_texture(away_shirt_color)
	var away_shirt_pattern_texture = Textures.get_shirt_texture(away_shirt_pattern_color, away_shirt_pattern)
	var away_shorts_color_texture = Textures.get_shorts_texture(away_shorts_color)

	# need to set this here as player scripts are run before match 
	# don't want to have the above code running for every player 
	for player in get_players():
		
		var shirt_color_texture
		var shirt_pattern_texture     
		var shorts_color_texture
		
		# all players wear the same shorts - goalie and outfield 
		if player.is_home_team:
			shorts_color_texture = home_shorts_color_texture
		else:
			shorts_color_texture = away_shorts_color_texture
		
		# goalie gets pink for now 
		if player.is_goalie():
			shirt_color_texture = Textures.get_shirt_texture("Pink")

		# home outfield players 
		elif player.is_home_team:
			shirt_color_texture = home_shirt_color_texture
			shirt_pattern_texture = home_shirt_pattern_texture

		# away outfield players 
		else:
			shirt_color_texture = away_shirt_color_texture
			shirt_pattern_texture = away_shirt_pattern_texture
		
		if shirt_color_texture:
			player.get_node("ShirtColor").set_texture(shirt_color_texture)
		if shirt_pattern_texture:
			player.get_node("ShirtPattern").set_texture(shirt_pattern_texture)
		if shorts_color_texture:
			player.get_node("ShortsColor").set_texture(shorts_color_texture)

	# # if either team is black, try another colour for ref etc
	# var officials_shirt_color = "Black"
	# var officials_shorts_color = "Black"

	# var all_colors = [home_shirt_color, away_shirt_color]

	# if home_shirt_pattern != "None":
	# 	all_colors.append(home_shirt_pattern_color)

	# if away_shirt_pattern != "None":
	# 	all_colors.append(away_shirt_pattern_color)

	# # try yellow and pink etc
	# if all_colors.has("Black") and !all_colors.has("Pink"):
	# 	officials_shirt_color = "Pink"
	# 	officials_shorts_color = "Black"
	
	# elif all_colors.has("Black") and !all_colors.has("Yellow"):
	# 	officials_shirt_color = "Yellow"
	# 	officials_shorts_color = "Orange"

	# # 
	# var officials_shirt_color_texture = Textures.get_shirt_texture(officials_shirt_color)
	# var officials_shorts_color_texture = Textures.get_shorts_texture(officials_shorts_color)

	# var hair_skin_colors = [
	# 	"LightSkinBlackHair",
	# 	"LightSkinGingerHair",
	# 	"LightSkinBrownHair",
	# 	"DarkSkinBlackHair",
	# 	"LightSkinNoHair",
	# 	# "LightSkinBlondeHair"
	# ]

	# for official in [ref, linesman_top, linesman_bottom]:
	# 	official.get_node("ShirtColor").set_texture(officials_shirt_color_texture)
	# 	official.get_node("ShortsColor").set_texture(officials_shorts_color_texture)

	# 	# update skin color, etc; skill level 
	# 	var hair_skin_color = hair_skin_colors[randi() % hair_skin_colors.size()]
	# 	var skin_color_texture = Textures.get_hair_skin_texture(hair_skin_color)
	# 	if skin_color_texture:
	# 		official.get_node("Body").set_texture(skin_color_texture)

# TODO cache
func get_players(home_or_away = null):
	var players = []
	for item in pitch_ysort.get_children():
		if item.is_in_group("players") and (home_or_away == null or item.get_home_or_away() == home_or_away):
			players.append(item)

	return players

func get_shooting_direction(player):
	if top_team == player.get_home_or_away():
		return Vector2.DOWN
	else:
		return Vector2.UP

func get_match_data():
	return _get_screen_setting("match_data")

func get_randon_home_or_away():
	var rnd = randi() % 2
	var home_and_away =  ["Home", "Away"]
	return home_and_away[rnd]

func set_camera_drone_target(target):
	camera_drone.set_target(target)

func load_player_positions(home_or_away, formation, play_style):
	player_positions.load_player_positions(home_or_away, formation, play_style, top_team)

func get_position_on_pitch(node):
	return node.position - pitch_top_left_position



## This is a function to determine who is the closest player(s) to run towards the ball
## Will exclude player in possession too as we don't factor them in
## @param {integer} num How many players to fetch 
## @param {string|null} home_or_away "Home" or "Away" or null
## @param {bool} include_goalie
## @return {array<Player>}
func _get_closest_players_to(something, num_players_required, home_or_away = null, include_goalie = true):
	
	# we'll build up this array of players who are closest to "something"
	var closest_players = []
	
	# we'll deduct from these as we go
	var players_pool = get_players(home_or_away)

	# we only need to loop a maximum of the number of players we're looking for, break when num reached
	for n in num_players_required:

		# loop through each players remaining and find the next closest
		var closest_player = null
		var closest_player_distance_to_something = 999999 # very high number to start

		for player in players_pool:

			# don't check players already in closest_players
			if closest_players.has(player):	
				continue
			
			# # this is important for making a pass, that it doesn't chose the player_in_possession
			# if something == ball and player == ball.player_in_possession:
			# 	players_pool.erase(player)
			# 	continue
			
			if !include_goalie and player.is_goalie():
				continue

			if !player.is_playable():
				continue
			
			# determine whether we need to replace the current closest_player with this player
			if player.position.distance_to(something.position) < closest_player_distance_to_something:
				closest_player = player
				closest_player_distance_to_something = closest_player.position.distance_to(something.position)
		
		if closest_player:
			closest_players.append(closest_player)

		if closest_players.size() >= num_players_required:
			break

	return closest_players

func get_closest_player_to_ball(home_or_away = null):
	var closest_players = _get_closest_players_to(ball, 1, home_or_away)
	if not closest_players.empty():
		return closest_players[0]

func get_closest_outfield_player_to_ball(home_or_away = null):
	var closest_players = _get_closest_players_to(ball, 1, home_or_away, false)
	if not closest_players.empty():
		return closest_players[0]

func change_state(new_state, state_settings = {}, send_update = true):

	# change state machine 
	state_machine.change_to(new_state)

	for prop in state_settings.keys():
		state_machine.state[prop] = state_settings[prop]
	
	# send update to server
	if is_online and send_update:
		ServerConnection.send_match_state_update(new_state, state_settings)

	# client app control flag needs updated when state changes
	for player in get_players():
		player.is_client_app_controlled = !is_state("NormalPlay") or client_app_user_teams.has(player.get_home_or_away())





## when we reach this handler either 1) we changed the state, in which case we just 
## need to get this notification that 
func _on_ServerConnection_match_state_updated(state_update):
	
	var new_state = state_update.new_state
	var state_settings = state_update.state_settings

	# if the server alerts us of a change in state, we should change the state
	# we don't need to alert the server of our state change as 
	if !is_state(new_state):
		change_state(new_state, state_settings)
	
	# we can add this condition so that when the original send update (from this client) is handled 
	# then if it's the same state we just set then we can assume(?) the client has got their broadcast.
	# if the we want to be double-y sure that the remote client has changed we should remove this 
	# and depend on state_update.is_clients_ready (remember to remove the false flag from change_state above)
	else:
		is_clients_ready = true 
	
	is_clients_ready = state_update.is_clients_ready

## state for humans is updated when they are not owned by this client e.g. opp team 
## state for ball is updated when the opp team is in possession, as they are in control of the ball
## state for linesmen/ ref is control by the home team(?)
## how do match states work? e.g. fouls; home team is host(?)
func _on_ServerConnection_player_state_updated(state_update):

	var humans = state_update.humans
	# var ball = state_update.ball
	
	# update players, ref, linesmen
	for name in humans.keys():
		var human_state = humans[name]
		var human_node = pitch_ysort.get_node(name)

		var is_player = human_node.is_in_group("players")
		
		# determine whether this is control by the user, or the server (opp team)
		# players will be controlled by their user, but other items will be controlled 
		# by the home user's client app
		if is_player and !human_node.is_client_app_controlled:
			human_node.update_state_from_server(human_state)

	# # store processed update for verification when the next one comes in
	# last_state_update_received = state_update

## send new direction update to other clients
func _on_Player_send_direction_update(player_node, new_direction):
	if send_player_updates:
		ServerConnection.send_direction_update(player_node.name, new_direction)

## send new direction update to other clients
func _on_Player_send_player_state_update(player_node, position, current_animation):
	if send_player_updates:
		ServerConnection.send_player_state_update(player_node.name, position, current_animation)

func _on_Player_kick_ball(player, fire_press_power, kick_direction):

	ball.kick(fire_press_power, kick_direction)

	# we don't use match.state_chaneg_to here because we want the kick to be un-interupted
	# normalplay doesn't have a clients ready check stage 
	# we state_chaneg_to(normalplayprestate) from other states as that state will check clients ready
	if !is_state("NormalPlay"):
		change_state("NormalPlay")

	# if is_penalties():
	# 	state_machine.state.on_penalty_kick_taken()
	# else:
	# 	state_machine.change_to("NormalPlay")

	# # update stats
	# if is_shot:

	# 	incrememnt_shot_attempts(player_in_possession.get_home_or_away())
		
	# 	# if player_in_possession.is_home_team:
	# 	# 	match_stats.shot_attempts[0] += 1
	# 	# else:
	# 	# 	match_stats.shot_attempts[1] += 1

	# 	# set skill level delays when the ball is kicked e.g. goalie reaction delay
	# 	for player in get_players():
	# 		if player.is_goalie():
	# 			player.goalie_dive_reaction_delay_counter = player.get_goalie_dive_reaction_delay()

	# # don't set this if offsides is off, as it would be a waster of cpu 
	# if Options.get_option("offsides_enabled"):
	# 	set_player_offsides()

	# Sounds.play_sound(Constants.Sounds.KICK_BALL)

	# # return players in possession to Run from ThrowIn/GoalieKick etc 
	# for player in get_players():
	# 	if !player.is_overhead_kicking():
	# 		player.set_state_to_run()

func _on_Player_is_idle(player):
	
	var direction_to_ball = player.position.direction_to(ball.position)
	player.set_direction(direction_to_ball)

	var run_target_is_object = player.run_target and typeof(player.run_target) != TYPE_VECTOR2
	var run_target_is_ball = run_target_is_object and player.run_target.name == "Ball"
	# var run_target_is_player_position = run_target_is_object and player.run_target == player.player_position

	# if ball is the target, and pip is null, then set pip as this player 
	# sometimes pip doesn't assign when the player stops short(?)
	if run_target_is_ball and !player.is_moving() and ball.player_in_possession == null:
		var is_close_to_ball = player.position.distance_to(ball.position) < 5
		if is_close_to_ball:
			ball.set_player_in_possession(player)

# func is_clients_ready:
# 	return (clients_ready[0] and clients_ready[1])

func _on_Player_ball_collection_area_body_entered(player, body):
	
	if body == ball:
		
		var player_can_collect_ball = true
	
		# ball is not collectable when we are staging match states e.g. fouls
		if !ball.is_collectable:
			player_can_collect_ball = false 

		# players cannot control a ball that is moving too fast
		if ball.is_too_fast_to_catch():
			player_can_collect_ball = false 
		
		# if player is goalie and is diving, we will bounce the ball 
		if player.is_goalie():
			if player.is_state("GoalieDive") or ball.is_too_fast_to_catch():
				player_can_collect_ball = false 

		if player_can_collect_ball:
			
			# if nobody is on the ball, then change the player in possession to this player 
			# otherwise, if ai, tackle the player
			if ball.player_in_possession == null:
				ball.set_player_in_possession(player)
			
			# # tackle?
			# else:
				
			# 	var is_same_team_player = (player.is_home_team == player_in_possession.is_home_team)

			# 	# is_same_team_as_user will determine that it's ai 
			# 	if is_state("NormalPlay") and !is_same_team_player and !player.is_same_team_as_user():
			# 		state_machine.change_to("Tackle")

	# handle another player entering area
	elif body.is_in_group("players"):

		pass
		
	# 	var ball = match_node.get_ball()
		
	# 	if body.is_tackling():
	# 		var tackling_player = body 

	# 		# checks to determine a clean tackle..

	# 		var is_clean_tackle = true

	# 		# check if player took ball
	# 		if is_clean_tackle and ball.player_in_possession != tackling_player:
	# 			is_clean_tackle = false

	# 		var is_same_team = (self.is_home_team == tackling_player.is_home_team)

	# 		# default. if not a clean tackle, increase the damage limit
	# 		var tackle_damage = randi() % 5

	# 		# did the tackling player take the ball? No?!
	# 		if Constants.ALLOW_FOULS and !is_clean_tackle and !is_same_team:
				
	# 			# increase the damage limit when not a clean tackle
	# 			tackle_damage = randi() % 30 # 20 + (randi() % 30)

	# 			# change to match Foul state 
	# 			if match_node.is_state("NormalPlay"):
	# 				match_node.state_machine.change_to("Foul")

	# 				var match_state = match_node.get_current_state()
	# 				match_state.ball_position = this_player.position
	# 				match_state.fouled_player = this_player
	# 				match_state.fouling_player = tackling_player

	# 		# calculate their chances of injury based on their match_fitness

	# 		# all tackles damage, hard tackle damage more 
	# 		var damage = round(tackle_damage / Options.get_option("match_length_real_minutes"))
	# 		this_player.update_match_fitness(-damage)

	# 		# Check if the side has remaining subs, if not don't injure the player, let them limp about 
	# 		if match_node.get_remaining_subs_allowed(this_player.get_home_or_away()) > 0:

	# 			var match_fitness = int(this_player.get_match_fitness())

	# 			# determine injury if not same team player and random threshold vs match fitness
	# 			var is_injury_tackle = Constants.ALLOW_INJURIES and !is_same_team and (randi() % match_fitness) < Constants.MATCH_FITNESS_INJURY_THRESHOLD

	# 			# determine if the tackle is an injury or not, only if the team can allow more subs though 
	# 			# otherwise the player will just need to remain on the park
	# 			if is_injury_tackle and !this_player.is_injured():
	# 				var injured_matches = 1 + randi() % 4 # might escape injury with a zero mind you
	# 				this_player.data.injured_matches = injured_matches

	# 				# ensure match fitness is low as they need to limp off
	# 				var i = 0 # dunno, why but i think this part is crashing, this is to prevent an inf loop
	# 				while this_player.get_match_fitness() > 40 and i < 5:
	# 					this_player.update_match_fitness(-10)
	# 					i += 1
			
	# 		# this player to fall down. this change state is also present in ball.gd, do we need both?
	# 		# however, removing the other broke goaliekickout
	# 		this_player.state_machine.change_to("Fall")
	# 		will_protest = true

	# 		# crunch!
	# 		Sounds.play_sound(Constants.Sounds.TACKLE)

func _on_Ball_set_player_in_possession(player):

	# # set player name in hud 
	# update_hud_player_name(player)

	# # required here for first_touch 
	# set_ball_position_properties()

	# pip might be null
	if player:

		# also set this player as the selected player so we can move 
		if ball.is_collectable:
			if player.is_same_team_as_user:
				set_selected_player(player)

		# flag to tell us if state has changed to e.g. overheadkick, throw in etc
		var is_player_state_set = false

		# depending on match state, we'll set the player to the 
		match state_machine.state.name:
			"NormalPlay":

				# # remove flag 
				# ball.is_penalty = false

				if false: # TODO is_penalty() or is_penalties():
					
					# set_player_state_other_players_to_run(player, "SetPiece")
					pass

				else:

					# # default, may be overwritten 
					# player.set_state_to_run()
					player.state_machine.change_to("Run")

					# # set ai first_touch always when crossing(?)
					# if Constants.ALLOW_FIRST_TOUCH:
					# 	if (ball.is_crossing() and player.is_computer()):
					# 		ball.set_first_touch(player.get_home_or_away(), 0.3, player.get_shooting_direction())
					
					# # check if it's first touch as we might do an overhead kick 
					# if Constants.ALLOW_FIRST_TOUCH:
					# 	var first_touch = ball.get_first_touch(player.get_home_or_away())
					# 	if first_touch:
							
					# 		# get the first touch data
					# 		var first_touch_power = first_touch[0]
					# 		var first_touch_direction = first_touch[1]
					# 		ball.reset_first_touch()

					# 		ball.is_first_touch = true
							
					# 		# if this is a cross and the same team member as the one making the cross, 
					# 		# then assume that it's an attempt at goal. And do an overhead kick
					# 		if ball.is_crossing() and ball.is_in_shooting_zone():
					# 			first_touch_direction = player.get_goal_direction()
					# 			first_touch_power = 0.35
								
					# 			player.set_direction(first_touch_direction)
					# 			ball.kick(first_touch_power, first_touch_direction) # will unset pip

					# 			if Constants.ALLOW_FIRST_TOUCH_OVERHEAD_KICKS:
					# 				player.state_machine.change_to("OverheadKick")
					# 				ball.is_overhead_kick = true
					
					# even if first touch, if they can instead pick it up then we'dd do that.
					if player.is_goalie():
						
						var last_player_in_possession = ball.get_last_player_in_possession()
						var is_last_player_opposition_player = (last_player_in_possession and last_player_in_possession.is_home_team != player.is_home_team)
						
						# sometimes the goalie saves, then should be able to still pick up the ball
						var is_last_player_in_possession_same_goalie = (player == last_player_in_possession)
						
						# # if the goalie can pick it up then they should every time
						# var goalie_can_pick_up = (is_last_player_in_possession_same_goalie or is_last_player_opposition_player) and player.is_ball_in_same_penalty_area()
						# if goalie_can_pick_up:
							
						# 	# match state, players running back to pos etc 
						# 	state_machine.change_to("GoalieKickOut")
						# 	state_machine.state.goalie_to_take = player

						# 	# pick up the ball 
						# 	player.state_machine.change_to("GoalieKickOut")
			
			# e.g. "OutOfPlay", "Foul", "KickOff", "Penalties"
			_:
				
				# if ball.is_throw_in:
				# 	# player.state_machine.change_to("ThrowIn")
				# 	set_player_state_other_players_to_run(player, "ThrowIn")
				# else:
				# 	# player.state_machine.change_to("SetPiece")
				# 	set_player_state_other_players_to_run(player, "SetPiece")
				
				# Each of these animations has ball in it, so hide the real ball until kick
				ball.visible = false

func _on_Ball_unset_player_in_possession():
	pass
	# update_hud_player_name(null)
