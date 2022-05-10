extends BaseScreen

onready var match_teams_row = $CenterContainer/VBoxContainer/HBoxContainer

onready var home_team_label = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/HomeTeamName
onready var away_team_label = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer3/AwayTeamName

onready var back_button = $CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/BackButton
onready var next_button = $CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/NextButton

# # TODO how to share these between client and server 
# enum EventStatus {
# 	PENDING,
# 	READY,
# }

# Called when the node enters the scene tree for the first time.
func _ready():
	match_teams_row.visible = false
	next_button.disabled = true

func _on_MenuButton_pressed(button):
	match button:
		next_button:
			load_screen(Constants.MATCH_SCREEN_PATH)
		back_button:
			load_screen(Constants.ONLINE_OFFLINE_SCREEN_PATH)
