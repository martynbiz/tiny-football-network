extends MatchBaseState

enum Stages {
	INIT,
	READY,
}

func enter():
	stage = Stages.INIT

func _physics_process(delta):
	
	match stage:
		Stages.INIT:

			owner.set_camera_drone_target(owner.ball)

			stage = Stages.READY

			# load player positions TODO move to READY with play_style etc
			owner.load_player_positions("Home", owner.home_formation, owner.home_play_style) # TODO not owner.home_play_style
			owner.load_player_positions("Away", owner.away_formation, owner.away_play_style) # TODO not owner.away_play_style

		Stages.READY:

			# TODO manage ref position 
			
			# TODO load player positions as the ball moves up and down the park

			# TODO manage player run targets

			pass
