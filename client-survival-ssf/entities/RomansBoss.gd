extends KinematicBody2D

onready var health_node: Node2D = $Health
onready var AI_node: Node2D = $AI
onready var movement_node: Node2D = $Movement
onready var sprite: Sprite = $Sprite
onready var tongue_node: Area2D = $Tongue
onready var ray_cast_solid_detection: Node2D = $RayCastSolidDetection

onready var timer_before_phase_1_new_walk: Timer = $TimerBeforePhase1NewWalk
onready var timer_before_phase_1_attacks: Timer = $TimerBeforePhase1Attacks
onready var timer_before_PHASE_2_LIGHT_ATTACKs_instanced: Timer = $TimerBeforeLightAttacksInstanced
onready var timer_between_PHASE_2_LIGHT_ATTACKs: Timer = $TimerBetweenLightAttacks
onready var timer_between_big_attacks: Timer = $TimerBetweenBigAttacks

onready var _target_walk_destination: Vector2 = self.global_position

export(Vector2) var head_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_distance_from_head: Vector2 = Vector2(140, 10)
export(int) var _movement_speed: int = 70
export(float) var _walk_distance: float = 100
export(float) var _time_before_phase_1_new_walk: float = 2.8
export(float) var _time_before_phase_1_attacks: float = 4
export(float) var _time_before_PHASE_2_LIGHT_ATTACKs_instanced: float = 1.1
export(float) var time_between_PHASE_2_LIGHT_ATTACKs: float = 4.0
export(float) var time_between_big_attacks: float = 10.0


export(int) var clouders_spawned: int = 4
export(int) var chowders_spawned: int = 1


var entity: Entity
var _is_animal = true
var leftHand: Node
var rightHand: Node

var _light_attack_started: bool = false

var players_in_tongue_area_array: Array = []
var _hand_nodes_in_hover_state_array: Array = []


var _phase = phases.PHASE_1
var _behaviour_state: int = behaviourStates.PHASE_1_NEUTRAL

enum phases {
	PHASE_1,
	PHASE_2
}

enum behaviourStates {
	PHASE_1_NEUTRAL,
	PHASE_1_LIGHT_ATTACK,
	PHASE_2_NEUTRAL,
	PHASE_2_LIGHT_ATTACK,
	PHASE_2_MOB_SPIT,
	PHASE_2_PROJECTILE_RAIN_SPIT
} 

enum handBehaviourState {
	HOVER,
	CHARGE,
	CHARGEBACK
} 


func _ready():
	entity.emit_signal("change_movement_speed", _movement_speed)
	AI_node.motionless_behaviour()
	
	tongue_node.deactivate_damage()
	self.set_scale(head_scale)
	_spawn_hands()
	
	timer_before_phase_1_new_walk.set_wait_time(_time_before_phase_1_new_walk)
	timer_before_phase_1_attacks.set_wait_time(_time_before_phase_1_attacks)
	timer_before_PHASE_2_LIGHT_ATTACKs_instanced.set_wait_time(_time_before_PHASE_2_LIGHT_ATTACKs_instanced)
	timer_between_PHASE_2_LIGHT_ATTACKs.set_wait_time(time_between_PHASE_2_LIGHT_ATTACKs)
	timer_between_big_attacks.set_wait_time(time_between_big_attacks)
	yield(get_tree().create_timer(1), "timeout")


func _process(delta):
	if _phase == phases.PHASE_1:
		_phase_1_process(delta)
	elif _phase == phases.PHASE_2:
		_phase_2_process(delta)


func _phase_1_process(delta) -> void:
	if _behaviour_state == behaviourStates.PHASE_1_NEUTRAL:
		if _target_walk_destination != Vector2.ZERO:
#			leftHand.global_position += self.global_position - hand_distance_from_head
#			rightHand.global_position += self.global_position + hand_distance_from_head
			if self.global_position.distance_to(_target_walk_destination) < 10:
				print("I am close to my target and ")
				_target_walk_destination = Vector2.ZERO
				AI_node.motionless_behaviour()
				timer_before_phase_1_new_walk.start()
	elif _behaviour_state == behaviourStates.PHASE_1_LIGHT_ATTACK:
		if !_light_attack_started:
			_light_attack_started = true
			timer_before_phase_1_attacks.start()


func _phase_2_process(delta) -> void:
	if _behaviour_state == behaviourStates.PHASE_2_NEUTRAL:
		if timer_between_PHASE_2_LIGHT_ATTACKs.is_stopped():
			_randomize_PHASE_2_LIGHT_ATTACK()
	elif _behaviour_state == behaviourStates.PHASE_2_LIGHT_ATTACK:
		pass
	elif _behaviour_state == behaviourStates.PHASE_2_MOB_SPIT:
		pass


func _set_to_phase_1() -> void:
	_target_walk_destination = self.global_position
	_phase = phases.PHASE_1
	behaviourStates.PHASE_1_NEUTRAL

func _set_to_phase_2() -> void:
	_on_TimerBetweenBigAttacks_timeout()
	timer_between_PHASE_2_LIGHT_ATTACKs.start()

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
	

func _randomize_PHASE_2_LIGHT_ATTACK() -> void:
	_behaviour_state = behaviourStates.PHASE_2_LIGHT_ATTACK
	randomize()
	
	var attack_choices = [] 
	if players_in_tongue_area_array.size() > 0:
		attack_choices.append(1)
	if _hand_nodes_in_hover_state_array.size() > 0:
		attack_choices.append(2)
		
	if attack_choices.size() > 0:
		print("Have to chose from new light attack now: ", attack_choices)
		timer_before_PHASE_2_LIGHT_ATTACKs_instanced.start()
		yield(timer_before_PHASE_2_LIGHT_ATTACKs_instanced, "timeout")
		var rand_attack = attack_choices[randi() % attack_choices.size()]
		
		if rand_attack == 1:
			_tongue_attack()
		elif rand_attack == 2:
			_hand_diagonal_attack()
	else:
		_behaviour_state = behaviourStates.PHASE_2_NEUTRAL


