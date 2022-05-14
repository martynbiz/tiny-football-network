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
					if owner.get_input_vector() != Vector2.ZERO:
						owner.velocity = owner.velocity.move_toward(
							owner.direction * owner.data.speed, 
							owner.data.acceleration * delta
						)
					else:
						owner.velocity = owner.velocity.move_toward(Vector2.ZERO, owner.player_friction * delta)

				# ai, same team (opp team will be managed from the server)
				else:
					pass

				# if player is selected, determine direction from user controls
				var new_direction = owner.direction
				if owner.is_selected:
					new_direction = owner.get_input_vector()
				
				owner.set_direction(new_direction)

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
