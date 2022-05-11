extends BaseScreen

onready var home_player_1 = $YSort/HomePlayer1
onready var away_player_1 = $YSort/AwayPlayer1

var player_friction := 500

func _ready():
	
	# set player properties on load 
	var player_nodes = [home_player_1, away_player_1]
	for player_node in player_nodes:
		player_node.player_friction = player_friction

	# TODO 
	home_player_1.is_selected = true

func _physics_process(delta):
	pass
