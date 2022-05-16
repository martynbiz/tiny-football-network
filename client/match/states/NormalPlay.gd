extends MatchBaseState

enum Stages {
	INIT,
	READY,
}

func enter():
	stage = Stages.INIT

func _physics_process(delta):
	
	var ball = owner.ball

	match stage:
		Stages.INIT:

			owner.set_camera_drone_target(ball)

			# load player positions TODO move to READY with play_style etc
			owner.load_player_positions("Home", owner.home_formation, owner.home_play_style) # TODO not owner.home_play_style
			owner.load_player_positions("Away", owner.away_formation, owner.away_play_style) # TODO not owner.away_play_style

			# # line up the players from the ball 
			# ball.position = owner.pitch_center.position
			# owner.home_player_1.position = owner.pitch_center.position + Vector2(10,10)
			# owner.away_player_1.position = owner.pitch_center.position + Vector2(20,20)
			# owner.home_player_2.position = owner.pitch_center.position + Vector2(30,30)
			# owner.away_player_2.position = owner.pitch_center.position + Vector2(40,40)
			# owner.home_player_3.position = owner.pitch_center.position + Vector2(50,50)
			# owner.away_player_3.position = owner.pitch_center.position + Vector2(60,60)

			# var closest_player_to_ball = owner.get_closest_players_to(ball, 3, "Home", false)

			# for player in owner.get_players():
			# 	player.is_selected = closest_player_to_ball.has(player)

			stage = Stages.READY

		Stages.READY:

			# TODO manage ref position 
			
			# TODO load player positions as the ball moves up and down the park

			# TODO manage player run targets

			# get the closest players for home and away
			var closest_player_to_ball = {"Home": null, "Away": null}
			var closest_outfield_player_to_ball = {"Home": null, "Away": null}
			for home_or_away in ["Home", "Away"]:
				closest_player_to_ball[home_or_away] = owner.get_closest_player_to_ball(home_or_away)
				if closest_player_to_ball[home_or_away].is_goalie():
					closest_outfield_player_to_ball[home_or_away] = owner.get_closest_outfield_player_to_ball(home_or_away)
				else:
					closest_outfield_player_to_ball[home_or_away] = owner.closest_player_to_ball[home_or_away]

			# Manage player run targets only
			for player in owner.get_players():

				var home_or_away = player.get_home_or_away()

				# Simple for now
				if player == closest_player_to_ball[home_or_away]:
					player.run_to(ball)
				else:
					player.run_to(player.player_position)










			# 	# defaults 
			# 	if player.is_goalie():
			# 		var goal_center_position = player.get_goal_center_position()
			# 		player.run_to(goal_center_position)
			# 	else:
			# 		player.run_to(player.player_position)
					
			# 	# fetch the closest players we need e.g. home or away 
			# 	var closest_outfield_player_same_team = closest_outfield_player_to_ball[home_or_away]
			# 	var closest_player_same_team_inc_goalie = closest_player_to_ball[home_or_away]
			# 	# var closest_player_goalside = closest_players_goalside[home_or_away]
				
			# 	var team_in_possession = ball.team_in_possession
				
			# 	# team in possession vars 
			# 	var same_team_in_possession = (team_in_possession == home_or_away)
			# 	var opposition_team_in_possession = (team_in_possession != home_or_away)
			# 	var no_team_in_possession = (team_in_possession == null)

			# 	# we'll give the goalie their own code space as they move quite differently
			# 	if player.is_goalie():
					
			# 		var center_position
			# 		var run_target_position

			# 		# quite a messy condition, so tidy it up 
			# 		var is_ball_in_same_penalty_area = player.is_ball_in_same_penalty_area()
			# 		var player_in_possession = ball.player_in_possession
			# 		var player_is_closest_player_same_team = (player == closest_player_same_team_inc_goalie)
					
			# 		# first checks, ball is in penalty area and opp in poss. Then checks if pip or not too fast to catch
			# 		if is_ball_in_same_penalty_area and opposition_team_in_possession and ((player_in_possession and player_is_closest_player_same_team) or (!player_in_possession and !ball.is_too_fast_to_catch())):
						
			# 			# rush out to the ball 
			# 			player.run_to(ball, 3)

			# 			# the goalie can use their hands, so enable goalie collision 
			# 			player.collision_shape.disabled = true
			# 			player.goalie_collision_shape.disabled = false

			# 			# this will tell us whether to attempt a lob or not (sometimes)
			# 			player.is_goalie_running_out = true

			# 		# position relative to ball on pitch
			# 		else:

			# 			# default
			# 			player.is_goalie_running_out = false
						
			# 			# determine our goal center (top or bottom) to get the direction to the ball from
			# 			if player.is_top_team():
			# 				center_position = owner.get_pitch_top_center_position()
			# 			else:
			# 				center_position = owner.get_pitch_bottom_center_position()
			# 			var ball_dir = center_position.direction_to(ball.position)
						
			# 			# if the ball is not on the picth, re center goalie
			# 			if !ball.is_on_pitch:
			# 				ball_dir = player.get_shooting_direction()
						
			# 			# unless a penalty, sit off the line directed towards the ball
			# 			run_target_position = center_position + (ball_dir * 15)

			# 			player.run_to(run_target_position, 3)

			# 	# outfield player 
			# 	else:
					
			# 		# player in possesion, not neccessarily this player 
			# 		if ball.player_in_possession:
						
			# 			# same team in possession (make a run, move into space etc)
			# 			if same_team_in_possession:
			# 				pass


			# 			# opp team in possession
			# 			else:

			# 				# ideally, goal side player - include goalie?
			# 				var closest_player = closest_outfield_player_same_team
								
			# 				# outfield player run to ball
			# 				if player == closest_player: # and !ball.exit_position:
			# 					if player.is_same_team_as_user():
			# 						owner.set_selected_player(player)
			# 					else:
									
			# 						# # ai this works better by selecting the goal side defender
			# 						# if closest_player_goalside and !closest_player_goalside.is_goalie():
			# 						# 	closest_player = closest_player_goalside

			# 						player.run_to(ball, 3)
					
			# 		# no player_in_possession, kicked or ball idle
			# 		else:
						
			# 			# same team in possession, or no team in possession - make a run before the opp player
			# 			if same_team_in_possession:
			# 				if player == closest_outfield_player_same_team: # and !ball.exit_position:
			# 					player.run_to(ball.get_destination(delta), 3)
						
			# 			# opp team in possession - select the player if the ball is in motion
			# 			if opposition_team_in_possession and ball.is_moving():
			# 				if player == closest_outfield_player_same_team:
			# 					if player.is_same_team_as_user():
			# 						owner.set_selected_player(player)
			# 					# else:
			# 					# 	player.run_to(ball.get_destination(delta), 3)

			# 			# if no team in possession, and ball has stopped, deselect player and both sides run to ball
			# 			if no_team_in_possession and !ball.is_moving(): # and !ball.exit_position:
			# 				owner.unset_selected_player()
			# 				if player == closest_outfield_player_same_team:
			# 					player.run_to(ball, 3)
