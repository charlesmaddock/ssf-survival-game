extends Node2D


var entity: Entity = Entity.new(self, "base", Vector2.ZERO)


func _ready():
	entity.connect("damage_taken", self, "_on_damage_taken")


func _on_damage_taken(health, _dir) -> void:
	if health <= 0:
		Events.emit_signal("game_over")
