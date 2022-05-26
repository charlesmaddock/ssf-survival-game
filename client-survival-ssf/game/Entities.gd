extends YSort


var item_scene = preload("res://entities/Item.tscn")

var mob_type_scenes: Dictionary = {
	Constants.MobTypes.CLOUDER: preload("res://entities/Clouder.tscn"),
	Constants.MobTypes.CHOWDER: preload("res://entities/Chowder.tscn"),
	Constants.MobTypes.TURRET_CRAWLER: preload("res://entities/TurretCrawler.tscn"),
	Constants.MobTypes.MOLE: preload("res://entities/Mole.tscn"),
	Constants.MobTypes.LOVE_BULL: preload("res://entities/LoveBull.tscn"),
	Constants.MobTypes.MINI_TURRET_CRAWLER: preload("res://entities/MiniTurretCrawler.tscn"),
	Constants.MobTypes.ROMANS_BOSS: preload("res://entities/RomansBoss.tscn")
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
			projectile.init(spawn_pos, dir, 10, packet.id, packet.team)
			add_child(projectile)
		Constants.PacketTypes.SPAWN_MOB:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var entity_type = int(packet.mob_type)
			var scene = mob_type_scenes[entity_type] 
			var entity = scene.instance()
			entity.entity = Entity.new(entity, packet.id, Constants.Teams.BAD_GUYS, spawn_pos)
			add_child(entity)
		Constants.PacketTypes.SPAWN_ENVIRONMENT:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var entity_type = int(packet.environment_type)
			var scene = environment_type_scenes[entity_type] 
			var entity = scene.instance()
			entity.entity = Entity.new(entity, packet.id, Constants.Teams.NONE, spawn_pos)
			add_child(entity)
		Constants.PacketTypes.SPAWN_ITEM:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var item = item_scene.instance()
			item.entity = Entity.new(item, packet.id, Constants.Teams.NONE, spawn_pos)
			item.init(int(packet.item_type)) 
			add_child(item)
		Constants.PacketTypes.PING:
			var response_time = OS.get_ticks_msec() - packet.send_time
			print("Pong! Response time: " + str(response_time) + " milliseconds")
		Constants.PacketTypes.SPAWN_PART:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var drop_scene = preload("res://entities/PartDrop.tscn")
			var drop = drop_scene.instance()
			drop.init(spawn_pos, int(packet.part))
			add_child(drop)
