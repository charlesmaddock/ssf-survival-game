extends Node
class_name ClientPredictionUtil


const POSITION_UPDATE_DIVISOR: int = 6

# Client send input w tick
# Host recieves input w tick and stores 
# Next tick when body has moved, send pos with tick
# Client receives tick, checks that there are on the right track

var _entity_parent_node: Node
var _server_preview_sprite: Sprite = null

# Client values
var _predicted_positions: Array

# Host values
var _latest_client_input_packet: Dictionary = {}


func _init(parent):
	_entity_parent_node = parent
	
	if Lobby.my_id == _entity_parent_node.entity.id && Lobby.is_host == false:
		var entities = Util.get_game_node().get_node("Entities")
		_server_preview_sprite = Sprite.new() 
		_server_preview_sprite.texture = load("res://assets/sprites/robot.png")
		_server_preview_sprite.modulate = Color(1, 1, 1, 0.3)
		_server_preview_sprite.offset = Vector2(2, -14)
		entities.add_child(_server_preview_sprite)


func get_reconciled_pos() -> Vector2:
	return Vector2.ZERO


func host_handle_client_input(input_packet: Dictionary) -> void:
	# Host doesn't do any client side prediction
	if input_packet.id == Lobby.my_id:
		return
	
	#print("2. (Host) Receiving Input: ", input_packet)
	
	_latest_client_input_packet = input_packet
	
	if _entity_parent_node != null:
		yield(_entity_parent_node.get_tree(), "physics_frame")
	
		if _latest_client_input_packet.empty() == false:
			#print("3. (Host) Reconciling pos: ", _latest_client_input_packet.i, " - ", _entity_parent_node.global_position)
			Server.host_reconcile_player_pos(_latest_client_input_packet.i, _entity_parent_node.global_position, _entity_parent_node.entity.id)
			_latest_client_input_packet = {}


func handle_reconciliation_from_host(position_iteration: int, server_pos: Vector2) -> void:
	#print("4. (Client) Handle and adjust reconciliation: ", position_iteration)
	
	_server_preview_sprite.global_position = server_pos
	var print_arr = ""
	var reconciled_pos_index = -1
	var server_diff = Vector2.ZERO
	for pos_hist_data in _predicted_positions:
		reconciled_pos_index += 1
		print_arr += str(pos_hist_data.i) + ", "
		if pos_hist_data.i == position_iteration:
			server_diff = pos_hist_data.pos - server_pos
			print("server_diff: ", pos_hist_data.pos.distance_to(server_pos))
			var local_time_pos_diff = pos_hist_data.pos - _predicted_positions[_predicted_positions.size() - 1].pos
			var reconciled_pos = (pos_hist_data.pos - server_diff) + local_time_pos_diff
			
			_entity_parent_node.global_position = server_pos
			break
	
	
	#print("Predicted Positions: ")
	#print(print_arr)

	_predicted_positions = _predicted_positions.slice(reconciled_pos_index + 1, _predicted_positions.size() - 1)
	print_arr = ""
	for pos_hist_data in _predicted_positions:
		print_arr += str(pos_hist_data.i) + ", "
	#print("New Predicted Positions: ")
	#print(print_arr)
	#print(".")


func add_prediction(pos: Vector2, position_iteration: int) -> void:
	_predicted_positions.append({"pos": pos, "i": position_iteration})
