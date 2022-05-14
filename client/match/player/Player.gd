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

onready var goalie_collision_shape = $GoalieCollisionShape2D

# This is the natural position that the player ought to be e.g. left back, is set with set_player_position
var player_position

func _ready():
	animation_tree.active = true

func _physics_process(delta: float):

	# timer for sending updats to the server 
	# TODO just run state???
	if is_client_user:
		if _send_update_timer <= 0:
			_send_state_update()
			_send_update_timer = _send_update_timer_initial
		else:
			_send_update_timer -= delta
	
	# show cursor
	cursor.visible = is_selected 

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

func set_collision_shape_disabled(collision_shape_disabled, goalie_collision_shape_disabled = true):
	collision_shape.disabled = collision_shape_disabled
	goalie_collision_shape.disabled = goalie_collision_shape_disabled

## Is player sent off, is player injured etc. Thus cannot continue to play.
## @param {Player} player 
func is_playable():
	
	if is_sent_off:
		return false

	return true

func is_goalie():
	return is_goalie

## 
func get_input_vector():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
