extends BaseScreen

onready var match_teams_row = $CenterContainer/VBoxContainer/HBoxContainer

onready var home_team_label = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/HomeTeamName
onready var away_team_label = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer3/AwayTeamName

onready var back_button = $CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/BackButton
onready var next_button = $CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/NextButton

# const MATCH_SCENE_PATH = "res://ui/MatchScreen.tscn"

# TODO how to share these between client and server 
enum EventStatus {
	PENDING,
	READY,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	match_teams_row.visible = false

	next_button.disabled = true

	Timers.create_timer("poll_match_preview", 0.5, true)

	# do initial fetch 
	fetch_event_data()

func _process(delta):

	if !visible:
		return
	
	# keep checking if we have two teams
	if Timers.is_timer_stopped("poll_match_preview"):
		fetch_event_data()

func fetch_event_data():
	Server.fetch_event_data(get_instance_id())

func handle_return_fetch_event_data(event_data):

	home_team_label.text = event_data.teams[0].team_name

	if event_data.teams.size() >= 2:
		away_team_label.text = event_data.teams[1].team_name

	match_teams_row.visible = true

	# TODO proceed if we have two teams?
	if event_data.status == EventStatus.READY:
		next_button.disabled = false

func _on_MenuButton_pressed(button):
	
	if button == next_button:
		load_screen(Constants.MATCH_PREVIEW_SCREEN_SCENE_PATH)
	
	elif button == back_button:
		load_screen(Constants.SELECT_TEAM_SCREEN_SCENE_PATH)
