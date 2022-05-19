extends KinematicBody2D

signal set_player_in_possession(player)
signal unset_player_in_possession()
# signal kick(player_in_possession, is_shot)
# signal bounce(collider)
# signal player_is_offside(player)
signal floor_bounce(ball)

onready var state_machine = $StateMachine
onready var ball_ball = $Ball
onready var collision_shape = $CollisionShape2D
onready var animation_player = get_node("AnimationPlayer")
onready var animation_tree = get_node("AnimationTree")
onready var playback = animation_tree.get("parameters/playback")

var last_players_in_possession := []

var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var ball_height_motion = Vector2.ZERO

var player_in_possession

var team_in_possession

var ball_friction := 0

var is_collectable = true 

var is_on_pitch := true

var kick_types := []

var kick_height := 0

var kick_height_floor := 0

func _ready():
	animation_tree.active = true

func _physics_process(delta):

	# 
	if Constants.ALLOW_BALL_BOUNCE:
		apply_bounce_effect(delta)

	# reset all cache items on every frame so that we can lazy load them

	# # closest players
	# for cache_id in ["Home", "HomeOutfield", "Away", "AwayOutfield", "All", "AllOutfield"]:
	# 	closest_player_to_ball[cache_id] = null

	# # we'll be caching destination
	# destination = null

	# null tip when stopped 
	if !player_in_possession and velocity == Vector2.ZERO:
		team_in_possession = null

	# # update possession stats 
	# if team_in_possession:
	# 	if team_in_possession == "Home":
	# 		owner.match_stats.possession[0] += delta 
	# 	else:
	# 		owner.match_stats.possession[1] += delta 

	# # 
	# if Constants.ALLOW_BALL_BOUNCE:
	# 	apply_bounce_effect(delta)
	
	var collision = move_and_collide(velocity * delta)

	# if collision:
	# 	var collider = collision.collider
		
	# 	if collider.is_in_group("bounceable"):

	# 		if collider.is_in_group("players"):

	# 			# this will ensure that correct decisions for out of play is given 
	# 			last_players_in_possession.push_front(collider)
				
	# 			# the goalie should make a save if diving, or the ball ought to bounce of players 
	# 			if collider.is_goalie() and collider.is_goalie_diving():
	# 				apply_bounce_goalie_dive(collider, collision)
	# 			elif is_too_fast_to_catch():
	# 				apply_bounce_player(collider, collision)

	# 		else:
	# 			velocity = velocity.bounce(collision.normal)

	# 	emit_signal("bounce", collider)

	# set pip cursor depending on where the ball is 
	if player_in_possession and player_in_possession.is_same_team_as_user:
		player_in_possession.set_cursor(Constants.CursorTypes.NORMAL_PLAY)
		# if is_throw_in:
		# 	player_in_possession.set_cursor(Constants.CursorTypes.NORMAL_PLAY)
		# elif is_in_crossing_zone:
		# 	player_in_possession.set_cursor(Constants.CursorTypes.CROSSING_RANGE)
		# elif is_in_attacking_third:
		# 	player_in_possession.set_cursor(Constants.CursorTypes.SHOOTING_RANGE)
		# else:
		# 	player_in_possession.set_cursor(Constants.CursorTypes.NORMAL_PLAY)

func apply_bounce_effect(delta):

	if kick_height > 0:
		if ball_ball.position.y >= kick_height_floor: # is on ground/head
			
			# jump
			ball_height_motion.y -= kick_height

			# calculate the next bounce, eventually zero 
			kick_height = int(floor(kick_height * Constants.BOUNCE_BACK_RATIO))

			# reset this to zero 
			kick_height_floor = 0

			# emit a signal to say that the ball has hit the ground
			emit_signal("floor_bounce", self)
		
		else: # is in air 

			# fall 
			ball_height_motion.y += Constants.BOUNCE_GRAVITY

		ball_height_motion = ball_ball.move_and_slide(ball_height_motion)

	# this ensures the ball doesn't go below the floor
	if ball_ball.position.y > 0:
		ball_ball.position.y = 0
		ball_height_motion = Vector2.ZERO

	# disable collision if ball too high 
	if is_on_pitch:
		collision_shape.disabled = ball_ball.position.y < Constants.BOUNCE_HEIGHT_THRESHOLD

