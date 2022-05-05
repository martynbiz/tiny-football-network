extends Node

var current_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func load_root_scene(reference_path, menu_settings = {}):
	
	# out with the old 
	if current_menu:
		current_menu.queue_free()

	# in with the nu(clear ;)
	current_menu = load(reference_path).instance()
	current_menu.menu_settings = menu_settings
	add_child(current_menu)