func _tongue_attack() -> void:
	print("doing tongue attack")
	sprite.set_frame(1)
	tongue_node.activate_damage()
	yield(get_tree().create_timer(0.4), "timeout")
	sprite.set_frame(0)
	tongue_node.deactivate_damage()
	timer_between_PHASE_2_LIGHT_ATTACKs.start()
	_behaviour_state = behaviourStates.PHASE_2_NEUTRAL
	pass


func _hand_diagonal_attack():
	if _hand_nodes_in_hover_state_array.size() > 0:
		timer_between_PHASE_2_LIGHT_ATTACKs.start()
		var rand_hand = _hand_nodes_in_hover_state_array[randi() % _hand_nodes_in_hover_state_array.size()]
		match(rand_hand):
			leftHand:
				leftHand.charge_mode(Vector2(300, 200))
				print("I did the diagonal slam for LEFT hand!")
			rightHand:
				rightHand.charge_mode(Vector2(-300, 200))
				print("I did the diagonal slam for RIGHT hand!")
	
	_behaviour_state = behaviourStates.PHASE_2_NEUTRAL


func _spawn_mob_attack() -> void:
	_behaviour_state = behaviourStates.PHASE_2_MOB_SPIT
	var mob_type: int = Constants.MobTypes.CLOUDER
	var spawn_amount: int = 2
	
	if health_node.health > health_node.max_health / 2:
		mob_type = Constants.MobTypes.CLOUDER
		spawn_amount = clouders_spawned
	else:
		mob_type = Constants.MobTypes.CHOWDER
		spawn_amount = chowders_spawned
		
	for i in spawn_amount:
		sprite.set_frame(1)
		tongue_node.activate_damage()
		Server.spawn_mob(Util.generate_id(), mob_type, self.global_position + Vector2(0, 40))
		yield(get_tree().create_timer(0.3), "timeout")
		tongue_node.deactivate_damage()
		sprite.set_frame(0)
		yield(get_tree().create_timer(0.3), "timeout")
	
	yield(get_tree().create_timer(1), "timeout")
	timer_between_big_attacks.start()
	_behaviour_state = behaviourStates.PHASE_2_NEUTRAL


func _spawn_hands():
	var left_hand_id = "RomansBossLeftHand"
	var right_hand_id = "RomansBossRightHand"
	
	var left_hand_position: Vector2
	var right_hand_position: Vector2
	
	if Lobby.is_host == true:
		left_hand_position = Vector2((self.global_position.x - hand_distance_from_head.x), (self.global_position.y + hand_distance_from_head.y))
		right_hand_position = Vector2((self.global_position.x + hand_distance_from_head.x), (self.global_position.y + hand_distance_from_head.y))
		
		Server.spawn_mob(left_hand_id, Constants.MobTypes.ROMANS_BOSS_HAND, left_hand_position)
		Server.spawn_mob(right_hand_id, Constants.MobTypes.ROMANS_BOSS_HAND, right_hand_position)
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	leftHand = Util.get_entity(left_hand_id)
	rightHand = Util.get_entity(right_hand_id)
	
	leftHand.set_scale(hand_scale)
	rightHand.set_scale(Vector2(-hand_scale.x, hand_scale.y))
	
	leftHand.init(true, left_hand_position, self)
	rightHand.init(false, right_hand_position, self)
	
	leftHand.connect("hand_behaviour_changed", self, "_on_hand_behaviour_changed")
	rightHand.connect("hand_behaviour_changed", self, "_on_hand_behaviour_changed")
	
	
	leftHand.set_phase(phases.PHASE_2)
	rightHand.set_phase(phases.PHASE_2)
	
	_on_hand_behaviour_changed(leftHand, handBehaviourState.HOVER)
	_on_hand_behaviour_changed(rightHand, handBehaviourState.HOVER)


func _on_TongueAreaDetection_body_entered(body):
	players_in_tongue_area_array.append(body.entity.id)


func _on_TongueAreaDetection_body_exited(body):
	players_in_tongue_area_array.erase(body.entity.id)


func _on_hand_behaviour_changed(hand, behaviour_state) -> void:
#	print("New signal to change hand state of ", hand, " and to this state ", behaviour_state)
	
	if behaviour_state == handBehaviourState.HOVER:
		if _hand_nodes_in_hover_state_array.find(hand) == -1:
			if hand == leftHand:
				_hand_nodes_in_hover_state_array.append(leftHand)
			elif hand == rightHand:
				_hand_nodes_in_hover_state_array.append(rightHand)
	else:
		if _hand_nodes_in_hover_state_array.find(hand):
			_hand_nodes_in_hover_state_array.erase(hand)
#	print("Current hands hovering in array: ", _hand_nodes_in_hover_state_array.size())


func _on_TimerBetweenBigAttacks_timeout():
	_spawn_mob_attack()



func _on_TimerBeforePhase1NewWalk_timeout():
	print("timerbeforenewwalk timeout, this is the behaviour state: ", _behaviour_state)
	if _behaviour_state == behaviourStates.PHASE_1_NEUTRAL:
		_walk_to_random_destination()


func _on_TimerBeforePhase1Attacks_timeout():
	pass # Replace with function body.
