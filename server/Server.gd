extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

## This will be a store of events running 
var events = []

enum EventStatus {
	PENDING,
	READY,
}

onready var player_container_scene = preload("res://PlayerContainer.tscn")

func _ready():
	start_server()
	
	# test data 
	var team_data = Data.get_team(46)
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_on_Peer_connected")
	network.connect("peer_disconnected", self, "_on_Peer_disconnected")

func _on_Peer_connected(id):
	print("peer_connected: ", id)
	create_player_container(id)
	
func _on_Peer_disconnected(id):
	print("peer_disconnected: ", id)
	remove_player_container(id)

func create_player_container(player_id):
	var player_container = player_container_scene.instance()
	player_container.name = str(player_id)
	add_child(player_container, true)

func remove_player_container(player_id):
	var player_container = get_node(str(player_id))
	player_container.queue_free()


## Remote functions 

remote func get_team_data(team_id):
	var sender_id = get_tree().get_rpc_sender_id()
	var team_data = Data.get_team(team_id)
	rpc_id(sender_id, "return_fetch_team_data", team_data)

remote func fetch_teams_data(team_type_id, requester_id):
	var sender_id = get_tree().get_rpc_sender_id()
	var teams_data = Data.get_teams(team_type_id)
	rpc_id(sender_id, "return_fetch_teams_data", teams_data, requester_id)

## Will either create a new friendly data, or will join a pending one 
## @param {int} team_id
remote func init_event(team_id, requester_id):
	var sender_id = get_tree().get_rpc_sender_id()

	# TODO move this code to Event.init_event
	
	# If we find a suitable event then we'll assign it to this
	var selected_event
	for event_data in events:

		# if teams filled
		if event_data.status != EventStatus.PENDING:
			continue
		
		# search event for team_id
		var has_team_id = false
		for team_data in event_data.teams:
			if team_data.team_id == team_id:
				has_team_id = true
				break

		# use this event if team_id not found so we don't have usa vs usa
		if !has_team_id:
			selected_event = event_data

	var team_data = Data.get_team(team_id)

	if selected_event:
		selected_event.teams.append(team_data)
		selected_event.sender_ids.append(sender_id)

		# mark as ready if enough players joined
		if selected_event.teams.size() >= selected_event.min_teams:
			selected_event.status = EventStatus.READY

	else:
		selected_event = {
			"status": EventStatus.PENDING,
			"teams": [team_data],
			"min_teams": 2,
			"max_teams": 2,
			"sender_ids": [sender_id],
			"matches": [],
		}
		events.append(selected_event)

	rpc_id(sender_id, "return_init_event", selected_event, requester_id)

remote func fetch_event_data(requester_id):
	var sender_id = get_tree().get_rpc_sender_id()

	# TODO move this code to Event.get_event_data(sender_id)
	
	# find the event that matches this sender_id
	var selected_event
	for event in events:
		if event.sender_ids.has(sender_id):
			selected_event = event

	rpc_id(sender_id, "return_fetch_event_data", selected_event, requester_id)
