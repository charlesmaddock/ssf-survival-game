extends TouchScreenButton


export(NodePath) var movement_path
export(bool) var show_attack_sprite
export(bool) var show_move_sprite


onready var InnerCircleSprite = $InnerCircleSprite


var direction = Vector2.ZERO
var joy_stick_active: bool = false
var inner_circle_offset: Vector2 = Vector2(10, 10)
var _is_mine: bool 


func init(is_mine: bool) -> void:
	_is_mine = is_mine


func _ready():
	get_node("InnerCircleSprite/Attack").set_visible(show_attack_sprite)
	get_node("InnerCircleSprite/Dir1").set_visible(show_move_sprite)
	get_node("InnerCircleSprite/Dir2").set_visible(show_move_sprite)
	get_node("InnerCircleSprite/Dir3").set_visible(show_move_sprite)
	get_node("InnerCircleSprite/Dir4").set_visible(show_move_sprite)
	
	var is_mobile = Util.is_mobile()
	set_visible(false) 
	yield(get_tree(), "idle_frame")
	set_visible(is_mobile && _is_mine) 
	set_physics_process(is_mobile && _is_mine)


func _input(event):
	if is_visible_in_tree() && visible == true:
		if (event is InputEventScreenTouch or event is InputEventScreenDrag) && in_range(event.position):
			if is_pressed():
				direction = calc_move_dir(event.position)
		
		if event is InputEventScreenTouch:
			if event.pressed == false:
				direction = Vector2.ZERO


func _physics_process(delta):
	var centre = global_position + Vector2(shape.radius / 2, shape.radius / 2) + inner_circle_offset
	InnerCircleSprite.global_position = centre + (direction * (shape.radius / 2))


func in_range(pos: Vector2) -> bool:
	return (global_position + (Vector2.ONE * get_shape().radius)).distance_squared_to(pos) < 10000


func calc_move_dir(event_pos: Vector2) -> Vector2:
	var centre = global_position + Vector2(shape.radius / 2, shape.radius / 2) + inner_circle_offset
	if centre.distance_squared_to(event_pos) < 300:
		return Vector2.ZERO
	return ((event_pos - centre) / (shape.radius / 2)).clamped(1)


func get_direction() -> Vector2:
	return direction
