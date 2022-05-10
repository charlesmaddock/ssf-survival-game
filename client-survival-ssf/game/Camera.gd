extends Camera2D


var destined_position: Vector2



func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func _process(delta):
	if Input.is_key_pressed(KEY_1) && Input.is_key_pressed(KEY_2):
		zoom = Vector2(9, 9)
	else:
		zoom = Vector2.ONE
	
	if self.global_position != destined_position:
		position = position.linear_interpolate(destined_position, delta * 4)


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SWITCH_ROOMS:
		destined_position = Vector2(packet.x, packet.y)
