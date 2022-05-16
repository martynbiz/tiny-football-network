extends Node

# Use this file when we want to save custom edits (e.g. Celtic)
var game_options_file = "user://options.save"

var options = {
	"window_fullscreen": true,
	"window_scale": 2,
	"music_enabled": true,
	"soundfx_enabled": true,
	"offsides_enabled": true,
	"game_speed": Constants.GAME_SPEED_OPTIONS[1],
	"match_length_real_minutes": Constants.MATCH_LENGTH_OPTIONS[1],
	"crt_scanlines": false,
	"weather_enabled": true,
	"difficulty_level": Constants.DIFFICULTY_LEVEL_OPTIONS[1],
	"replays_enabled": true,
	"replay_quality": Constants.REPLAY_QUALITY_OPTIONS[3],
	# "replay_speed_rate": Constants.REPLAY_SPEED_RATE_OPTIONS[1],
	"show_player_cursors": true,
	"show_player_fitness": true,
	"locale": null,
}

## Load settings from local users file
func load():
	var game_options = File.new()
	if not game_options.file_exists(game_options_file):
		print("Could not find options file")
		save()
		# return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	game_options.open(game_options_file, File.READ)
	while game_options.get_position() < game_options.get_len():
		
		# Get the saved dictionary from the next line in the save file
		var options_from_file = parse_json(game_options.get_line())

		# Now we set the remaining variables.
		for key in options_from_file.keys():
			set_option(key, options_from_file[key])

	game_options.close()
	
	# # apply fullscreen and scale options on load, etc
	# init_options()

## Save settings to local users file
func save():
	var game_options = File.new()
	game_options.open(game_options_file, File.WRITE)
	game_options.store_line(to_json(options))
	game_options.close()

func get_option(name):
	return options[name]

func set_option(name, value):
	options[name] = value 

	# special conditions when we change some options 
	match name:
		"window_fullscreen", "window_scale":
			
			# full screen, windowed
			OS.window_fullscreen = options.window_fullscreen
			if !options.window_fullscreen:
				var display_width = ProjectSettings.get_setting("display/window/size/width")
				var display_height = ProjectSettings.get_setting("display/window/size/height")
				OS.set_window_size(Vector2(display_width * options.window_scale, display_height * options.window_scale))
		
		"locale": 

			# locale
			TranslationServer.set_locale(options.locale)
		
		"replay_quality":

			# replays
			options.replays_enabled = (options.replay_quality != Constants.REPLAY_QUALITY_OPTIONS[0])

# ## 
# func init_options():

# 	# locale
# 	TranslationServer.set_locale(options.locale)

# 	# replays
# 	options.replays_enabled = (options.replay_quality != Constants.REPLAY_QUALITY_OPTIONS[0])

