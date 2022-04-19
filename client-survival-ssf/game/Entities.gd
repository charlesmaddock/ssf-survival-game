extends YSort


var item_scene = preload("res://entities/Item.tscn")

var mob_type_scenes: Dictionary = {
	Constants.EntityTypes.CLOUDER: preload("res://entities/Clouder.tscn"),
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
		Constants.PacketTypes.SPAWN_ITEM:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var item_type = int(packet.item_type)
			var item = item_scene.instance()
			item.entity = Entity.new(item, packet.id, spawn_pos)
			add_child(item)
		Constants.PacketTypes.DESPAWN_ITEM:
			for child in get_children():
				if Util.is_entity(child):
					if child.entity.id == packet.id:
						pass
						#child.queue_free()

