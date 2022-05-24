extends Node2D


export(Array, preload("res://globals/Constants.gd").collisionLayers) var layers_to_be_detected: Array
export var _set_raycast_length: bool = false
export var _raycast_length: int = 0

onready var _array_of_raycasts: Array = []



func _ready():
	_array_of_raycasts = self.get_children()
	
	if layers_to_be_detected.size() != 0:
		for raycast in _array_of_raycasts:
			for layer in layers_to_be_detected:
				raycast.set_collision_mask_bit(layer, true)
	
	if _set_raycast_length != false:
		for raycast in _array_of_raycasts:
				if raycast.get_cast_to().x != 0:
					if raycast.get_cast_to().x > 0:
						raycast.set_cast_to(Vector2(_raycast_length, 0))
					else:
						raycast.set_cast_to(Vector2(-_raycast_length, 0))
				if raycast.get_cast_to().y != 0:
					if raycast.get_cast_to().y > 0:
						raycast.set_cast_to(Vector2(0, _raycast_length))
					else:
						raycast.set_cast_to(Vector2(0, -_raycast_length))

func set_all_ray_cast_length(length_multiplier: int) -> void:
	for raycast in _array_of_raycasts:
		raycast.set_cast_to(raycast.get_cast_to() * length_multiplier)


func set_individual_ray_casts_length(ray_cast_names: Array, length_multiplier: int) -> void:
	for sought_raycast in ray_cast_names:
		for raycast in _array_of_raycasts:
			if raycast.get_name() == sought_raycast:
				raycast.set_cast_to(raycast.get_cast_to() * length_multiplier)


func is_colliding_with_layers(collision_layers) -> Array:
	var array_of_colliding_ray_casts: Array = []
	
	for ray_cast in _array_of_raycasts:
		var this_ray_cast_dict: Dictionary = {
			"ray_cast_name": ray_cast.get_name(),
			"colliding_layers": []
		}
		
		if !ray_cast.is_colliding():
			pass
		else:
			for layer in collision_layers:
				if ray_cast.get_collider().get_collision_layer_bit(layer):
					if array_of_colliding_ray_casts.find(this_ray_cast_dict) == -1:
						this_ray_cast_dict["colliding_layers"].append(layer)
						array_of_colliding_ray_casts.append(this_ray_cast_dict)
					else:
						this_ray_cast_dict["colliding_layers"].append(layer)
	
	return array_of_colliding_ray_casts
#Return an array of the names of the RayCasts with the layers they collide with
