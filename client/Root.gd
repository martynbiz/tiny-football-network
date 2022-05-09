extends Node

var current_screen_name

# const HOME_SCENE_PATH = "res://ui/HomeScreen.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_screen("Home")

func load_screen(screen_name, menu_settings = {}):

	if Online.nakama_session == null:
		screen_name = "Connection"

	var screens_node = get_node("Screens")
	
	# out with the old 
	if current_screen_name != null:
		screens_node.get_node(current_screen_name).visible = false

	# in with the nu(clear ;)
	var current_screen = screens_node.get_node(screen_name)
	current_screen.visible = true
	current_screen.menu_settings = menu_settings
	current_screen_name = screen_name

	if current_screen.has_method("init"):
		current_screen.init()
