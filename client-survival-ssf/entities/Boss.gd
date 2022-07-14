extends KinematicBody2D


onready var normal_boss_sprite = $Boss
onready var angry_boss_sprite = $BossAngry
onready var hit_boss_sprite = $BossHit
onready var shooting_boss_sprite = $BossShooting
onready var animation_player = $AnimationPlayer 
onready var boss_hitbox_shape = $BossHitbox/shape 


var entity: Entity 

var bouncing_around: bool = false
var shooting_hearts: bool = false
var bounce_dir: Vector2 = Vector2.DOWN
var lives: int = 3
var invinsible: bool = true


func _ready():
	show_boss_sprite(shooting_boss_sprite)
	Events.emit_signal("focus_camera", global_position + Vector2.UP * 32, 1.5)
	Server.connect("packet_received", self, "_on_packet_received")
	
	yield(get_tree().create_timer(1), "timeout")
	enter_bounce_mode()
	entity.id = "boss"


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.BOSS_EVENT:
			if packet.event == Constants.BossEvent.HIT:
				lose_life()
			elif packet.event == Constants.BossEvent.SHOOT_MODE:
				enter_shoot_mode()


func _process(delta):
	if bouncing_around == true:
		if Lobby.is_host:
			move_and_slide(bounce_dir * 310)


func show_boss_sprite(sprite: Sprite) -> void:
	normal_boss_sprite.visible = false
	angry_boss_sprite.visible = false
	hit_boss_sprite.visible = false
	shooting_boss_sprite.visible = false
	
	sprite.visible = true


func enter_bounce_mode() -> void:
	if bouncing_around == false && lives > 0:
		invinsible = true
		show_boss_sprite(normal_boss_sprite)
		shooting_hearts = false
		_on_DetectSolid_body_entered(null)
		animation_player.play("enterBounceMode")
		yield(get_tree().create_timer(0.9), "timeout")
		$BounceModeTimer.start()
		bouncing_around = true


func enter_shoot_mode() -> void:
	if shooting_hearts == false:
		bouncing_around = false
		shooting_hearts = true
		invinsible = false
		
		animation_player.play("enterShootMode")
		
		yield(get_tree().create_timer(0.2), "timeout")
		show_boss_sprite(shooting_boss_sprite)
		yield(get_tree().create_timer(0.1), "timeout")
		if shooting_hearts == false:
			return
		shoot_hearts(12)
		yield(get_tree().create_timer(1), "timeout")
		if shooting_hearts == false:
			return
		shoot_hearts(8)
		yield(get_tree().create_timer(1), "timeout")
		if shooting_hearts == false:
			return
		shoot_hearts(10)
		yield(get_tree().create_timer(1), "timeout")
		if shooting_hearts == false:
			return
		shoot_hearts(8)
		yield(get_tree().create_timer(1), "timeout")
		if shooting_hearts == false:
			return
		shoot_hearts(6)
		yield(get_tree().create_timer(1), "timeout")
		if shooting_hearts == false:
			return
		shoot_hearts(8)
		yield(get_tree().create_timer(0.5), "timeout")
		if shooting_hearts == false:
			return
		
		enter_bounce_mode()


func shoot_hearts(amount) -> void:
	if Lobby.is_host:
		var id = Util.generate_id()
		for angle in range(0, 359, (360 / amount) - 1):
			Server.shoot_projectile(15, global_position, Vector2.RIGHT.rotated(deg2rad(angle)), id, Constants.Teams.BAD_GUYS, Constants.ProjectileTypes.HEART)


func lose_life() -> void:
	if invinsible == false:
		shooting_hearts = false
		invinsible = true
		bouncing_around = false
		
		lives -= 1
		show_boss_sprite(hit_boss_sprite)
		
		$CanvasLayer/Control/HBoxContainer.get_child(lives).modulate = "#52656565"
		
		if lives <= 0:
			$BossHit/AnimationPlayer.play("death")
			set_process(false)
			yield(get_tree().create_timer(4), "timeout")
			Server.despawn_mob("boss")
			Events.emit_signal("game_over", true)
		else:
			$BossHit/AnimationPlayer.play("jump")
			yield($BossHit/AnimationPlayer, "animation_finished")
			show_boss_sprite(angry_boss_sprite)
			$BossAngry/AnimationPlayer.play("shake")
			yield(get_tree().create_timer(1.3), "timeout")
			enter_bounce_mode()


func get_closest_nearby_player():
	var players = Util.get_living_players()
	var closest_player = null
	var distance_to_closest_player = 99999
	
	for player in players:
		var distance_between_positions = self.global_position.distance_to(player.global_position)
		
		if distance_between_positions < distance_to_closest_player:
			distance_to_closest_player = distance_between_positions
			closest_player = player
	
	return closest_player


func _on_DetectSolid_body_entered(body):
	var player = get_closest_nearby_player()
	if player != null:
		bounce_dir = global_position.direction_to(player.global_position)


func _on_BounceModeTimer_timeout():
	if Lobby.is_host:
		Server.send_boss_event(Constants.BossEvent.SHOOT_MODE)


func _on_BossHitbox_body_entered(body):
	if Lobby.is_host:
		Server.send_boss_event(Constants.BossEvent.HIT)


func _on_BossHitbox_area_entered(area):
	if "HeartProjectile" in area.name:
		return
	
	if area.name != "MonsterDetector" && area.name != "BossDamage" && Lobby.is_host:
		Server.send_boss_event(Constants.BossEvent.HIT)

