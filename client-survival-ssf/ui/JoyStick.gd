extends TouchScreenButton


export(NodePath) var movement_path
export(bool) var show_attack_sprite
export(bool) var show_move_sprite


onready var InnerCircleSprite = $InnerCircleSprite


var direction = Vector2.ZERO
var joy_stick_active: bool = false
var inner_circle_offset: Vector2 = Vector2(10, 10)
var _is_mine: bool 
var _touch_index: int = -1


func init(is_mine: bool) -> void:
	_is_mine = is_mine


func _ready():
	get_node("InnerCircleSprite/Sprite").set_visible(show_attack_sprite)
	
	var is_mobile = Util.is_mobile()
	set_visible(false) 
	yield(get_tree(), "idle_frame")
	set_visible(is_mobile && _is_mine) 
	set_physics_process(is_mobile && _is_mine)


func _input(event):
	if is_visible_in_tree() && visible == true:
		if (event is InputEventScreenTouch or event is InputEventScreenDrag):
			
			yield(get_tree(), "idle_frame")
			if is_pressed():
				if event is InputEventScreenTouch && _touch_index == -1:
					_touch_index = event.get_index()
				
				if event.get_index() == _touch_index:
					direction = calc_move_dir(event.position)
		
		if event is InputEventScreenTouch:
			if event.pressed == false && event.get_index() == _touch_index:
				_touch_index = -1
				direction = Vector2.ZERO


func _physics_process(delta):
	InnerCircleSprite.global_position = global_position + (direction * (shape.radius / 2))


func in_range(pos: Vector2) -> bool:
	return (global_position + (Vector2.ONE * get_shape().radius)).distance_squared_to(pos) < 10000


func calc_move_dir(event_pos: Vector2) -> Vector2:
	var centre = global_position
	return ((event_pos - centre) / (shape.radius / 2)).clamped(1)


func get_direction() -> Vector2:
	return direction
