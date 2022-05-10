extends Node

const LOGIN_SCREEN_PATH = "res://screens/LoginRegister.tscn"
const HOME_SCREEN_PATH = "res://screens/Home.tscn"
const ONLINE_OFFLINE_SCREEN_PATH = "res://screens/OnlineOffline.tscn"
const MATCH_PREVIEW_SCREEN_PATH = "res://screens/MatchPreview.tscn"
const MATCH_SCREEN_PATH = "res://screens/Match.tscn"
const ONLINE_SCREEN_PATH = "res://screens/Online.tscn"
const SELECT_TEAM_SCREEN_PATH = "res://screens/SelectTeam.tscn"


# # features on/off to test performance
# const ALLOW_CATCH_THRESHOLD_BY_SKILL_LEVEL = true
# # const ALLOW_CATCH_THRESHOLD_BY_SKILL_LEVEL_GOALKEEPING = false
# # const ALLOW_CATCH_THRESHOLD_BY_SKILL_LEVEL_DRIBBLING = true
# const ALLOW_BALL_BOUNCE = true
# const ALLOW_BOUNCEABLE_GROUPS = true
# const ALLOW_BOUNCEABLE_PLAYERS = true
# const ALLOW_GOALIE_DIVE_REACTION_DELAY = true

# const ALLOW_MATCH_FITNESS = true
# const ALLOW_MATCH_FITNESS_RECOVERY = ALLOW_MATCH_FITNESS and true

# const ALLOW_INJURIES = true
# const ALLOW_GOALIE_DIVES = true
# const ALLOW_SHOT_AUTO_DIRECTION_AND_POWER = true
# const ALLOW_PASS_AUTO_DIRECTION_AND_POWER = true
# const ALLOW_PASS_AUTO_DIRECTION_AND_POWER_UP_ONLY = ALLOW_PASS_AUTO_DIRECTION_AND_POWER and true
# const ALLOW_CROSS_AUTO_DIRECTION_AND_POWER = true

# # fouls
# const ALLOW_FOULS = true
# const ALLOW_YELLOW_RED_CARDS = ALLOW_FOULS and true

# const ALLOW_OFFSIDES = true
# const ALLOW_OFFSIDE_AUTO_ADJUST_PLAYER_POSITIONS = ALLOW_OFFSIDES and true

# const ALLOW_LOB_SHOTS = true
# const ALLOW_AI_WIDE_PASSES = true
# const ALLOW_AI_CROSSES = true
# const ALLOW_AI_KEEP_IT_ON_LEFT_RIGHT_FLANK = true
# const ALLOW_AI_LONG_BALL = true

# const ALLOW_SKILL_LEVEL_FUZZINESS = true
# # const ALLOW_FUZZINESS_BY_ROTATION = true
# # const ALLOW_FUZZINESS_TO_GOAL_TARGET_POSITION = !ALLOW_FUZZINESS_BY_ROTATION

# # const ALLOW_RANDOMLY_ASSIGN_TEAM_IN_POSSESSION_ON_BOUNCE = true

# # replays
# const ALLOW_REPLAYS = true
# const ALLOW_REPLAYS_AFTER_GOALS = ALLOW_REPLAYS and true
# const ALLOW_HIGHLIGHTS = ALLOW_REPLAYS and true

# const ALLOW_GOAL_MARQUEE = false

# # steam
# const ALLOW_STEAM_API = false
# const ALLOW_STEAM_ACHIEVEMENTS = ALLOW_STEAM_API and true
# # const ALLOW_STEAM_QUIT_IF_STEAM_NOT_RUNNING = false
# const ALLOW_STEAM_QUIT_IF_NOT_OWNED = false

# const ALLOW_DOUBLE_TAP_FIRE = true

# # crosses
# const ALLOW_ADJUST_BALL_DESTINATION_FOR_CROSSES = true
# const ALLOW_DIRECT_CROSSES_ON_BOUNCE = true

# ## @depracated: set to false after we'd added proper crosses
# const ALLOW_FIRST_TOUCH = false
# const ALLOW_FIRST_TOUCH_OVERHEAD_KICKS = false

