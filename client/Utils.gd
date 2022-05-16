extends Node

static func clamp_direction(dir, force_up_or_down = null):
	var degrees = dir.angle() * (180/PI)
	var direction = convert_degrees_to_direction(degrees)

	# if we only want the player to go in the shooting direction 
	if force_up_or_down:
		if (force_up_or_down == Vector2.DOWN and direction.y > 0) or (force_up_or_down == Vector2.UP and direction.y < 0):
			if direction.x < 0:
				direction = Vector2.LEFT 
			else:
				direction = Vector2.RIGHT 

	return direction

static func convert_degrees_to_direction(degrees):
	
	var direction

	var direction_angles = [-135, -90, -45, 0, 45, 90, 135, 180]

	# calculate the closest
	var min_diff = 100000
	var this_diff
	var closest_angle
	for angle in direction_angles:
		this_diff = abs(angle - degrees)
		if this_diff < min_diff:
			min_diff = this_diff
			closest_angle = angle

	# convert
	if closest_angle == -135:
		direction = Vector2(-1, -1).normalized()
	elif closest_angle == -90:
		direction = Vector2.UP
	elif closest_angle == -45:
		direction = Vector2(1, -1).normalized()
	elif closest_angle == 0:
		direction = Vector2.RIGHT
	elif closest_angle == 45:
		direction = Vector2(1, 1).normalized()
	elif closest_angle == 90:
		direction = Vector2.DOWN
	elif closest_angle == 135:
		direction = Vector2(-1, 1).normalized()
	elif closest_angle == 180:
		direction = Vector2.LEFT
	
	return direction

static func get_ancestor_node_by_group_name(current_node, name):
	var parent_node = current_node.get_parent()
	while parent_node and !parent_node.is_in_group(name):
		parent_node = parent_node.get_parent()
	return parent_node

static func get_ancestor_node_by_name(current_node, name):
	var parent_node = current_node.get_parent()
	while parent_node and parent_node.name != name:
		parent_node = parent_node.get_parent()
	return parent_node

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

## This will return a value close to the base, with a random precision
## @param {float} base 
## @param {float} precision Cannot be zero e.g. 0.2 prec on 1 will be between 0.9 and 1.1
## @param {bool} call_randomize Whether we call randomize on every get 
## @return {float}
static func get_randon_kick_power(base, precision): #, call_randomize = false):
	# if call_randomize:
	# 	randomize()
	return (base - (precision / 2)) + (randf() * precision)

static func is_position_within_rect(position, top_left, bottom_right):
	return (position.x >= top_left.x and position.x <= bottom_right.x) and (position.y >= top_left.y and position.y <= bottom_right.y)

## Will return random 1 or -1
static func get_random_pos_neg():
	# randomize()
	var input_x = randi() % 2
	if input_x == 0:
		input_x = -1
	return input_x

static func array_join(arr, glue = ","):
	var text = ""
	for item in arr:
		text += item + glue
	return text.trim_suffix(glue)

static func ellipsis_trim(str_to_trim, max_length, ellipsis = "..."):
	if str_to_trim.length() > max_length:
		return str_to_trim.substr(0, max_length).rstrip(" ") + ellipsis
	return str_to_trim

## Sometimes we require both Home and Away, but other times we'll choose just one
## @param {string} home_or_away
static func get_home_or_away_array(home_or_away = null):
	if home_or_away:
		return [home_or_away]
	else:
		return ["Home", "Away"]

## Will take a <100 int and convert it to decimal then apply it to a value
## e.g. if shooting is 75 and we want to apply it to a value of 10 then: return 0.75 * 10
## @param {int} skill_level e.g. shooting=92
## @param {int|float} value e.g. 10
## @return {float}
static func get_percentage_applied_value(skill_level, value):
	return (float(skill_level) / 100) * value


## This makes shots and passes less accurate for lesser skill levels 
## @param {int} skill_level e.g. Player.shooting
## @param {int} fuzziness_level 
## @param {int} pos_or_neg 1 or -1 Decide how to apply error e.g. apply to wide of goal
static func get_skill_level_fuzziness(skill_level, fuzziness_level = 5, pos_or_neg = null):
	# randomize()

	var skill_level_fuzziness = 0

	if fuzziness_level > 0:

		# set potential error based on skill level 
		skill_level_fuzziness = int(ceil(float(100 - skill_level) / 10)) * fuzziness_level

		# set random value
		skill_level_fuzziness = randi() % skill_level_fuzziness

		# randomize pos and negative 
		if pos_or_neg == null:
			pos_or_neg = get_random_pos_neg()
		skill_level_fuzziness *= pos_or_neg
	
	return skill_level_fuzziness

# Calculate ratio between teams to calculate chance. A ratio above 1 would indicate 
# a home advantage, otherwise an away advantage 
static func get_random_home_or_away(home_team_weight = 1, away_team_weight = 1):
	var team_skill_level_ratio = float(home_team_weight) / float(away_team_weight)

	# randomize()
	if (randf() * team_skill_level_ratio) > 0.5:
		return "Home"
	else:
		return "Away"

# TODO test
## Used when we have a block of matches to insert into another array
static func array_insert_array(arr, insert_after_index, array_to_insert):
	for i in array_to_insert.size():
		arr.insert(insert_after_index, array_to_insert[i])
		insert_after_index += 1

static func array_filter(arr, Filterer, func_to_call):
	var filterer_instance = Filterer.new()

	for i in arr.size():
		for j in i:
			var first = j;
			var second = j+1;
			if filterer_instance.call(func_to_call, arr[second], arr[first]):
				var tmp = arr[first]
				arr[first] = arr[second]
				arr[second] = tmp

	return arr

## 
func get_replay_data_by_node(type, node, metadata = {}):
	
	var data = {
		"type": type,
		"node": node,
		"metadata": metadata,
	}
	
	if "visible" in node:
		data.visible =  node.visible
	
	if "position" in node:
		data.position =  Vector2(node.position.x, node.position.y)

	return data
