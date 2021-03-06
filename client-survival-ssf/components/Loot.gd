extends Node2D


var dropped: bool = false
var rng = RandomNumberGenerator.new()

export(Array, preload("res://globals/Constants.gd").PartNames) var drop_parts: Array
export(Array, int) var drop_chance: Array
var part: int = -1


func _ready():
	get_parent().entity.connect("damage_taken", self, "_on_damage_taken")
	rng.randomize()
	
	var rand_int: int = rng.randi_range(0, 100)
	
	for i in range(0, drop_chance.size()):
		if rand_int < drop_chance[i]:
			part = drop_parts[i]
			break
	
	if drop_parts.empty() || part == -1:
		queue_free()


func _on_damage_taken(health, _dir) -> void:
	if Lobby.is_host == true:
		if health <= 0 && dropped == false && Lobby.monsters_drop_loot == true:
			dropped = true
			Server.spawn_pickup(Util.generate_id(), part, global_position)
