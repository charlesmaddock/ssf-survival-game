extends Node2D


export(NodePath) var movement_component_path


onready var Movement: Node2D = get_node(movement_component_path)
onready var nav: Navigation2D = Util.get_game_node().get_node("Navigation2D")
onready var roomNavPoints: Node2D = Util.get_game_node().get_node("RoomNavPoints")
onready var gameNode = Util.get_game_node()
onready var timer = $Timer


var path = []
var threshold = 16

var room_point: Node2D = null
var target_freeable_node: Node2D = null
var unchecked_room_points: Array = []
var freeable_nodes_in_view: Array = []
var scammers_in_view: Array = []


func _ready():
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


func set_target_walking_path(target_pos):
	path = nav.get_simple_path(global_position, target_pos, false)


func _on_Timer_timeout():
	randomize()
	var sees_scammer = run_from_scammer()


func run_from_scammer() -> bool:
	if scammers_in_view.size() > 0:
		set_random_room_point()
		set_target_walking_path(room_point.position)
		return true
	return false


func set_random_room_point() -> void:
	var check_another_room: bool = false
	if room_point == null:
		check_another_room = true
	else:
		check_another_room = global_position.distance_to(room_point.position) < 40
	
	if  check_another_room == true:
		if unchecked_room_points.size() == 0:
			unchecked_room_points.append_array(roomNavPoints.get_children())
		
		var random_room_point = unchecked_room_points[randi() % unchecked_room_points.size()]
		var remove_at = unchecked_room_points.find(random_room_point)
		unchecked_room_points.remove(remove_at)
		room_point = random_room_point


func _on_ScammerFOVArea_body_exited(body):
	var remove_at = scammers_in_view.find(body)
	if remove_at != -1:
		scammers_in_view.remove(remove_at)


func _on_FreeableNodeFOVArea_area_entered(area):
	var remove_at = freeable_nodes_in_view.find(area.get_parent())
	if remove_at == -1:
		freeable_nodes_in_view.append(area.get_parent())


func _on_FreeableNodeFOVArea_area_exited(area):
	var remove_at = freeable_nodes_in_view.find(area.get_parent())
	if remove_at != -1:
		freeable_nodes_in_view.remove(remove_at)
