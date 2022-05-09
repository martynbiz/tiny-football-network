extends BaseScreen

onready var friendly_button = $CenterContainer/VBoxContainer/Friendly

# const SELECT_TEAM_SCENE_PATH = "res://ui/SelectTeamScreen.tscn"

func _ready():
	friendly_button.connect("pressed", self, "_on_Button_pressed")
	friendly_button.disabled = true

func _process(delta):

	if !visible:
		return

	# enable buttons when connected  
	if friendly_button.disabled and Server.is_connected:
		friendly_button.disabled = false

func _on_MenuButton_pressed(button):
	if button == friendly_button:
		load_screen(Constants.SELECT_TEAM_SCREEN_SCENE_PATH)
