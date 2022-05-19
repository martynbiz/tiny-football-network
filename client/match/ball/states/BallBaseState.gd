extends BaseState
class_name BallBaseState

var ball_height_motion = Vector2.ZERO

onready var ball = owner.get_node("Ball")
onready var collision_shape = owner.get_node("CollisionShape2D")
