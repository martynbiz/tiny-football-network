extends Node
class_name BaseScreen

var current_screen

var menu_settings = {}

onready var root_node = get_tree().get_root().get_node("Root")

func load_root_scene(reference_path, menu_settings = {}):
	root_node.load_root_scene(reference_path, menu_settings)
