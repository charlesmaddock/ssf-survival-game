extends Node2D

onready var sprite_node = $"Sprite"
onready var AI_node = $"AI"

var entity: Entity
var _targeted_player = null
var _is_animal = true

var aimless_walking_destination

func _ready():
	get_node("AI").connect("target_player", self, "_on_target_player")
	entity.emit_signal("change_movement_speed", 90.0)
	
	new_aimless_walking_path()

func _process(delta):
	pass

func _charge_at_player() -> void:
	pass


func new_aimless_walking_path() -> void:
	randomize()
	var random_distance = rand_range(100, 600)
	var random_direction = randi() % 4
	var target_pos = Vector2.ZERO
	match random_direction:
		0:
			target_pos = self.global_position + Vector2(0, -random_distance)
		1:
			target_pos = self.global_position + Vector2(0, random_distance)
		2:
			target_pos = self.global_position + Vector2(-random_distance, 0)
		3:
			target_pos = self.global_position + Vector2(random_distance, 0)
	AI_node.set_target_walking_path(target_pos)
	aimless_walking_destination = target_pos
	pass

func _on_ChargeBuildupTimer_timeout():
	pass # Replace with function body.


func _on_AimlessWalkingTimer_timeout():
	new_aimless_walking_path()
