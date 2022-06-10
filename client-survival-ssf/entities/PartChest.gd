extends StaticBody2D


var entity: Entity
var _dropped: bool


func _ready():
	entity.connect("damage_taken", self, "_on_damage_taken")


func generate_part() -> int:
	return Constants.PartNames.DrillArm


func _on_damage_taken(health, dir) -> void:
	if Lobby.is_host == true:
		if health <= 0 && _dropped == false:
			var part_name = generate_part()
			_dropped = true
			Server.spawn_pickup(Util.generate_id(), part_name, global_position + (Vector2.ONE * 2))
