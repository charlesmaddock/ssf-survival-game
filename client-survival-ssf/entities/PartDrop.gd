extends Node2D


onready var sprite: Node = get_node("Sprite")

var _part_name: int
var _id: String

func init(id: String, pos: Vector2, part_name: int):
	global_position = pos
	
	_part_name = part_name
	_id = id
	
	var part_scene = Constants.PartScenes[part_name].duplicate(true).instance()
	get_node("Sprite").texture = part_scene.get_sprite()
	part_scene.queue_free()


func _ready() -> void:
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.PICK_UP_PART:
			if _id == packet.part_id:
				queue_free()


func get_id():
	return _id


func get_part_name():
	return _part_name
