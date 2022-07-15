extends Area2D


func _on_RepellArea_body_entered(body):
	if Util.is_entity(body):
		body.entity.emit_signal("knockback", global_position.direction_to(body.global_position) * 1000)

