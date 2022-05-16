extends Node

## Fetch the textures for skin color
## {string} color e.g. LightSkinBrownHair 
func get_hair_skin_texture(hair_skin):
	var hair_skin_node = get_node("SkinTextures/" + hair_skin)
	if hair_skin_node:
		return hair_skin_node.get_texture()

## Fetch the textures for skin color
## {string} color e.g. LightSkinBrownHair 
func get_pitch_texture(pitch_name):
	var pitch_node = get_node("PitchTextures/" + pitch_name)
	if pitch_node:
		return pitch_node.get_texture()

## Fetch the textures for skin color
## {string} color e.g. LightSkinBrownHair 
func get_ball_texture(ball_name):
	var ball_node = get_node("BallTextures/" + ball_name)
	if ball_node:
		return ball_node.get_texture()

## Fetch the textures for shirt color and patterns 
## {string} color e.g. Red 
## {Constants.SHIRT_PATTERN_*} pattern 
func get_shirt_texture(color, pattern = null):
	if pattern == Constants.SHIRT_PATTERN_STRIPES:
		return get_node("ShirtTextures/" + color + pattern).get_texture()
	elif pattern == null:
		return get_node("ShirtTextures/" + color).get_texture()

## Fetch the textures for shorts color and patterns 
## {string} color e.g. Red 
func get_shorts_texture(color):
	return get_node("ShortsTextures/" + color + "Shorts").get_texture()

## Will return the best combo of Home/Away, Away/Home etc
## @param {Array<Array<String,String (opt)>>(4)} shirt_color_combos 
##   Expects [[Home,Home],[Home,Away],[Away,Home],[Away,Away]] 
##   e.g. [[[Blue], [Green]], [[Blue], [Green, Black]], [[White], [Green]], [[White], [Green, Black]]]
## @return {Array<String,String>}
func get_best_combo_team_shirts_array(shirt_color_combos):
	
	# clash_score combos until we find one that doesn't clash
#	var best_combo = shirt_color_combos[0]
	var best_clash_score = get_team_colors_clash_score(shirt_color_combos[0])
	var best_combo_i
	for i in range(shirt_color_combos.size()):
		var combo = shirt_color_combos[i]
		var clash_score = get_team_colors_clash_score(combo)
		best_combo_i = i
		if clash_score < best_clash_score:
#			best_combo = combo
			best_clash_score = clash_score
		if clash_score == 0:
			break
	
	var home_team_shirt = "Home"
	var away_team_shirt = "Home"
	if best_combo_i == 1 or best_combo_i == 3:
		away_team_shirt = "Away"
	if best_combo_i == 2 or best_combo_i == 3:
		home_team_shirt = "Away"

	return [home_team_shirt, away_team_shirt]

## Convert a shade (e.g. LightBlue) to color (e.g. Blue) so that we can compare
## different shades as the same color to match e.g. LightBlue == Blue
## @param {string} shade e.g. LightBlue
## @return {string} e.g. Blue
func convert_shade_to_color(shade):
	match shade:
		"LightBlue", "DarkBlue":
			return "Blue"
		"Maroon":
			return "Red"
		_:
			return shade

## Check whether combination of [home|away]_shirt[_pattern]_colors clash 
## @param {Array} e.g. [["Blue"], ["Red", "White"]]
func get_team_colors_clash_score(combo):
	var clash_score = 0

	# compare either one or two colours against the other side 
	for color_0 in combo[0]:
		for color_1 in combo[1]:

			# convert shades to colors e.g. LightBlue -> Blue
			color_0 = convert_shade_to_color(color_0)
			color_1 = convert_shade_to_color(color_1)

			if color_0 == color_1:
				clash_score += 1
				break
	
	return clash_score

## Will produce an combination of colors for home and away e.g. [["Pink", "White"], [..]]
func create_shirt_combo(home_team_data, away_team_data, home_away_combo):
	var home_combo = []
	var away_combo = []
	
	if home_away_combo[0] == "Home":
		if home_team_data.home_shirt_color:
			home_combo.append(home_team_data.home_shirt_color)
		if home_team_data.home_shirt_pattern != Constants.SHIRT_PATTERN_NONE:
			home_combo.append(home_team_data.home_shirt_pattern_color)
	elif home_away_combo[0] == "Away":
		if home_team_data.away_shirt_color:
			home_combo.append(home_team_data.away_shirt_color)
		if home_team_data.away_shirt_pattern != Constants.SHIRT_PATTERN_NONE:
			home_combo.append(home_team_data.away_shirt_pattern_color)

	if home_away_combo[1] == "Home":
		if away_team_data.home_shirt_color:
			away_combo.append(away_team_data.home_shirt_color)
		if away_team_data.home_shirt_pattern != Constants.SHIRT_PATTERN_NONE:
			away_combo.append(away_team_data.home_shirt_pattern_color)
	elif home_away_combo[1] == "Away":
		if away_team_data.away_shirt_color:
			away_combo.append(away_team_data.away_shirt_color)
		if away_team_data.away_shirt_pattern != Constants.SHIRT_PATTERN_NONE:
			away_combo.append(away_team_data.away_shirt_pattern_color)
	
	return [home_combo, away_combo]	
