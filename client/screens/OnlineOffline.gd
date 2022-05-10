extends BaseScreen

onready var online_button = $CenterContainer/VBoxContainer/Online
onready var local_button = $CenterContainer/VBoxContainer/Local
onready var back_button = $CenterContainer/VBoxContainer/Back

func _on_MenuButton_pressed(button):
	match button:
		online_button:
			load_screen(Constants.ONLINE_SCREEN_PATH)
		back_button:
			load_screen(Constants.HOME_SCREEN_PATH)
