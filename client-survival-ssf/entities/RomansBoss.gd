extends KinematicBody2D

onready var health_node: Node2D = $Health
onready var sprite: Sprite = $Sprite
onready var tongue_node: Area2D = $Tongue

onready var timer_before_light_attacks_instanced: Timer = $TimerBeforeLightAttacksInstanced
onready var timer_between_light_attacks: Timer = $TimerBetweenLightAttacks
onready var timer_between_big_attacks: Timer = $TimerBetweenBigAttacks


export(Vector2) var head_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_distance_from_head: Vector2 = Vector2(140, 10)
export(float) var _time_before_light_attacks_instanced: float = 1.1
export(float) var time_between_light_attacks: float = 4.0
export(float) var time_between_big_attacks: float = 10.0

export(int) var clouders_spawned: int = 4
export(int) var chowders_spawned: int = 1


var entity: Entity
var _is_animal = true
var leftHand: Node
var rightHand: Node

var players_in_tongue_area_array: Array = []
var _hand_nodes_in_hover_state_array: Array = []

var _behaviour_state: int = behaviourState.MOB_SPIT


enum behaviourState {
	NEUTRAL,
	LIGHT_ATTACK,
	MOB_SPIT,
	PROJECTILE_RAIN_SPIT
} 

enum handBehaviourState {
	HOVER,
	CHARGE,
	CHARGEBACK
} 


func _ready():
	_behaviour_state = behaviourState.MOB_SPIT
	tongue_node.deactivate_damage()
	self.set_scale(head_scale)
	_spawn_hands()
	
	timer_before_light_attacks_instanced.set_wait_time(_time_before_light_attacks_instanced)
	timer_between_light_attacks.set_wait_time(time_between_light_attacks)
	timer_between_big_attacks.set_wait_time(time_between_big_attacks)
	yield(get_tree().create_timer(1), "timeout")
	_on_TimerBetweenBigAttacks_timeout()
	timer_between_light_attacks.start()


func _process(delta):
	if _behaviour_state == behaviourState.NEUTRAL:
		if timer_between_light_attacks.is_stopped():
			_randomize_light_attack()
	elif _behaviour_state == behaviourState.LIGHT_ATTACK:
		pass
	elif _behaviour_state == behaviourState.MOB_SPIT:
		pass


func _randomize_light_attack() -> void:
	_behaviour_state = behaviourState.LIGHT_ATTACK
	randomize()
	
	var attack_choices = [] 
	if players_in_tongue_area_array.size() > 0:
		attack_choices.append(1)
	if _hand_nodes_in_hover_state_array.size() > 0:
		attack_choices.append(2)
		
	if attack_choices.size() > 0:
		print("Have to chose from new light attack now: ", attack_choices)
		timer_before_light_attacks_instanced.start()
		yield(timer_before_light_attacks_instanced, "timeout")
		var rand_attack = attack_choices[randi() % attack_choices.size()]
		
		if rand_attack == 1:
			_tongue_attack()
		elif rand_attack == 2:
			_hand_diagonal_attack()
	else:
		_behaviour_state = behaviourState.NEUTRAL


func _tongue_attack() -> void:
	print("doing tongue attack")
	sprite.set_frame(1)
	tongue_node.activate_damage()
	yield(get_tree().create_timer(0.4), "timeout")
	sprite.set_frame(0)
	tongue_node.deactivate_damage()
	timer_between_light_attacks.start()
	_behaviour_state = behaviourState.NEUTRAL
	pass


func _hand_diagonal_attack():
	if _hand_nodes_in_hover_state_array.size() > 0:
		timer_between_light_attacks.start()
		var rand_hand = _hand_nodes_in_hover_state_array[randi() % _hand_nodes_in_hover_state_array.size()]
		match(rand_hand):
			leftHand:
				leftHand.charge_mode(Vector2(300, 200))
				print("I did the diagonal slam for LEFT hand!")
			rightHand:
				rightHand.charge_mode(Vector2(-300, 200))
				print("I did the diagonal slam for RIGHT hand!")
	
	_behaviour_state = behaviourState.NEUTRAL


func _spawn_mob_attack() -> void:
	_behaviour_state = behaviourState.MOB_SPIT
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
	_behaviour_state = behaviourState.NEUTRAL


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
	
	_on_hand_behaviour_changed(leftHand, handBehaviourState.HOVER)
	_on_hand_behaviour_changed(rightHand, handBehaviourState.HOVER)


func _on_TongueAreaDetection_body_entered(body):
	players_in_tongue_area_array.append(body.entity.id)


func _on_TongueAreaDetection_body_exited(body):
	players_in_tongue_area_array.erase(body.entity.id)


func _on_hand_behaviour_changed(hand, behaviour_state) -> void:
	print("New signal to change hand state of ", hand, " and to this state ", behaviour_state)
	
	if behaviour_state == handBehaviourState.HOVER:
		if _hand_nodes_in_hover_state_array.find(hand) == -1:
			if hand == leftHand:
				_hand_nodes_in_hover_state_array.append(leftHand)
			elif hand == rightHand:
				_hand_nodes_in_hover_state_array.append(rightHand)
	else:
		if _hand_nodes_in_hover_state_array.find(hand):
			_hand_nodes_in_hover_state_array.erase(hand)
	print("Current hands hovering in array: ", _hand_nodes_in_hover_state_array.size())


func _on_TimerBetweenBigAttacks_timeout():
	_spawn_mob_attack()
