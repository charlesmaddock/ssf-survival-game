extends Node2D


onready var JoyStick = $CanvasLayer/Control/JoyStick
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
var speed: float = 160.0
var speed_modifier: float = 1.0
var weight_modifiers: Array 


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	
	get_parent().entity.connect("damage_taken", self, "_on_take_damage")
	get_parent().entity.connect("change_movement_speed", self, "_on_change_movement_speed")
	get_parent().entity.connect("attack_freeze", self, "_on_attack_freeze")
	get_parent().entity.connect("knockback", self, "_on_knockback")
	
	get_parent().entity.connect("add_weight", self, "_on_add_weight")
	get_parent().entity.connect("remove_weight", self, "_on_remove_weight")
	
	
	_prev_pos = get_parent().global_position
	get_parent().entity.connect("dashed", self, "_on_dashed")
	
	JoyStick.init(get_parent().entity.id == Lobby.my_id)


func _on_add_weight(weight: float) -> void:
	weight_modifiers.append(weight)


func _on_remove_weight(weight: float) -> void:
	var index = weight_modifiers.find(weight)
	if index != -1:
		weight_modifiers.remove(index) 


func _on_dashed(dir) -> void:
	_force += dir


func _on_take_damage(health, dir) -> void:
	_force += dir 


func _on_knockback(dir) -> void:
	_force += dir


func _on_change_movement_speed(new_speed):
	speed = new_speed


func set_speed(speed: float) -> void:
	speed = speed 


func set_velocity(dir: Vector2) -> void:
	var weight = 100 if !Util.is_player(get_parent()) else 0.01
	for mod in weight_modifiers:
		weight += mod
	
	_velocity = dir.normalized() * speed * speed_modifier * (100 / weight)


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
		Constants.PacketTypes.TELEPORT_ENTITY:
			if entity_id == packet.id:
				get_parent().global_position = Vector2(packet.x, packet.y)
				target_position = Vector2(packet.x, packet.y)


func _on_attack_freeze(time):
	speed_modifier = 0.0
	attack_freeze = true
	freeze_timer.start(time)


func get_input():
	var velocity = Vector2.ZERO
	var joy_stick_velocity = JoyStick.get_direction()
	if Input.is_action_pressed("ui_right") || (Lobby.auto_aim == true && Input.is_key_pressed(KEY_RIGHT)):
		velocity.x += 1
	if Input.is_action_pressed("ui_left") || (Lobby.auto_aim == true && Input.is_key_pressed(KEY_LEFT)):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down") || (Lobby.auto_aim == true && Input.is_key_pressed(KEY_DOWN)):
		velocity.y += 1
	if Input.is_action_pressed("ui_up") || (Lobby.auto_aim == true && Input.is_key_pressed(KEY_UP)):
		velocity.y -= 1
	
	return velocity.normalized() + joy_stick_velocity


func get_velocity() -> Vector2:
	return _velocity + _force


func _physics_process(delta):
	_send_pos_iteration += 1
	
	if Util.is_my_entity(get_parent()):
		var input: Vector2 = get_input()
		if input != _prev_input:
			if get_parent().has_node("BirdLegs"):
				if input.x != 0 && input.y != 0:
					input.y = 0
			if get_parent().has_node("BlueShoes"):
				input = input.rotated(deg2rad(180))
			Server.send_input(input, _send_pos_iteration)
		_prev_input = input
		
		set_velocity(input)
	
	if (Lobby.is_host == true && Util.is_player(get_parent()) == false) || entity_id == Lobby.my_id:
		var vel = get_parent().move_and_slide(_velocity + _force)
		if _send_pos_iteration % 7:
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
