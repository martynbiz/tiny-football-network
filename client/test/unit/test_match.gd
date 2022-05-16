extends "res://addons/gut/test.gd"

var match_scene = preload("res://match/Match.tscn")

var match_instance

var home_player_1
var home_player_2
var home_player_3

var away_player_1
var away_player_2
var away_player_3

var ball

func before_all():
	pass

func before_each():
	match_instance = match_scene.instance()
	add_child(match_instance)

	home_player_1 = match_instance.home_player_1
	home_player_2 = match_instance.home_player_2
	home_player_3 = match_instance.home_player_3

	away_player_1 = match_instance.away_player_1
	away_player_2 = match_instance.away_player_2
	away_player_3 = match_instance.away_player_3

	ball = match_instance.ball

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

func test__get_closest_players_to_ball():

	var pitch_center_position = match_instance.pitch_center.position

	# line up the players from the ball 
	ball.position = pitch_center_position
	home_player_1.position = pitch_center_position + Vector2(10,10)
	away_player_1.position = pitch_center_position + Vector2(20,20)
	home_player_2.position = pitch_center_position + Vector2(30,30)
	away_player_2.position = pitch_center_position + Vector2(40,40)
	home_player_3.position = pitch_center_position + Vector2(50,50)
	away_player_3.position = pitch_center_position + Vector2(60,60)

	var closest_players = match_instance._get_closest_players_to(ball, 6)
	
	assert_eq(closest_players.size(), 6, "Get closest players size")
	assert_eq(closest_players[0], home_player_1, "Get closest players")
	assert_eq(closest_players[1], away_player_1, "Get closest players")
	assert_eq(closest_players[2], home_player_2, "Get closest players")
	assert_eq(closest_players[3], away_player_2, "Get closest players")
	assert_eq(closest_players[4], home_player_3, "Get closest players")
	assert_eq(closest_players[5], away_player_3, "Get closest players")

	var closest_home_players = match_instance._get_closest_players_to(ball, 3, "Home")
	
	assert_eq(closest_home_players.size(), 3, "Get closest players size")
	assert_eq(closest_home_players[0], home_player_1, "Get closest players")
	assert_eq(closest_home_players[1], home_player_2, "Get closest players")
	assert_eq(closest_home_players[2], home_player_3, "Get closest players")

	var closest_home_outfield_players = match_instance._get_closest_players_to(ball, 3, "Home", false)
	
	assert_eq(closest_home_outfield_players.size(), 2, "Get closest players size")
	assert_eq(closest_home_outfield_players[0], home_player_2, "Get closest players")
	assert_eq(closest_home_outfield_players[1], home_player_3, "Get closest players")

	var closest_home_player_to_ball = match_instance.get_closest_player_to_ball("Home")
	assert_eq(closest_home_player_to_ball, home_player_1, "Get closest players")

	var closest_outfield_home_player_to_ball = match_instance.get_closest_outfield_player_to_ball("Home")
	assert_eq(closest_outfield_home_player_to_ball, home_player_2, "Get closest players")
