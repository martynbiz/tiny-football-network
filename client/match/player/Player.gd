extends KinematicBody2D

signal send_direction_update(player, new_direction)
signal send_state_update(player, position, current_animation)

onready var animation_tree = $AnimationTree
onready var playback = animation_tree.get("parameters/playback")
onready var cursor = $Cursor

var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var input_vector := Vector2.ZERO

export var is_goalie := false

const MAX_SPEED = 40
const MAX_ACCELERATION = 450

var data = {
	"acceleration": MAX_ACCELERATION * 0.7,
	"speed": MAX_SPEED * 0.7,
}

# set from match
var player_friction := 500

# whether the player is under the user's control 
var is_selected := false

# player in possession, set from match 
var is_in_possession := false

var current_animation

var last_state_update

# 
export var is_home_team := false

var is_client_user := true

var _send_update_timer_initial := 0.05
var _send_update_timer := _send_update_timer_initial

# this is for guessing where the opponent will be between ticks
var interpolate_to_position
var interpolate_weight := 0.0

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

func set_animation(name):
	playback.travel(name)
	current_animation = name

## Return Home or Away depending on value of _is_home_team
func get_home_or_away():
	if is_home_team:
		return "Home"
	else:
		return "Away"

## 
func set_direction(new_direction: Vector2, send_update: bool = true):

	# if the players direction has update, send update to the server 
	if new_direction != direction and new_direction != Vector2.ZERO:

		# update animation tree states
		animation_tree.set("parameters/Run/blend_position", new_direction)
		animation_tree.set("parameters/Idle/blend_position", new_direction)
		animation_tree.set("parameters/Tackle/blend_position", new_direction)
		animation_tree.set("parameters/ThrowIn/blend_position", new_direction)
		animation_tree.set("parameters/GoalieKickOut/blend_position", new_direction)
		animation_tree.set("parameters/SetPiece/blend_position", new_direction)
		animation_tree.set("parameters/ShowFlag/blend_position", new_direction)
		
		direction = new_direction

		if send_update:
			_send_direction_update()

## 
func _get_input_vector():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

## 
func _send_state_update():
	var animation_name = playback.get_current_node()
	emit_signal("send_state_update", self, position, animation_name)

## 
func _send_direction_update():
	emit_signal("send_direction_update", self, direction)

## Will take state data and update the player 
func update_state_from_server(human_state):
	
	# before dir, as we may alter it there too
	if "pos" in human_state:
		var new_position = Vector2(human_state.pos.x, human_state.pos.y)
		interpolate_to_position = new_position # + (new_position - position)
		interpolate_weight = 0

	if "dir" in human_state:
		var new_direction = Vector2(human_state.dir.x, human_state.dir.y)
		set_direction(new_direction, false)

	if "anim" in human_state:
		var new_animation = human_state.anim
		if current_animation != new_animation:
			set_animation(new_animation)

	# we'll use this to ensure we don't update from an old one
	last_state_update = human_state