## Used to kick the ball, fairly dumb function - takes a power and direction and executes it.
## Plays no role in deciding whether it's a pass, shot etc
## @param {float} power Between 0.1 and 0.5 is sensible
## @param {Vector2.normalised} ball_direction
func kick(fire_press_power, ball_direction):

	# throw in and goalie kicks hide the ball
	visible = true
	
	# we occassionally have a bug where pip isn't assigned, let's just ensure that 
	# never occurs and play continues if so - should really figure it out 
	if !player_in_possession:
		return 

	# convert fire_press_power to kick_power 
	var kick_power = fire_press_power * Constants.KICK_MAX_POWER

	# # 
	# var is_fire_button_tap = kick_power < Constants.KICK_POWER_BUTTON_TAP_THRESHOLD

	# # shot is determined by power and facing goal, etc
	# var is_facing_goal = player_in_possession.is_facing(player_in_possession.get_opposition_goal_center_position(), 0)
	# var is_in_shooting_zone = is_in_shooting_zone()
	# var is_shot = is_facing_goal and is_in_shooting_zone
	
	# # this is calculate from how hard they kick, hard the kick the more potatial fuzziness
	# var fuzziness_level = int(round(fire_press_power * 10))

	# # this will be given a value based on kick type (e.g. pass), relevant skill level and fuzziness_level applied
	# var skill_level_fuzziness

	# # this is during normal play, freekick, penalty etc
	# if Constants.ALLOW_SHOT_AUTO_DIRECTION_AND_POWER and is_shot:

	# 	if Constants.ALLOW_SKILL_LEVEL_FUZZINESS:
	# 		skill_level_fuzziness = Utils.get_skill_level_fuzziness(player_in_possession.shooting, fuzziness_level)

	# 	# if the player is facing head on, then we'll just randomly choose a side 
	# 	var input_x = player_in_possession.direction.x
	# 	if input_x == 0:
	# 		input_x = Utils.get_random_pos_neg()

	# 	ball_direction = player_in_possession.get_goal_direction(false, input_x , false) #, skill_level_fuzziness)

	# 	if Constants.ALLOW_LOB_SHOTS:

	# 		# check easy/cached flags first
	# 		# var is_in_penalty_area = (is_in_top_penalty_area or is_in_bottom_penalty_area)
	# 		var is_overhead_kicking = player_in_possession.is_overhead_kicking()
	# 		var is_in_goal_area = (is_in_top_goal_area or is_in_bottom_goal_area)
	# 		if !is_penalty and !is_overhead_kicking and !is_in_goal_area: # and is_in_penalty_area

	# 			# randomize()
				
	# 			# determine whether this is a lob attempt: random for the ai/ shooting ability, double tap for user if in shooting zone 
	# 			var is_lob_attempt
	# 			if player_in_possession.is_same_team_as_user():
	# 				is_lob_attempt = Controllers.is_double_tap and is_in_shooting_zone()
	# 			elif player_in_possession.shooting > 80:
	# 				var opposition_goalie = player_in_possession.get_opposition_goalie()
	# 				var is_random_true = (randi() % 6) > 3
	# 				is_lob_attempt = (is_random_true and opposition_goalie.is_goalie_running_out)

	# 			if is_lob_attempt:

	# 				# this is just the right kick height for a lob, but skill level will factor in
	# 				var lob_optimal_kick_height = 80

	# 				# depending on the skill level of the player, they may fault the kick_height
	# 				var shooting_error_margin = (100 - player_in_possession.shooting)
	# 				var kick_height = max(70, (lob_optimal_kick_height - (randi() % shooting_error_margin))) # min(100 + ((randi() % shooting_error_margin) * 2), 130) # ,max
					
	# 				# as we're trying to lob the keeper, we should set the direction to the goal center
	# 				var goal_center_position = player_in_possession.get_opposition_goal_center_position()
	# 				ball_direction = position.direction_to(goal_center_position)

	# 				set_kick_height(kick_height)
	# 				kick_types.append(Constants.KickTypes.LOB)

	# 				# it actually makes it easier to score when there is fizziness, so will try removing it for lobs
	# 				skill_level_fuzziness = 0

	# 	# # calculate distance to goal so we can adjust power accordinly 
	# 	# if !is_penalty and !is_first_touch:
	# 	# 	var goal_center_position = player_in_possession.get_opposition_goal_center_position()
	# 	# 	var distance_to_goal = position.distance_to(goal_center_position)

	# 	kick_types.append(Constants.KickTypes.SHOT_ATTEMPT)

	# # normal play and corners
	# elif Constants.ALLOW_CROSS_AUTO_DIRECTION_AND_POWER and is_in_crossing_zone and !is_throw_in:

	# 	if Constants.ALLOW_SKILL_LEVEL_FUZZINESS:
	# 		skill_level_fuzziness = Utils.get_skill_level_fuzziness(player_in_possession.passing, fuzziness_level)

	# 	var cross_direction
	# 	if is_on_left_flank:
	# 		cross_direction = Vector2.RIGHT
	# 	if is_on_right_flank:
	# 		cross_direction = Vector2.LEFT
	# 	var closest_player = get_closest_player_in_view(player_in_possession.get_home_or_away(), cross_direction)
		
	# 	var cross_to_position = player_in_possession.get_opposition_goal_center_position() + (player_in_possession.get_shooting_direction() * -20) - velocity
		
	# 	ball_direction = player_in_possession.position.direction_to(cross_to_position)

	# 	# have a minimum so that crosses are never weak passes
	# 	# var random_kick_power = (randf() * 0.1) + 0.35
	# 	kick_power = max(kick_power, 0.4 * Constants.KICK_MAX_POWER)
		
	# 	# kick_intent = KickIntents.CROSSING
	# 	kick_types.append(Constants.KickTypes.CROSS_BALL)

	# # normal play passing 
	# elif Constants.ALLOW_PASS_AUTO_DIRECTION_AND_POWER and is_fire_button_tap:

	# 	if Constants.ALLOW_SKILL_LEVEL_FUZZINESS:
	# 		skill_level_fuzziness = Utils.get_skill_level_fuzziness(player_in_possession.passing, fuzziness_level)

	# 	# if not facing shooting direction otherwise we'll do a through ball
	# 	if !Constants.ALLOW_PASS_AUTO_DIRECTION_AND_POWER_UP_ONLY or (Constants.ALLOW_PASS_AUTO_DIRECTION_AND_POWER_UP_ONLY and !player_in_possession.is_facing_shooting_direction()): # or !is_in_attacking_third:

	# 		var home_or_away = player_in_possession.get_home_or_away()
	# 		var closest_player = get_closest_player_in_view(home_or_away, player_in_possession.direction)
	# 		var opposition_goal_center = player_in_possession.get_opposition_goal_center_position()
			
	# 		kick_types.append(Constants.KickTypes.PASS_BALL)

	# 		if closest_player:
	# 			var closest_player_position = closest_player.position
				
	# 			ball_direction = player_in_possession.position.direction_to(closest_player_position)
				
	# 			# this is just to adjust kick power so that a short pass is a short pass etc
	# 			var distance_to_closest_player = player_in_possession.position.distance_to(closest_player_position)
	# 			kick_power = distance_to_closest_player * 1.2
	
	# else:
		
	# 	# default if true
	# 	if Constants.ALLOW_SKILL_LEVEL_FUZZINESS:
	# 		skill_level_fuzziness = Utils.get_skill_level_fuzziness(player_in_possession.passing, fuzziness_level)
	
	kick_power = clamp(kick_power, Constants.KICK_MIN_POWER, Constants.KICK_MAX_POWER)

	# # apply fuzziness to kicks so that we don't always kick on target if skill level is lower 
	# if skill_level_fuzziness:
	# 	var rotated_by = skill_level_fuzziness * Constants.DEGREE_AS_RADIANS
	# 	ball_direction = ball_direction.rotated(rotated_by)
	
	# override for a throw in
	if false: #is_throw_in:

		pass
		
		# var throw_direction = player_in_possession.direction # ball_direction
		# velocity = throw_direction * (0.25 * Constants.KICK_MAX_POWER)

		# # start the ball in the air, held over head
		# ball_ball.position.y -= 6
		
		# # init kick height and jump 
		# set_kick_height(50)

	else:

		# velocity plus ball_direction 
		velocity += ball_direction * kick_power
		
		# calculate kick_height based on power, reset ball_height_motion
		ball_height_motion = Vector2.ZERO

		# apply kick height if not already given
		if kick_height <= 0:
			kick_height = pow((kick_power / 10), 1.65)

	# # this will also enable players to move after a kick (e.g. free kick) sending into normalplay 
	# emit_signal("kick", player_in_possession, is_shot)

	# need to put this after the emit signal, as we might need player in possession
	unset_player_in_possession()

	# is_first_touch = false

