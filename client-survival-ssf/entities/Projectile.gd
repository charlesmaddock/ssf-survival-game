extends Area2D


export(float) var _damage = 50
export(float) var _speed = 100


var _velocity: Vector2 
var _damage_creator_id: String
var _damage_creator_team: int


func init(pos: Vector2, dir: Vector2, val: float, creator_id: String, creator_team: int) -> void:
	_damage = val
	_damage_creator_id = creator_id
	_damage_creator_team = creator_team
	
	global_position = pos
	_velocity = dir.normalized() * _speed


func same_creator_or_team(id: String, team: int) -> bool:
	return id == _damage_creator_id || _damage_creator_team == team


func get_damage() -> float:
	return _damage


func _process(delta):
	global_position += _velocity * delta


func _on_Projectile_area_entered(area):
	if Util.is_entity(area.get_parent().get_parent()) == true:
		var entity = area.get_parent().get_parent().entity
		if same_creator_or_team(entity.id, entity.team) == false:
			self.queue_free()
	else:
		self.queue_free()


func _on_Projectile_body_entered(body):
	self.queue_free()
