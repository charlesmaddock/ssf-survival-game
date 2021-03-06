extends Area2D


export(float) var _speed = 360
export(float) var _life_time_modifier = 1
export(float) var _knockback_mod = 1


var _damage = 50
var _velocity: Vector2 
var _damage_creator_id: String
var _damage_creator_team: int
var _destroyed: bool
var _damage_mod: float = 1


func init(pos: Vector2, dir: Vector2, val: float, creator_id: String, creator_team: int, add_dir: Vector2) -> void:
	_damage = val
	_damage_creator_id = creator_id
	_damage_creator_team = creator_team
	
	global_position = pos
	_velocity = (dir.normalized() * _speed) + add_dir
	
	$AnimationPlayer.playback_speed = _life_time_modifier


func same_creator_or_team(id: String, team: int) -> bool:
	return id == _damage_creator_id || _damage_creator_team == team


func get_damage() -> float:
	return _damage * _damage_mod


func get_knockback_mod() -> float:
	return _knockback_mod


func _destroy() -> void:
	_destroyed = true
	get_node("Sprite").set_visible(false)
	get_node("Shadow").set_visible(false)
	get_node("CollisionShape2D").disabled = true
	get_node("CPUParticles2D").emitting = true
	yield(get_tree().create_timer(0.3), "timeout")
	self.queue_free()


func _process(delta):
	if _destroyed == false:
		global_position += _velocity * delta


func _on_Projectile_area_entered(area):
	if area.name == "WontLetProjectilesPass" && has_node("WontLetProjectilesPass") == true:
		return
	
	if has_node("WontLetProjectilesPass") == true && area.name == "BossHitbox":
		return
	
	if Util.is_entity(area.get_parent().get_parent()) == true:
		var entity = area.get_parent().get_parent().entity
		if same_creator_or_team(entity.id, entity.team) == false:
			_destroy()
	else:
		_destroy()


func _on_Projectile_body_entered(body):
	_destroy()


func _on_AnimationPlayer_animation_finished(anim_name):
	_destroy()
