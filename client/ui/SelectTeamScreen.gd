extends BaseScreen

onready var button_column = $CenterContainer/VBoxContainer

onready var back_button = $CenterContainer/VBoxContainer2/BackButton

const HOME_SCENE_PATH = "res://ui/HomeScreen.tscn"
const MATCH_PREVIEW_SCENE_PATH = "res://ui/MatchPreviewScreen.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	Server.fetch_teams_data(get_instance_id())
	
	# hide column until loaded
	button_column.visible = false

func handle_return_fetch_team_data(teams_data):
	
	# show column until loaded
	button_column.visible = true
	
	if teams_data:
		for i in teams_data.slice(0,3).size():
			var button = button_column.get_node("Team" + str(i))
			var team_data = teams_data[i]
			button.text = team_data.team_name
			button.data = team_data

func _on_MenuButton_pressed(button):
	if button == back_button:
		load_root_scene(HOME_SCENE_PATH)
	else:
		Server.init_event(button.data.team_id, get_instance_id())

func handle_return_init_event(event_data):
	if event_data:
		load_root_scene(MATCH_PREVIEW_SCENE_PATH)
