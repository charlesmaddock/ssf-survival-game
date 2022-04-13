extends YSort


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SHOOT_PROJECTILE:
		var spawn_pos = Vector2(packet.posX, packet.posY)
		var dir = Vector2(packet.dirX, packet.dirY)
		var projectile_scene = preload("res://entities/Projectile.tscn")
		var projectile = projectile_scene.instance()
		add_child(projectile)
		projectile.fire(spawn_pos, dir)

