extends KinematicBody2D


export var _walk_distance = 70
export var _walk_speed = 70
export var _time_before_new_walk: float = 1.5
export var _charge_max_speed: float = 180
export var _friction: float = 1
export var _friction_time_multiplier: float = 1.0
export var _time_before_charge: float = 1.4
export var _time_before_knockdown_stopped: float = 1.5

onready var ray_cast_solid_detection: Node2D = $RayCastSolidDetection
onready var sprite: Sprite = $Sprite
onready var animationPlayer: AnimationPlayer = $AnimationPlayer

onready var timer_before_new_walk: Timer = $TimerBeforeNewWalk
onready var timer_before_charge: Timer = $TimerBeforeCharge
onready var timer_before_knockdown_stopped: Timer = $TimerBeforeKnockdownStopped
onready var timer_if_walk_never_ends: Timer = $TimerIfWalkNeverEnds

var entity: Entity
var _is_animal = true
var boss_node


var _target_walk_destination: Vector2 = Vector2.ZERO
var _target_charge_direction: Vector2 = Vector2.ZERO
var _array_of_detected_players: Array = []
var _current_friction: float

var behaviourState = behaviourStates.AIMLESS_WANDERING

enum behaviourStates {
	AIMLESS_WANDERING,
	CHARGE,
	KNOCKED_OUT,
	MOTIONLESS,
} 


func _ready() -> void:
	_current_friction = _friction
	
	timer_if_walk_never_ends.set_wait_time(2.0)
	timer_before_new_walk.set_wait_time(_time_before_new_walk)
	timer_before_charge.set_wait_time(_time_before_charge)
	timer_before_knockdown_stopped.set_wait_time(_time_before_knockdown_stopped)

func init(boss_node_id: String):
	boss_node = Util.get_entity(boss_node_id)


func _process(delta) -> void:
	if behaviourState == behaviourStates.AIMLESS_WANDERING:
		if _array_of_detected_players.size() > 0:
			behaviourState = behaviourStates.MOTIONLESS
			_target_charge_direction = self.global_position.direction_to(_get_closest_nearby_player().global_position.normalized())
			print("am in aimless and this is my future target dir: ", _target_charge_direction)
			timer_before_charge.start()
			
		else:
			if timer_before_new_walk.is_stopped():
				
				if _target_walk_destination == Vector2.ZERO:
					_walk_to_random_destination()
				else:
					if !animationPlayer.is_playing():
						print("telling animation to play in aimless_wandering")
						animationPlayer.play("Walking", -1, 1)
					
					self.global_position += self.global_position.direction_to(_target_walk_destination).normalized() * _walk_speed * delta
					if self.global_position.distance_to(_target_walk_destination) < 15:
						timer_before_new_walk.start()
			else:
				if animationPlayer.is_playing():
					animationPlayer.stop()
					sprite.set_frame(0)
		
	if behaviourState == behaviourStates.CHARGE:
		if !animationPlayer.is_playing():
			print("telling animation to play in charge")
			animationPlayer.play("Walking", -1, 1.5)
			
		# _current_friction == _friction always at the beginning of a charge
		# currently the friciton does not taper off exponentially
		
		_current_friction -= clamp((delta / _friction_time_multiplier), 0, 1) * _friction
		_current_friction = clamp(_current_friction, 0, 99999)
		print("Current fric: ", _current_friction, " and this the subtraction of it next: ", clamp((delta / _friction_time_multiplier), 0, 1) * _friction)
		var velocity: float = _charge_max_speed - _current_friction 
#		var velocity: float = _charge_max_speed 
		self.global_position += _target_charge_direction * velocity * delta
		
	if behaviourState == behaviourStates.MOTIONLESS:
		if animationPlayer.is_playing():
			animationPlayer.stop()
			sprite.set_frame(0)

func _walk_to_random_destination() -> void:
	timer_if_walk_never_ends.stop()
	var possible_y_range: Vector2 = Vector2(-1, 1)
	var possible_x_range: Vector2 = Vector2(-1, 1)
	var wall_data = ray_cast_solid_detection.is_colliding_with_layers([Constants.collisionLayers.SOLID, Constants.collisionLayers.ANIMAL])
	if wall_data != []:
		for raycast in wall_data:
			match(raycast["ray_cast_name"]):
				"Up":
					possible_y_range.x += 1
				"Down":
					possible_y_range.y -= 1
				"Left":
					possible_x_range.x += 1
				"Right":
					possible_x_range.y -= 1
	print("New walk, these are my ranges. Up-down: ", possible_y_range, " left-right: ", possible_x_range)
	var random_direction: Vector2 = Vector2(rand_range(possible_x_range.x, possible_x_range.y), rand_range(possible_y_range.x, possible_y_range.y)).normalized()
	var random_destination: Vector2 = global_position + random_direction * _walk_distance
	_target_walk_destination = random_destination
	timer_if_walk_never_ends.start()


func _get_closest_nearby_player() -> Object:
	var closest_player
	var distance_to_closest_player = 99999
	
	for player in _array_of_detected_players:
		var distance_between_positions = self.global_position.distance_to(player.global_position)
		
		if distance_between_positions < distance_to_closest_player:
			distance_to_closest_player = distance_between_positions
			closest_player = player
	
	return closest_player


func _on_PlayerDetectionArea_body_entered(body):
	if _array_of_detected_players.find(body) == -1:
		print("this guy entered and has pos: ", body, " ", body.global_position)
		_array_of_detected_players.append(body)


func _on_PlayerDetectionArea_body_exited(body):
	if _array_of_detected_players.find(body) != -1:
		_array_of_detected_players.erase(body)


func _on_TimeBeforeCharging_timeout():
	print("Time to charge - timer is up!")
	timer_before_new_walk.stop()
	behaviourState = behaviourStates.CHARGE


func _on_TimerBeforeKnockdownStop_timeout():
	pass # Replace with function body.


func _on_TimerIfWalkNeverEnds_timeout():
	_target_walk_destination = Vector2.ZERO
