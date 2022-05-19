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
						pass


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
