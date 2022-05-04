extends YSort


var item_scene = preload("res://entities/Item.tscn")
var attack_scene: PackedScene = preload("res://entities/Attack.tscn")

var mob_type_scenes: Dictionary = {
	Constants.EntityTypes.CLOUDER: preload("res://entities/Clouder.tscn"),
	Constants.EntityTypes.CHOWDER: preload("res://entities/Chowder.tscn"),
}

var environment_type_scenes: Dictionary = {
	Constants.EntityTypes.TREE: preload("res://entities/Tree.tscn")
}


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func get_entity(id: String) -> Node:
	for child in get_children():
		if Util.is_entity(child):
			if child.entity.id == id:
				return child
	
	return null


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.SHOOT_PROJECTILE:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var dir = Vector2(packet.dirX, packet.dirY)
			var projectile_scene = preload("res://entities/Projectile.tscn")
			var projectile = projectile_scene.instance()
			projectile.init(spawn_pos, dir, 10, packet.id)
			add_child(projectile)
		Constants.PacketTypes.SPAWN_MOB:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var entity_type = int(packet.mob_type)
			var scene = mob_type_scenes[entity_type] 
			var entity = scene.instance()
			entity.entity = Entity.new(entity, packet.id, spawn_pos)
			add_child(entity)
		Constants.PacketTypes.SPAWN_ENVIRONMENT:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var entity_type = int(packet.environment_type)
			var scene = environment_type_scenes[entity_type] 
			var entity = scene.instance()
			entity.entity = Entity.new(entity, packet.id, spawn_pos)
			add_child(entity)
		Constants.PacketTypes.SPAWN_ITEM:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var item = item_scene.instance()
			item.entity = Entity.new(item, packet.id, spawn_pos)
			item.init(int(packet.item_type)) 
			add_child(item)
		Constants.PacketTypes.MELEE_ATTACK:
			var attacker_entity = get_entity(packet.id)
			if attacker_entity != null:
				var attack = attack_scene.instance()
				var spawn_pos = attacker_entity.global_position 
				var dir = Vector2(packet.dirX, packet.dirY)
				attack.init(spawn_pos, dir, 20, packet.id)
				add_child(attack)

