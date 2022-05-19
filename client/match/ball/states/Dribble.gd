extends BallBaseState

const DRIBBLE_PLAYER_OFFSET = Vector2(5,5)

func physics_process(delta):
	
	# animation 
	if owner.is_moving():		
		owner.playback.travel("Move")
	else:
		owner.playback.travel("Idle")
	
	if owner.player_in_possession:
		
		owner.direction = owner.player_in_possession.direction
		owner.velocity = owner.player_in_possession.velocity
		
#		# if the ball is in flight, this will bring it to feet
#		if !owner.is_throw_in:
#			owner.position.y = 0
		
		# set the ball offset from the player in any direction 
		owner.position = owner.player_in_possession.position + (owner.direction * DRIBBLE_PLAYER_OFFSET)
