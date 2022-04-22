extends Node2D


var player_scene = preload("res://entities/Player.tscn")
var scammer_scene = preload("res://entities/Scammer.tscn")
var time: float = 0.0
var wave: int = 0
var time_between_waves = 60


onready var Camera: Camera2D = $Camera
onready var Entities = $Entities


func _ready():
	Lobby.emit_signal("game_has_loaded", self)
	Server.connect("packet_received", self, "_on_packet_received")
	
<<<<<<< HEAD
	for i in 5:
		var id = str(i + 1 * 12259194)
=======
	for i in 20:
		var id = Util.generate_id()
>>>>>>> e16d375bf86bc81e26fd5255798d0a90c7887a31
		var pos = Vector2(rand_range(-1000, 1000), rand_range(-1000, 1000))
		Server.spawn_mob(id, Constants.EntityTypes.CLOUDER, pos)
	
	for i in 20:
		var id = Util.generate_id()
		var pos = Vector2(rand_range(-1000, 1000), rand_range(-1000, 1000))
		Server.spawn_environment(id, Constants.EntityTypes.TREE, pos)


func _physics_process(delta):
	time += delta
	var time_left_to_next_wave = time_between_waves - (int(time) % time_between_waves)
	var text = "Next wave in " + str(time_left_to_next_wave)
	if floor(time / time_between_waves) > wave:
		wave = floor(time / time_between_waves)
		var spawn_pos: Vector2 = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 800 
		for i in (wave) * 2:
			var id = Util.generate_id()
			Server.spawn_mob(id, Constants.EntityTypes.CHOWDER, spawn_pos + Vector2(rand_range(-100, 100), rand_range(-100, 100)))
	
	get_node("CanvasLayer/ObjectiveMarker/PlayersLeft").text = text


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
