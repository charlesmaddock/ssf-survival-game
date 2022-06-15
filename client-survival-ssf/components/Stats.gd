extends Control


onready var HealthIcon = $Panel/HBoxContainer/HealthIcon
onready var AttackIcon = $Panel/HBoxContainer/AttackIcon
onready var SpeedIcon = $Panel/HBoxContainer/SpeedIcon
onready var WeightIcon = $Panel/HBoxContainer/WeightIcon


func _ready():
	var parent_entity: Node = get_parent().get_parent()
	set_visible(parent_entity.entity.id == Lobby.my_id)
	parent_entity.entity.connect("damage_taken", self, "_on_damage_taken")
	parent_entity.entity.connect("change_movement_speed", self, "_on_change_movement_speed")
	parent_entity.entity.connect("change_weight", self, "_on_change_weight")
	parent_entity.entity.connect("change_attack_damage", self, "_on_change_attack_damage")


func _on_change_attack_damage(damage) -> void:
	AttackIcon.get_node("Label").text = str(int(damage))


func _on_change_movement_speed(speed) -> void:
	SpeedIcon.get_node("Label").text = str(int(speed))


func _on_change_weight(weight) -> void:
	WeightIcon.get_node("Label").text = str(int(weight))


func _on_damage_taken(health: float, _dir) -> void:
	HealthIcon.get_node("Label").text = str(int(health))
	
