extends "res://addons/gut/test.gd"

var textures_scene = preload("res://Textures.tscn")

var textures_instance

func before_each():
	textures_instance = textures_scene.instance()
	add_child(textures_instance)

func test_get_best_combo_team_shirts_array():

	var shirt_color_combos = [
		[["Green"], ["Green"]], # Home,Home
		[["Green"], ["Green", "Black"]], # Home,Away
		[["White"], ["Red"]], # Away,Home
		[["Red"], ["Green", "Black"]] # Away,Away
	]
	var team_shirts_array = textures_instance.get_best_combo_team_shirts_array(shirt_color_combos)

	assert_eq(team_shirts_array.size(), 2, "team_shirts_array has 2 elements")
	assert_eq(team_shirts_array[0], "Away")
	assert_eq(team_shirts_array[1], "Home")

func test_convert_shade_to_color():

	var blue_from_lightblue = textures_instance.convert_shade_to_color("LightBlue")
	var blue_from_darkblue = textures_instance.convert_shade_to_color("DarkBlue")
	var red_from_maroon = textures_instance.convert_shade_to_color("Maroon")

	assert_eq(blue_from_lightblue, "Blue")
	assert_eq(blue_from_darkblue, "Blue")
	assert_eq(red_from_maroon, "Red")

func test_get_best_combo_team_shirts_array_with_different_shades():

	var shirt_color_combos = [
		[["Blue"], ["LightBlue"]], # Home,Home
		[["DarkBlue"], ["LightBlue", "Black"]], # Home,Away
		[["White"], ["Red"]], # Away,Home
		[["Red"], ["Green", "Black"]] # Away,Away
	]
	var team_shirts_array = textures_instance.get_best_combo_team_shirts_array(shirt_color_combos)

	assert_eq(team_shirts_array.size(), 2, "team_shirts_array has 2 elements")
	assert_eq(team_shirts_array[0], "Away")
	assert_eq(team_shirts_array[1], "Home")

func test_get_team_colors_clash_score():
	
	# no clash 
	var no_clash = textures_instance.get_team_colors_clash_score([[0, 1], [2, 3]])
	assert_eq(no_clash, 0, "Test clash score of shirt colours")
	
	# shirt color clash 
	var clash_shirt_color = textures_instance.get_team_colors_clash_score([[0, 1], [0, 3]])
	assert_eq(clash_shirt_color, 1, "Test clash score of shirt colours")
	
	# shirt pattern clash 
	var clash_shirt_pattern = textures_instance.get_team_colors_clash_score([[0, 1], [2, 1]])
	assert_eq(clash_shirt_pattern, 1, "Test clash score of shirt colours")
	
	# both clash 
	var both_clash = textures_instance.get_team_colors_clash_score([[0, 1], [0, 1]])
	assert_eq(both_clash, 2, "Test clash score of shirt colours")
	
	# both clash reverse
	var both_clash_reverse = textures_instance.get_team_colors_clash_score([[0, 1], [1, 0]])
	assert_eq(both_clash_reverse, 2, "Test clash score of shirt colours")

func test_create_shirt_combo():

	var home_team_data = {
		"home_shirt_color": "Green",
		"home_shirt_pattern": "None",
		"home_shirt_pattern_color": "White",
		"home_shorts_color": "White",
		"away_shirt_color": "Black",
		"away_shirt_pattern": "Stripes",
		"away_shirt_pattern_color": "Green",
		"away_shorts_color": "Black",
	}

	var away_team_data = {
		"home_shirt_color": "Blue",
		"home_shirt_pattern": "None",
		"home_shirt_pattern_color": "White",
		"home_shorts_color": "White",
		"away_shirt_color": "Orange",
		"away_shirt_pattern": "Stripes",
		"away_shirt_pattern_color": "Blue",
		"away_shorts_color": "Black",
	}

	var shirt_combo = textures_instance.create_shirt_combo(home_team_data, away_team_data, ["Away", "Home"])

	assert_eq(shirt_combo.size(), 2, "shirt_combo has 2 elements")

	assert_eq(shirt_combo[0].size(), 2, "shirt_combo[0] has 2 elements")
	assert_eq(shirt_combo[0][0], "Black")
	assert_eq(shirt_combo[0][1], "Green")

	assert_eq(shirt_combo[1].size(), 1, "shirt_combo[0] has 2 elements")
	assert_eq(shirt_combo[1][0], "Blue")
