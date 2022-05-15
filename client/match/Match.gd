extends BaseScreen

onready var pitch = $Pitch 
onready var pitch_sub_bench = pitch.get_node("SubBench")
onready var pitch_by_kick_top_right = pitch.get_node("ByKickTopRight")
onready var pitch_by_kick_top_left = pitch.get_node("ByKickTopLeft")
onready var pitch_by_kick_bottom_right = pitch.get_node("ByKickBottomRight")
onready var pitch_by_kick_bottom_left = pitch.get_node("ByKickBottomLeft")
onready var pitch_bottom_center = pitch.get_node("BottomCenter")
onready var pitch_top_right = pitch.get_node("TopRight")
onready var pitch_top_left = pitch.get_node("TopLeft")
onready var pitch_top_penalty_area_top_left = pitch.get_node("PenaltyAreaTopLeft")
onready var pitch_top_penalty_area_bottom_right = pitch.get_node("PenaltyAreaBottomRight")
onready var pitch_bottom_penalty_area_top_left = pitch.get_node("PenaltyAreaTopLeft")
onready var pitch_bottom_penalty_area_bottom_right = pitch.get_node("PenaltyAreaBottomRight")
onready var pitch_top_center = pitch.get_node("TopCenter")
onready var pitch_top_penalty_spot = pitch.get_node("TopPenaltySpot")
onready var pitch_center = pitch.get_node("Center")
onready var pitch_bottom_penalty_spot = pitch.get_node("BottomPenaltySpot")
onready var pitch_bottom_right = pitch.get_node("BottomRight")
onready var pitch_bottom_left = pitch.get_node("BottomLeft")

onready var pitch_items = $YSort
onready var home_player_1 = pitch_items.get_node("HomePlayer1")
onready var home_player_2 = pitch_items.get_node("HomePlayer2")
onready var home_player_3 = pitch_items.get_node("HomePlayer3")
onready var away_player_1 = pitch_items.get_node("AwayPlayer1")
onready var away_player_2 = pitch_items.get_node("AwayPlayer2")
onready var away_player_3 = pitch_items.get_node("AwayPlayer3")
onready var ball = pitch_items.get_node("Ball")

onready var camera_drone = $CameraDrone

onready var player_positions = $Pitch/PlayerPositions

# team config (tactics etc)
var home_formation = "442"
var home_play_style = "NormalPlay"
var away_formation = "442"
var away_play_style = "NormalPlay"

var top_team = "Home" # TODO get_randon_home_or_away()

# we'll use this for syncing state updates
var current_frame := 0

var player_friction := 500

var selected_player = {
	"Home": null,
	"Away": null,
}

var is_client_user_home_team := false

var last_state_update_received

func _ready():

	is_client_user_home_team = (_get_client_user_home_or_away() == "Home")
	
	# set player properties on load 
	for player_node in get_players():
		player_node.player_friction = player_friction
		player_node.is_client_user = (is_client_user_home_team == player_node.is_home_team)
		player_node.connect("send_direction_update", self, "_on_Player_send_direction_update")
		player_node.connect("send_state_update", self, "_on_Player_send_state_update")

	# TODO this is just to intialise for testing, later set as closest player to ball
	if _get_client_user_home_or_away() == "Home":
		home_player_1.is_selected = true
	else:
		away_player_1.is_selected = true

	ServerConnection.connect("state_updated", self, "_on_ServerConnection_state_updated")

func _physics_process(delta):
	current_frame += 1

## Will return whether this client user is home or away 
## @return {String|null} Home|Away, or null if watching ai vs ai 
func _get_client_user_home_or_away():
	var match_data = get_match_data()
	var user_id = ServerConnection.get_user_id()
	
	if match_data: 
		if (match_data.home_team.user_id == user_id):
			return "Home"
		elif (match_data.away_team.user_id == user_id):
			return "Away"

# TODO cache
func get_players(home_or_away = null):
	var players = []
	for item in pitch_items.get_children():
		if item.is_in_group("players") and (home_or_away == null or item.get_home_or_away() == home_or_away):
			players.append(item)

	return players


func get_match_data():
	return _get_menu_setting("match_data")

func set_selected_player(player_node):
	pass

func get_randon_home_or_away():
	var rnd = randi() % 2
	var home_and_away =  ["Home", "Away"]
	return home_and_away[rnd]

func set_camera_drone_target(target):
	camera_drone.set_target(target)

func load_player_positions(home_or_away, formation, play_style):
	player_positions.load_player_positions(home_or_away, formation, play_style)

func get_position_on_pitch(node):
	return node.position - pitch_top_left.position



## This is a function to determine who is the closest player(s) to run towards the ball
## Will exclude player in possession too as we don't factor them in
## @param {integer} num How many players to fetch 
## @param {string|null} home_or_away "Home" or "Away" or null
## @param {bool} include_goalie
##
## @return {array<Player>}
func get_closest_players_to(something, num, home_or_away = null, include_goalie = true):
	
	# we'll build up this array of players who are closest to "something"
	var closest_players = []
	
	# we'll deduct from these as we go
	var players_pool = get_players(home_or_away)

	while closest_players.size() < num and !players_pool.empty():
		
		# loop through each players remaining and find the next closest
		var closest_player = null
		for player in players_pool:
			
			# # this is important for making a pass, that it doesn't chose the player_in_possession
			# if something == ball and player == self.player_in_possession:
			# 	players_pool.erase(player)
			# 	continue
			
			if !include_goalie and player.is_goalie():
				players_pool.erase(player)
				continue

			if !player.is_playable():
				players_pool.erase(player)
				continue
			
			if closest_player == null:
				closest_player = player
				continue
			
			# determine whether we need to replace the current closest_player with this player
			var this_player_distance_to_something = player.position.distance_to(something.position)
			var closest_player_distance_to_something = closest_player.position.distance_to(something.position)
			if this_player_distance_to_something < closest_player_distance_to_something:
				closest_player = player
		
		closest_players.append(closest_player)
		players_pool.erase(closest_player)

	return closest_players













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
		if (is_player and !human_node.is_client_user) or !is_client_user_home_team:
			human_node.update_state_from_server(human_state)

	# store processed update for verification when the next one comes in
	last_state_update_received = state_update

## send new direction update to other clients
func _on_Player_send_direction_update(player_node, new_direction):
	ServerConnection.send_direction_update(player_node.name, new_direction)

## send new direction update to other clients
func _on_Player_send_state_update(player_node, position, current_animation):
	ServerConnection.send_state_update(player_node.name, position, current_animation)
