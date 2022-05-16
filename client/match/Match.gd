extends BaseScreen

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

onready var pitch_items = $YSort
onready var ball = pitch_items.get_node("Ball")

onready var camera_drone = $CameraDrone

onready var player_positions = $Pitch/PlayerPositions

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

var player_friction := 500

var selected_player = {
	"Home": null,
	"Away": null,
}

# network props
var is_online := false

# teams that the client app is in control of
var client_app_user_teams := []

# TODO user controlled teams
var user_teams := ["Home"]

var last_state_update_received

var team_in_possession

func _ready():

	# random top team
	top_team = "Home" # rand_home_or_away() # "Away"

	# coin toss to start 
	initial_team_to_start = "Home" # TODO get_random_home_or_away()
	team_to_start = initial_team_to_start

	_set_player_textures()
	
	# TODO testing - presence of match_data will tells is it's not scene only
	var match_data = get_match_data()
	is_online = !!match_data and "user_id" in match_data.home_team

	client_app_user_teams = _get_client_app_user_teams()
	
	# set player properties on load 
	for player_node in get_players():
		player_node.player_friction = player_friction

		# used for run states whether to use input or server state updates
		player_node.is_client_app_user_team = client_app_user_teams.has(player_node.get_home_or_away())
		
		player_node.connect("send_direction_update", self, "_on_Player_send_direction_update")
		player_node.connect("send_state_update", self, "_on_Player_send_state_update")
		player_node.connect("is_idle", self, "_on_Player_is_idle")

	# # TODO this is just to intialise for testing, later set as closest player to ball
	# if client_app_user_teams.has("Home"):
	# 	set_selected_player(home_player_2)
	# elif client_app_user_teams.has("Away"):
	# 	set_selected_player(away_player_2)

	ServerConnection.connect("state_updated", self, "_on_ServerConnection_state_updated")

func _physics_process(delta):
	current_frame += 1

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

## Will return whether this client user is home or away 
## @return {String|null} Home|Away, or null if watching ai vs ai 
func _get_client_app_user_teams():
	
	# passed from screen_settings during load_screen
	var match_data = get_match_data()

	print("### _get_client_app_user_teams: ", is_online)
	
	# match data may not be set when running scene alone
	if is_online: 
	
		var user_id = ServerConnection.get_user_id()

		print("...user_id: ", user_id)
		print("...match_data.home_team.user_id: ", match_data.home_team.user_id)
		print("...match_data.away_team.user_id: ", match_data.away_team.user_id)
		
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
	for item in pitch_items.get_children():
		if item.is_in_group("players") and (home_or_away == null or item.get_home_or_away() == home_or_away):
			players.append(item)

	return players

func get_shooting_direction(player):
	if top_team == player.get_home_or_away():
		return Vector2.DOWN
	else:
		return Vector2.UP

func get_match_data():
	return _get_menu_setting("match_data")

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
			# if something == ball and player == self.player_in_possession:
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










# state for humans is updated when they are not owned by this client e.g. opp team 
# state for ball is updated when the opp team is in possession, as they are in control of the ball
# state for linesmen/ ref is control by the home team(?)
# how do match states work? e.g. fouls; home team is host(?)
func _on_ServerConnection_state_updated(state_update):

	# don't process if older than the previous received state
	if last_state_update_received and last_state_update_received.tick >= state_update.tick:
		print("recieved old state", state_update)
		return

	var humans = state_update.humans
	var ball = state_update.ball
	
	# update players, ref, linesmen
	for name in humans.keys():
		var human_state = humans[name]
		var human_node = pitch_items.get_node(name)

		var is_player = human_node.is_in_group("players")
		
		# determine whether this is control by the user, or the server (opp team)
		# players will be controlled by their user, but other items will be controlled 
		# by the home user's client app
		if is_player and !human_node.is_client_app_user_team:
			human_node.update_state_from_server(human_state)

	# store processed update for verification when the next one comes in
	last_state_update_received = state_update

## send new direction update to other clients
func _on_Player_send_direction_update(player_node, new_direction):
	ServerConnection.send_direction_update(player_node.name, new_direction)

## send new direction update to other clients
func _on_Player_send_state_update(player_node, position, current_animation):
	ServerConnection.send_state_update(player_node.name, position, current_animation)

func _on_Player_is_idle(player):
	
	var direction_to_ball = player.position.direction_to(ball.position)
	player.set_direction(direction_to_ball)

	# # if ball is the target, and pip is null, then set pip as this player 
	# # sometimes pip doesn't assign when the player stops short(?)
	# if run_target_is_ball and !owner.is_moving() and ball.player_in_possession == null:
	# 	var is_close_to_ball = owner.position.distance_to(ball.position) < 5
	# 	if is_close_to_ball:
	# 		ball.set_player_in_possession(owner)
