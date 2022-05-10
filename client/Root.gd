extends Node

var current_screen

# Called when the node enters the scene tree for the first time.
func _ready():
	load_screen(Constants.ONLINE_OFFLINE_SCREEN_PATH)

func load_screen(reference_path, menu_settings = {}):

	if ServerConnection.get_session() == null:
		reference_path = Constants.LOGIN_SCREEN_PATH
	
	# out with the old 
	if current_screen != null:
		current_screen.queue_free()

	# in with the nu(clear ;)
	current_screen = load(reference_path).instance()
	current_screen.menu_settings = menu_settings
	get_node("Screens").add_child(current_screen)

	# if current_screen.has_method("init"):
	# 	current_screen.init()
