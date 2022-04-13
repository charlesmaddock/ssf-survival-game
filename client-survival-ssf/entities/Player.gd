extends KinematicBody2D

var is_player = true

var _id: String = ""
var abilities_used = [false, false, false]
var _is_bot: bool
var using_invis_ability: bool = false


onready var Sprite = $Sprite


signal take_damage(damage, dir)
signal damage_taken(health, dir)


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	connect("damage_taken", self, "_on_damage_taken")
	
	if _is_bot == false:
		get_node("PlayerAI").set_physics_process(false)


func _on_damage_taken(damage, dir) -> void:
	modulate = Color(1000, 0, 0, 1)
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.white


func get_id() -> String:
	return _id


func get_is_bot() -> bool:
	return _is_bot


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.ABILITY_USED:
			if _id == packet.id:
				handle_ability_used(packet)
		Constants.PacketTypes.ROOM_LEFT:
			if _id == packet.id:
				queue_free()


func set_players_data(id: String, name: String, pos: Dictionary, className: String, is_bot: bool) -> void:
	var spawn_pos = Vector2(pos.x, pos.y)
	position = spawn_pos
	_id = id
	
	_is_bot = is_bot
	$UsernameLabel.text = name
	
	get_node("Sprite").texture = Util.get_sprite_for_class(className)


func _input(event):
	if Input.is_action_just_pressed("ability_1"):
		Server.use_ability("1")
	elif Input.is_action_just_pressed("ability_2") && abilities_used[1] == false:
		Server.use_ability("2")
	elif Input.is_action_just_pressed("ability_3") && abilities_used[2] == false:
		Server.use_ability("3")


func handle_ability_used(packet) -> void:
	if packet.key == "1" && abilities_used[0] == false:
		
		if Lobby.is_host:
			abilities_used[0] = true
			var prev_speed = get_node("Movement").speed
			get_node("Movement").speed = 140
			yield(get_tree().create_timer(8), "timeout")
			get_node("Movement").speed = prev_speed
	elif packet.key == "2"&& abilities_used[1] == false:
		
		if Lobby.is_host:
			set_visible(false)
			yield(get_tree().create_timer(0.2), "timeout")
			abilities_used[1] = true
			var nav_points = Util.get_nav_points()
			var teleport_pos = nav_points[randi() % nav_points.size()].position
			position = teleport_pos
			yield(get_tree().create_timer(0.1), "timeout")
			set_visible(true)
	elif packet.key == "3":
		
		abilities_used[2] = true
		if _id == Lobby.my_id:
			modulate = Color(1, 1, 1, 0.3)
		else:
			set_visible(false)
		using_invis_ability = true
		yield(get_tree().create_timer(8), "timeout")
		if _id == Lobby.my_id:
			modulate = Color(1, 1, 1, 1)
		else:
			set_visible(true)
		using_invis_ability = false
