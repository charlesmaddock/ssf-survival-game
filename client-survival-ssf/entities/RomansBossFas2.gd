extends KinematicBody2D


onready var health_node: Node2D = $Health
onready var AI_node: Node2D = $AI
onready var movement_node: Node2D = $Movement
onready var sprite: Sprite = $Sprite
onready var ray_cast_solid_detection: Node2D = $RayCastSolidDetection
onready var slap_range_detection: Node2D = $SlapRangeDetection

onready var timer_before_phase_1_new_walk: Timer = $TimerBeforePhase1NewWalk
onready var timer_before_phase_1_attacks: Timer = $TimerBeforePhase1Attacks
onready var timer_before_PHASE_2_LIGHT_ATTACKs_instanced: Timer = $TimerBeforeLightAttacksInstanced
onready var timer_between_PHASE_2_LIGHT_ATTACKs: Timer = $TimerBetweenLightAttacks
onready var timer_between_big_attacks: Timer = $TimerBetweenBigAttacks

onready var _target_walk_destination: Vector2 = self.global_position

export(Vector2) var head_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_scale: Vector2 = Vector2(0.7, 0.7)
export(float) var _hand_distance_from_head: float = 120
export(int) var _movement_speed: int = 70
export(float) var _walk_distance: float = 100
export(float) var _time_before_new_walk: float = 2.8


export(int) var clouders_spawned: int = 4
export(int) var chowders_spawned: int = 1


var entity: Entity
var _is_animal = true
var slapHand: Node
var rightHand: Node

var _light_attack_started: bool = false
var _is_slapping: bool = false

var _behaviour_state: int = behaviourStates.NEUTRAL

enum behaviourStates {
	NEUTRAL,
	LIGHT_ATTACK
} 

enum handBehaviourState {
	HOVER_AROUND_HEAD,
	SLAP,
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
				AI_node.motionless_behaviour()
#				if !_is_slapping:
#					if slap_range_detection.is_colliding():
#						_is_slapping = true
#						_slap_nearby_player()
#					elif _target_walk_destination != Vector2.ZERO:
				_target_walk_destination = Vector2.ZERO
				timer_before_phase_1_new_walk.start()
	elif _behaviour_state == behaviourStates.LIGHT_ATTACK:
		if !_light_attack_started:
			_light_attack_started = true
			timer_before_phase_1_attacks.start()

func _slap_nearby_player() -> void:
	pass

func _walk_to_random_destination() -> void:
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
	var random_direction: Vector2 = Vector2(rand_range(possible_x_range.x, possible_x_range.y), rand_range(possible_y_range.x, possible_y_range.y)).normalized()
	var random_destination: Vector2 = global_position + random_direction * _walk_distance
	_target_walk_destination = random_destination
	AI_node.custom_behaviour()
	print("New walking destination for RomansBoss: ", random_destination)
	yield(get_tree().create_timer(0.1), "timeout")
	AI_node.set_target_walking_path(random_destination)


func _spawn_hands():
	var slap_hand_id = "RomansBossSlapHand"
	var right_hand_id = "RomansBossRightHand"
	
	var slap_hand_position: Vector2
#	var right_hand_position: Vector2
	
	if Lobby.is_host == true:
		slap_hand_position = Vector2((self.global_position.x - _hand_distance_from_head), self.global_position.y)
		Server.spawn_mob(slap_hand_id, Constants.MobTypes.ROMANS_BOSS_SLAP_HAND_FAS_2, slap_hand_position)
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	slapHand = Util.get_entity(slap_hand_id)
	slapHand.set_scale(hand_scale)
	slapHand.init(slap_hand_position.distance_to(self.global_position), entity.id)
	slapHand.connect("slapping_done", self, "_on_slapping_done")


func _on_slapping_done(hand, behaviour_state) -> void:
	yield(get_tree().create_timer(0.8), "timeout")
	_walk_to_random_destination()


func _on_TimerBeforePhase1NewWalk_timeout():
	print("timerbeforenewwalk timeout, this is the behaviour state: ", _behaviour_state)
	if _behaviour_state == behaviourStates.NEUTRAL:
		_walk_to_random_destination()

