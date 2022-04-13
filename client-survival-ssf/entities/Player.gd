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

