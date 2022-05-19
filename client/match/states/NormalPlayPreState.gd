extends MatchBaseState

enum Stages {
	WAITING_ON_CLIENTS_READY,
	INIT,
	READY,
	READY_USER_AI,
}

var player_in_possession

func enter():
	stage = Stages.WAITING_ON_CLIENTS_READY

	player_in_possession = owner.ball.player_in_possession

func physics_process(delta):

	match stage:
		Stages.WAITING_ON_CLIENTS_READY:

			if owner.is_clients_ready:
				stage = Stages.INIT
			
		Stages.INIT:

			stage = Stages.READY

		Stages.READY:
			
			if !owner.is_online:
				if player_in_possession.is_computer:
					var home_or_away = player_in_possession.get_home_or_away()
					var closest_player = owner.get_closest_outfield_player_to_ball(home_or_away)
					var direction_to_closest_player = player_in_possession.position.direction_to(closest_player.position)
					direction_to_closest_player = Utils.clamp_direction(direction_to_closest_player)

					var fire_press_power = 0.25
					player_in_possession.kick_ball(fire_press_power, direction_to_closest_player)

				else:
					start_timer(3)
					stage = Stages.READY_USER_AI

		# this is just so the user doesn't take ages... or the game crashes
		Stages.READY_USER_AI:

			if timer_is_stopped():
				var fire_press_power = 0.25
				player_in_possession.kick_ball(fire_press_power, player_in_possession.direction)
				
			update_timer(delta)
