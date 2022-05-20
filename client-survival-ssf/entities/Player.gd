extends KinematicBody2D


onready var Sprite = $Sprite


var entity: Entity
var is_player: bool = true


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.ROOM_LEFT:
			if entity.id == packet.id:
				queue_free()


func set_players_data(name: String, className: String) -> void:
	$UsernameLabel.text = name
	get_node("Sprite").texture = Util.get_sprite_for_class(className)
	
	var nameLength = name.length()
	var armArray: Array = [
		"res://parts/arms/Default Arm.tscn",
		"res://parts/arms/HammerArm.tscn",
		"res://parts/arms/Heart Arm.tscn",
		"res://parts/arms/DrillArm.tscn"
		]
	var armPath: String = armArray[nameLength % armArray.size()]
	var armNode = load(armPath).instance()
	add_child_below_node($UsernameLabel, armNode)
	armNode.position = Vector2(1, -14)
	
	Server.ping()
