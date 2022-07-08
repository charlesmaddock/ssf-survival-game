extends Control


onready var HealthIcon = $HealthIcon
onready var AttackIcon = $StatsBar/AttackIcon
onready var SpeedIcon = $StatsBar/SpeedIcon
onready var WeightIcon = $StatsBar/WeightIcon


func _ready():
	var parent_entity: Node = get_parent().get_parent()
	set_visible(parent_entity.entity.id == Lobby.my_id)
	parent_entity.entity.connect("damage_taken", self, "_on_damage_taken")
	parent_entity.entity.connect("change_movement_speed", self, "_on_change_movement_speed")
	parent_entity.entity.connect("change_weight", self, "_on_change_weight")
	parent_entity.entity.connect("change_attack_damage", self, "_on_change_attack_damage")
	
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SET_HEALTH:
		if packet.id == Lobby.my_id:
			if HealthIcon.get_node("Label").text != str(int(packet.health)):
				HealthIcon.get_node("AnimationPlayer").play("change")
			HealthIcon.get_node("Label").text = str(int(packet.health))


func _on_change_attack_damage(damage) -> void:
	if AttackIcon.get_node("Label").text != str(damage):
		AttackIcon.get_node("AnimationPlayer").play("change")
	AttackIcon.get_node("Label").text = str(int(damage))


func _on_change_movement_speed(speed) -> void:
	if SpeedIcon.get_node("Label").text != str(speed):
		SpeedIcon.get_node("AnimationPlayer").play("change")
	SpeedIcon.get_node("Label").text = str(int(speed))


func _on_change_weight(weight) -> void:
	if WeightIcon.get_node("Label").text != str(weight):
		WeightIcon.get_node("AnimationPlayer").play("change")
	WeightIcon.get_node("Label").text = str(int(weight))

