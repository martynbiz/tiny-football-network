extends Node2D
class_name BaseScreen

var current_screen

var screen_settings = {}

onready var root_node = get_tree().get_root().get_node("Root")

func init():
	pass

func load_screen(screen_name, screen_settings = {}):
	root_node.load_screen(screen_name, screen_settings)

func require_authentication():
	if ServerConnection.get_session() == null:
		load_screen(Constants.LOGIN_SCREEN_PATH)

func _get_screen_setting(name):
	if name in screen_settings:
		return screen_settings[name]
