extends KinematicBody2D


export var _walk_distance = 70
export var _walk_speed = 70
export var _time_before_new_walk: float = 1.5
export var _charge_max_speed: float = 180
export var _friction: float = 1
export var _friction_time_multiplier: float = 1.0
export var _time_before_charge: float = 1.4
export var _time_before_knockdown_stopped: float = 1.5
export var time_for_if_collided_downtime: float = 1.0

onready var ray_cast_solid_detection: Node2D = $RayCastSolidDetection
onready var sprite: Sprite = $Sprite
onready var animationPlayer: AnimationPlayer = $AnimationPlayer

onready var timer_before_new_walk: Timer = $TimerBeforeNewWalk
onready var timer_before_charge: Timer = $TimerBeforeCharge
onready var timer_before_knockdown_stopped: Timer = $TimerBeforeKnockdownStopped
onready var timer_if_walk_never_ends: Timer = $TimerIfWalkNeverEnds
onready var timer_for_if_collided_downtime: Timer = $TimerForIfCollidedDowntime

var entity: Entity
var _is_animal = true
var boss_node


var _target_walk_destination: Vector2 = Vector2.ZERO
var _target_charge_direction: Vector2 = Vector2.ZERO
var _array_of_detected_players: Array = []
var _current_friction: float 
var _just_collided: bool = false
var _just_collided_collider_pos_: Vector2 = Vector2()
var _must_walk_once_after_knockout: bool = false

var behaviourState = behaviourStates.AIMLESS_WANDERING

enum behaviourStates {
	AIMLESS_WANDERING,
	CHARGE,
	KNOCKED_OUT,
	MOTIONLESS,
} 

signal collided_with_boss()

func _ready() -> void:
	Server.connect("packet_received", self, "_on_packet_received")
	
	if Lobby.is_host == true:
		_current_friction = _friction
		
		timer_if_walk_never_ends.set_wait_time(2.0)
		timer_before_new_walk.set_wait_time(_time_before_new_walk)
		timer_before_charge.set_wait_time(_time_before_charge)
		timer_before_knockdown_stopped.set_wait_time(_time_before_knockdown_stopped)
		timer_for_if_collided_downtime.set_wait_time(time_for_if_collided_downtime)

func init(boss_node_id: String):
	boss_node = Util.get_entity(boss_node_id)


func _physics_process(delta) -> void:
	if Lobby.is_host == true:
		if behaviourState == behaviourStates.AIMLESS_WANDERING:
			if _array_of_detected_players.size() > 0 && timer_for_if_collided_downtime.is_stopped() && !_must_walk_once_after_knockout:
				_target_charge_direction = self.global_position.direction_to(_get_closest_nearby_player().global_position).normalized()
				behaviourState = behaviourStates.MOTIONLESS
#				print("am in aimless and this is my future target dir: ", _target_charge_direction)
				timer_before_charge.start()
				
			else:
				if timer_before_new_walk.is_stopped():
					
					if _target_walk_destination == Vector2.ZERO:
#						print("calling new walk")
						_walk_to_random_destination()
					else:
						if !animationPlayer.is_playing():
							Server.set_animation_player("Walking", 1, false, self.entity.id)
							
						self.move_and_slide(self.global_position.direction_to(_target_walk_destination).normalized() * _walk_speed)
						if self.get_slide_collision(0) && timer_for_if_collided_downtime.is_stopped():
							timer_before_new_walk.start() 
							_target_walk_destination = Vector2.ZERO
							_just_collided_collider_pos_ = self.get_slide_collision(0).position
							_just_collided = true
							_must_walk_once_after_knockout = false
						elif self.global_position.distance_to(_target_walk_destination) < 15:
							timer_before_new_walk.start()
							_target_walk_destination = Vector2.ZERO
							_must_walk_once_after_knockout = false
				else:
					if animationPlayer.is_playing():
						Server.set_animation_player("Walking", 1, true, self.entity.id)
						Server.set_sprite_frame(0, self.entity.id)
			
		elif behaviourState == behaviourStates.CHARGE:
			if !animationPlayer.is_playing():
				Server.set_animation_player("Walking", 1.5, false, self.entity.id)
				
			# _current_friction == _friction always at the beginning of a charge
			# currently the friciton does not taper off exponentially
			
			_current_friction -= clamp((delta / _friction_time_multiplier), 0, 1) * _friction
			_current_friction = clamp(_current_friction, 0, 99999)
	#		print("Current fric: ", _current_friction, " and this the subtraction of it next: ", clamp((delta / _friction_time_multiplier), 0, 1) * _friction)
			var velocity: float = _charge_max_speed - _current_friction 
	#		var velocity: float = _charge_max_speed 
			self.move_and_slide(_target_charge_direction * velocity)
			if self.get_slide_collision(0):
				behaviourState = behaviourStates.KNOCKED_OUT
