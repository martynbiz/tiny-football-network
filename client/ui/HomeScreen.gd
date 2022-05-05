extends BaseScreen

onready var friendly_button = $CenterContainer/VBoxContainer/Friendly

const SELECT_TEAM_SCENE_PATH = "res://ui/SelectTeamScreen.tscn"

func _ready():
	friendly_button.connect("pressed", self, "_on_Button_pressed")

func _on_MenuButton_pressed(button):
	if button == friendly_button:
		load_root_scene(SELECT_TEAM_SCENE_PATH)
