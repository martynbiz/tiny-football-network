extends BaseScreen

onready var friendly_button = $CenterContainer/VBoxContainer/Friendly
onready var tournament_button = $CenterContainer/VBoxContainer/Tournament
onready var back_button = $CenterContainer/VBoxContainer/Back

func _ready():
	require_authentication()

func _on_MenuButton_pressed(button):
	match button:
		friendly_button:
			load_screen(Constants.MATCH_PREVIEW_SCREEN_PATH)
		back_button:
			load_screen(Constants.ONLINE_OFFLINE_SCREEN_PATH)
