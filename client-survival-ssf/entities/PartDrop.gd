extends Node2D


onready var sprite: Node = get_node("Sprite")


var _part_name: int
var _id: String

var title: String = ""
var desc: String = ""
var perk_desc: String = ""
var con_desc: String = ""
var perks: Dictionary = {
	"damage": 0,
	"speed": 0,
	"weight": 0,
	"health_mod": 0
}

func init(id: String, pos: Vector2, part_name: int):
	global_position = pos
	
	_part_name = part_name
	_id = id
	
	var part_scene = Constants.PartScenes[part_name].duplicate(true).instance()
	
	title = part_scene.title
	desc = part_scene.optional_desc
	perk_desc = part_scene.optional_perk_desc
	con_desc = part_scene.optional_con_desc
	
	if part_scene.part_type == Constants.PartTypes.ARM:
		perks.damage = part_scene.damage
		perks.weight = part_scene.weight
		perks.health_mod = part_scene.health_modifier
	elif part_scene.part_type == Constants.PartTypes.BODY:
		perks.weight = part_scene.weight
		perks.health_mod = part_scene.health_modifier
	elif part_scene.part_type == Constants.PartTypes.LEG:
		perks.speed = part_scene.walk_speed
		perks.weight = part_scene.weight
		perks.health_mod = part_scene.health_modifier
	
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
