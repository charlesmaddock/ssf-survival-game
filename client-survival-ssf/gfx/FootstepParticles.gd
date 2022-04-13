extends Node2D


var _previous_global_pos: Vector2
var iteration: int

var footsteps_i: int 
var _colliding_hidden_rooms: Array


func _physics_process(delta):
	iteration += 1
	
	var sprite: Sprite = get_parent().get_node("Sprite")
	var entity_is_invisible = false
	if get_parent().get("using_invis_ability") != null:
		entity_is_invisible = get_parent().using_invis_ability
	
	if entity_is_invisible == false:
		if iteration % 20 == 0 && _previous_global_pos != global_position && sprite.modulate != Color(1,1,1,1):
			var dir = _previous_global_pos - global_position
			_previous_global_pos = global_position
			Events.emit_signal("add_footstep", global_position, dir)
