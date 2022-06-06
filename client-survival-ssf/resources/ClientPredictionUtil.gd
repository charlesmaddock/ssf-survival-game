extends Node
class_name ClientPredictionUtil


const POSITION_UPDATE_DIVISOR: int = 6

# Client send input w tick
# Host recieves input w tick and stores 
# Next tick when body has moved, send pos with tick
# Client receives tick, checks that there are on the right track

var _entity_parent_node: Node
var _server_preview_sprite: Sprite = null
var _server_preview_sprites: Array 
var draw_previews: bool = false

# Client values
var _predicted_positions: Array
var _dt_since_server_reconciliations: Array
var _tot_latency: float
var _pings: int
var _host_client_pos_difference: Vector2
var _target_pos: Vector2
var _latency_adjuster: float
var lerp_to_host_pos_speed: float = 10
var _test_body: KinematicBody2D = null


func _init(parent):
	_entity_parent_node = parent
	_dt_since_server_reconciliations.append({"start": OS.get_ticks_usec(), "stop": OS.get_ticks_usec()})
	
	if draw_previews == true:
		_server_preview_sprite = draw_preview(0)
	
	_target_pos = _entity_parent_node.global_position
	
	if Lobby.my_id == _entity_parent_node.entity.id && Lobby.is_host == false:
		var test_body = KinematicBody2D.new()
		test_body.collision_layer = parent.collision_layer
		test_body.collision_mask = parent.collision_mask
		test_body.global_position = parent.global_position
		var entities = Util.get_game_node().get_node("Entities")
		test_body.add_child(_entity_parent_node.get_node("CollisionShape2D").duplicate())
		entities.add_child(test_body)
		_test_body = test_body


func set_test_body_enabled(enabled: bool) -> void:
	_test_body.collision_layer = 0 if enabled == false else _entity_parent_node.collision_layer 


func get_adjust_vector() -> Vector2:
	return _host_client_pos_difference


func get_target_pos() -> Vector2:
	return _target_pos


func get_test_body() -> KinematicBody2D:
	return _test_body


func draw_preview(opacity: float, pos: Vector2 = Vector2.ZERO) -> Node:
	if Lobby.my_id == _entity_parent_node.entity.id && Lobby.is_host == false:
		var entities = Util.get_game_node().get_node("Entities")
		var server_preview_sprite = Sprite.new() 
		server_preview_sprite.texture = load("res://assets/sprites/robot.png")
		server_preview_sprite.modulate = Color(1, 1, 1, opacity)
		server_preview_sprite.offset = Vector2(2, -14)
		entities.add_child(server_preview_sprite)
		server_preview_sprite.global_position = pos
		return server_preview_sprite
	
	return null


func update(delta) -> void:
	_dt_since_server_reconciliations.append({"start": OS.get_ticks_usec(), "stop": -1, })
	
	if _predicted_positions.size() > 0:
		_target_pos = _target_pos.linear_interpolate(_target_pos + _host_client_pos_difference, delta * lerp_to_host_pos_speed)
		for data in _predicted_positions:
			data.pos = data.pos.linear_interpolate(_target_pos + _host_client_pos_difference, delta * lerp_to_host_pos_speed)
		for sprite in _server_preview_sprites:
			sprite.global_position = sprite.global_position.linear_interpolate(_target_pos + _host_client_pos_difference, delta * lerp_to_host_pos_speed)


func get_reconciled_pos() -> Vector2:
	return Vector2.ZERO


func host_handle_client_input(input_packet: Dictionary) -> void:
	# Host doesn't do any client side prediction
	if input_packet.id == Lobby.my_id:
		return
	
	#print("2. (Host) Receiving Input: ", input_packet)
	
	if _entity_parent_node != null:
		#print("3. (Host) Reconciling pos:  ", _entity_parent_node.global_position)
		Server.host_reconcile_player_pos(1, _entity_parent_node.global_position, _entity_parent_node.entity.id)


