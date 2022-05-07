extends BaseScreen

onready var online_button = $CenterContainer/VBoxContainer/Online
onready var local_button = $CenterContainer/VBoxContainer/Local

# const SELECT_TEAM_SCENE_PATH = "res://ui/SelectTeamScreen.tscn"

func _ready():
	pass

func init():
	online_button.connect("pressed", self, "_on_Button_pressed")
	online_button.disabled = true

func _process(delta):

	# enable buttons when connected  
	if online_button.disabled and Server.is_connected:
		online_button.disabled = false

func _on_MenuButton_pressed(button):
	if button == online_button:
		load_screen("SelectTeam")
