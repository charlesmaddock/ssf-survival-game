extends Node2D


onready var JoyStick = $CanvasLayer/CanvasModulate/Control/JoyStick
onready var entity_id = get_parent().entity.id
onready var freeze_timer: Node = get_node("FreezeTimer")


var sprite_scale: Vector2 = Vector2.ONE
var target_position: Vector2 = Vector2.ZERO
var _send_pos_iteration = 0
var _velocity = Vector2.ZERO
var _force: Vector2 = Vector2.ZERO
var _prev_input: Vector2 = Vector2.ZERO
var _prev_pos: Vector2

var walking: bool = false
var attack_freeze: bool = false
var speed: float = 80.0
var speed_modifier: float = 1.0
var weight: float = 0.0


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	
	get_parent().entity.connect("damage_taken", self, "_on_take_damage")
	get_parent().entity.connect("change_movement_speed", self, "_on_change_movement_speed")
	get_parent().entity.connect("change_weight", self, "_on_change_weight")
	get_parent().entity.connect("attack_freeze", self, "_on_attack_freeze")
	get_parent().entity.connect("knockback", self, "_on_knockback")
	
	_prev_pos = get_parent().global_position
	get_parent().entity.connect("dashed", self, "_on_dashed")
	
	JoyStick.init(get_parent().entity.id == Lobby.my_id)


func _on_dashed(dir) -> void:
	_force += dir


func _on_take_damage(health, dir) -> void:
	_force += dir 


func _on_knockback(dir) -> void:
	_force += dir


func _on_change_movement_speed(new_speed):
	speed = new_speed


func _on_change_weight(new_weight):
	weight = new_weight


func set_speed(speed: float) -> void:
	speed = speed 


func set_velocity(dir: Vector2) -> void:
	_velocity = dir.normalized() * speed * speed_modifier


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.SET_INPUT:
			if entity_id == packet.id:
				_velocity = Vector2(packet.x, packet.y).normalized() * speed
		Constants.PacketTypes.SET_PLAYER_POS:
			if entity_id == packet.id:
				# Don't move the host's player if we are the host
				if Lobby.is_host == true && entity_id == Lobby.my_id:
					return
				
				target_position = Vector2(packet.x, packet.y)


func _on_attack_freeze(time):
	speed_modifier = 0.0
	attack_freeze = true
	freeze_timer.start(time)


func get_input():
	var velocity = Vector2.ZERO
	var joy_stick_velocity = JoyStick.get_direction()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	return velocity.normalized() + joy_stick_velocity


func _physics_process(delta):
	_send_pos_iteration += 1
	
	if Util.is_my_entity(get_parent()):
		var input = get_input()
		if input != _prev_input:
			Server.send_input(input, _send_pos_iteration)
		_prev_input = input
		
		set_velocity(input)
	
	if Lobby.is_host == true:
		var vel = get_parent().move_and_slide(_velocity + _force)
		if _send_pos_iteration % 6:
			Server.send_pos(entity_id, global_position + (vel * delta))
			
			if vel == Vector2.ZERO:
				walking = false
			else:
				walking = true
	else:
		get_parent().global_position = get_parent().global_position.linear_interpolate(target_position, delta * 6)
	
	if _prev_pos.distance_to(get_parent().global_position) > 0.1:
		walking = true
	else:
		walking = false
	
	if walking:
		if abs(_prev_pos.x - get_parent().global_position.x) > 1:
			get_parent().entity.emit_signal("turned_around", _prev_pos.x > get_parent().global_position.x)
	
	_prev_pos = get_parent().global_position
	
	
	if _force.length() < 3:
		_force = Vector2.ZERO
	else:
		_force /= 1.1


func _on_FreezeTimer_timeout():
	attack_freeze = false
	speed_modifier = 1.0
