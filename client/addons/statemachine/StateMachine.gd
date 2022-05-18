extends Node
class_name StateMachine

export var debug = false
export var autostart = true

var state: Object

var history = []

# var schedule_change_to
# var schedule_change_to_time_remain = 0

var active_status = true

func _ready():
	
	# Set the initial state to the first child node
	if autostart:
		state = get_child(0)
		_enter_state()

# # useful if e.g. the ball goes out of play we can schedule that, but if a goal too it will unschedule the outofplay state
# func schedule_change_to(new_state, timeout_seconds, override_existing_schedule = false):
# 	if not override_existing_schedule and schedule_change_to != null:
# 		return
# 	schedule_change_to = new_state
# 	schedule_change_to_time_remain = timeout_seconds

# func unschedule_change_to():
# 	schedule_change_to = null
# 	schedule_change_to_time_remain = 0

func set_active_status(value):
	active_status = value

func change_to(new_state):
	if !state or state.name != new_state:
		# unschedule_change_to()
		if state:
			history.append(state.name)
		state = get_node(new_state)
		_enter_state()

func back():
	if history.size() > 0:
		state = get_node(history.pop_back())
		_enter_state()

func _enter_state():
	if debug:
		print("["+owner.name+"] Entering state: ", state.name)
	# Give the new state a reference to this state machine script
	state.state_machine = self
	if state.has_method("enter"):
		state.enter()

# Route Game Loop function calls to
# current state handler method if it exists
func _process(delta):

	if !state:
		return
	
	if !active_status:
		return
	
	if state.has_method("process"):
		state.process(delta)

func _physics_process(delta):

	if !state:
		return
	
	if !active_status:
		return

	# if schedule_change_to_time_remain > 0:
	# 	schedule_change_to_time_remain -= delta
	
	# if schedule_change_to_time_remain <= 0 and schedule_change_to != null:
	# 	change_to(schedule_change_to)
	# 	schedule_change_to = null
	# 	schedule_change_to_time_remain = 0
	
	if state.has_method("physics_process"):
		state.physics_process(delta)

func _input(event):

	if !state:
		return
	
	if !active_status:
		return
	
	if state.has_method("input"):
		state.input(event)

func _unhandled_input(event):

	if !state:
		return
	
	if !active_status:
		return
	
	if state.has_method("unhandled_input"):
		state.unhandled_input(event)

func _unhandled_key_input(event):

	if !state:
		return
	
	if !active_status:
		return
	
	if state.has_method("unhandled_key_input"):
		state.unhandled_key_input(event)

# func _notification(what):
# 	if state && state.has_method("notification"):
# 		state.notification(what)
