extends CanvasModulate


onready var JoyStick: TouchScreenButton = $JoyStick
onready var _player = get_parent().get_parent()

var _key_input: Vector2 = Vector2.ZERO


func _ready():
	JoyStick.init(_player.entity.id == Lobby.my_id && Lobby.auto_aim == false)


func _input(_event):
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


func _process(_delta):
	_player.entity.emit_signal("aim_dir", (JoyStick.get_direction() + _key_input).normalized())
