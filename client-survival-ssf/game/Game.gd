extends Node2D


onready var Camera: Camera2D = $Camera
onready var Entities = $Entities


func _ready():
	Lobby.emit_signal("game_has_loaded", self)


func generate_players(player_data: Array) -> void:
	var spawn_scammer: bool = true
	var spawn_i: int
	var player_scene = load("res://entities/Player.tscn")
	for data in player_data:
		var player = player_scene.instance()
		player.entity = Entity.new(player, data.id, Constants.Teams.GOOD_GUYS,  Vector2(100 + spawn_i * Constants.TILE_SIZE.x, 200))
		player.set_players_data(data.name, data.class)
		Entities.add_child(player)
		spawn_i += 1
