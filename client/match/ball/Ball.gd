extends KinematicBody2D

var velocity := Vector2.ZERO

var player_in_possession

var is_on_pitch := true

# TODO need to calculate destination 
func get_destination(delta):
	return position

func is_moving():
	return velocity.length() > Constants.VELOCITY_IDLE_THRESHOLD

## The goalie cannot catch it if it's traveling too fast 
## @return bool
func is_too_fast_to_catch():

	# # if this option is turned off, then this'll return false as in they can take the ball
	# if !Constants.ALLOW_BOUNCEABLE_PLAYERS:
	# 	return false

	# speed until ball cannot be held, defaults
	var catch_threshold = 60

	return velocity.length() > catch_threshold
