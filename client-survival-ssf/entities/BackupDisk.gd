extends StaticBody2D


var entity: Entity
var _revived_players: bool


func _on_DetectPlayerArea_body_entered(body):
	if _revived_players == false && Lobby.is_host:
		_revived_players = true
		for dead_player_id in Lobby.dead_player_ids:
			var player = Util.get_entity(dead_player_id)
			if player != null:
				player.global_position = global_position + (Vector2.DOWN * 12)
			
			Server.set_health(dead_player_id, 50, Vector2.ZERO)
