extends "res://addons/gut/test.gd"

var ball_scene = preload("res://match/ball/Ball.tscn")
var player_scene = preload("res://match/player/Player.tscn")

var ball_instance

var player_1 
var player_2

func before_all():
	pass

func before_each():
	ball_instance = ball_scene.instance()
	add_child(ball_instance)

	player_1 = player_scene.instance()
	add_child(player_1)
	player_2 = player_scene.instance()
	add_child(player_2)

func after_each():
	ball_instance.queue_free()

func test_set_player_in_possession():

	assert_eq(player_1.is_in_possession, false, "Set player in possession")
	assert_eq(player_2.is_in_possession, false, "Set player in possession")
	
	ball_instance.set_player_in_possession(player_1)

	assert_eq(ball_instance.player_in_possession, player_1, "Set player in possession")
	assert_eq(player_1.is_in_possession, true, "Set player in possession")
	
	ball_instance.set_player_in_possession(player_2)

	assert_eq(ball_instance.player_in_possession, player_2, "Set player in possession")
	assert_eq(player_1.is_in_possession, false, "Set player in possession")
	assert_eq(player_2.is_in_possession, true, "Set player in possession")

func test_unset_player_in_possession():
	
	ball_instance.set_player_in_possession(player_1)

	assert_eq(ball_instance.player_in_possession, player_1, "Unset player in possession")
	assert_eq(player_1.is_in_possession, true, "Unset player in possession")
	
	ball_instance.unset_player_in_possession()

	assert_eq(ball_instance.player_in_possession, null, "Unset player in possession")
	assert_eq(player_1.is_in_possession, false, "Unset player in possession")
