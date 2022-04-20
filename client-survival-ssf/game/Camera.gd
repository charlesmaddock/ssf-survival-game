extends Camera2D


var follow: Node2D = null
var my_player_is_dead: bool = false
var spectate_index: int = 0
var follow_prev_pos: Vector2


func _ready():
	Events.connect("player_dead", self, "_on_player_dead")


func _on_player_dead(id) -> void:
	if id == Lobby.my_id:
		my_player_is_dead = true


func _input(event):
	if Input.is_key_pressed(KEY_C):
		zoom = Vector2(5, 5)
	else:
		zoom = Vector2(1, 1)
	
	if my_player_is_dead == true:
		if Input.is_action_just_pressed("ui_left") or event is InputEventScreenTouch:
			var all_players = Util.get_living_players() 
			spectate_index -= 1
			if spectate_index < 0:
				spectate_index = all_players.size() - 1
			set_follow(all_players[spectate_index])
		if Input.is_action_just_pressed("ui_right"):
			var all_players = Util.get_living_players() 
			spectate_index += 1
			if spectate_index > all_players.size() - 1:
				spectate_index = 0
			set_follow(all_players[spectate_index])


func set_follow(node: Node2D) -> void:
	Lobby.specating_player_w_id = node.entity.id
	follow = node
	Events.emit_signal("switched_spectate", node)


func _process(delta):
	if is_instance_valid(follow):
		#var follow_dir = (follow.global_position - follow_prev_pos).normalized() * 40
		#var target = follow.position + follow_dir 
		position = position.linear_interpolate(follow.global_position, delta * 4)
		#follow_prev_pos = follow.global_position
