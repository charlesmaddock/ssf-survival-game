extends Node2D


onready var Bar = $Bar
onready var health: float = Bar.max_value


var health_for_entity_w_id: String = ""
var _is_dead: bool


func _ready():
	health_for_entity_w_id = get_parent().get_id()
	get_parent().connect("take_damage", self, "_on_damage_taken")
	Server.connect("packet_received", self, "_on_packet_received")


func _on_damage_taken(damage, dir: Vector2) -> void:
	take_damage(damage, dir)


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SET_HEALTH:
		if packet.id == health_for_entity_w_id:
			health = packet.health
			Bar.value = health
			var knockback_dir = Vector2(packet.dirX, packet.dirY)
			get_parent().emit_signal("damage_taken", packet.health, knockback_dir)
			if health <= 0 && _is_dead == false:
				_is_dead = true
				get_parent().rotation_degrees = 90
				get_parent().collision_layer = 0
				
				var movement_component = get_parent().get_node("Movement")
				if movement_component != null:
					movement_component.set_process(false)
					movement_component.set_physics_process(false)
				yield(get_tree().create_timer(2), "timeout")
				get_parent().set_visible(false)
				
				Events.emit_signal("player_dead", get_parent().get_id())


func take_damage(damage: float, dir: Vector2) -> void:
	if Lobby.is_host == true:
		Server.set_health(health_for_entity_w_id, health - damage, dir.normalized() * (damage * 10))


func _on_DamageArea_area_entered(area):
		take_damage(area.get_damage(), area.global_position.direction_to(global_position))
