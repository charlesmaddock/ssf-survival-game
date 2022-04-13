extends Node2D


enum behaviour {
	SEARCH,
	HUNT
}


export(NodePath) var movement_component_path


onready var Movement: Node2D = get_node(movement_component_path)
onready var nav: Navigation2D = Util.get_game_node().get_node("Navigation2D")
onready var roomNavPoints: Node2D = Util.get_game_node().get_node("RoomNavPoints")
onready var gameNode = Util.get_game_node()
onready var timer = $Timer


var path = []
var threshold = 16

var behaviour_mode: int = behaviour.SEARCH
var room_point: Node2D = null
var unchecked_room_points: Array = []
var players_in_view: Array = []


func _ready():
	yield(get_tree().create_timer(10), "timeout")
	timer.start()


# Development test
func _input(event):
	if event.is_action("ui_up"):
		timer.start()


func _physics_process(delta):
	if Lobby.is_host == true:
		if path.size() > 0:
			move_to_target()


func move_to_target():
	if global_position.distance_to(path[0]) < threshold:
		path.remove(0)
	else:
		var direction = global_position.direction_to(path[0])
		Movement.set_velocity(direction)


func get_target_path(target_pos):
	path = nav.get_simple_path(global_position, target_pos, false)


func _on_Damage_body_entered(body):
	if body.get("is_player"):
		body.emit_signal("take_damage", 30, global_position.direction_to(body.global_position))


func _on_Timer_timeout():
	for player in players_in_view:
		if player.visible == true:
			get_target_path(player.position)
			return
	
	var check_another_room: bool = false
	if room_point == null:
		check_another_room = true
	else:
		check_another_room = global_position.distance_to(room_point.position) < 40
	
	if  check_another_room == true:
		if unchecked_room_points.size() == 0:
			unchecked_room_points.append_array(roomNavPoints.get_children())
		
		randomize()
		var random_room_point = unchecked_room_points[randi() % unchecked_room_points.size()]
		var remove_at = unchecked_room_points.find(random_room_point)
		unchecked_room_points.remove(remove_at)
		room_point = random_room_point
	
	get_target_path(room_point.position)


func _on_FOVArea_body_entered(body):
	if body.get("is_player") != null:
		players_in_view.append(body)


func _on_FOVArea_body_exited(body):
	var remove_at = players_in_view.find(body)
	if remove_at != -1:
		players_in_view.remove(remove_at)