# const ENV = "production"

# const DATABASE_PATH_RES = "res://data/data.db"

# # only change this when we make breaking changes to the structure of the db
# const DATABASE_PATH = "user://data_20220330.db"

const TEAM_TYPE_CLUB_ID = 1
const TEAM_TYPE_NATION_ID = 2

# const SHIRT_PATTERN_NONE = "None"
# const SHIRT_PATTERN_STRIPES = "Stripes"

# const COMPETITION_CHAMPIONS_LEAGUE_ID = 1
# const COMPETITION_WORLD_CUP_ID = 2
# const COMPETITION_NATIONS_EURO_CUP_ID = 2

# const HOME_SCREEN_PATH = "res://ui/Home.tscn"
# const TOURNAMENTS_SCENE_PATH = "res://ui/Tournaments.tscn"
# const LANGUAGE_SELECTION_SCENE_PATH = "res://ui/LanguageSelection.tscn"

# const TEAM_TYPE_SELECTION_SCENE_PATH = "res://ui/tournament_scenes/setup_scenes/TeamTypeSelection.tscn"
# const TEAM_SELECTION_16_SCENE_PATH = "res://ui/tournament_scenes/setup_scenes/TeamSelection16.tscn"
# const TEAM_SELECTION_32_SCENE_PATH = "res://ui/tournament_scenes/setup_scenes/TeamSelection32.tscn"
# const CONTROLLER_SELECTION_SCENE_PATH = "res://ui/tournament_scenes/setup_scenes/ControllerSelection.tscn"
# const FIXTURE_LIST_SCENE_PATH = "res://ui/tournament_scenes/setup_scenes/FixtureList.tscn"
# const LEAGUE_TABLE_SCENE_PATH = "res://ui/tournament_scenes/setup_scenes/LeagueTable.tscn"
# const WINNER_SCREEN_PATH = "res://ui/tournament_scenes/setup_scenes/WinnerScreen.tscn"

# const TEAM_EDIT_SCENE_PATH = "res://ui/edit_mode_scenes/TeamEdit.tscn"


# # Human 


# # Player constants 

# # apply a skill factor to kicks e.g. higher skill more accurate


# # 10 would be a 1 in 10 chance for 100% match fitness, but a 1 in 4 for 40%
# const MATCH_FITNESS_INJURY_THRESHOLD = 10

# const DEGREE_AS_RADIANS = 0.01745329

# # enum KickIntents {
# # 	SHOOT,
# # 	CROSS,
# # 	LONG_BALL, # in use?
# # 	PASS_OUT_WIDE, # in use?
# # }

# enum KickTypes {
# 	HEADER,
# 	DIVING_HEADER,
# 	OVERHEAD_KICK,
# 	LOB,
# 	CORNER,
# 	THROW_IN,
# 	FREE_KICK,
# 	PENALTY,
# 	GOALIE_KICK_OUT,
# 	SHOT_ATTEMPT,
# 	CROSS_BALL,
# 	PASS_BALL, # "pass" is reserved keyword
# 	LONG_BALL,
# 	PASS_OUT_WIDE,
# }

# enum CursorTypes {
# 	NORMAL_PLAY,
# 	SHOOTING_RANGE,
# 	CROSSING_RANGE
# }

# enum MatchResults {
# 	Win,
# 	Draw,
# 	Lose
# }

# const MAX_SPEED = 50
# const MAX_ACCELERATION = 200

# const TACKLE_SLIDE_MULTIPLY = 1.5
# const TACKLE_SLIDE_DURATION = 0.5




# ## Event

# enum EventTypes {
# 	MATCH,
# 	KNOCKOUT,
# 	LEAGUE,
# 	CLUB_EURO_CUP,
# 	NATIONS_WORLD_CUP,
# 	NATIONS_EURO_CUP,

# 	SEASON
# }

# enum EventStatus {
# 	INIT,
# 	RUNNING,
# 	COMPLETE
# }



# # Match constants 

# enum FoulTypes {
# 	FREE_KICK,
# 	PENALTY,
# }

# enum FoulCards {
# 	YELLOW_CARD,
# 	RED_CARD
# }

