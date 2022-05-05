extends Node

## Can create timers that run down to zero then are reset
## Usage:
##   Timers.create_timer("CalculatePlayersRunningToRunTargets", 0.5)
##   ..
##   if Timers.is_timer_stopped("CalculatePlayersRunningToRunTargets")

# so we don't have to deal with floats
const PRECISION_MAGNITUDE = 1000 # 0.016 .. 16

var timers = {}

func _physics_process(delta):
    for key in timers.keys():

        # if the timer is zero then it's been zero for one frame so we can 
        # restore it to start_seconds
        if timers[key].current_time <= 0:
            if timers[key].auto_reset:
                timers[key].current_time = timers[key].start_seconds

        elif timers[key].current_time > 0:

            timers[key].current_time -= int(delta * PRECISION_MAGNITUDE)
            if timers[key].current_time < 0:
                timers[key].current_time = 0

func create_timer(name, start_seconds, auto_reset = false):
	timers[name] = {
		"current_time": int(start_seconds * PRECISION_MAGNITUDE),
		"start_seconds": int(start_seconds * PRECISION_MAGNITUDE),
        "auto_reset": auto_reset,
	}

func is_timer_stopped(name):
	return timers[name].current_time <= 0