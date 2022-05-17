extends Human

# we'll send this signal to tell match to e.g. make the player face the ball
signal is_idle(player)

onready var cursor = $Cursor

export var is_goalie := false

var is_computer := false

const MAX_SPEED = 60
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

var is_client_app_user_team := true

var is_sent_off = false

onready var goalie_collision_shape = $GoalieCollisionShape2D

# When set, the player will run towards this target e.g. ball, player_position
var run_target
var run_target_precision = null

var is_goalie_running_out := false

# not keen on this, but when we initially set run_to the player velocity is ZERO, so 
# we can't tell if they are movig until the next physics process. This is set immedietely
var is_running_to_target = false

# This is the natural position that the player ought to be e.g. left back, is set with set_player_position
var player_position

func _ready():
	animation_tree.active = true

func _physics_process(delta: float):

	# timer for sending updats to the server 
	# TODO just run state???
	if is_client_app_user_team:
		if _send_update_timer <= 0:
			_send_player_state_update()
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

func is_injured():
	# return data.injured_matches > 0
	return false

func is_goalie():
	return is_goalie

# 
func set_cursor(type = null):

	# simple for now
	cursor.visible = (type != null)
	
	# # hide all by default 
	# cursor_normal_play.visible = false
	# cursor_shooting_range.visible = false
	# cursor_crossing_range.visible = false

	# if !Options.get_option("show_player_cursors"):
	# 	return

	# if !Constants.ALLOW_SHOT_AUTO_DIRECTION_AND_POWER and type == Constants.CursorTypes.SHOOTING_RANGE:
	# 	cursor_normal_play.visible = true
	
	# elif !Constants.ALLOW_CROSS_AUTO_DIRECTION_AND_POWER and type == Constants.CursorTypes.CROSSING_RANGE:
	# 	cursor_normal_play.visible = true
	
	# else:

	# 	# 
	# 	match type:
	# 		Constants.CursorTypes.NORMAL_PLAY:
	# 			cursor_normal_play.visible = true
	# 		Constants.CursorTypes.SHOOTING_RANGE:
	# 			cursor_shooting_range.visible = true
	# 		Constants.CursorTypes.CROSSING_RANGE:
	# 			cursor_crossing_range.visible = true

## 
func get_input_vector():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

func run_to(target, target_precision = 5):

	# players sent off the park cannot return to position/ball etc
	if is_sent_off:
		target = null

	# player in possession shouldn't run anywhere other than with the ball 
	if is_in_possession:
		target = null

	run_target = target
	run_target_precision = target_precision
	is_running_to_target = (target != null)

# match will make the player simply face the ball
func set_idle():
	emit_signal("is_idle", self)


func _on_BallCollectionArea_body_entered(body):
	pass
	
func _on_BallCollectionArea_body_exited(body):
	pass
