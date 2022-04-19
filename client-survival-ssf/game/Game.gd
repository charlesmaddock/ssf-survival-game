extends Node2D


var player_scene = preload("res://entities/Player.tscn")
var scammer_scene = preload("res://entities/Scammer.tscn")


onready var Camera: Camera2D = $Camera
onready var Entities = $Entities


func _ready():
	Lobby.emit_signal("game_has_loaded", self)
	Server.connect("packet_received", self, "_on_packet_received")
	
	for i in 10:
		var id = str(i + 1 * 12259194)
		var pos = Vector2(rand_range(-100, 100), rand_range(-100, 100))
		Server.spawn_mob(id, Constants.EntityTypes.CLOUDER, pos)


func _on_packet_received(packet: Dictionary):
	pass


func generate_players(player_data: Array) -> void:
	var spawn_scammer: bool = true
	var scammer_i: int
	for data in player_data:
		var player = player_scene.instance()
		player.entity = Entity.new(player, data.id, Vector2.ZERO)
		player.set_players_data(data.name, data.class)
		Entities.add_child(player)
		if data.id == Lobby.my_id:
			Camera.set_follow(player)
