extends Node2D

export(float) var _charge_speed: float = 200.0 

onready var sprite_node = $"Sprite"
onready var AI_node = $"AI"
onready var raycast_node = $"RayCast2D"
onready var charge_buildup_timer = $"ChargeBuildupTimer"
onready var aimless_walking_timer = $"AimlessWalkingTimer"
onready var charge_collision_node = $"ChargeCollision"

enum behaviourState {
	AIMLESS_WALKING,
	CHARGE_ATTACK
} 

var entity: Entity
var _targeted_player = null
var _is_animal = true

var _behaviour_state = behaviourState.AIMLESS_WALKING


func _ready():
	get_node("AI").connect("target_player", self, "_on_target_player")
	entity.emit_signal("change_movement_speed", 60.0)
	new_aimless_walking_path()
	

func _physics_process(delta):
	if raycast_node.is_colliding() == true:
		if Util.is_player(raycast_node.get_collider()) && _behaviour_state == behaviourState.AIMLESS_WALKING:
			print("Physics process working and told to charge at: ", raycast_node.get_collider())
			_behaviour_state = behaviourState.CHARGE_ATTACK
			AI_node.stop_moving()
			entity.emit_signal("change_movement_speed", _charge_speed)
			_charge_at_player(raycast_node.get_collider())
	pass


func _charge_at_player(player) -> void:
	charge_buildup_timer.start()
	pass


func new_aimless_walking_path() -> void:
	randomize()
	var random_distance = rand_range(100, 600)
	var random_direction = randi() % 4
	var target_pos = Vector2.ZERO
	match random_direction:
		0:
			target_pos = self.global_position + Vector2(0, -random_distance)
			sprite_node.set_frame(0)
			raycast_node.rotation_degrees = 180
		1:
			target_pos = self.global_position + Vector2(0, random_distance)
			sprite_node.set_frame(1)
			raycast_node.rotation_degrees = 0
		2:
			target_pos = self.global_position + Vector2(-random_distance, 0)
			sprite_node.set_frame(2)
			raycast_node.rotation_degrees = 90
		3:
			target_pos = self.global_position + Vector2(random_distance, 0)
			sprite_node.set_frame(3)
			raycast_node.rotation_degrees = 270
	AI_node.set_target_walking_path(target_pos)


func detected_charge_collision() -> void:
	if _behaviour_state == behaviourState.CHARGE_ATTACK:
		yield(get_tree().create_timer(0.10), "timeout")
		entity.emit_signal("change_movement_speed", 60.0)
		AI_node.stop_moving()
		yield(get_tree().create_timer(0.60), "timeout")
		_behaviour_state = behaviourState.AIMLESS_WALKING


func _on_ChargeBuildupTimer_timeout():
	print("Builduptimer is timeout, this is the frame: ", sprite_node.get_frame())
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
		new_aimless_walking_path()


func _on_ChargeCollision_body_entered(body):
	print("and the bull collided with a somebooody!")
	detected_charge_collision()


func _on_ChargeCollision_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if _behaviour_state == behaviourState.CHARGE_ATTACK:
		detected_charge_collision()
	else: 
		aimless_walking_timer.emit_signal("timeout")
		
