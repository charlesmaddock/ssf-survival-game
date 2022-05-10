extends Node


var room_code: String = ""
var my_id: String = ""
var my_client_data: Dictionary = {}

var is_host: bool
var players_data: Array
var dead_player_ids: Array = []
var bot_amount: int = 0


signal game_has_loaded(game_node)


func _ready():
	Server.connect("packet_received", self, "_on_packet_recieved")
	Events.connect("player_dead", self, "_on_player_dead")
	Events.connect("player_revived", self, "_on_player_revived")
	connect("game_has_loaded", self, "_on_game_loaded")


func get_amount_good_guys() -> int:
	var amount: int = 0
	for data in players_data:
		if data.class != "Romance Scammer":
			amount += 1
	
	return amount


func _on_player_dead(id) -> void:
	if dead_player_ids.find(id) == -1:
		dead_player_ids.append(id)
		if dead_player_ids.size() == players_data.size():
			Events.emit_signal("game_over", false)


func _on_player_revived(id) -> void:
	var index = dead_player_ids.find(id)
	if index != -1:
		dead_player_ids.remove(index)


func _on_packet_recieved(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.CONNECTED:
			my_client_data = packet.clientData
			my_id = packet.clientData.id
		Constants.PacketTypes.ROOM_HOSTED:
			is_host = true
		Constants.PacketTypes.ROOM_JOINED:
			room_code = packet.code
			players_data = packet.clientData
		Constants.PacketTypes.UPDATE_CLIENT_DATA:
			handle_update_client_data(packet)
		Constants.PacketTypes.GAME_STARTED:
			handle_game_started(packet) 
		Constants.PacketTypes.ROOM_LEFT:
			handle_room_left(packet)


func handle_room_left(packet: Dictionary) -> void:
	if my_id == packet.id:
		room_code = ""
		is_host = false
		players_data.clear()
		dead_player_ids.clear()
		bot_amount = 0
		get_tree().change_scene("res://ui/MainMenu.tscn")


func handle_update_client_data(packet: Dictionary) -> void:
	var new_client_data = packet.clientData
	for player_data in players_data:
		if new_client_data.id == player_data.id:
			var remove_at = players_data.find(player_data)
			players_data.remove(remove_at)
			players_data.insert(remove_at, new_client_data)
	
	if new_client_data.id == my_id:
		my_client_data = new_client_data
	
	print("players_data: ", players_data)


func handle_game_started(packet: Dictionary) -> void:
	players_data = packet.players
	dead_player_ids.clear()
	
	print("players_data: ", packet.players)
	
	get_tree().change_scene("res://game/Game.tscn")
	# Now we wait for _on_game_loaded


func _on_game_loaded(game_node: Node2D) -> void:
	game_node.generate_players(players_data)
