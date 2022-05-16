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
			if owner.is_client_user:

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


				# ai, same team (opp team will be managed from the server?)
				else:
					
					if owner.is_in_possession:
						pass


					elif owner.run_target != null:

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
							
							# match will make the player simply face the ball
							emit_signal("is_idle", owner)

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
