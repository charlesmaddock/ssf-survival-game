extends KinematicBody2D


onready var AI_node: Node2D = $AI
onready var movement_node: Node2D = $Movement
onready var sprite: Sprite = $Sprite
onready var ray_cast_solid_detection: Node2D = $RayCastSolidDetection
onready var slap_range_detection: Node2D = $SlapRangeDetection

onready var timer_before_phase_1_new_walk: Timer = $TimerBeforePhase1NewWalk
onready var timer_if_walk_never_ends: Timer = $TimerIfWalkNeverEnds
onready var timer_before_knocked_out_finished: Timer = $TimerBeforeKnockedOutFinished
onready var timer_between_mob_spit: Timer = $TimerBetweenMobSpit

onready var _target_walk_destination: Vector2 = self.global_position

export(Vector2) var head_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_scale: Vector2 = Vector2(0.7, 0.7)
export(float) var _hand_distance_from_head: float = 180
export(int) var _movement_speed: int = 70
export(float) var _walk_distance: float = 100
export(float) var _time_before_new_walk: float = 1
export(float) var _time_if_walk_never_ends: float = 2
export(float) var _knocked_out_time: float = 3.2
export(float) var _time_between_mob_spits: float = 10

export(int) var clouders_spawned: int = 4
export(int) var chowders_spawned: int = 1
var _health = 3


var entity: Entity
var _is_animal = true
var slapHand: Node
var spindelhand: Node
var slap_hand_id = "RomansBossSlapHand"
var spindelhand_id = "SpindelHand"

var _players_in_slapping_range: Array = []
var _is_slapping: bool = false
var _is_spitting: bool = false

var _behaviour_state: int = behaviourStates.NEUTRAL

enum behaviourStates {
	NEUTRAL,
	SLAPPING,
	KNOCKED_OUT
} 


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	
	if Lobby.is_host == true:
		entity.emit_signal("change_movement_speed", _movement_speed)
		AI_node.motionless_behaviour()
		
		self.set_scale(head_scale)
		_spawn_hands()
		
		timer_between_mob_spit.set_wait_time(_time_between_mob_spits)
		timer_before_knocked_out_finished.set_wait_time(_knocked_out_time)
		timer_before_phase_1_new_walk.set_wait_time(_time_before_new_walk)
		timer_if_walk_never_ends.set_wait_time(_time_if_walk_never_ends)
		
		yield(get_tree().create_timer(10), "timeout")
		spawn_mob_spit()


func _process(delta):
	if Lobby.is_host == true:
		Server.set_sprite_frame(0, self.entity.id)
		if _behaviour_state == behaviourStates.NEUTRAL:
			if timer_between_mob_spit.is_stopped() && !_is_spitting:
				match(_health):
					3:
						timer_between_mob_spit.start(_time_between_mob_spits)
					2:
						timer_between_mob_spit.start(_time_between_mob_spits * 2)
					1:
						timer_between_mob_spit.start(_time_between_mob_spits * 3)
			if _target_walk_destination != Vector2.ZERO:
				if self.global_position.distance_to(_target_walk_destination) < 10 or timer_if_walk_never_ends.is_stopped():
					_target_walk_destination = Vector2.ZERO
					AI_node.motionless_behaviour()
					if _players_in_slapping_range.size() > 0:
						_behaviour_state = behaviourStates.SLAPPING
						var slap_target = AI_node.get_closest_player()
						slapHand.set_slapping_behaviour(slap_target)
					else:
						timer_before_phase_1_new_walk.start()
		elif _behaviour_state == behaviourStates.KNOCKED_OUT:
			Server.set_sprite_frame(2, self.entity.id)


func spawn_mob_spit():
	if Lobby.is_host == true:
		_is_spitting = true
		var mob_type: int
		var spawn_amount = _health
		var mob_spit_time
		match(_health):
			3:
				mob_type = Constants.MobTypes.CLOUDER
				mob_spit_time = _time_between_mob_spits
			2:
				mob_type = Constants.MobTypes.MOLE
				mob_spit_time = _time_between_mob_spits + 10
			1:
				mob_type = Constants.MobTypes.CHOWDER
				mob_spit_time = _time_between_mob_spits + 20
			
		for i in spawn_amount:
			Server.set_sprite_frame(1, self.entity.id)
			Server.spawn_mob(Util.generate_id(), mob_type, self.global_position + Vector2(0, 40), -1)
			yield(get_tree().create_timer(0.3), "timeout")
			Server.set_sprite_frame(0, self.entity.id)
			yield(get_tree().create_timer(0.3), "timeout")


