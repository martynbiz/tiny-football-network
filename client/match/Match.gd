extends BaseScreen

onready var pitch_items = $YSort
onready var home_player_1 = pitch_items.get_node("HomePlayer1")
onready var away_player_1 = pitch_items.get_node("AwayPlayer1")

var player_friction := 500

func _ready():
	
	# set player properties on load 
	for player_node in _get_players():
		player_node.player_friction = player_friction

	# TODO 
	home_player_1.is_selected = true

	ServerConnection.connect("state_updated", self, "_on_ServerConnection_state_updated")

func _physics_process(delta):
	pass

func _get_players(home_or_away = null):
	return [home_player_1, away_player_1]

# state for humans is updated when they are not owned by this client e.g. opp team 
# state for ball is updated when the opp team is in possession, as they are in control of the ball
# state for linesmen/ ref is control by the home team(?)
# how do match states work? e.g. fouls; home team is host(?)
func _on_ServerConnection_state_updated(humans, ball):
	print("_on_ServerConnection_state_updated ", humans, ball)
