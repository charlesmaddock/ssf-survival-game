extends KinematicBody2D

export(int) var _movement_speed: int = 40
export(int) var distance_from_player: int = 70


export(int) var _attack_damage: int = 30
export(Vector2) var _attack_scale: Vector2 = Vector2(1, 1)
export(Color) var _attack_color: Color = "ff0000"
export(float) var _pause_before_attack: float = 1.0
export(int) var _distance_between_attack: int = 50
export(int) var _number_of_attacks: int = 3
export(float) var _flurry_attack_intervall_time: float = 1.0
export(bool) var _triple_attack: bool = false
export(float) var _triple_attack_angle  = 35



onready var attack_scene: PackedScene = preload("res://entities/Attack.tscn")
onready var attackTimer: Timer = $AttackTimer
onready var AI_node: Node2D = $AI


var entity: Entity
var _is_animal = true

func _ready():
	entity.emit_signal("change_movement_speed", _movement_speed)
	AI_node.strafe_player_behaviour(distance_from_player)
	attackTimer.start()
	pass


func _create_attack(dir, attack_index) -> void:
	var middle_attack = attack_scene.instance()
	middle_attack.init(dir, _attack_damage, self.entity.id, self.entity.team)
	middle_attack.global_position += dir * _distance_between_attack * attack_index
	middle_attack.set_scale(_attack_scale)
	middle_attack.get_node("Polygon2D").set_color(_attack_color)
	self.add_child(middle_attack)
	
	if _triple_attack:
		
		for i in 2:
			var angle_attack = attack_scene.instance()
			var angle_dir: Vector2
			
			if i == 0:
					angle_dir = dir.rotated(deg2rad(-_triple_attack_angle))
					
			elif i == 1:
					angle_dir = dir.rotated(deg2rad(_triple_attack_angle))
			
			angle_attack.init(angle_dir, _attack_damage, self.entity.id, self.entity.team)
			angle_attack.global_position += angle_dir * _distance_between_attack * attack_index
			angle_attack.set_scale(_attack_scale)
			angle_attack.get_node("Polygon2D").set_color(_attack_color)
			self.add_child(angle_attack)


func _on_AttackTimer_timeout():
	
	var targeted_player = AI_node.get_closest_player() 
	AI_node.motionless_behaviour()
	yield(get_tree().create_timer(_pause_before_attack), "timeout")
	
	if targeted_player != null:
		var dir = (targeted_player.global_position - self.global_position).normalized()
		
		for i in (_number_of_attacks):
			if i == 0:
				pass
			else:
				yield(get_tree().create_timer(_flurry_attack_intervall_time), "timeout")
			_create_attack(dir, i)
		
		AI_node.strafe_player_behaviour(distance_from_player)
		attackTimer.start()

