extends Node2D


var _array_of_raycasts: Array = []
var array_of_colliding_ray_casts: Array = []


func _ready():
	_array_of_raycasts = self.get_children()
	for raycast in _array_of_raycasts:
		raycast.set_collision_mask_bit(0, true)
		raycast.set_collision_mask_bit(3, true)


func is_colliding_with_layers(collision_layers) -> bool:
	for ray_cast in _array_of_raycasts:
		for layer in collision_layers:
			if !ray_cast.is_colliding():
				if array_of_colliding_ray_casts.find(ray_cast):
						array_of_colliding_ray_casts.erase(ray_cast)
			else:
					if ray_cast.get_collider().get_collision_layer_bit(layer):
						if array_of_colliding_ray_casts.find(ray_cast) == -1:
							array_of_colliding_ray_casts.append(ray_cast)
					else:
						if array_of_colliding_ray_casts.find(ray_cast) != -1:
							array_of_colliding_ray_casts.erase(ray_cast)
	
	if array_of_colliding_ray_casts.size() != 0:
		return true
	else:
		return false

