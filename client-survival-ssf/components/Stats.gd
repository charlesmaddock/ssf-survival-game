extends Control


onready var HealthIcon = $HealthIcon
onready var AttackIcon = $StatsBar/AttackIcon
onready var SpeedIcon = $StatsBar/SpeedIcon
onready var WeightIcon = $StatsBar/WeightIcon


var weight_modifiers: Array


func _ready():
	var parent_entity: Node = get_parent().get_parent()
	set_visible(parent_entity.entity.id == Lobby.my_id)
	parent_entity.entity.connect("damage_taken", self, "_on_damage_taken")
	parent_entity.entity.connect("change_movement_speed", self, "_on_change_movement_speed")
	parent_entity.entity.connect("change_attack_damage", self, "_on_change_attack_damage")
	
	parent_entity.entity.connect("add_weight", self, "_add_change_weight")
	parent_entity.entity.connect("remove_weight", self, "_add_change_weight")
	
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SET_HEALTH:
		if packet.id == Lobby.my_id:
			if HealthIcon.get_node("Label").text != str(int(packet.health)):
				HealthIcon.get_node("AnimationPlayer").play("change")
			HealthIcon.get_node("Label").text = str(int(packet.health))


func _on_add_weight(weight: float) -> void:
	weight_modifiers.append(weight)
	change_weight()


func _on_remove_weight(weight: float) -> void:
	var index = weight_modifiers.find(weight)
	if index != -1:
		weight_modifiers.remove(index) 
		change_weight()


func _on_change_attack_damage(damage) -> void:
	if AttackIcon.get_node("Label").text != str(damage):
		AttackIcon.get_node("AnimationPlayer").play("change")
	AttackIcon.get_node("Label").text = str(int(damage))


func _on_change_movement_speed(speed) -> void:
	if SpeedIcon.get_node("Label").text != str(speed):
		SpeedIcon.get_node("AnimationPlayer").play("change")
	SpeedIcon.get_node("Label").text = str(int(speed))


func change_weight() -> void:
	var weight = 0
	for mod in weight_modifiers:
		weight += mod 
	if WeightIcon.get_node("Label").text != str(weight):
		WeightIcon.get_node("AnimationPlayer").play("change")
	WeightIcon.get_node("Label").text = str(int(weight))

