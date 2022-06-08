extends KinematicBody2D

export(bool) var _is_mini: bool = false
export(int) var _spiders_to_spawn: int = 3
export(float) var _dashing_interval = 2.5
export(float) var _dashing_interval_variability = 0.5
export(float) var _dashing_time = 0.5
export(float) var _dashing_multiplier: float = 150
export(int) var _player_detection_radius: int = 80
export(int) var _ray_cast_length_multiplier = 1


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
var _is_first_jumping: bool = false
var _random_jump_dir: Vector2 


func _ready():
	player_detection_node.get_node("CollisionShape2D").shape.set_radius(_player_detection_radius)
	
	if _is_mini:
		_is_first_jumping = true
		player_detection_node.get_node("CollisionShape2D").set_disabled(true)
		health_node.set_invinsible(true)
		damage_node.deactivate_damage()
		_start_dash()
	else: 
		_start_dash_timer()

func _process(delta):
	health_node.global_position = intact_turret_sprite.global_position

func _start_dash() -> void:
	if Lobby.is_host:
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
			var closest_player_pos = _get_closest_nearby_player().global_position
			initial_dir = self.global_position.direction_to(closest_player_pos)
		
		var final_dir = initial_dir * _dashing_multiplier
		
		# CHARLES - kommer inte fungera om !is_host
		animationPlayer.play("Jump", -1, 1 / _dashing_time)
		yield(self.get_tree().create_timer(0.05), "timeout")
		entity.emit_signal("dashed", final_dir)


func _start_dash_timer() -> void:
	var dash_time = _dashing_interval
	dash_time += rand_range(-_dashing_interval_variability, _dashing_interval_variability)
	dash_timer_node.start(dash_time)


func _get_closest_nearby_player() -> Object:
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


func _on_DashTimer_timeout():
	_start_dash()


func _on_PlayerDetection_body_entered(body):
	_nearby_players.append(body)


func _on_PlayerDetection_body_exited(body):
	_nearby_players.erase(body)


func _on_AnimationPlayer_animation_finished(anim_name):
	if _is_first_jumping:
		_is_first_jumping = false
		health_node.set_invinsible(false)
		damage_node.activate_damage()
		player_detection_node.get_node("CollisionShape2D").set_disabled(false)
		yield(self.get_tree().create_timer(0.5), "timeout")
	
	dash_timer_node.start()


func _on_TurretCrawler_tree_exiting():
	intact_turret_sprite.set_visible(false)
	broken_turret_sprite.set_visible(true)

	if Lobby.is_host && !_is_mini:
		for i in _spiders_to_spawn:
				Server.spawn_mob(Util.generate_id(), Constants.MobTypes.MINI_TURRET_CRAWLER, self.global_position + Vector2(0, 5))

