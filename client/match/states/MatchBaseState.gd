extends BaseState
class_name MatchBaseState

func is_players_in_position(players = null):
	if !players:
		players = owner.get_players()
	var players_in_position = true
	for player in players:

		# ignore injured players, they just delay the match
		if player.is_injured():
			continue

		if player.is_running_to_target: #player.velocity != Vector2.ZERO: # 
			players_in_position = false
			break
			
	return players_in_position

func set_players_collision_shape_disabled(collision_shape_disabled, goalie_collision_shape_disabled = true):
	for player in owner.get_players():
		player.set_collision_shape_disabled(collision_shape_disabled, goalie_collision_shape_disabled)
