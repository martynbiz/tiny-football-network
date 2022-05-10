extends Node

var network = NetworkedMultiplayerENet.new()
var ip_address = "127.0.0.1"
var port = 1909

var is_connected = false

func _ready():
	# connect_to_server()
	pass

func connect_to_server():
	
	print("Connecting to server...", ip_address)

	# # SceneTree.get_network_unique_id().
	# var network_unique_id = get_tree().get_network_unique_id()
	# print("network_unique_id: ", network_unique_id)

	network.create_client(ip_address, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_succeeded():
	print("connection_succeeded")
	is_connected = true

func _on_connection_failed():
	print("connection_failed")


# Remote functions 

## Get team from db and return as array of entities
## @return {Array}
func fetch_team_data(team_id):
	rpc_id(1, "fetch_team_data", team_id)	

## 
remote func return_fetch_team_data(teams_data, requester_id):
	var requester_instance = instance_from_id(requester_id)
	if requester_instance:
		requester_instance.handle_return_fetch_team_data(teams_data)

## 
func fetch_teams_data(requester_id):
	rpc_id(1, "fetch_teams_data", Constants.TEAM_TYPE_NATION_ID, requester_id)

## 
remote func return_fetch_teams_data(teams_data, requester_id):
	var requester_instance = instance_from_id(requester_id)
	if requester_instance:
		requester_instance.handle_return_fetch_team_data(teams_data)

## 
func init_event(team_id, requester_id):
	rpc_id(1, "init_event", team_id, requester_id)

## 
remote func return_init_event(teams_data, requester_id):
	var requester_instance = instance_from_id(requester_id)
	if requester_instance:
		requester_instance.handle_return_init_event(teams_data)

## 
func fetch_event_data(requester_id):
	rpc_id(1, "fetch_event_data", requester_id)

## 
remote func return_fetch_event_data(event_data, requester_id):
	var requester_instance = instance_from_id(requester_id)
	if requester_instance:
		requester_instance.handle_return_fetch_event_data(event_data)
