extends Area2D


var entity: Entity
var force: Vector2

var _mouse_over: bool
var _dragging: bool


func _input(event):
	if Input.is_action_just_pressed("attack") && _mouse_over == true:
		_dragging = true
	
	if Input.is_action_just_released("attack") && _dragging == true:
		_dragging = false


func _physics_process(delta):
	if _dragging == true:
		global_position = global_position.linear_interpolate(get_global_mouse_position(), delta * 10)


func _on_Item_body_entered(body):
	if Util.is_entity(body):
		if Lobby.is_host == true:
			Server.add_to_inventory(body.entity.id, entity.id)
			Server.despawn_item(entity.id)


func _on_Item_mouse_entered():
	print("mouse over")
	_mouse_over = true


func _on_Item_mouse_exited():
	_mouse_over = true
