extends Node2D

## Load player positions when a tactical change of event (e.g. kickoff)
## @param team String "Home|Away"
## @param formation String e.g. "442"
## @param mode String e.g. "KickOff"
func load_player_positions(home_or_away, formation, play_style):

	var player_positions = get_node(home_or_away + "PlayerPositions")

	for player_position in get_node("PlayerPositions/"+formation+"/"+play_style).get_children():
		
		# # first delete this position
		# var old_position = player_positions.get_node(player_position.name)
		# if old_position:
		# 	player_positions.remove_child(old_position)
		# 	old_position.queue_free()
		
		var player_position_duplicate = player_position.duplicate()
		
		# if away, we need to mathematically "flip" the position for the top_team 
		if owner.top_team == home_or_away:
			var bottom_right_position = owner.get_pitch_bottom_right_position()
			player_position_duplicate.position = bottom_right_position - owner.get_position_on_pitch(player_position)
			
		var existing_player_position = get_node(home_or_away+"PlayerPositions/" + player_position_duplicate.name)
		if existing_player_position:
			existing_player_position.position = player_position_duplicate.position
		else:
			get_node(home_or_away+"PlayerPositions").add_child(player_position_duplicate)

	# we can use this when we want to assign positions to other players e.g. during corners
	var unassigned_positions = []
	
	# set players position 
	for player in owner.get_players(home_or_away):

		var player_position = get_node(home_or_away + "PlayerPositions/" + str(player.number))

		if player_position:

			if !player.is_playable():
				match play_style:
					"DefendingCross":
						if player.number == 3 or player.number == 4:
							unassigned_positions.append(player_position)
					"AttackingCross":
						if player.number == 10 or player.number == 4:
							unassigned_positions.append(player_position)

			else:
				player.set_player_position(player_position)
	
	# assign positions to other players if any unassigned 
	if unassigned_positions.size() > 0:
		for player in owner.get_players(home_or_away):

			# as we loop through we'll be popping so need to keep checking if we have more positions 
			if unassigned_positions.size() > 0:
				
				if player.is_playable():
					
					match play_style:
						
						# start with the defenders and work up
						"DefendingCross":
							if !player.is_goalie() and (player.number != 3 or player.number != 4):
								player.set_player_position(unassigned_positions.pop_front())
						
						# would rather it was a midfielder than a defender 
						"AttackingCross":
							if !player.is_goalie() and (player.number > 6):
								player.set_player_position(unassigned_positions.pop_front())

			# if we've no more positions then break out 
			else:
				break
