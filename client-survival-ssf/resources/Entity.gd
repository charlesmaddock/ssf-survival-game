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


func _init(node: Node, entity_id: String, entity_team: int, pos: Vector2):
	Server.connect("packet_received", self, "_on_packet_received")
	entity_node = node
	id = entity_id
	node.global_position = pos
	team = entity_team


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.DESPAWN_ENVIRONMENT, Constants.PacketTypes.DESPAWN_ITEM:
			if id == packet.id:
				entity_node.queue_free()
		Constants.PacketTypes.DESPAWN_MOB:
			if id == packet.id:
				entity_node.queue_free()

