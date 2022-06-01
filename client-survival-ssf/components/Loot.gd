extends Node2D


var dropped: bool = false
var rng = RandomNumberGenerator.new()


func _ready():
	get_parent().entity.connect("damage_taken", self, "_on_damage_taken")
	rng.randomize()


func _on_damage_taken(health, _dir) -> void:
	if rng.randi_range(0, 8) == 8 && Lobby.is_host == true:
		if health <= 0 && dropped == false:
			dropped = true
			Server.spawn_pickup(rng.randi_range(0, 3), global_position)
