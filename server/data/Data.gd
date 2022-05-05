extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var db

class TeamsDataArraySorter:
	static func sort_by_name_ascending(a, b):
		if a.short_name < b.short_name:
			return true
	static func sort_by_skill_level_descending(a, b):
		if a.skill_level > b.skill_level:
			return true

class PlayersDataArraySorter:
	static func sort_by_position_number_ascending(a, b):
		if a.position_number < b.position_number:
			return true

func _ready():

	# Check if file exists, move it to user path if not 
	var dir = Directory.new();
	if !dir.file_exists(Constants.DATABASE_PATH) or Constants.ENV != "production":
		dir.copy(Constants.DATABASE_PATH_RES, Constants.DATABASE_PATH);
		print("Copied db file to users dir")

	# connect to db 
	db = SQLite.new()
	db.path = Constants.DATABASE_PATH
	# db.verbose_mode = true
	db.open_db()

## Get team from db and return as array of entities
## @return {Array}
func get_teams(query_team_type_id, query_country_id = null):

	# build query 
	var sql = get_teams_table_sql()

	sql += " WHERE teams.team_type_id = '%s'" % query_team_type_id
	if query_country_id != null:
		sql += " AND teams.country_id = '%s'" % query_country_id

	db.query(sql)

	return db.query_result.duplicate()

## Get team from db and return as array of entities
## @return {Array}
func get_team(team_id):

	# build query 
	var sql = get_teams_table_sql()

	sql += " WHERE teams.team_id = '%s'" % team_id

	db.query(sql)
	
	if !db.query_result.empty():
		return db.query_result.duplicate()[0]

# ## Get team from db and return as array of entities
# ## @return {Array}
# func get_team_by_name(query_team_name, query_team_type_id):

# 	# build query 
# 	var sql = get_teams_table_sql()

# 	sql += " WHERE teams.team_name = '%s'" % query_team_name
# 	sql += " AND teams.team_type_id = '%s'" % query_team_type_id

# 	db.query(sql)
	
# 	if !db.query_result.empty():
# 		return db.query_result.duplicate()[0]


## Get team from db and return as array of entities
## @return {Array}
func get_teams_by_competition(query_competition_id):

	# build query 
	var sql = get_teams_table_sql()

	sql += " WHERE teams.team_id in (SELECT team_id FROM competition_team WHERE competition_id = %s)" % query_competition_id

	db.query(sql)
	
	if !db.query_result.empty():
		return db.query_result.duplicate()


## Get team from db and return as array of entities
## @param {int} query_team_id Required to get position_number 
## @return {Array}
func get_players(query_team_id, query_order_by = ["position_number", "ASC"]):

	var sql = get_players_table_sql()

	sql += " WHERE player_team.team_id = %s" % query_team_id

	sql += " ORDER BY %s %s" % query_order_by

	db.query(sql)

	return db.query_result.duplicate()

func get_player_by_team_number(query_team_id, query_position_number):

	var sql = get_players_table_sql()

	sql += " WHERE player_team.team_id = %s" % query_team_id
	sql += " AND player_team.position_number = %s" % query_position_number

	db.query(sql)

	if !db.query_result.empty():
		return db.query_result.duplicate()[0]

func get_players_table_sql():
	var sql = "SELECT *"
	sql += " FROM player_team"
	sql += " LEFT JOIN players ON player_team.player_id = players.player_id"
	sql += " LEFT JOIN countries ON countries.country_id = players.country_id"
	sql += " LEFT JOIN hair_skin_colors ON hair_skin_colors.hair_skin_color_id = players.hair_skin_color_id"
	return sql

func get_teams_table_sql():
	var sql = "SELECT *,"
	sql += " (SELECT color from colors where colors.color_id = teams.home_shirt_color_id) as home_shirt_color,"
	sql += " (SELECT shirt_pattern from shirt_patterns where shirt_patterns.shirt_pattern_id = teams.home_shirt_pattern_id) as home_shirt_pattern,"
	sql += " (SELECT color from colors where colors.color_id = teams.home_shirt_pattern_color_id) as home_shirt_pattern_color,"
	sql += " (SELECT color from colors where colors.color_id = teams.home_shorts_color_id) as home_shorts_color,"
	sql += " (SELECT color from colors where colors.color_id = teams.away_shirt_color_id) as away_shirt_color,"
	sql += " (SELECT shirt_pattern from shirt_patterns where shirt_patterns.shirt_pattern_id = teams.away_shirt_pattern_id) as away_shirt_pattern,"
	sql += " (SELECT color from colors where colors.color_id = teams.away_shirt_pattern_color_id) as away_shirt_pattern_color,"
	sql += " (SELECT color from colors where colors.color_id = teams.away_shorts_color_id) as away_shorts_color"
	sql += " FROM teams"
	sql += " LEFT JOIN team_types ON team_types.team_type_id = teams.team_type_id"
	sql += " LEFT JOIN countries ON countries.country_id = teams.country_id"
	return sql



## Get a player by position (e.g. Midfielder) on a slice of the array (e.g. subs bench only)
## @param {Array<Dict>} players
## @param {string} position_name e.g. Midfielder
## @param {int} start 
## @param {int} end 
## @param {Array<int>} excludes Player_ids to exclude e.g. already subbed players
func get_player_by_position_in_array_slice(players, position_name, start = 0, end = null, excludes = []):
	
	# set end based on players size
	if end == null:
		end = players.size() - 1 

	for player_data in players.slice(start, end):

		# check player hasn't already been subbed 
		if excludes.has(player_data.player_id):
			continue

		# exit if we've found our same position sub
		if player_data.position == position_name:
			return player_data

## 
func swap_player_positions_in_array(players, selected_player_data, player_data):
	
	# var players = get_players_data(home_or_away)
	
	var selected_player_i
	var swap_with_i
	
	# find i of selected player 
	for i in players.size():
		var player = players[i]
		if selected_player_data.position_number == player.position_number:
			selected_player_i = i

	# find i of this player 
	for i in players.size():
		var player = players[i]
		if player_data.position_number == player.position_number:
			swap_with_i = i

	# do the swap, higher number first, then restore the position_number for the new 
	var tmp = players[selected_player_i]
	var tmp_position_number = players[swap_with_i].position_number

	players[selected_player_i] = players[swap_with_i]
	players[selected_player_i].position_number = tmp.position_number

	players[swap_with_i] = tmp 
	players[swap_with_i].position_number = tmp_position_number
