extends Node2D


var player_scene = preload("res://entities/Player.tscn")
var scammer_scene = preload("res://entities/Scammer.tscn")


onready var Camera: Camera2D = $Camera
onready var Entities = $Entities
onready var WinScreen = $CanvasLayer/WinScreen


var nodes_freed: Array = []
var total_nodes: int = 0


func _ready():
	Lobby.emit_signal("game_has_loaded", self)
	Server.connect("packet_received", self, "_on_packet_received")
	
	for e in Entities.get_children():
		var entity: Node2D = e
		if entity.get("node_id") != null: # is freeable node
			total_nodes += 1


func _on_packet_received(packet: Dictionary):
	match(packet.type):
		Constants.PacketTypes.NODE_FREED:
			if nodes_freed.find(packet.id) == -1:
				nodes_freed.append(packet.id)
				if nodes_freed.size() == total_nodes:
					WinScreen.set_visible(true)


func generate_players(player_data: Array) -> void:
	var spawn_scammer: bool = true
	var amount_players: int 
	var scammer_i: int
	var player_spawn_pos: Dictionary = {"x": -164 + randf() * 5, "y": 351 + randf() * 5}
	for data in player_data:
		if data.class == "Romance Scammer":
			spawn_scammer = false
			var scammer = scammer_scene.instance()
			scammer.set_scammer_data(data.id, data.pos, data.class, false, scammer_i)
			Entities.add_child(scammer)
			scammer_i += 1
			if data.id == Lobby.my_id:
				Camera.set_follow(scammer)
		else:
			amount_players += 1
			var player = player_scene.instance()
			player.set_players_data(data.id, data.name, data.pos, data.class, false)
			player_spawn_pos = data.pos
			Entities.add_child(player)
			if data.id == Lobby.my_id:
				Camera.set_follow(player)
	
	
	var player = player_scene.instance()
	player.set_players_data("player_bot_", "SSF Bot ", player_spawn_pos, "Sam the Sniper", true)
	Entities.add_child(player)
	
	if spawn_scammer == true:
		var scammer = scammer_scene.instance()
		scammer.set_scammer_data("scammer_ai", {"x": 128, "y": -265}, "Romance Scammer", true, 0)
		Entities.add_child(scammer)
