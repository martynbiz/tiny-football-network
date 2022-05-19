extends BallBaseState

func physics_process(delta):
	
	# start to slow the ball as soon as it's kicked 
	owner.apply_friction(delta)
	
	# animation 
	if owner.is_moving():
		owner.playback.travel("Move")
	else:
		owner.playback.travel("Idle")