# TODO need to calculate destination 
func get_destination(delta):
	return position

	# if destination != null:
	# 	return destination
	
	# # var match_node = get_match_node()
	# var temp_velocity = velocity
	# var temp_pos = position
	# var temp_destination = temp_pos
	# var i = 0
	# while temp_velocity.length() > Constants.DESTINATION_SLOW_THRESHOLD:

	# 	temp_velocity = temp_velocity.move_toward(Vector2.ZERO, ball_friction * delta)
	# 	temp_pos += temp_velocity * delta
	# 	i += 1

	# 	if !is_position_on_pitch(temp_pos): # and keep_within_pitch
	# 		break

	# 	# knowing that this pos is still on the pitch, set it to temp_destination 
	# 	temp_destination = temp_pos

	# # cache the result 
	# destination = temp_destination
	
	# # if crossing then set destination to slightly higher than ground level
	# if Constants.ALLOW_ADJUST_BALL_DESTINATION_FOR_CROSSES:
	# 	if is_crossing():
	# 		destination -= get_direction() * 30

	# return destination

func is_moving():
	return velocity.length() > Constants.VELOCITY_IDLE_THRESHOLD

## The goalie cannot catch it if it's traveling too fast 
## @return bool
func is_too_fast_to_catch():

	# # if this option is turned off, then this'll return false as in they can take the ball
	# if !Constants.ALLOW_BOUNCEABLE_PLAYERS:
	# 	return false

	# speed until ball cannot be held, defaults
	var catch_threshold = 60

	return velocity.length() > catch_threshold

