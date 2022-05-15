extends Node2D


enum behaviour {
	SEARCH,
	HUNT
}


export(NodePath) var movement_component_path
export(bool) var cowardly = false
export(bool) var agressive = false
export(bool) var attack_base = false


onready var Movement: Node2D = get_node(movement_component_path)
onready var nav: Navigation2D = Util.get_game_node().get_node("Navigation2D")
onready var gameNode = Util.get_game_node()
onready var base = Util.get_entity("base")
onready var timer = $Timer
onready var parent_entity: Node2D = self.get_parent()


var path = []
var threshold = 16

var behaviour_mode: int = behaviour.SEARCH
var room_point: Node2D = null
var unchecked_room_points: Array = []
var players_in_view: Array = []


signal target_player(player)


func _ready():
	timer.start()


# Development test
func _input(event):
	if event.is_action("ui_up"):
		timer.start()


func _physics_process(delta):
	if Lobby.is_host == true:
		if path.size() > 0:
			move_to_target()


func stop_moving() -> void:
	path = []
	Movement.set_velocity(Vector2.ZERO)


func get_strafe_position(strafe_dist, target_player_position) -> Vector2:
	var strafe_dir_normalized = target_player_position.global_position.direction_to(self.global_position)
	var strafe_pos_without_strafe: Vector2 = target_player_position.global_position + strafe_dir_normalized * strafe_dist
	var strafe_pos: Vector2  = target_player_position.global_position + strafe_dir_normalized.rotated(deg2rad(40)) * strafe_dist
	return strafe_pos
	

func move_to_target():
	if global_position.distance_to(path[0]) < threshold:
		path.remove(0)
	else:
		var direction = global_position.direction_to(path[0])
		Movement.set_velocity(direction)


func get_target_path(target_pos):
	path = nav.get_simple_path(global_position, target_pos, false)


func _on_Damage_body_entered(body):
	if Util.is_player(body):
		body.emit_signal("take_damage", 30, global_position.direction_to(body.global_position))


func _on_Timer_timeout():
	if agressive == true:
		for player in players_in_view:
			if player.visible == true:
				emit_signal("target_player", player)
				get_target_path(player.position)
				return


func _on_FOVArea_body_entered(body):
	if Util.is_entity(body):
		players_in_view.append(body)


func _on_FOVArea_body_exited(body):
	var remove_at = players_in_view.find(body)
	if remove_at != -1:
		players_in_view.remove(remove_at)

"""
func _on_IdleWalkTimer_timeout(): 
	randomize()
	if cowardly == true && agressive == false && players_in_view.size() > 0:
		get_target_path(global_position + global_position.direction_to(players_in_view[0].global_position) * -100 )
	elif randf() > 0.9:
		get_target_path(global_position + Vector2.ONE * (randf() - 0.5) * 100)
	else:
		get_target_path(global_position)
"""
