extends PlayerBaseState

enum Stages {
	INIT,
	READY
}

func enter():
	stage = Stages.INIT

func _physics_process(delta):
	match stage:
		Stages.INIT:

			owner.set_collision_shape_disabled(false, true)

			stage = Stages.READY

		Stages.READY:
			
			# handle interpolate when set 
			if owner.is_client_app_controlled:

				if owner.is_selected:

					var input_vector = owner.get_input_vector()
					
					# move player from user controls
					if input_vector != Vector2.ZERO:
						owner.velocity = owner.velocity.move_toward(
							owner.direction * owner.data.speed, 
							owner.data.acceleration * delta
						)
					else:
						owner.velocity = owner.velocity.move_toward(Vector2.ZERO, owner.player_friction * delta)

					# determine direction from user controls
					owner.set_direction(input_vector)

					# # handle fire button 
					# if ball.player_in_possession == owner:

					# 	# we currently only need to check for double tap if the ball is in shooting range
					# 	# as we will use this to lob the keeper
					# 	var detect_double_tap = ball.is_in_shooting_zone()

					# 	fire_press_power = Controllers.get_fire_press_power(owner.is_home_team, detect_double_tap, delta)

					# 	if fire_press_power:

					# 		# calulate distance and height
					# 		owner.kick_ball(fire_press_power)

					# 		fire_press_power = 0


				# ai
				else:
					
					# if ai in possession, do something
					if owner.is_in_possession:

						# TODO added for now, belongs to code below though
						owner.apply_friction(delta)
						



						
						# # pass/shoot when pass timer runs out
						# var is_in_attacking_third = ball.is_in_attacking_third()
						# var is_in_defending_third = ball.is_in_defending_third()
						# var is_on_left_flank = ball.is_on_left_flank()
						# var is_on_right_flank = ball.is_on_right_flank()
						# var is_in_crossing_zone = ball.is_in_crossing_zone()
						

						# # don't give them a target, we'll manage this here instead 
						# owner.run_to(null)

						# # if dir == zero, run toward the opponents end
						# var shooting_direction = owner.get_shooting_direction()

						# var closest_opponent = ball.get_closest_player_to_ball(delta, opposide_home_or_away)
						# var distance_to_closest_opponent = owner.position.distance_to(closest_opponent.position)

						# var is_in_middle_zone = !is_in_attacking_third and !is_in_defending_third and !is_on_left_flank and !is_on_right_flank
						# var is_in_shooting_zone = is_in_attacking_third and !is_in_crossing_zone

						# # we can do a check here to see if timer has run out, but we want them 
						# # to carry on e.g. in shooting range but nobody closing them down 
						# if ai_kick_timer <= 0 and ai_kick_direction == null:
						# 	if is_in_shooting_zone:

						# 		var goal_center_position = owner.get_opposition_goal_center_position()
						# 		var distance_to_goal = ball.position.distance_to(goal_center_position)

						# 		# # is_in_shooting_zone will determine top or bottom, so just check either penalty box
						# 		# var is_in_penalty_area = (ball.is_in_top_penalty_area or ball.is_in_bottom_penalty_area)
								
						# 		# get the closest opp player
						# 		var is_close_to_opponent_player = distance_to_closest_opponent < 15

						# 		# players with better shooting skill level will attempt from long range
						# 		var is_far_from_goal = distance_to_goal > max(50, int(owner.shooting / 2))

						# 		if !is_close_to_opponent_player and is_far_from_goal and !is_past_last_defender(): # !is_in_penalty_area:
									
						# 			# face the goal
						# 			var direction_to_goal = owner.get_goal_direction(true)
						# 			owner.set_direction(direction_to_goal)
									
						# 			# give a little more time 
						# 			ai_kick_timer += 0.5
						
						# if ai_kick_timer <= 0: # or (is_in_attacking_third and owner.is_player_in_possession()):

						# 	# attempt to set ai_kick_direction whilst we slow the player down 
						# 	if ai_kick_direction == null:
								
						# 		# determine where to kick to and set ai_kick_direction..
								
						# 		# if in attacking third, 
						# 		if is_in_shooting_zone:
						# 			# ai_kick_intent = Constants.KickIntents.SHOOT
						# 			ai_kick_types.append(Constants.KickTypes.SHOT_ATTEMPT)
						# 			ai_kick_direction = owner.get_goal_direction(true)

						# 		# cross 
						# 		elif Constants.ALLOW_AI_CROSSES and is_in_crossing_zone:
						# 			# ai_kick_intent = Constants.KickIntents.CROSS
						# 			ai_kick_types.append(Constants.KickTypes.CROSS_BALL)
						# 			if is_on_left_flank:
						# 				ai_kick_direction = Vector2.RIGHT
						# 			if is_on_right_flank:
						# 				ai_kick_direction = Vector2.LEFT
								
						# 		# long ball?
						# 		elif is_in_defending_third:
						# 			if Constants.ALLOW_AI_LONG_BALL and randi() % 2 == 0:
						# 				# ai_kick_intent = Constants.KickIntents.LONG_BALL
						# 				ai_kick_types.append(Constants.KickTypes.LONG_BALL)
						# 				ai_kick_direction = shooting_direction

						# 		# keep it on the flank
						# 		elif Constants.ALLOW_AI_KEEP_IT_ON_LEFT_RIGHT_FLANK and (is_on_left_flank or is_on_right_flank):
						# 			ai_kick_direction = shooting_direction
								
						# 		# pass out wide?
						# 		elif is_in_middle_zone:
						# 			if Constants.ALLOW_AI_WIDE_PASSES and randi() % 2 == 0:
						# 				# ai_kick_intent = Constants.KickIntents.PASS_OUT_WIDE
						# 				ai_kick_types.append(Constants.KickTypes.PASS_OUT_WIDE)
						# 				ai_kick_direction = shooting_direction
						# 				ai_kick_direction.x = Utils.get_random_pos_neg()
						# 				ai_kick_direction = ai_kick_direction.normalized()
								
						# 		# if no kick direction (e.g. long ball) then set to closest player 
						# 		if !ai_kick_direction:
						# 			ai_kick_direction = get_direction_to_closest_pass(same_home_or_away)
								
						# 		# direction might still be null if e.g. no passes on
						# 		if ai_kick_direction:
						# 			owner.set_direction(ai_kick_direction)

						# 	# slow player down when we have a kick_direction set 
						# 	else:
						# 		owner.apply_friction(delta)

						# 	# if the player is slow enough
						# 	if owner.velocity == Vector2.ZERO:

						# 		# only pass if we have a target to
						# 		if ai_kick_direction:
									
						# 			# randomize()
									
						# 			if ai_kick_types.has(Constants.KickTypes.SHOT_ATTEMPT):

						# 				var goal_center_position = owner.get_opposition_goal_center_position()
						# 				var distance_to_goal = ball.position.distance_to(goal_center_position)

						# 				# this is the ideal kick power for the distance 
						# 				var base_kick_power = (distance_to_goal / 300) + 0.1

						# 				fire_press_power = Utils.get_randon_kick_power(base_kick_power, 0.1)

						# 			elif ai_kick_types.has(Constants.KickTypes.CROSS_BALL):
						# 				fire_press_power = Utils.get_randon_kick_power(0.3, 0.1)

						# 			elif ai_kick_types.has(Constants.KickTypes.LONG_BALL):
						# 				fire_press_power = Utils.get_randon_kick_power(0.35, 0.1)

						# 			elif ai_kick_types.has(Constants.KickTypes.PASS_OUT_WIDE):
						# 				fire_press_power = Utils.get_randon_kick_power(0.2, 0.1)
									
						# 			else:
						# 				fire_press_power = Utils.get_randon_kick_power(0.1, 0.1)

						# 			owner.kick_ball(fire_press_power)
									
						# 			owner.emit_signal("ai_kick", owner, ai_kick_types)

						# 			# ai_kick_intent = null
						# 			ai_kick_types = []
						# 			ai_kick_direction = null
							
						# 		# reset pass timer
						# 		randomise_ai_kick_timer()

						# # keep on runnin'
						# else: #if owner.can_move():
							
						# 	# match_node.set_selected_player(closest_opponent)

						# 	if ai_change_direction_timer <= 0:
								
						# 		var is_passed_opponent = (shooting_direction == Vector2.UP and owner.position.y <= closest_opponent.position.y) or (shooting_direction == Vector2.DOWN and owner.position.y >= closest_opponent.position.y)
						# 		var opponent_is_close = distance_to_closest_opponent < 30
						# 		var is_on_wing_and_closest_opponent_inside = (ball.is_on_left_flank() and (closest_opponent.position.x > owner.position.x)) or (ball.is_on_right_flank() and (closest_opponent.position.x < owner.position.x))
								
						# 		if is_passed_opponent or is_on_wing_and_closest_opponent_inside:
						# 			ai_run_direction = shooting_direction
									
						# 		else:
									
						# 			# calculate a diagonal avoid direction depending on where the opponent is
						# 			ai_run_direction = Vector2(1,1).normalized()
						# 			if shooting_direction == Vector2.UP:
						# 				ai_run_direction.y *= -1
						# 			if closest_opponent.position.x > owner.position.x:
						# 				ai_run_direction.x *= -1

						# 		ai_change_direction_timer = 0.3 + (randf() * 0.2) # between 0.3 and 0.5

						# 	else:
						# 		ai_change_direction_timer -= delta
						
						# 	# owner.run_toward(ai_run_direction, delta)
						# 	owner.set_direction(ai_run_direction)
						# 	var player_acceleration = owner.calculated_acceleration(Constants.SKIPPY_PLAYER_RUN_DIVISOR)
						# 	var player_speed = owner.get_player_speed()
						# 	owner.velocity = owner.velocity.move_toward(owner.direction * player_speed, player_acceleration * delta)
							
						# 	if is_in_attacking_third or is_in_crossing_zone:
						# 		ai_kick_timer = min(0.2, ai_kick_timer)

						# 	ai_kick_timer -= delta


					# run target set?
					elif owner.run_target != null:

							# we use this if we need to do cmoparisons with e.g. ball and run_target
						var run_target_is_object = typeof(owner.run_target) != TYPE_VECTOR2
						var run_target_is_ball = run_target_is_object and owner.run_target.name == "Ball"
						var run_target_is_player_position = run_target_is_object and owner.run_target == owner.player_position

						var run_target_position = owner.run_target

						# support for a target with a position property, or simply a position
						if typeof(run_target_position) != TYPE_VECTOR2:
							run_target_position = owner.run_target.position


						# .. from here on, we expect run_target to be a Vector2 position ..

						var direction_to_target = owner.position.direction_to(run_target_position)
						var distance_to_target = owner.position.distance_to(run_target_position) # (run_target_position - owner.position).length()
						
						var run_target_precision = owner.run_target_precision
						if run_target_precision == null:
							run_target_precision = 5

						# If we don't set a roughly thereabouts threshold then the player will try to be exactly on the mark
						if distance_to_target > run_target_precision:
							
							# TODO 
							var player_acceleration = owner.data.acceleration # owner.calculated_acceleration(skip_process_divisor)
							var player_speed = owner.data.speed # owner.calculated_speed()

							owner.set_direction(direction_to_target)
							
							owner.velocity = owner.velocity.move_toward(direction_to_target * player_speed, player_acceleration * delta)
						
						else:

							owner.apply_friction(delta)

							owner.is_running_to_target = false

							# if ball is the target, and pip is null, then set pip as this player 
							# sometimes pip doesn't assign when the player stops short(?)
							if run_target_is_ball and !owner.is_moving():
								var ball = owner.run_target
								if ball.player_in_possession == null:
									var is_close_to_ball = owner.position.distance_to(ball.position) < 5
									if is_close_to_ball:
										ball.set_player_in_possession(owner)

							owner.set_idle()

					else:
						
						owner.apply_friction(delta)
						
						owner.set_idle()

				# regardless of means of movement (user controls or ai), we'll set the animation
				if owner.velocity != Vector2.ZERO:
					owner.set_animation("Run")
				else:
					owner.set_animation("Idle")

			# can be used for replays and highlights too
			else:

				# interpolate user
				if owner.interpolate_to_position and owner.interpolate_weight < 1:
					if owner.interpolate_to_position != owner.position:
						owner.interpolate_weight += delta * 2
						owner.position = owner.position.linear_interpolate(owner.interpolate_to_position, owner.interpolate_weight)
