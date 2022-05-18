extends Resource
class_name Entity


var id: String = ""
var team: int = Constants.Teams.NONE
var entity_node: Node


signal take_damage(damage, dir)
signal damage_taken(health, dir)
signal request_attack()
signal change_movement_speed(speed)
signal turned_around(dir)
signal dashed(force)
signal move_dir(dir)
signal is_attacking(attack_bool)
signal attack_freeze(time)
signal knockback(dir)


func _init(node: Node, entity_id: String, entity_team: int, pos: Vector2):
	Server.connect("packet_received", self, "_on_packet_received")
	entity_node = node
	id = entity_id
	node.global_position = pos
	team = entity_team
	connect("damage_taken", self, "on_damage_taken")


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.DESPAWN_ENVIRONMENT, Constants.PacketTypes.DESPAWN_ITEM:
			if id == packet.id:
				entity_node.queue_free()
		Constants.PacketTypes.DESPAWN_MOB:
			if id == packet.id:
				entity_node.queue_free()


func on_damage_taken(health, dir) -> void:
	if health <= 0:
		if Lobby.is_host == true:
			Server.despawn_mob(id)
