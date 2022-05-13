extends Node


onready var url = "ws://127.0.0.1:9005" if Constants.app_mode == Constants.AppMode.DEVELOPMENT else "http://173.212.232.13:9005/"


var _client = WebSocketClient.new()


signal packet_received(packet)


func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	
	var err = _client.connect_to_url(url)
	if err != OK:
		printerr("Unable to connect")
		set_process(false)
	
	yield(get_tree(), "idle_frame")
	Events.emit_signal("error_message", "Connecting to " + url + "...")


func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)
	Events.emit_signal("error_message", "Couldn't connect to server with the url " + url)


func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	send_packet({"type": Constants.PacketTypes.CONNECTED})


func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var packet = _client.get_peer(1).get_packet().get_string_from_utf8()
	var jsonRes: JSONParseResult = JSON.parse(packet)
	var res = jsonRes.result
	res.type = int(res.type)
	emit_signal("packet_received", res)


func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()


func send_packet(packet: Dictionary) -> void:
	var json = JSON.print(packet)
	_client.get_peer(1).put_packet(json.to_utf8())


func req_update_client_data(client_data: Dictionary) -> void:
	var payload = {
		"type": Constants.PacketTypes.UPDATE_CLIENT_DATA, 
		"clientData": client_data
	}
	send_packet(payload)


func host() -> void:
	print("Hosting room...")
	send_packet({"type": Constants.PacketTypes.HOST_ROOM})


func join(code: String) -> void:
	print("Joining room with code: ", code)
	var payload = {
		"type": Constants.PacketTypes.JOIN_ROOM, 
		"code": code
	}
	send_packet(payload)


func leave() -> void:
	var payload = {
		"type": Constants.PacketTypes.LEAVE_ROOM, 
	}
	send_packet(payload)


func start() -> void:
	print("Starting the game...")
	var payload = {
		"type": Constants.PacketTypes.START_GAME, 
	}
	send_packet(payload)


func restart_game() -> void:
	var payload = {
		"type": Constants.PacketTypes.START_GAME, 
	}
	send_packet(payload)


func send_input(input: Vector2, pos_iteration: int) -> void:
	var payload = {
		"type": Constants.PacketTypes.SET_INPUT, 
		"i": pos_iteration,
		"x": input.x,
		"y": input.y
	}
	send_packet(payload)


func send_free_node(id: String) -> void:
	var payload = {
		"type": Constants.PacketTypes.FREE_NODE, 
		"id": id
	}
	send_packet(payload)	


func switch_rooms(new_pos: Vector2) -> void:
	var payload = {
		"type": Constants.PacketTypes.SWITCH_ROOMS,
		"x": new_pos.x,
		"y": new_pos.y
	}
	send_packet(payload)


func room_completed(name: String) -> void:
	var payload = {
		"type": Constants.PacketTypes.COMPLETE_ROOM,
		"name": name,
	}
	send_packet(payload)


func send_pos(id: String, pos: Vector2, pos_iteration: int) -> void:
	var payload = {
		"type": Constants.PacketTypes.SET_PLAYER_POS, 
		"i": pos_iteration,
		"id": id,
		"x": pos.x,
		"y": pos.y
	}
	send_packet(payload)


func set_health(id: String, health: float, knockback_dir: Vector2)  -> void:
	var payload = {
		"type": Constants.PacketTypes.SET_HEALTH, 
		"id": id,
		"health": health,
		"dirX": knockback_dir.x,
		"dirY": knockback_dir.y
	}
	send_packet(payload)


func melee_attack(id: String, dir: Vector2, team: int)  -> void:
	var payload = {
		"type": Constants.PacketTypes.MELEE_ATTACK, 
		"id": id,
		"team": team,
		"dirX": dir.x,
		"dirY": dir.y
	}
	send_packet(payload)


func shoot_projectile(start_pos: Vector2, dir: Vector2, id: String, team: int)  -> void:
	if Lobby.is_host:
		var payload = {
			"type": Constants.PacketTypes.SHOOT_PROJECTILE, 
			"posX": start_pos.x,
			"posY": start_pos.y,
			"dirX": dir.x,
			"dirY": dir.y,
			"id": id,
			"team": team,
		}
		send_packet(payload)


func spawn_mob(id: String, type: int, pos: Vector2) -> void:
	var payload = {
		"type": Constants.PacketTypes.SPAWN_MOB, 
		"id": id,
		"mob_type": type,
		"posX": pos.x,
		"posY": pos.y,
	}
	send_packet(payload)


func despawn_mob(id: String) -> void:
	var payload = {
		"type": Constants.PacketTypes.DESPAWN_MOB, 
		"id": id,
	}
	send_packet(payload)


func despawn_environment(id: String) -> void:
	var payload = {
		"type": Constants.PacketTypes.DESPAWN_ENVIRONMENT, 
		"id": id,
	}
	send_packet(payload)


func spawn_environment(id: String, type: int, pos: Vector2) -> void:
	var payload = {
		"type": Constants.PacketTypes.SPAWN_ENVIRONMENT, 
		"id": id,
		"environment_type": type,
		"posX": pos.x,
		"posY": pos.y,
	}
	send_packet(payload)


func spawn_item(item_type: int, pos: Vector2) -> void:
	var id = Util.generate_id()
	var payload = {
		"type": Constants.PacketTypes.SPAWN_ITEM, 
		"id": id,
		"item_type": item_type,
		"posX": pos.x,
		"posY": pos.y,
	}
	send_packet(payload)


func despawn_item(id: String) -> void:
	var payload = {
		"type": Constants.PacketTypes.DESPAWN_ITEM, 
		"id": id,
	}
	send_packet(payload)


func rooms_generated(rooms: Array) -> void:
	var modified_rooms = rooms.duplicate(true)
	for room_data in modified_rooms:
		for key in room_data.keys():
			if typeof(room_data[key]) == TYPE_VECTOR2:
				room_data[key] = {"x": room_data[key].x, "y": room_data[key].y, }
	
	var payload = {
		"type": Constants.PacketTypes.ROOMS_GENERATED, 
		"rooms": modified_rooms,
	}
	send_packet(payload)


func add_to_inventory(id: String, item_id: String) -> void:
	var payload = {
		"type": Constants.PacketTypes.ADD_TO_INVENTORY, 
		"id": id,
		"item_id": item_id
	}
	send_packet(payload)
