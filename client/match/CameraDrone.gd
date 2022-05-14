extends Position2D

# const Utils = preload("res://Utils.gd")

var target

var velocity = Vector2.ZERO

func _physics_process(delta):
	var target_position = get_target_position()
#	var target_position = owner.get_pitch_center_position()
	if target_position:
		position = target_position

func get_target_position():
	var target_position
	if target:
		target_position = target
		if typeof(target_position) != TYPE_VECTOR2:
			target_position = target.position
	return target_position

func set_target(target):
	self.target = target
