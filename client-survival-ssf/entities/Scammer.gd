extends KinematicBody2D


onready var Sprite = $Sprite

var _id = "scammer_ai"
var _is_bot: bool = true
var shoot_i: int 
var _prev_pos: Vector2


func get_id() -> String:
	return _id


func get_is_bot() -> bool:
	return _is_bot


func _ready() -> void:
	get_node("AI").set_physics_process(_is_bot)


func _physics_process(delta):
	shoot_i += 1
	if Lobby.is_host && shoot_i % 30 == 0 && _prev_pos != global_position:
		Server.shoot_projectile(global_position + Vector2.UP * 10, (global_position - _prev_pos).normalized())
	_prev_pos = global_position


func set_scammer_data(id: String, pos: Dictionary, className: String, has_ai: bool, scammer_i: int) -> void:
	var spawn_pos = Vector2(80 + scammer_i * 30, -270)
	position = spawn_pos
	_id = id
	_is_bot = has_ai
	
	get_node("Sprite").texture = Util.get_sprite_for_class(className)


func _on_Damage_body_entered(body):
	if body.get("is_player"):
		body.emit_signal("take_damage", 30, global_position.direction_to(body.global_position))