func add_input(vel) -> void:
	_target_pos += vel


# Nothing wrong with time between packets latency
# Perfect at the start, slowly get unsynced. Removing to few frames.
# Must sync somehow with lerp.


var first_time: bool = true

func handle_reconciliation_from_host(position_iteration: int, server_pos: Vector2) -> void:
	#print("4. (Client) Handle and adjust reconciliation: ", position_iteration)
	
	if _server_preview_sprite != null:
		_server_preview_sprite.global_position = server_pos
	
	var print_arr = ""
	var slice_pos = -1
	var latency: float = Constants.RECONCILE_POSITION_RATE
	
	for i in _dt_since_server_reconciliations.size():
		if _dt_since_server_reconciliations[i].stop == -1:
			_dt_since_server_reconciliations[i].stop = OS.get_ticks_usec()
			break
	
	if _dt_since_server_reconciliations.size() > 1:
		for i in _dt_since_server_reconciliations.size():
			if _dt_since_server_reconciliations[i].stop != -1 && i > 0:
				var time_between_packets = (float(_dt_since_server_reconciliations[i].stop - _dt_since_server_reconciliations[i - 1].stop) / 1000000.0)
				var time_between_packets_without_interval = time_between_packets - Constants.RECONCILE_POSITION_RATE
				var host_client_sync_factor = (time_between_packets_without_interval / 2.0) 
				latency = Constants.RECONCILE_POSITION_RATE + host_client_sync_factor
				
				#print("time_between_packets: ", time_between_packets)
				_tot_latency += latency
				_pings += 1
				
				#print("Start: ", _dt_since_server_reconciliations[i].start, ", Stop: ", _dt_since_server_reconciliations[i].stop, ", Diff since last: ", _dt_since_server_reconciliations[i].stop - _dt_since_server_reconciliations[i - 1].stop)
	
	var history_dt = 0.0
	if latency != null:
		for pos_hist_data in _predicted_positions:
			slice_pos += 1
			print_arr += str(pos_hist_data.dt) + ", "
			history_dt += pos_hist_data.dt 
			if history_dt >= latency + _latency_adjuster:
				#print("Diff Latency vs Prediction Delta Time: ", latency - history_dt)
				break
	else:
		printerr("No _dt_since_server_reconciliations available")
	
	#print("Prediction Delta Time: ", history_dt)
	#print("Latency: ", latency)
	
	#print("Predicted Positions: ")
	#print(print_arr)
	
	if draw_previews == true:
		var to_delete = _server_preview_sprites.slice(0, slice_pos, 1, true)
		var to_keep = _server_preview_sprites.slice(slice_pos + 1, _predicted_positions.size() - 1, 1, true)
		for s in to_delete:
			s.queue_free()
		_server_preview_sprites = to_keep
	
	
	if _predicted_positions.size() > 0:
		_host_client_pos_difference = server_pos - _predicted_positions[0].pos
		var predicted_between: Vector2 = _predicted_positions[0].pos.direction_to(_predicted_positions[1].pos) 
		var server_between: Vector2 = server_pos.direction_to(_predicted_positions[1].pos) 
		var dot = predicted_between.normalized().dot(server_between.normalized()) 
		if dot > 0:
			_latency_adjuster = -0.01
		else:
			_latency_adjuster = 0.01
	
	#print("Diff len: ", server_pos.distance_to(_predicted_positions[0].pos))
	_predicted_positions = _predicted_positions.slice(slice_pos + 1, _predicted_positions.size() - 1, 1, true)
	
	#print_arr = ""
	#for pos_hist_data in _predicted_positions:
	#	print_arr += str(pos_hist_data.dt) + ", "
	
	#print("New Predicted Positions: ")
	#print(print_arr)
	#print(".")


func add_prediction(pos: Vector2, delta: float) -> void:
	if draw_previews == true:
		_server_preview_sprites.append(draw_preview(0, pos))
	_predicted_positions.append({"pos": pos, "dt": delta})
