extends Resource
class_name Entity


var id: String = ""
var entity_node: Node


signal take_damage(damage, dir)
signal damage_taken(health, dir)


func _init(node: Node, entity_id: String, pos: Vector2):
	entity_node = node
	id = entity_id
	node.global_position = pos


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.DESPAWN_MOB:
			if id == packet.id:
				entity_node.queue_free()
