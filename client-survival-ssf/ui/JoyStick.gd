extends TouchScreenButton


export(NodePath) var movement_path


onready var InnerCircleSprite = $InnerCircleSprite


var velocity = Vector2.ZERO
var joy_stick_active: bool = false
var inner_circle_offset: Vector2 = Vector2(10, 10)


func _ready():
	var is_mobile = Util.is_mobile()
	yield(get_tree(), "idle_frame")
	var use_joy_stick = is_mobile && get_node(movement_path).entity_id == Lobby.my_id
	set_visible(use_joy_stick) 
	set_physics_process(use_joy_stick)


func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if is_pressed():
			velocity = calc_move_dir(event.position)
	
	if event is InputEventScreenTouch:
		if event.pressed == false:
			velocity = Vector2.ZERO


func _physics_process(delta):
	var centre = global_position + Vector2(shape.radius / 2, shape.radius / 2) + inner_circle_offset
	InnerCircleSprite.global_position = centre + (velocity * (shape.radius / 2))


func calc_move_dir(event_pos: Vector2) -> Vector2:
	var centre = global_position + Vector2(shape.radius / 2, shape.radius / 2) + inner_circle_offset
	return ((event_pos - centre) / (shape.radius / 2)).clamped(1)


func get_velocity() -> Vector2:
	return velocity
