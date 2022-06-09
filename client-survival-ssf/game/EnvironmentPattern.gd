extends Node2D


export(preload("res://globals/Constants.gd").EnvironmentTypes) var environment_type: int
export(float) var chest_spawn_change: float = 0.3


func _ready():
	if Lobby.is_host:
		yield(get_tree(), "idle_frame")
		for child in get_children():
			if environment_type == Constants.EnvironmentTypes.HEART_CHEST || environment_type == Constants.EnvironmentTypes.PART_CHEST:
				randomize()
				if randf() > chest_spawn_change:
					continue
			
			Server.spawn_environment(Util.generate_id(), environment_type, child.global_position)
	
	queue_free()


