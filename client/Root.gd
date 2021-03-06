extends Node

var current_screen

# Called when the node enters the scene tree for the first time.
func _ready():
	load_screen(Constants.HOME_SCREEN_PATH)

	# this is the only randomize that is required, apparently
	# https://docs.godotengine.org/en/latest/tutorials/math/random_number_generation.html
	randomize()

func load_screen(reference_path, screen_settings = {}):
	
	# out with the old 
	if current_screen != null:
		current_screen.queue_free()

	# in with the nu(clear ;)
	current_screen = load(reference_path).instance()
	current_screen.screen_settings = screen_settings
	get_node("Screens").add_child(current_screen)
