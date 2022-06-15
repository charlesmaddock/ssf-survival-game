extends Resource
class_name Entity


var id: String = ""
var team: int = Constants.Teams.NONE
var entity_node: Node
var target_sprite: Sprite
var room_id: int


signal take_damage(damage, dir)
signal damage_taken(health, dir)
signal heal(amount)
signal request_attack()
signal change_movement_speed(speed)
signal change_weight(weight)
signal change_attack_damage(damage)
signal turned_around(dir)
signal dashed(force)
signal aim_dir(dir)
signal is_attacking(attack_bool)
signal attack_freeze(time)
signal knockback(dir)


func _init(node: Node, entity_id: String, entity_team: int, pos: Vector2, r_id: int):
	Server.connect("packet_received", self, "_on_packet_received")
	entity_node = node
	
	target_sprite = Sprite.new()
	target_sprite.texture = load("res://assets/sprites/largePoint.png")
	target_sprite.scale = Vector2(4, 1.5)
	target_sprite.offset = Vector2(0, 6)
	target_sprite.modulate = Color.red
	entity_node.add_child(target_sprite)
	entity_node.move_child(target_sprite, 0)
	set_is_target(false)
	
	id = entity_id
	node.global_position = pos
	team = entity_team
	room_id = r_id
	connect("damage_taken", self, "on_damage_taken")


func set_is_target(val: bool) -> void:
	target_sprite.set_visible(val)


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.DESPAWN_ENVIRONMENT, Constants.PacketTypes.DESPAWN_ITEM:
			if id == packet.id:
				entity_node.queue_free()
		Constants.PacketTypes.DESPAWN_MOB:
			if id == packet.id:
				entity_node.queue_free()


func on_damage_taken(health, dir) -> void:
	if health <= 0 && Util.is_player(entity_node) == false:
		if Lobby.is_host == true:
			if entity_node is KinematicBody:
				entity_node.rotation_degrees = 90
				yield(entity_node.get_tree().create_timer(0.4), "timeout")
			
			Server.despawn_mob(id)