func apply_friction(delta):
	velocity = velocity.move_toward(Vector2.ZERO, ball_friction * delta)

func set_disabled(disabled = true):
	if disabled:
		unset_player_in_possession()
		collision_shape.disabled = true
		is_collectable = false 
	else:
		collision_shape.disabled = false
		is_collectable = true 

func set_player_in_possession(player):

	# remove types.. is_collectable needed?
	kick_types = []

	if player == null:
		player_in_possession = null
		direction = Vector2.ZERO
		state_machine.change_to("Idle")
	elif is_collectable:

		#
		Controllers.reset_controller(player.is_home_team)

		if !player.is_playable():
			return
		
		# this prevents those from simply entering the area and taking the ball if already in possession
		# checking exit_position ensure that the ball hasn't gone out of play 
		if player_in_possession == null:
			player_in_possession = player

			# # if ball is run target, remove it
			# player.run_to(null)

			# if Constants.ALLOW_MATCH_FITNESS:
			# 	if player_in_possession.is_same_team_as_user():
			# 		player.set_match_fitness_progress_bar_visible(true)

		# # check if this player is offside 
		# if Options.get_option("offsides_enabled") and player.is_offside:
		# 	emit_signal("player_is_offside", player)

		# set team in possession, will remain until ball stops
		team_in_possession = player.get_home_or_away()
		
		# change ball state 
		state_machine.change_to("Dribble")

	# ground the ball
	kick_height = 0
	ball_ball.position.y = 0

	emit_signal("set_player_in_possession", player)

func get_last_player_in_possession(home_or_away = null, include_goalie = true):
	for player in last_players_in_possession:
		
		# skip goalies?
		if !include_goalie and player.is_goalie():
			continue
		
		if player.get_home_or_away() == home_or_away or home_or_away == null:
			return player

func unset_player_in_possession():	
	if player_in_possession:
		last_players_in_possession.push_front(player_in_possession)
#		player_in_possession.set_match_fitness_progress_bar_visible(false)
	last_players_in_possession = last_players_in_possession.slice(0,10)
	player_in_possession = null
	direction = Vector2.ZERO
	state_machine.change_to("Idle")
			
#	# this should reset when kicked, and unset between states
#	reset_first_touch()

	emit_signal("unset_player_in_possession")
