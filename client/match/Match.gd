extends BaseScreen

onready var pitch_items = $YSort
onready var home_player_1 = pitch_items.get_node("HomePlayer1")
onready var away_player_1 = pitch_items.get_node("AwayPlayer1")

# we'll use this for syncing state updates
var current_frame := 0

var player_friction := 500

var selected_player = {
	"Home": null,
	"Away": null,
}

var is_client_user_home_team := false

func _ready():

	is_client_user_home_team = (_get_client_user_home_or_away() == "Home")
	
	# set player properties on load 
	for player_node in _get_players():
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
	var match_data = _get_match_data()
	var user_id = ServerConnection.get_user_id()
	
	if match_data: 
		if (match_data.home_team.user_id == user_id):
			return "Home"
		elif (match_data.away_team.user_id == user_id):
			return "Away"

func _get_players(home_or_away = null):
	return [home_player_1, away_player_1]

func _get_match_data():
	return _get_menu_setting("match_data")

func _set_selected_player(player_node):
	pass

var last_state_update_received

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
