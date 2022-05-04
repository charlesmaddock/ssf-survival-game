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
