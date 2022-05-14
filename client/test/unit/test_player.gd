extends "res://addons/gut/test.gd"

var player_scene = preload("res://match/player/Player.tscn")

var player_instance

func before_all():
	pass

func before_each():
	player_instance = player_scene.instance()
	add_child(player_instance)

func after_each():
	player_instance.queue_free()

func test_get_home_or_away_when_is_home_team_true():
	player_instance.is_home_team = true
	var home_or_away = player_instance.get_home_or_away()
	assert_eq(home_or_away, "Home", "Get all players")

func test_get_home_or_away_when_is_home_team_false():
	player_instance.is_home_team = false
	var home_or_away = player_instance.get_home_or_away()
	assert_eq(home_or_away, "Away", "Get all players")

func test_set_player_position():
	var player_position = Vector2.ZERO
	player_instance.set_player_position(player_position)
	assert_eq(player_instance.player_position, player_position, "Set player position")

func test_set_collision_shape_disabled():
	player_instance.set_collision_shape_disabled(true, true)
	assert_eq(player_instance.collision_shape.disabled, true, "Set collision shape")
	assert_eq(player_instance.goalie_collision_shape.disabled, true, "Set collision shape")
	
	player_instance.set_collision_shape_disabled(true, false)
	assert_eq(player_instance.collision_shape.disabled, true, "Set collision shape")
	assert_eq(player_instance.goalie_collision_shape.disabled, false, "Set collision shape")
	
	player_instance.set_collision_shape_disabled(false, false)
	assert_eq(player_instance.collision_shape.disabled, false, "Set collision shape")
	assert_eq(player_instance.goalie_collision_shape.disabled, false, "Set collision shape")

func test_is_playable_when_sent_off():

	# default is playable
	assert_eq(player_instance.is_playable(), true, "Set player position")

	player_instance.is_sent_off = true
	assert_eq(player_instance.is_playable(), false, "Set player position")