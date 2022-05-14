extends Human

onready var cursor = $Cursor

export var is_goalie := false

const MAX_SPEED = 40
const MAX_ACCELERATION = 450

var data = {
	"acceleration": MAX_ACCELERATION * 0.7,
	"speed": MAX_SPEED * 0.7,
}

# whether the player is under the user's control 
var is_selected := false

# player in possession, set from match 
var is_in_possession := false

# 
export var is_home_team := false
export var number := 1

var is_client_user := true

var is_sent_off = false

# This is the natural position that the player ought to be e.g. left back, is set with set_player_position
var player_position

func _ready():
	animation_tree.active = true

func _physics_process(delta: float):

	# timer for sending updats to the server 
	if is_client_user:
		if _send_update_timer <= 0:
			_send_state_update()
			_send_update_timer = _send_update_timer_initial
		else:
			_send_update_timer -= delta

	
	# handle interpolate when set 
	if is_client_user:

		if is_selected:
			if _get_input_vector() != Vector2.ZERO:
				velocity = velocity.move_toward(direction * data.speed, data.acceleration * delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, player_friction * delta)

		# ai, same team (opp team will be managed from the server)
		else:
			pass

		# if player is selected, determine direction from user controls
		var new_direction := direction
		if is_selected:
			new_direction = _get_input_vector()
		
		set_direction(new_direction)
		
		# show cursor
		cursor.visible = is_selected 

		if velocity != Vector2.ZERO:
			set_animation("Run")
		else:
			set_animation("Idle")

	# can be used for replays and highlights too
	else:

		# interpolate user
		if interpolate_to_position and interpolate_weight < 1:
			if interpolate_to_position != position:
				interpolate_weight += delta * 2
				position = position.linear_interpolate(interpolate_to_position, interpolate_weight)

	# 
	velocity = move_and_slide(velocity, Vector2.ZERO)

## Return Home or Away depending on value of _is_home_team
func get_home_or_away():
	if is_home_team:
		return "Home"
	else:
		return "Away"

## Will set player position
func set_player_position(value):
	player_position = value

## Is player sent off, is player injured etc. Thus cannot continue to play.
## @param {Player} player 
func is_playable():
	
	if is_sent_off:
		return false

	return true

func is_goalie():
	return is_goalie

## 
func _get_input_vector():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
