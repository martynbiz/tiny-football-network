extends KinematicBody2D
class_name Human

signal send_direction_update(player, new_direction)
signal send_player_state_update(player, position, current_animation)

onready var animation_tree = $AnimationTree
onready var playback = animation_tree.get("parameters/playback")
onready var state_machine = $StateMachine

var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var input_vector := Vector2.ZERO

onready var collision_shape = $CollisionShape2D

# set from match
var player_friction := 500

var current_animation

var last_state_update

var _send_update_timer_initial := 0.05
var _send_update_timer := _send_update_timer_initial

# this is for guessing where the opponent will be between ticks
var interpolate_to_position
var interpolate_weight := 0.0

func set_animation(name):
	playback.travel(name)
	current_animation = name

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
func _send_player_state_update():
	var animation_name = playback.get_current_node()
	emit_signal("send_player_state_update", self, position, animation_name)

## 
func _send_direction_update():
	emit_signal("send_direction_update", self, direction)

func apply_friction(delta):
	velocity = velocity.move_toward(Vector2.ZERO, owner.player_friction * delta)

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
