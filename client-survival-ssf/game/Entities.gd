extends YSort


var item_scene = preload("res://entities/Item.tscn")
var pino_scene: PackedScene = preload("res://entities/Pino_3.tscn")


var projectile_scenes: Dictionary = {
	Constants.ProjectileTypes.RED_BULLET: preload("res://entities/RedBullet.tscn"),
	Constants.ProjectileTypes.BLUE_BULLET: preload("res://entities/BlueBullet.tscn"),
	Constants.ProjectileTypes.KISS: preload("res://entities/KissProjectile.tscn"),
	Constants.ProjectileTypes.HEART: preload("res://entities/HeartProjectile.tscn"),
	Constants.ProjectileTypes.CD: preload("res://entities/CDProjectile.tscn"),
}

var mob_type_scenes: Dictionary = {
	Constants.MobTypes.CLOUDER: preload("res://entities/Clouder.tscn"),
	Constants.MobTypes.CHOWDER: preload("res://entities/Chowder.tscn"),
	Constants.MobTypes.TURRET_CRAWLER: preload("res://entities/TurretCrawler.tscn"),
	Constants.MobTypes.MOLE: preload("res://entities/Mole.tscn"),
	Constants.MobTypes.LOVE_BULL: preload("res://entities/LoveBull.tscn"),
	Constants.MobTypes.MINI_TURRET_CRAWLER: preload("res://entities/MiniTurretCrawler.tscn"),
	Constants.MobTypes.BOSS: preload("res://entities/Boss.tscn"),
}

var environment_type_scenes: Dictionary = {
	Constants.EnvironmentTypes.SPIKES: preload("res://entities/Spikes.tscn"),
	Constants.EnvironmentTypes.CHIP: preload("res://entities/Chip.tscn"),
	Constants.EnvironmentTypes.HEART_CHEST: preload("res://entities/Chest.tscn"),
	Constants.EnvironmentTypes.PART_CHEST: preload("res://entities/PartChest.tscn"),
	Constants.EnvironmentTypes.REVIVE_DISK: preload("res://entities/BackupDisk.tscn"),
}


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	_spawn_pino(Constants.TILE_SIZE * 4)


func _spawn_pino(pino_global_position: Vector2) -> void:
	var pino: Node2D = pino_scene.instance()
	pino.global_position = pino_global_position
	var entities: YSort = $"../Entities"
	entities.add_child(pino)


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
			var add_dir = Vector2(packet.add_dirX, packet.add_dirY)
			var projectile_scene = projectile_scenes[int(packet.p_type)]
			var projectile = projectile_scene.instance()
			projectile.init(spawn_pos, dir, packet.damage, packet.id, packet.team, add_dir)
			add_child(projectile)
		Constants.PacketTypes.SPAWN_MOB:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var entity_type = int(packet.mob_type)
			var scene = mob_type_scenes[entity_type] 
			var entity = scene.instance()
			entity.entity = Entity.new(entity, packet.id, Constants.Teams.BAD_GUYS, spawn_pos, packet.room_id)
			add_child(entity)
			entity.global_position = spawn_pos
			
			if Lobby.is_host:
				Server.teleport_entity(packet.id, spawn_pos)
		Constants.PacketTypes.SPAWN_ENVIRONMENT:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var entity_type = int(packet.environment_type)
			var scene = environment_type_scenes[entity_type] 
			var entity = scene.instance()
			entity.entity = Entity.new(entity, packet.id, Constants.Teams.BAD_GUYS, spawn_pos, packet.room_id)
			add_child(entity)
		Constants.PacketTypes.SPAWN_ITEM:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var item = item_scene.instance()
			item.entity = Entity.new(item, packet.id, Constants.Teams.NONE, spawn_pos, -1)
			item.init(int(packet.item_type)) 
			add_child(item)
		Constants.PacketTypes.PING:
			var response_time = OS.get_ticks_msec() - packet.send_time
			print("Pong! Response time: " + str(response_time) + " milliseconds")
		Constants.PacketTypes.SPAWN_PART:
			var spawn_pos = Vector2(packet.posX, packet.posY)
			var drop_scene = preload("res://entities/PartDrop.tscn")
			var drop = drop_scene.instance()
			drop.init(packet.id, spawn_pos, int(packet.part))
			add_child(drop)
