extends Node2D


onready var entity_id = get_parent().entity.id

var attack_scene: PackedScene = preload("res://entities/Attack.tscn")
var able_to_attack: bool = false

func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	

func _input(event):
	if Input.is_action_just_pressed("attack") && entity_id == Lobby.my_id && able_to_attack == true:
		able_to_attack = false
		var dir = (get_global_mouse_position() - global_position).normalized()
		print("telling server to send a packet of attack")
		Server.melee_attack(entity_id, dir)


func _on_packet_received(packet) -> void:
	
	if packet.type == Constants.PacketTypes.MELEE_ATTACK:
		if packet.id == entity_id:
			var attack = attack_scene.instance()
			var spawn_pos = global_position 
			var dir = Vector2(packet.dirX, packet.dirY)
			attack.init(spawn_pos, dir, 20, entity_id)
			get_parent().get_parent().add_child(attack)
			
		



func _on_Timer_timeout():
	able_to_attack = true
