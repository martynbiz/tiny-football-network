extends BaseState
class_name PlayerBaseState

func face_the_ball():
	var match_node = owner.get_match_node()
	var match_state = match_node.get_current_state()
	
	# we'll not face the ball when it's half time, or player is sent off
	if owner.is_in_group("players"):
		if owner.is_sent_off or match_state.name == "EndHalf":
			return

	var direction_to_ball = owner.position.direction_to(match_node.ball.position)
	owner.set_direction(direction_to_ball)

func clamp_direction(dir, force_up_or_down = null):
	return Utils.clamp_direction(dir, force_up_or_down)
