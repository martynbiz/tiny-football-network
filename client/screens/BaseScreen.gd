extends Node2D
class_name BaseScreen

var current_screen

var menu_settings = {}

onready var root_node = get_tree().get_root().get_node("Root")

func init():
	pass

func load_screen(screen_name, menu_settings = {}):
	root_node.load_screen(screen_name, menu_settings)

func require_authentication():
	if ServerConnection.get_session() == null:
		load_screen(Constants.LOGIN_SCREEN_PATH)
