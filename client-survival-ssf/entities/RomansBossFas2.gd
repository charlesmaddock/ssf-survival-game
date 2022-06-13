extends KinematicBody2D


onready var AI_node: Node2D = $AI
onready var movement_node: Node2D = $Movement
onready var sprite: Sprite = $Sprite
onready var ray_cast_solid_detection: Node2D = $RayCastSolidDetection
onready var slap_range_detection: Node2D = $SlapRangeDetection

onready var timer_before_phase_1_new_walk: Timer = $TimerBeforePhase1NewWalk

onready var _target_walk_destination: Vector2 = self.global_position

export(Vector2) var head_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_scale: Vector2 = Vector2(0.7, 0.7)
export(float) var _hand_distance_from_head: float = 180
export(int) var _movement_speed: int = 70
export(float) var _walk_distance: float = 100
export(float) var _time_before_new_walk: float = 1


export(int) var clouders_spawned: int = 4
export(int) var chowders_spawned: int = 1


var entity: Entity
var _is_animal = true
var slapHand: Node
var spindelhand: Node

var _players_in_slapping_range: Array = []
var _is_slapping: bool = false

var _behaviour_state: int = behaviourStates.NEUTRAL

enum behaviourStates {
	NEUTRAL,
	SLAPPING
} 


func _ready():
	entity.emit_signal("change_movement_speed", _movement_speed)
	AI_node.motionless_behaviour()
	
	self.set_scale(head_scale)
	_spawn_hands()
	
	timer_before_phase_1_new_walk.set_wait_time(_time_before_new_walk)
	yield(get_tree().create_timer(1), "timeout")


func _process(delta):
	if _behaviour_state == behaviourStates.NEUTRAL:
		if _target_walk_destination != Vector2.ZERO:
			if self.global_position.distance_to(_target_walk_destination) < 10:
				_target_walk_destination = Vector2.ZERO
				AI_node.motionless_behaviour()
				if _players_in_slapping_range.size() > 0:
					_behaviour_state = behaviourStates.SLAPPING
					var slap_target = AI_node.get_closest_player()
					slapHand.set_slapping_behaviour(slap_target)
				else:
					timer_before_phase_1_new_walk.start()

func _slap_nearby_player() -> void:
	pass

func _walk_to_random_destination() -> void:
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


func _spawn_hands():
	var slap_hand_id = "RomansBossSlapHand"
	var spindelhand_id = "SpindelHand"
	
	var slap_hand_position: Vector2
	var spindehand_position: Vector2
	
	if Lobby.is_host == true:
		slap_hand_position = Vector2((self.global_position.x - _hand_distance_from_head), self.global_position.y)
		Server.spawn_mob(slap_hand_id, Constants.MobTypes.ROMANS_BOSS_SLAP_HAND_FAS_2, slap_hand_position)
		spindehand_position = self.global_position + Vector2(100, 100)
		Server.spawn_mob(spindelhand_id, Constants.MobTypes.SPINDELHAND, spindehand_position)
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	slapHand = Util.get_entity(slap_hand_id)
	slapHand.set_scale(hand_scale)
	slapHand.init(slap_hand_position.distance_to(self.global_position), self.entity.id)
	slapHand.connect("slapping_done", self, "_on_slapping_done")
	
	spindelhand = Util.get_entity(spindelhand_id)
	spindelhand.set_scale(hand_scale)
	spindelhand.init(self.entity.id)
#	spindelhand.connect()

func _on_slapping_done() -> void:
#	print("slapping is donne so i am calling new walk destination and setting neutral")
	yield(get_tree().create_timer(0.8), "timeout")
	slapHand.set_hovering_behaviour()
	_walk_to_random_destination()
	_behaviour_state = behaviourStates.NEUTRAL

func _on_TimerBeforePhase1NewWalk_timeout():
	if _behaviour_state == behaviourStates.NEUTRAL:
		_walk_to_random_destination()


func _on_SlapRangeDetection_body_entered(body):
	_players_in_slapping_range.append(body)


func _on_SlapRangeDetection_body_exited(body):
	if _players_in_slapping_range.find(body) != -1:
		_players_in_slapping_range.erase(body)