#				print("I collided with ", self.get_slide_collision(0).collider.get_name())
				if self.get_slide_collision(0).collider == boss_node:
#					print("it was the boss so i emit signal")
					emit_signal("collided_with_boss")
				_just_collided_collider_pos_ = self.get_slide_collision(0).position
				_just_collided = true
				_must_walk_once_after_knockout = true
				Server.set_animation_player("Walking", 1, true, self.entity.id)
				Server.set_sprite_frame(2, self.entity.id)
				timer_before_knockdown_stopped.start()
			
		elif behaviourState == behaviourStates.MOTIONLESS:
			if animationPlayer.is_playing():
				Server.set_animation_player("Walking", 1, true, self.entity.id)
				Server.set_sprite_frame(0, self.entity.id)
			
		elif behaviourState == behaviourStates.KNOCKED_OUT:
			pass


func _walk_to_random_destination() -> void:
	if Lobby.is_host == true:
		timer_if_walk_never_ends.stop()
		if _just_collided != true:
			var possible_y_range: Vector2 = Vector2(-1, 1)
			var possible_x_range: Vector2 = Vector2(-1, 1)
			var wall_data = ray_cast_solid_detection.is_colliding_with_layers([Constants.collisionLayers.SOLID, Constants.collisionLayers.ANIMAL])
		#	if wall_data != []:
		#		for raycast in wall_data:
		#			match(raycast["ray_cast_name"]):
		#				"Up":
		#					possible_y_range.x += 1
		#				"Down":
		#					possible_y_range.y -= 1
		#				"Left":
		#					possible_x_range.x += 1
		#				"Right":
		#					possible_x_range.y -= 1
#			print("New walk, these are my ranges. Up-down: ", possible_y_range, " left-right: ", possible_x_range)
			var random_direction: Vector2 = Vector2(rand_range(possible_x_range.x, possible_x_range.y), rand_range(possible_y_range.x, possible_y_range.y)).normalized()
			var random_destination: Vector2 = global_position + random_direction * _walk_distance
			_target_walk_destination = random_destination
			
		else:
			if _just_collided_collider_pos_ != Vector2.ZERO:
				_target_walk_destination = self.global_position + (-self.global_position.direction_to(_just_collided_collider_pos_) * _walk_distance)
			else:
				_target_walk_destination = global_position + Vector2(-100, -50)
#			print("doing a walk after knocked out, this is my target: ", _target_walk_destination, "this is slide collpos: ", _just_collided_collider_pos_, " and this is my pos: ", self.global_position)
			_just_collided = false
		timer_for_if_collided_downtime.start()
		timer_if_walk_never_ends.start()


func _get_closest_nearby_player() -> Object:
	var closest_player
	var distance_to_closest_player = 99999
	
	for player in Util.get_living_players():
		var distance_between_positions = self.global_position.distance_to(player.global_position)
		
		if distance_between_positions < distance_to_closest_player:
			distance_to_closest_player = distance_between_positions
			closest_player = player
	
	return closest_player


func _on_PlayerDetectionArea_body_entered(body):
	if Lobby.is_host == true:
		if _array_of_detected_players.find(body) == -1:
			_array_of_detected_players.append(body)


func _on_PlayerDetectionArea_body_exited(body):
	if Lobby.is_host == true:
		if _array_of_detected_players.find(body) != -1:
			_array_of_detected_players.erase(body)


func _on_TimeBeforeCharging_timeout():
	if Lobby.is_host == true:
		timer_before_new_walk.stop()
		behaviourState = behaviourStates.CHARGE


func _on_TimerBeforeKnockdownStop_timeout():
	if Lobby.is_host == true:
		behaviourState = behaviourStates.AIMLESS_WANDERING


func _on_TimerIfWalkNeverEnds_timeout():
	if Lobby.is_host == true:
		_target_walk_destination = Vector2.ZERO

func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SET_SPRITE_FRAME:
		if packet.id == self.entity.id:
			sprite.set_frame(packet.frame)
	elif packet.type == Constants.PacketTypes.SET_ANIMATION_PLAYER:
		if packet.id == self.entity.id:
			print("spindelhanden told to play animation: ", packet.animation_name, " and stop is: ", packet.stop_animation)
			if packet.stop_animation != true:
				animationPlayer.play(packet.animation_name, -1, packet.animation_speed)
			else:
				animationPlayer.stop()