# enum Sounds {
# 	REF_WHISTLE,
# 	REF_WHISTLE_KICK_OFF,
# 	REF_WHISTLE_END_HALF,
# 	REF_WHISTLE_MATCH_END,
# 	REF_WHISTLE_FOUL,
# 	TACKLE,
# 	CROWD,
# 	CROWD_GOAL,
# 	CROWD_CHEER,
# 	CROWD_MISS,
# 	CROWD_BOOING,
# 	KICK_BALL,
# 	HIT_POST,
# 	RUNNING,
# 	MENU_MUSIC,
# 	MENU_BUTTON_FOCUS
# }

# enum Intervals {
# 	FIRST_HALF,
# 	SECOND_HALF,
# 	ET_FIRST_HALF,
# 	ET_SECOND_HALF,
# 	PENALTIES
# }

# enum PitchThirds {
# 	DEFEND,
# 	MIDDLE,
# 	ATTACK
# }

# enum PitchFlank {
# 	LEFT,
# 	MIDDLE,
# 	RIGHT
# }

# # needs to be 3 or more, the lower the more strict
# const REF_STRICTNESS = 10

# # adjust run_target player positions when offside 

# const FIRST_HALF_END_MINUTES = 45
# const SECOND_HALF_END_MINUTES = 90
# const ET_FIRST_HALF_END_MINUTES = 105
# const ET_SECOND_HALF_END_MINUTES = 120

# const GOAL_LABEL_SCROLL_SPEED = -500


# # Ball constants 

# #
# const BOUNCE_HEIGHT_THRESHOLD = -10

# # the speed at which the ball is moving for bounce to be enabled
# const KICK_POWER_BUTTON_TAP_THRESHOLD = 110

# const DESTINATION_SLOW_THRESHOLD = 40

# const VELOCITY_IDLE_THRESHOLD = 2

# const KICK_MIN_POWER = 80
# const KICK_MAX_POWER = 400

# const BOUNCE_GRAVITY = 5
# const BOUNCE_BACK_RATIO = 0.5


# # Controllers

# const KICK_PRESS_DURATION_MAX = 0.5


# const MATCH_LENGTH_OPTIONS = [1, 2, 3]

# const DIFFICULTY_LEVEL_OPTIONS = ["Easy", "Medium", "Hard"]
# const GAME_SPEED_OPTIONS = ["Slower", "Normal", "Faster"]
# const WINDOWS_SCALE_OPTIONS = [1,2,3]
# const REPLAY_QUALITY_OPTIONS = ["Off", "Low", "Medium", "High"]
# # const REPLAY_SPEED_RATE_OPTIONS = [0.5, 0.75, 1]
# const LOCALE_OPTIONS = ["en", "fr", "de", "it", "es", "ru"] #, "ja", "zh"]

# const CHANCE_OF_RAIN = 10

# const HIGHLIGHTS_SCORE_SHOT_MISS = 100
# const HIGHLIGHTS_SCORE_SHOT_SAVED = 200
# const HIGHLIGHTS_SCORE_RED_CARD = 400
# const HIGHLIGHTS_SCORE_HEADER_SHOT = 500
# const HIGHLIGHTS_SCORE_DIVING_HEADER_SHOT = 700
# const HIGHLIGHTS_SCORE_SHOT_OFFPOST = 750
# const HIGHLIGHTS_SCORE_SHOT_FREE_KICK_SAVED = 800
# const HIGHLIGHTS_SCORE_SHOT_PENALTY_SHOT_MISS = 800
# const HIGHLIGHTS_SCORE_OVERHEAD_KICK_SHOT = 800
# const HIGHLIGHTS_SCORE_SHOT_PENALTY_SHOT_SAVED = 850
# const HIGHLIGHTS_SCORE_GOAL = 1000

# # skippy
# const SKIPPY_PLAYER_RUN_DIVISOR = 1
# const SKIPPY_MATCH_RUN_DIVISOR = 1
# # const SKIPPY_REF_RUN_DIVISOR = 5
# # const SKIPPY_LINESMAN_RUN_DIVISOR = 5
