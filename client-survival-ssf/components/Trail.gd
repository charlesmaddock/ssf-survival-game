extends Node2D


func _on_Timer_timeout():
	if Lobby.is_host:
		Server.shoot_projectile(8, get_parent().global_position + (Vector2.UP * 6), Vector2.ZERO, "", Constants.Teams.GOOD_GUYS, Constants.ProjectileTypes.CD)
