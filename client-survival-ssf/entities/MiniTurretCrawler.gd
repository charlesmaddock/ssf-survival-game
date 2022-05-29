extends KinematicBody2D


export(int) var _movement_speed = 40
export(float) var _dashing_interval = 2.5
export(float) var _dashing_time = 0.5
export(float) var _dashing_multiplier: float = 150
export(int) var _player_detection_radius: int = 48
export(int) var _ray_cast_length_multiplier = 1

export(float) var _jump_speed: float = 50.0

onready var intact_turret_sprite: Sprite = $IntactTurret
onready var broken_turret_sprite: Sprite = $BrokenTurret
onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var health_node: Node2D = $Health
onready var player_detection_node = $PlayerDetection
onready var ray_cast_wall_detection = $RayCastContainerWallDetection
onready var damage_node = $Damage
onready var AI_node = $AI
onready var movement_node: Node2D = $Movement

onready var dash_timer_node: Timer = $DashTimer
onready var stop_dashing_timer_node: Timer = $StopDashingTimer


var entity: Entity
var _is_animal = true

var _nearby_players: Array = []
var _is_dashing: bool = false
var _has_dashed: bool = false
var _is_first_jumping: bool = true
var _random_jump_dir: Vector2 


func _ready():
	health_node.set_invinsible(true)
	AI_node.custom_behaviour()
	damage_node.deactivate_damage()
	randomize()
	_random_jump_dir = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()


func _process(delta):
	if _is_first_jumping && Lobby.is_host():
		self.global_position += (_random_jump_dir * delta) * _jump_speed


func get_closest_player() -> Object:
	
	var closest_player
	var distance_to_closest_player = 99999
	for player in _nearby_players:
		var distance_between_positions = self.global_position.distance_to(player.global_position)
		if distance_between_positions < distance_to_closest_player:
			distance_to_closest_player = distance_between_positions
			closest_player = player
	return closest_player


func _detect_walls() -> Array:
	return ray_cast_wall_detection.is_colliding_with_layers([Constants.collisionLayers.SOLID])


func on_damage_taken(health, dir) -> void:
	
	if health <= 0:
		if Lobby.is_host == true:
			Server.despawn_mob(entity.id)


func _on_DashTimer_timeout():
	
	if _has_dashed == false:
		
		_is_dashing = true
		
		var initial_dir: Vector2
		var left_right: Vector2 = Vector2(-1, 1)
		var up_down: Vector2 = Vector2(-1, 1)
		var detected_walls: Array = _detect_walls()
		
		randomize()
		
		if !_nearby_players.size() != 0:
			if detected_walls.size() != 0:
				for rayCast in detected_walls:
					match(rayCast["ray_cast_name"]):
						"Up":
							up_down = Vector2(0, 1)
						"Down":
							up_down = Vector2(0, -1)
						"Left":
							left_right = Vector2(0, 1)
						"Right":
							left_right = Vector2(0, -1)
						
			initial_dir = Vector2(rand_range(left_right.x, left_right.y), rand_range(up_down.x, up_down.y))
		else:
			var closest_player_pos = get_closest_player().global_position
			initial_dir = self.global_position.direction_to(closest_player_pos) / 1.5
		
		var final_dir = initial_dir * _dashing_multiplier
		
		animationPlayer.play("Jump", -1, 1 / _dashing_time)
		yield(self.get_tree().create_timer(0.05), "timeout")
		entity.emit_signal("dashed", final_dir)
		_has_dashed = true


#func _on_StopDashingTimer_timeout():
#
#	AI_node.stop_moving()
#	_is_dashing = false
#	_has_dashed = false
#	dash_timer_node.start()



func _on_PlayerDetection_body_entered(body):
	
	_nearby_players.append(body)


func _on_PlayerDetection_body_exited(body):
	
	_nearby_players.erase(body)


func _on_AnimationPlayer_animation_finished(anim_name):
	if _is_first_jumping == true:
		_is_first_jumping = false
		health_node.set_invinsible(false)
		damage_node.activate_damage()
		player_detection_node.get_node("CollisionShape2D").shape.set_radius(_player_detection_radius)
		entity.emit_signal("change_movement_speed", _movement_speed)
		dash_timer_node.set_wait_time(_dashing_interval)
		yield(self.get_tree().create_timer(0.5), "timeout")
		_on_DashTimer_timeout()
	elif _is_first_jumping == false:
		AI_node.stop_moving()
		_is_dashing = false
		_has_dashed = false
		dash_timer_node.start()



#func _on_MiniTurretCrawler_tree_exiting():
##	intact_turret_sprite.set_visible(false)
##	broken_turret_sprite.set_visible(true)
##	yield(get_tree().create_timer(1), "timeout")
	
