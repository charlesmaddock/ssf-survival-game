extends Node2D

export(float) var _charge_speed: float = 200.0 


onready var sprite_node = $Sprite
onready var AI_node = $AI
onready var damage_node = $Damage

onready var ray_cast_charge_holder = $RayCastContainer
onready var charge_collision_node = $ChargeCollision

onready var charge_buildup_timer = $ChargeBuildupTimer
onready var aimless_walking_timer = $AimlessWalkingTimer

var entity: Entity
var _targeted_player = null
var _is_animal = true
var _is_looking_at_player: bool
var _behaviour_state = behaviourState.AIMLESS_WALKING


enum behaviourState {
	AIMLESS_WALKING,
	CHARGE_ATTACK
} 


func _ready():
	_behaviour_state = behaviourState.AIMLESS_WALKING
	entity.emit_signal("change_movement_speed", 60.0)
	damage_node.init(entity.id, entity.team)
	AI_node.motionless_behaviour()
	_new_aimless_walking_path()
	AI_node.custom_behaviour()


func _physics_process(delta):
	if ray_cast_charge_holder.is_colliding_with_layers([Constants.collisionLayers.PLAYER]) && _behaviour_state == behaviourState.AIMLESS_WALKING:
		AI_node.stop_moving()
		entity.emit_signal("change_movement_speed", _charge_speed)
		_charge_at_player()


func _charge_at_player() -> void:
	_behaviour_state = behaviourState.CHARGE_ATTACK
	charge_buildup_timer.start()


func _new_aimless_walking_path() -> void:
	print("New aimless walking path!")
	randomize()
	var random_distance = rand_range(100, 600)
	var random_direction = randi() % 4
	var target_pos = Vector2.ZERO
	match random_direction:
		0:
			target_pos = self.global_position + Vector2(0, -random_distance)
			sprite_node.set_frame(0)
			ray_cast_charge_holder.rotation_degrees = 180
		1:
			target_pos = self.global_position + Vector2(0, random_distance)
			sprite_node.set_frame(1)
			ray_cast_charge_holder.rotation_degrees = 0
		2:
			target_pos = self.global_position + Vector2(-random_distance, 0)
			sprite_node.set_frame(2)
			ray_cast_charge_holder.rotation_degrees = 90
		3:
			target_pos = self.global_position + Vector2(random_distance, 0)
			sprite_node.set_frame(3)
			ray_cast_charge_holder.rotation_degrees = 270
	AI_node.set_target_walking_path(target_pos)


func _detected_charge_collision(body) -> void:
	if _behaviour_state == behaviourState.CHARGE_ATTACK:
		entity.emit_signal("change_movement_speed", 60.0)
		AI_node.stop_moving()
		yield(get_tree().create_timer(0.60), "timeout")
		_behaviour_state = behaviourState.AIMLESS_WALKING


func _on_ChargeCollision_body_entered(body):
	if !Util.is_player(body):
		if _behaviour_state == behaviourState.CHARGE_ATTACK:
			_detected_charge_collision(body)
		else: 
			aimless_walking_timer.emit_signal("timeout")


func _on_ChargeBuildupTimer_timeout():
	match(sprite_node.get_frame()):
		0:
			AI_node.set_target_walking_path(self.global_position + Vector2(0, -1000))
		1:
			AI_node.set_target_walking_path(self.global_position + Vector2(0, 1000))
		2:
			AI_node.set_target_walking_path(self.global_position + Vector2(-1000, 0))
		3:
			AI_node.set_target_walking_path(self.global_position + Vector2(1000, 0))


func _on_AimlessWalkingTimer_timeout():
	if _behaviour_state == behaviourState.AIMLESS_WALKING:
		_new_aimless_walking_path()

