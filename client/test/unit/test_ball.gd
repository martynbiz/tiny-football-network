extends "res://addons/gut/test.gd"

var ball_scene = preload("res://match/ball/Ball.tscn")
var player_scene = preload("res://match/player/Player.tscn")

var ball_instance

var home_player_1 
var home_player_2
var home_player_3
var away_player_1 
var away_player_2
var away_player_3

func before_all():
	pass

func before_each():
	ball_instance = ball_scene.instance()
	add_child(ball_instance)

	home_player_1 = player_scene.instance()
	home_player_1.is_goalie = true
	home_player_1.is_home_team = true
	add_child(home_player_1)
	home_player_2 = player_scene.instance()
	home_player_2.is_home_team = true
	add_child(home_player_2)
	home_player_3 = player_scene.instance()
	home_player_3.is_home_team = true
	add_child(home_player_3)

	away_player_1 = player_scene.instance()
	away_player_1.is_goalie = true
	away_player_1.is_home_team = false
	add_child(away_player_1)
	away_player_2 = player_scene.instance()
	away_player_2.is_home_team = false
	add_child(away_player_2)
	away_player_3 = player_scene.instance()
	away_player_3.is_home_team = false
	add_child(away_player_3)

func after_each():
	ball_instance.queue_free()

func test_set_player_in_possession():

	assert_eq(home_player_1.is_in_possession, false, "Set player in possession")
	assert_eq(home_player_2.is_in_possession, false, "Set player in possession")
	assert_eq(ball_instance.last_players_in_possession.size(), 0, "Set player in possession")

	ball_instance.set_player_in_possession(home_player_1)

	assert_eq(ball_instance.player_in_possession, home_player_1, "Set player in possession")
	assert_eq(home_player_1.is_in_possession, true, "Set player in possession")
	assert_eq(ball_instance.last_players_in_possession.size(), 0, "Set player in possession")

	ball_instance.set_player_in_possession(home_player_2)

	assert_eq(ball_instance.player_in_possession, home_player_2, "Set player in possession")
	assert_eq(home_player_1.is_in_possession, false, "Set player in possession")
	assert_eq(home_player_2.is_in_possession, true, "Set player in possession")
	assert_eq(ball_instance.last_players_in_possession.size(), 1, "Set player in possession")

	# again
	ball_instance.set_player_in_possession(home_player_2)

	assert_eq(ball_instance.player_in_possession, home_player_2, "Set player in possession")
	assert_eq(home_player_1.is_in_possession, false, "Set player in possession")
	assert_eq(home_player_2.is_in_possession, true, "Set player in possession")
	assert_eq(ball_instance.last_players_in_possession.size(), 1, "Set player in possession")

func test_unset_player_in_possession():
	
	ball_instance.set_player_in_possession(home_player_1)

	assert_eq(ball_instance.player_in_possession, home_player_1, "Unset player in possession")
	assert_eq(home_player_1.is_in_possession, true, "Unset player in possession")
	
	ball_instance.unset_player_in_possession()

	assert_eq(ball_instance.player_in_possession, null, "Unset player in possession")
	assert_eq(home_player_1.is_in_possession, false, "Unset player in possession")

func test_get_last_player_in_possession():

	ball_instance.set_player_in_possession(away_player_2)
	ball_instance.set_player_in_possession(home_player_2)
	ball_instance.set_player_in_possession(home_player_1)
	ball_instance.set_player_in_possession(home_player_3)

	assert_eq(ball_instance.last_players_in_possession.size(), 3, "Unset player in possession")
	assert_eq(ball_instance.get_last_player_in_possession(), home_player_1, "Unset player in possession")
	assert_eq(ball_instance.get_last_player_in_possession(), home_player_1, "Unset player in possession")
	assert_eq(ball_instance.get_last_player_in_possession("Away"), away_player_2, "Unset player in possession")
	assert_eq(ball_instance.get_last_player_in_possession("Home", false), home_player_2, "Unset player in possession")
