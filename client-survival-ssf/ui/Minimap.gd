tool
extends Control


export(NodePath) var world_tile_map_path
export(Vector2) var _cell_size: Vector2 = Vector2.ONE
export(bool) var _is_large: bool


onready var point: Sprite = $Sprite
onready var large_point: Sprite = $LargeSprite


var _minimap_bounds: Rect2


func _ready():
	point.set_visible(!_is_large) 
	large_point.set_visible(_is_large) 
	Server.connect("packet_received", self, "_on_packet_received")
	
	var world_tile_map: TileMap = get_node(world_tile_map_path)
	var cells = world_tile_map.get_used_cells()
	var new_world_tile_map: TileMap = world_tile_map.duplicate()
	new_world_tile_map.collision_layer = 0
	new_world_tile_map.collision_mask = 0
	add_child(new_world_tile_map)
	move_child(point, 1)
	new_world_tile_map.cell_size = _cell_size
	
	_minimap_bounds = calculate_bounds(new_world_tile_map)
	new_world_tile_map.position -= _minimap_bounds.position
	rect_min_size = _minimap_bounds.size
	rect_size = _minimap_bounds.size


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.SET_PLAYER_POS:
			if Lobby.my_id == packet.id:
				point.position = Vector2(packet.x, packet.y) / (32.0 / _cell_size.x)
				point.position -= _minimap_bounds.position
				large_point.position = Vector2(packet.x, packet.y) / (32.0 / _cell_size.x)
				large_point.position -= _minimap_bounds.position


func calculate_bounds(tilemap: TileMap) -> Rect2:
	var dimensions = Vector2(0,0)
	var cell_bounds = tilemap.get_used_rect()
	var cell_to_pixel = Transform2D(Vector2(tilemap.cell_size.x * tilemap.scale.x, 0), Vector2(0, tilemap.cell_size.y * tilemap.scale.y), Vector2())
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)


func _on_TouchScreenButton_pressed():
	pass # Replace with function body.
