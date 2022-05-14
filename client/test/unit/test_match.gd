extends "res://addons/gut/test.gd"

var match_scene = preload("res://match/Match.tscn")

var match_instance

func before_all():
	pass

func before_each():
	match_instance = match_scene.instance()
	add_child(match_instance)

func after_each():
	match_instance.queue_free()

func test_get_players():
	var players = match_instance.get_players()
	assert_eq(players.size(), 6, "Get all players")

func test_get_players_home():
	var players = match_instance.get_players("Home")
	assert_eq(players.size(), 3, "Get all players")
	for player in players:
		assert_eq(player.get_home_or_away(), "Home", "Get home players")

func test_get_players_away():
	var players = match_instance.get_players("Away")
	assert_eq(players.size(), 3, "Get all players")
	for player in players:
		assert_eq(player.get_home_or_away(), "Away", "Get away players")

func test_set_camera_drone_target():
	var target = match_instance.ball
	match_instance.set_camera_drone_target(target)
	assert_eq(match_instance.camera_drone.target, target, "Camera target is set")