func _walk_to_random_destination() -> void:
	if Lobby.is_host == true:
	#	print("calling new walk!")
		var possible_y_range: Vector2 = Vector2(-1, 1)
		var possible_x_range: Vector2 = Vector2(-1, 1)
		var wall_data = ray_cast_solid_detection.is_colliding_with_layers([Constants.collisionLayers.SOLID])
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
	#	print("This is the rand ranges for walking i am working with. Up-down: ", possible_y_range, " left-right: ", possible_x_range)
		var random_direction: Vector2 = Vector2(rand_range(possible_x_range.x, possible_x_range.y), rand_range(possible_y_range.x, possible_y_range.y)).normalized()
		var random_destination: Vector2 = global_position + random_direction * _walk_distance
		_target_walk_destination = random_destination
		AI_node.custom_behaviour()
		yield(get_tree().create_timer(0.1), "timeout")
		AI_node.set_target_walking_path(random_destination)
		timer_if_walk_never_ends.start()


func _spawn_hands():
	if Lobby.is_host == true:
		var slap_hand_position: Vector2
		var spindehand_position: Vector2
		
		if Lobby.is_host == true:
			slap_hand_position = Vector2((self.global_position.x - _hand_distance_from_head), self.global_position.y)
			Server.spawn_mob(slap_hand_id, Constants.MobTypes.ROMANS_BOSS_SLAP_HAND_FAS_2, slap_hand_position, -1)
			spindehand_position = self.global_position + Vector2(100, 100)
			Server.spawn_mob(spindelhand_id, Constants.MobTypes.SPINDELHAND, spindehand_position, -1)
		
		yield(get_tree().create_timer(0.1), "timeout")
		
		slapHand = Util.get_entity(slap_hand_id)
		slapHand.set_scale(hand_scale)
		slapHand.init(slap_hand_position.distance_to(self.global_position), self.entity.id)
		slapHand.connect("slapping_done", self, "_on_slapping_done")
		
		spindelhand = Util.get_entity(spindelhand_id)
		spindelhand.set_scale(hand_scale)
		spindelhand.init(self.entity.id)
		spindelhand.connect("collided_with_boss", self, "_on_collided_with_boss")
	#	spindelhand.connect()


func _on_slapping_done() -> void:
	if Lobby.is_host == true:
	#	print("slapping is donne so i am calling new walk destination and setting neutral")
		yield(get_tree().create_timer(0.8), "timeout")
		slapHand.set_hovering_behaviour()
		_walk_to_random_destination()
		_behaviour_state = behaviourStates.NEUTRAL


func _on_collided_with_boss() -> void:
	if Lobby.is_host == true:
		timer_before_knocked_out_finished.start()
		_behaviour_state = behaviourStates.KNOCKED_OUT
		slapHand.set_knocked_out_behaviour()
	
		_health -= -1
		if _health <= 0:
			Server.despawn_mob(slap_hand_id)
			Server.despawn_mob(spindelhand_id)
			Server.despawn_mob(self.entity.id)


func _on_TimerBeforePhase1NewWalk_timeout():
	if Lobby.is_host == true:
		if _behaviour_state == behaviourStates.NEUTRAL:
			_walk_to_random_destination()


func _on_SlapRangeDetection_body_entered(body):
	if Lobby.is_host == true:
		_players_in_slapping_range.append(body)


func _on_SlapRangeDetection_body_exited(body):
	if Lobby.is_host == true:
		if _players_in_slapping_range.find(body) != -1:
			_players_in_slapping_range.erase(body)


func _on_TimerBeforeKnockedOutFinished_timeout():
	if Lobby.is_host == true:
		Server.set_sprite_frame(0, self.entity.id)
		_behaviour_state = behaviourStates.NEUTRAL
		slapHand.set_hovering_behaviour()


func _on_TimerBetweenMobSpit_timeout():
	if Lobby.is_host == true:
		spawn_mob_spit()


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SET_SPRITE_FRAME:
		if packet.id == self.entity.id:
			sprite.set_frame(packet.frame)
