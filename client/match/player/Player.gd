extends KinematicBody2D

onready var animation_tree = $AnimationTree
onready var playback = animation_tree.get("parameters/playback")
onready var cursor = $Cursor

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

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
var is_pip := false

func _ready():
	animation_tree.active = true

func _physics_process(delta: float):
	_set_direction()
	_set_velocity(delta)

	# show cursor
	cursor.visible = is_selected

	# animation
	if velocity != Vector2.ZERO:
		playback.travel("Run")
	else:
		playback.travel("Idle")

	velocity = move_and_slide(velocity, Vector2.ZERO)

## 
func _set_direction():

	var new_direction := direction

	# if player is selected, determine direction from user controls
	if is_selected:
		new_direction = _get_input_vector()

	# if the players direction has changed, send update to the server 
	if new_direction != direction and new_direction != Vector2.ZERO:

		# update animation tree states
		animation_tree.set("parameters/Run/blend_position", new_direction)
		animation_tree.set("parameters/Idle/blend_position", new_direction)
		animation_tree.set("parameters/Tackle/blend_position", new_direction)
		animation_tree.set("parameters/ThrowIn/blend_position", new_direction)
		animation_tree.set("parameters/GoalieKickOut/blend_position", new_direction)
		animation_tree.set("parameters/SetPiece/blend_position", new_direction)
		animation_tree.set("parameters/ShowFlag/blend_position", new_direction)
		
		# send new direction update to other clients
		print("new_direction: ", new_direction)
		ServerConnection.send_direction_update(name, new_direction)
		
		direction = new_direction

## 
func _set_velocity(delta):

	var new_velocity := velocity
	
	# if selected player, move by controller
	if is_selected:
		if _get_input_vector() != Vector2.ZERO:
			new_velocity = velocity.move_toward(direction * data.speed, data.acceleration * delta)
		else:
			new_velocity = velocity.move_toward(Vector2.ZERO, player_friction * delta)

	# ai, same team (opp team will be managed from the server)
	else:
		pass

	# if the players velocity has changed, send update to the server 
	if new_velocity != velocity:
		
		# # send new velocity update to other clients
		# ServerConnection.send_velocity_update(name, new_velocity)
		
		velocity = new_velocity

## 
func _get_input_vector():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
