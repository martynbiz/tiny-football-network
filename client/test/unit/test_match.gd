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

	home_player_1 = match_instance.pitch_ysort.get_node("HomePlayer1")
	home_player_2 = match_instance.pitch_ysort.get_node("HomePlayer2")
	home_player_3 = match_instance.pitch_ysort.get_node("HomePlayer3")

	away_player_1 = match_instance.pitch_ysort.get_node("AwayPlayer1")
	away_player_2 = match_instance.pitch_ysort.get_node("AwayPlayer2")
	away_player_3 = match_instance.pitch_ysort.get_node("AwayPlayer3")

	ball = match_instance.ball

func after_each():
	match_instance.queue_free()

func test_get_players():
	var players = match_instance.get_players()
	assert_eq(players.size(), 22, "Get all players")

func test_get_players_home():
	var players = match_instance.get_players("Home")
	assert_eq(players.size(), 11, "Get all players")
	for player in players:
		assert_eq(player.get_home_or_away(), "Home", "Get home players")

func test_get_players_away():
	var players = match_instance.get_players("Away")
	assert_eq(players.size(), 11, "Get all players")
	for player in players:
		assert_eq(player.get_home_or_away(), "Away", "Get away players")

func test_set_camera_drone_target():
	var target = match_instance.ball
	match_instance.set_camera_drone_target(target)
	assert_eq(match_instance.camera_drone.target, target, "Camera target is set")

func test_get_closest_players_to():

	var pitch_center_position = match_instance.pitch_center_position

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
	
	assert_eq(closest_home_outfield_players.size(), 3, "Get closest players size")
	assert_eq(closest_home_outfield_players[0], home_player_2, "Get closest players")
	assert_eq(closest_home_outfield_players[1], home_player_3, "Get closest players")


	# "public" functions

	var closest_home_player_to_ball = match_instance.get_closest_player_to_ball("Home")
	assert_eq(closest_home_player_to_ball, home_player_1, "Get closest players")

	var closest_outfield_home_player_to_ball = match_instance.get_closest_outfield_player_to_ball("Home")
	assert_eq(closest_outfield_home_player_to_ball, home_player_2, "Get closest players")


func test_set_unset_selected_player():
	
	# set players
	match_instance.set_selected_player(home_player_1)
	match_instance.set_selected_player(away_player_1)
	assert_eq(match_instance.selected_player["Home"], home_player_1, "Set selected player")
	assert_eq(home_player_1.is_selected, true, "Set selected player")
	assert_eq(match_instance.selected_player["Away"], away_player_1, "Set selected player")
	assert_eq(away_player_1.is_selected, true, "Set selected player")

	# check all other players are not is_selected
	for player in match_instance.get_players():
		if player != home_player_1 and player != away_player_1:
			 assert_eq(player.is_selected, false, "Set selected player")

	# change the players
	match_instance.set_selected_player(home_player_2)
	match_instance.set_selected_player(away_player_2)
	assert_eq(match_instance.selected_player["Home"], home_player_2, "Set selected player")
	assert_eq(home_player_2.is_selected, true, "Set selected player")
	assert_eq(match_instance.selected_player["Away"], away_player_2, "Set selected player")
	assert_eq(away_player_2.is_selected, true, "Set selected player")

	# check all other players are not is_selected
	for player in match_instance.get_players():
		if player != home_player_2 and player != away_player_2:
			 assert_eq(player.is_selected, false, "Set selected player")

	# unset home
	match_instance.set_selected_player(home_player_2)
	match_instance.set_selected_player(away_player_2)
	match_instance.unset_selected_player("Home")
	assert_eq(match_instance.selected_player["Home"], null, "Set selected player")
	assert_eq(home_player_2.is_selected, false, "Set selected player")
	assert_eq(match_instance.selected_player["Away"], away_player_2, "Set selected player")
	assert_eq(away_player_2.is_selected, true, "Set selected player")

	# unset away
	match_instance.set_selected_player(home_player_2)
	match_instance.set_selected_player(away_player_2)
	match_instance.unset_selected_player("Away")
	assert_eq(match_instance.selected_player["Home"], home_player_2, "Set selected player")
	assert_eq(home_player_2.is_selected, true, "Set selected player")
	assert_eq(match_instance.selected_player["Away"], null, "Set selected player")
	assert_eq(away_player_2.is_selected, false, "Set selected player")

	# unset both
	match_instance.set_selected_player(home_player_2)
	match_instance.set_selected_player(away_player_2)
	match_instance.unset_selected_player()
	assert_eq(match_instance.selected_player["Home"], null, "Set selected player")
	assert_eq(home_player_2.is_selected, false, "Set selected player")
	assert_eq(match_instance.selected_player["Away"], null, "Set selected player")
	assert_eq(away_player_2.is_selected, false, "Set selected player")

func test_get_goal_center_position():

	match_instance.top_team = "Home"

	var home_goal_center_position = match_instance.get_goal_center_position("Home")
	assert_eq(home_goal_center_position, match_instance.pitch_top_goal_center_position, "Get goal center")

	var away_goal_center_position = match_instance.get_goal_center_position("Away")
	assert_eq(away_goal_center_position, match_instance.pitch_bottom_goal_center_position, "Get goal center")

func test_get_shooting_direction():

	match_instance.top_team = "Home"

	var home_shooting_direction = match_instance.get_shooting_direction(home_player_1)
	assert_eq(home_shooting_direction, Vector2.DOWN, "Get shooting direction")
	
	var away_shooting_direction = match_instance.get_shooting_direction(away_player_1)
	assert_eq(away_shooting_direction, Vector2.UP, "Get shooting direction")

func test_change_state():
	
	match_instance.change_state("KickOff", {
		"team_to_start": "Home"
	})

	assert_eq(match_instance.state_machine.state.name, "KickOff", "Change state")
	assert_eq(match_instance.state_machine.state.team_to_start, "Home", "Change state")

