extends Node
class_name BaseState

var state_machine: StateMachine

var stage

var timer = 0

func start_timer(seconds):
	timer = seconds

func update_timer(delta):
	timer -= delta

func timer_is_stopped():
	return timer <= 0
