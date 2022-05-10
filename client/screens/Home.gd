extends BaseScreen

onready var play_button = $CenterContainer/VBoxContainer/Play

func _on_MenuButton_pressed(button):
	match button:
		play_button:
			load_screen(Constants.ONLINE_OFFLINE_SCREEN_PATH)
