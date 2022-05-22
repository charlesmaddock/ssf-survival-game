extends Node2D


export(Array, preload("res://globals/Constants.gd").collisionLayers) var layers_to_be_detected: Array


var _array_of_raycasts: Array = []



func _ready():
	_array_of_raycasts = self.get_children()
	if layers_to_be_detected.size() != 0:
		for raycast in _array_of_raycasts:
			for layer in layers_to_be_detected:
				raycast.set_collision_mask_bit(layer, true)


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

