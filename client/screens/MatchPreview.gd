extends BaseScreen

onready var match_teams_row = $CenterContainer/VBoxContainer/HBoxContainer

onready var home_team_label = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/HomeTeamName
onready var away_team_label = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer3/AwayTeamName

onready var back_button = $CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/BackButton
onready var next_button = $CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/NextButton

# will be passed to match 
var match_data := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	require_authentication()

	match_teams_row.visible = false
	next_button.disabled = true

	ServerConnection.connect("match_joined", self, "_on_ServerConnection_match_joined")

# 
func _on_MenuButton_pressed(button):
	match button:
		next_button:
			load_screen(Constants.MATCH_SCREEN_PATH, {
				"match_data": match_data,
				"is_online": true, # TODO how do we set this?
			})
			
		back_button:
			load_screen(Constants.ONLINE_SCREEN_PATH)

func _on_ServerConnection_match_joined(data):

	var has_home_team = ("home_team" in data and data.home_team != null)
	var has_away_team = ("away_team" in data and data.away_team != null)

	if has_home_team:
		match_teams_row.visible = true
		home_team_label.text = data.home_team.team_name

	if has_away_team:
		match_teams_row.visible = true
		away_team_label.text = data.away_team.team_name

	if has_home_team and has_away_team:
		next_button.disabled = false

	match_data = data
