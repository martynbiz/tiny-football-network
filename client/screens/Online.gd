extends BaseScreen

onready var friendly_button = $CenterContainer/VBoxContainer/Friendly
onready var tournament_button = $CenterContainer/VBoxContainer/Tournament
onready var back_button = $CenterContainer/VBoxContainer/Back

func _ready():
	require_authentication()

func _on_MenuButton_pressed(button):
	match button:
		friendly_button:
			ServerConnection.join_match_async()
			load_screen(Constants.MATCH_PREVIEW_SCREEN_PATH)
		back_button:
			load_screen(Constants.ONLINE_OFFLINE_SCREEN_PATH)

# func init_friendly():

# 	# Setup socket connection
# 	if not ServerConnection._socket:
# 		result = yield(ServerConnection.connect_to_server_async(), "completed")
# 		if result != OK:
# 			print("Error: connecting to socket. code %s: %s" % [result, ServerConnection.error_message])
# 			result = yield(ServerConnection.init_friendly(), "completed")
# 		# if result == OK:
# 		# 	pass
# 		# 	# warning-ignore:return_value_discarded
# 		# 	pass
# 		# 	# get_tree().change_scene_to(load("res://src/Main/GameWorld.tscn"))
# 		# 	# ServerConnection.send_spawn(player_color, player_name)
