extends Camera2D


var destined_position: Vector2
var _follow: Node2D = null
var _lerp_toward_follow: bool = true
var _target_zoom: Vector2 = Vector2.ONE


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	Events.connect("follow_w_camera", self, "_on_follow_w_camera")


func _on_follow_w_camera(follow) -> void:
	_follow = follow


func _process(delta):
	zoom = zoom.linear_interpolate(_target_zoom, delta * 10)
	
	if Input.is_key_pressed(KEY_1) && Input.is_key_pressed(KEY_2):
		_target_zoom = Vector2(15, 15)
	else:
		_target_zoom = Vector2.ONE
	
	if _lerp_toward_follow == false:
		_target_zoom = Vector2(2, 2)
	
	if is_instance_valid(_follow) && _lerp_toward_follow == true:
		position = position.linear_interpolate(_follow.global_position, delta * 14)
	if self.global_position != destined_position:
		position = position.linear_interpolate(destined_position, delta * 4)


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SWITCH_ROOMS:
		destined_position = Vector2(packet.x, packet.y)
		_lerp_toward_follow = false
		yield(get_tree().create_timer(1), "timeout")
		_lerp_toward_follow = true
		
