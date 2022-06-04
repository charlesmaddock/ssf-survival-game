extends Camera2D


var destined_position: Vector2
var _follow: Node2D = null


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	Events.connect("follow_w_camera", self, "_on_follow_w_camera")


func _on_follow_w_camera(follow: Node2D) -> void:
	_follow = follow


func _process(delta):
	if Input.is_key_pressed(KEY_1) && Input.is_key_pressed(KEY_2):
		zoom = Vector2(15, 15)
	else:
		zoom = Vector2.ONE
	
	if is_instance_valid(_follow):
		position = position.linear_interpolate(_follow.global_position, delta * 4)
	if self.global_position != destined_position:
		position = position.linear_interpolate(destined_position, delta * 4)


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SWITCH_ROOMS:
		destined_position = Vector2(packet.x, packet.y)
		var prev_follow = _follow
		_follow = null
		yield(get_tree().create_timer(1), "timeout")
		_follow = prev_follow
		
