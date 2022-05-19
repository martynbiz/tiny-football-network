extends MatchBaseState

enum Stages {
	INIT,
	READY,
}

func enter():
	stage = Stages.INIT

func physics_process(delta):
	
	var ball = owner.ball

	match stage:
		Stages.INIT:

			# # remove offside_player from Match as it'll prevent a goal 
			# # this is also set to null in Foul, but we can remove it from there perhaps(?)
			# if owner.offside_player:
			# 	owner.offside_player = null

			# # reset these for init
			# self.home_play_style_saved = null
			# self.away_play_style_saved = null

			# ensure all send off players are hidden when we return to normal play 
			for player in owner.get_players():
				if player.is_sent_off:
					player.visible = false
					player.set_collision_shape_disabled(true, true)

			owner.set_camera_drone_target(ball)

			# TODO move to READY with play_style etc
			owner.load_player_positions("Home", owner.home_formation, owner.home_play_style) # TODO not owner.home_play_style
			owner.load_player_positions("Away", owner.away_formation, owner.away_play_style) # TODO not owner.away_play_style

			stage = Stages.READY

		Stages.READY:

			# we'll use these to check if changed, and if we need to reload positions e.g. kickoff
			var home_play_style
			var away_play_style

			# # update time - fractor in skipped frames 
			# owner.update_match_time(delta)
				
			# # set ref/linesman position 
			# set_ref_run_target_relative_to_ball()

			# if Options.get_option("offsides_enabled"):
			# 	set_linesman_run_targets_relative_to_ball()

			# # check whether it's half time or full time
			# var current_interval = owner.current_interval
			# var match_time_minutes = owner.get_match_time_minutes()
			
			# # end half?
			# if owner.is_current_interval_time_up():
			# 	state_machine.change_to("EndHalf")

			# var is_crossing = ball.is_crossing() or (ball.player_in_possession and ball.is_in_crossing_zone())

			# # TODO put somewhere we can test 
			# # manage player positions depending on whether the ball is in the top, middle or bottom
			# match owner.get_ball_position_pitch_third():
			# 	0:
			# 		if owner.top_team == "Home":
			# 			home_play_style = "Defending"
			# 			away_play_style = "Attacking"
			# 		else:
			# 			home_play_style = "Attacking"
			# 			away_play_style = "Defending"
			# 	1:
			# 		home_play_style = "NormalPlay"
			# 		away_play_style = "NormalPlay"
			# 	2:
			# 		if owner.top_team == "Home":
			# 			home_play_style = "Attacking"
			# 			away_play_style = "Defending"
			# 		else:
			# 			home_play_style = "Defending"
			# 			away_play_style = "Attacking"

			# # Overrides e.g. Attacking, crossing
			# if is_crossing:
			# 	if home_play_style == "Attacking" or home_play_style == "Defending":
			# 		home_play_style += "Cross"
			# 	if away_play_style == "Attacking" or away_play_style == "Defending":
			# 		away_play_style += "Cross"
			
			# # if not a cross, we can use play styles if set 
			# elif ball.team_in_possession:
			# 	if ball.team_in_possession == "Home":
			# 		if owner.home_play_style == "Attacking":
			# 			home_play_style = "Attacking"
			# 		if owner.away_play_style == "Defending":
			# 			away_play_style = "Defending"
			# 	elif ball.team_in_possession == "Away":
			# 		if owner.home_play_style == "Defending":
			# 			home_play_style = "Defending"
			# 		if owner.away_play_style == "Attacking":
			# 			away_play_style = "Attacking"

			# # check if we need to reload the position nodes if style has changed
			# if home_play_style != self.home_play_style_saved or away_play_style != self.away_play_style_saved:
				
			# 	# load player positions 
			# 	owner.load_player_positions("Home", owner.home_formation, home_play_style)
			# 	owner.load_player_positions("Away", owner.away_formation, away_play_style)

			# 	# update so that we can check the next time
			# 	self.home_play_style_saved = home_play_style
			# 	self.away_play_style_saved = away_play_style

			# TODO manage player run targets

			# get the closest players for home and away
			var closest_player_to_ball = {"Home": null, "Away": null}
			var closest_outfield_player_to_ball = {"Home": null, "Away": null}
			for home_or_away in ["Home", "Away"]:
				closest_player_to_ball[home_or_away] = owner.get_closest_player_to_ball(home_or_away)
				if closest_player_to_ball[home_or_away].is_goalie():
					closest_outfield_player_to_ball[home_or_away] = owner.get_closest_outfield_player_to_ball(home_or_away)
				else:
					closest_outfield_player_to_ball[home_or_away] = closest_player_to_ball[home_or_away]

			# Manage player run targets only
			for player in owner.get_players():

				var home_or_away = player.get_home_or_away()

				player.run_to(player.player_position)
					
				# fetch the closest players we need e.g. home or away 
				var closest_outfield_player_same_team = closest_outfield_player_to_ball[home_or_away]
				var closest_player_same_team_inc_goalie = closest_player_to_ball[home_or_away]
				
				var team_in_possession = owner.team_in_possession
				
				# team in possession vars 
				var same_team_in_possession = (team_in_possession == home_or_away)
				var opposition_team_in_possession = (team_in_possession != home_or_away)
				var no_team_in_possession = (team_in_possession == null)

				var player_is_user_team = owner.user_teams.has(player.get_home_or_away())

				# we'll give the goalie their own code space as they move quite differently
				if player.is_goalie():
					
					var center_position
					var run_target_position

					# quite a messy condition, so tidy it up 
					var is_ball_in_same_penalty_area = false # TODO player.is_ball_in_same_penalty_area()
					var player_in_possession = ball.player_in_possession
					var player_is_closest_player_same_team = (player == closest_player_same_team_inc_goalie)
					
					# first checks, ball is in penalty area and opp in poss. Then checks if pip or not too fast to catch
					if is_ball_in_same_penalty_area and opposition_team_in_possession and ((player_in_possession and player_is_closest_player_same_team) or (!player_in_possession and !ball.is_too_fast_to_catch())):
						
						# rush out to the ball 
						player.run_to(ball, 3)

						# the goalie can use their hands, so enable goalie collision 
						player.set_collision_shape_disabled(true, false)

						# this will tell us whether to attempt a lob or not (sometimes)
						player.is_goalie_running_out = true

					# position relative to ball on pitch
					else:

						# default
						player.is_goalie_running_out = false
						
						# determine our goal center (top or bottom) to get the direction to the ball from
						center_position = owner.get_goal_center_position(home_or_away)
						var ball_dir = center_position.direction_to(ball.position)
						
						# if the ball is not on the picth, re center goalie
						if !ball.is_on_pitch:
							ball_dir = owner.get_shooting_direction(player)
						
						# unless a penalty, sit off the line directed towards the ball
						run_target_position = center_position + (ball_dir * 15)

						player.run_to(run_target_position, 3)

				# outfield player 
				else:
					
					# player in possesion, not neccessarily this player 
					if ball.player_in_possession:
						
						# same team in possession (make a run, move into space etc)
						if same_team_in_possession:
							pass


						# opp team in possession
						else:

							# ideally, goal side player - include goalie?
							var closest_player = closest_outfield_player_same_team
								
							# outfield player run to ball
							if player == closest_player:
								if player_is_user_team:
									owner.set_selected_player(player)
								else:

									player.run_to(ball, 3)
					
					# no player_in_possession, kicked or ball idle
					else:
						
						# same team in possession, or no team in possession - make a run before the opp player
						if same_team_in_possession:
							if player == closest_outfield_player_same_team: # and !ball.exit_position:
								player.run_to(ball.get_destination(delta), 3)
						
						# opp team in possession - select the player if the ball is in motion
						if opposition_team_in_possession and ball.is_moving():
							if player == closest_outfield_player_same_team:
								if player_is_user_team:
									owner.set_selected_player(player)
								# else:
								# 	player.run_to(ball.get_destination(delta), 3)

						# if no team in possession, and ball has stopped, deselect player and both sides run to ball
						if no_team_in_possession and !ball.is_moving(): # and !ball.exit_position:
							owner.unset_selected_player()
							if player == closest_outfield_player_same_team:
								player.run_to(ball, 3)
