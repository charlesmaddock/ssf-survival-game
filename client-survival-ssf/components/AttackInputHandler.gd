extends Control


onready var JoyStick: TouchScreenButton = $JoyStick
var _key_input: Vector2 = Vector2.ZERO


func _input(event):
	yield(get_tree().create_timer(0.05), "timeout")
	var aim_dir = Vector2.ZERO
	if Input.is_action_pressed("aim_right"):
		aim_dir += Vector2(1, 0)
	if Input.is_action_pressed("aim_left"):
		aim_dir += Vector2(-1, 0)
	if Input.is_action_pressed("aim_up"):
		aim_dir += Vector2(0, -1)
	if Input.is_action_pressed("aim_down"):
		aim_dir += Vector2(0, 1)
	_key_input = aim_dir


func _process(delta):
	get_parent().entity.emit_signal("aim_dir", (JoyStick.get_direction() + _key_input).normalized())