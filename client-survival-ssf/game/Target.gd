extends Sprite


const AIM_OFFSET: Vector2 = Vector2.DOWN * 6


var _target_node: Node = null
var _target_pos: Vector2
var _monsters_in_area: Array
var _aiming: bool = false


func _ready():
	Events.connect("target_entity", self, "_on_target_entity")
	set_visible(false)


func _on_target_entity(node: Node, manually_targeted: bool) -> void:
	_target_node = node


func _unhandled_input(event):
	if event.is_action_pressed("aim_and_shoot") || (event is InputEventScreenTouch && event.is_pressed()):
		_aiming = true
		Events.emit_signal("manual_aim", true)
		_target_pos = get_global_mouse_position()
		global_position =  get_global_mouse_position()
	
	if event.is_action_released("aim_and_shoot") || (event is InputEventScreenTouch && event.is_pressed() == false):
		_aim_at_closest_monster()
		_aiming = false
		Events.emit_signal("manual_aim", false)


func _aim_at_closest_monster() -> void:
	var closest_monster: Node = null
	var closest_dist: float = 150
	
	for monster in _monsters_in_area:
		var dist: float = monster.global_position.distance_to(global_position)
		if dist < closest_dist:
			closest_monster = monster
			closest_dist = dist
	
	if closest_monster != null:
		Events.emit_signal("target_entity", closest_monster, true)


func _process(delta):
	if Lobby.auto_aim == false:
		return 
	
	global_position = global_position.linear_interpolate(_target_pos + AIM_OFFSET, delta * 10)
	Events.emit_signal("update_target_pos", Vector2.ZERO if _aiming == false else global_position - AIM_OFFSET)
	
	if _aiming == true:
		if visible == false:
			set_visible(true)
		_target_pos = get_global_mouse_position()
	elif is_instance_valid(_target_node):
		if visible == false:
			set_visible(true)
		_target_pos = _target_node.global_position
	elif visible == true:
		set_visible(false)


func _on_MonsterDetector_body_entered(body):
	if (Util.is_entity(body) or Util.is_entity(body.get_parent())) && Util.is_player(body) == false:
		_monsters_in_area.append(body)


func _on_MonsterDetector_body_exited(body):
	_monsters_in_area.erase(body)
