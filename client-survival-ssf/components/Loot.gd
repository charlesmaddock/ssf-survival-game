extends Node2D


var dropped: bool = false


func _ready():
	get_parent().entity.connect("damage_taken", self, "_on_damage_taken")


func _on_damage_taken(health, _dir) -> void:
	if health <= 0 && dropped == false:
		dropped = true
		Server.spawn_item(Constants.ItemTypes.PINK_FLUFF, global_position)
