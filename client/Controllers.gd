extends Node

enum ControllerTypes {
	GAMEPAD,
	KEYS
}

var kick_press_duration = 0

var fire_press_power = 0

var user_controllers = [null, null]

# other scripts can check this value to know whether fire was a double tap e.g. lob
# TODO we might need to have Home|Away stores for this? Currently it only applied to pip so might be OK(?)
var is_double_tap = false

# variables for detecting double tap
var dt_timeframe_timer = 0
var dt_is_first_tap = true
var dt_prev_tap_kick_press_duration

## We can do this when pip is assigned so that we don't 
func reset_controller(is_home_team):
	is_double_tap = false
	dt_timeframe_timer = 0
	dt_is_first_tap = true
	dt_prev_tap_kick_press_duration

	kick_press_duration = 0

func set_user_controllers(user_controllers):
	self.user_controllers = user_controllers

## Will get the controller (e.g. KEYS) from the controller for that team 
## @param {bool} is_home_team
## @return {Controllers}
func get_team_controller(is_home_team):
	var controller
	if is_home_team:
		controller = user_controllers[0]
	else:
		controller = user_controllers[1]
	return controller

## Will get the input_vector from the controller for that team 
## @param {bool} is_home_team
## @return {Vector2.normalised}
func get_user_input_vector(is_home_team):
	var controller = get_team_controller(is_home_team)
	var input_vector = Vector2.ZERO
	if controller == ControllerTypes.KEYS:
		input_vector.x = Input.get_action_strength("ui_right_keys") - Input.get_action_strength("ui_left_keys")
		input_vector.y = Input.get_action_strength("ui_down_keys") - Input.get_action_strength("ui_up_keys")
	elif controller == ControllerTypes.GAMEPAD:
		input_vector.x = Input.get_action_strength("ui_right_gamepad") - Input.get_action_strength("ui_left_gamepad")
		input_vector.y = Input.get_action_strength("ui_down_gamepad") - Input.get_action_strength("ui_up_gamepad")
	
	return input_vector.normalized()

## Fire button either gamepad or keys
## @param {bool} is_home_team
## @return {bool}
func is_menu_button_pressed(is_home_team):	
	var controller = get_team_controller(is_home_team)
	if controller == ControllerTypes.KEYS:
		return Input.is_action_pressed("menu_keys")
	elif controller == ControllerTypes.GAMEPAD:
		return Input.is_action_pressed("menu_gamepad")

## Fire button either gamepad or keys
## @param {bool} is_home_team
## @return {bool}
func is_fire_button_pressed(is_home_team):	
	var controller = get_team_controller(is_home_team)
	if controller == ControllerTypes.KEYS:
		return Input.is_action_pressed("fire_keys")
	elif controller == ControllerTypes.GAMEPAD:
		return Input.is_action_pressed("fire_gamepad")

## Fire button either gamepad or keys
## @param {bool} is_home_team
## @return {bool}
func is_fire_button_just_pressed(is_home_team):
	var controller = get_team_controller(is_home_team)
	if controller == ControllerTypes.KEYS:
		return Input.is_action_just_pressed("fire_keys")
	elif controller == ControllerTypes.GAMEPAD:
		return Input.is_action_just_pressed("fire_gamepad")

## Fire button either gamepad or keys
## @param {bool} is_home_team
## @return {bool}
func is_fire_button_just_released(is_home_team):
	var controller = get_team_controller(is_home_team)
	if controller == ControllerTypes.KEYS:
		return Input.is_action_just_released("fire_keys")
	elif controller == ControllerTypes.GAMEPAD:
		return Input.is_action_just_released("fire_gamepad")


## 
func get_fire_press_power(is_home_team, detect_double_tap, delta):
	
	# we either have disabled double tap, or it isn't required for this request
	if Constants.ALLOW_DOUBLE_TAP_FIRE and detect_double_tap:
		
		if is_fire_button_just_released(is_home_team) or kick_press_duration > Constants.KICK_PRESS_DURATION_MAX:
			var return_value = min(kick_press_duration, Constants.KICK_PRESS_DURATION_MAX)

			# determine whether this is a tap
			var is_fire_button_tap = (return_value < 0.15)

			# if the fire button has been tapped and is first tap, no return.. yet
			if is_fire_button_tap and dt_is_first_tap:
				dt_timeframe_timer = 0.15
				dt_prev_tap_kick_press_duration = return_value
				kick_press_duration = 0
				dt_is_first_tap = false

			# if we are looking our for a second tap and it's within the timeframe
			elif !dt_is_first_tap and dt_timeframe_timer > 0:
				is_double_tap = true
				dt_timeframe_timer = 0
				kick_press_duration = 0
				dt_is_first_tap = true
				return return_value

			# all other cases
			else:
				dt_timeframe_timer = 0
				is_double_tap = false
				kick_press_duration = 0
				dt_is_first_tap = true
				return return_value

		elif is_fire_button_pressed(is_home_team):
			kick_press_duration += delta

		elif dt_timeframe_timer > 0:
			dt_timeframe_timer -= delta 
			if dt_timeframe_timer <= 0:

				# check if it's double tap but the timer has run out 
				if !dt_is_first_tap and dt_prev_tap_kick_press_duration > 0:
					var return_value = min(dt_prev_tap_kick_press_duration, Constants.KICK_PRESS_DURATION_MAX)
					dt_is_first_tap = true
					is_double_tap = false
					kick_press_duration = 0
					return return_value
				
				dt_timeframe_timer = 0

	# single tap only 
	else:

		if is_fire_button_just_released(is_home_team) or kick_press_duration > Constants.KICK_PRESS_DURATION_MAX:
			var return_value = min(kick_press_duration, Constants.KICK_PRESS_DURATION_MAX)
			kick_press_duration = 0
			return return_value
		elif is_fire_button_pressed(is_home_team):
			kick_press_duration += delta
