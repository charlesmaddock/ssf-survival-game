extends Node2D


onready var JoyStick = $CanvasLayer/CanvasModulate/Control/JoyStick
onready var entity_id = get_parent().entity.id
onready var client_prediction_util: ClientPredictionUtil = ClientPredictionUtil.new(get_parent())


var sprite_scale: Vector2 = Vector2.ONE
var target_position: Vector2 = Vector2.ZERO
var _send_pos_iteration = 0
var _velocity = Vector2.ZERO
var _force: Vector2 = Vector2.ZERO
var _prev_input: Vector2 = Vector2.ZERO
var _prev_pos: Vector2


var _time_since_last_input: float = 0.0

var walking: bool = false
var attack_freeze: bool = false
var speed: float = 80.0


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	
	get_parent().entity.connect("damage_taken", self, "_on_take_damage")
	get_parent().entity.connect("change_movement_speed", self, "_on_change_movement_speed")
	get_parent().entity.connect("change_movement_speed", self, "")
	
	_prev_pos = get_parent().global_position
	get_parent().entity.connect("dashed", self, "_on_dashed")


func _on_dashed(dir) -> void:
	print("I am dashing within movement right now!")
	_force += dir


func _on_take_damage(health, dir) -> void:
	_force += dir 


func _on_change_movement_speed(new_speed):
	speed = new_speed


func set_speed(speed: float) -> void:
	speed = speed 


func set_velocity(dir: Vector2) -> void:
	_velocity = dir.normalized() * speed


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.SET_INPUT:
			if entity_id == packet.id:
				client_prediction_util.host_handle_client_input(packet)
				_velocity = Vector2(packet.x, packet.y).normalized() * speed
		Constants.PacketTypes.SET_PLAYER_POS:
			if entity_id == packet.id:
				# Don't move the host's player if we are the host
				if Lobby.is_host == true && entity_id == Lobby.my_id:
					return
				
				if entity_id != Lobby.my_id:
					target_position = Vector2(packet.x, packet.y)
		Constants.PacketTypes.RECONCILE_PLAYER_POS:
			if packet.id == entity_id: 
				var position_iteration: int = packet.i
				var server_pos: Vector2 = Vector2(packet.x, packet.y)
				client_prediction_util.handle_reconciliation_from_host(position_iteration, server_pos)


func _on_attack_freeze(time):
	attack_freeze = true


func get_input():
	var velocity = Vector2.ZERO
	var joy_stick_velocity = JoyStick.get_velocity()
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
	if attack_freeze:
		return
	
	_send_pos_iteration += 1
	_time_since_last_input += delta
	
	if Util.is_my_entity(get_parent()):
		var input = get_input()
		if input != _prev_input || _time_since_last_input > 0.2:
			
			if Lobby.is_host == false:
				print("1. Sending Input: ", input, _send_pos_iteration)
			
			Server.send_input(input, _send_pos_iteration)
			_time_since_last_input = 0.0
		_prev_input = input
		
		set_velocity(input)
	
	if Lobby.is_host == true:
		var vel = get_parent().move_and_slide(_velocity + _force)
		if _send_pos_iteration % client_prediction_util.POSITION_UPDATE_DIVISOR == 0:
			Server.send_pos(entity_id, global_position + (vel * delta))
			
			if vel == Vector2.ZERO:
				walking = false
			else:
				walking = true
			#only works for host
	elif entity_id == Lobby.my_id:
		# Local client side prediction 
		var vel: Vector2 = get_parent().move_and_slide(_velocity + _force)
		client_prediction_util.add_prediction(get_parent().global_position, _send_pos_iteration)
		
		var reconciled_pos = client_prediction_util.get_reconciled_pos()
		
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
