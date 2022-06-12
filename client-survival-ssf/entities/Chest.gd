extends Node2D


var entity: Entity 
var _dropped: bool


func _ready():
	entity.connect("damage_taken", self, "_on_damage_taken")


func _on_damage_taken(health, dir) -> void:
	if Lobby.is_host == true:
		if health <= 0 && _dropped == false:
			_dropped = true
			Server.spawn_item(Constants.ItemTypes.HEART, global_position + (Vector2.ONE * 2))
