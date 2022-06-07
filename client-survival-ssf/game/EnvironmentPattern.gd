extends Node2D


export(preload("res://globals/Constants.gd").EnvironmentTypes) var environment_type: int


func _ready():
	if Lobby.is_host:
		yield(get_tree(), "idle_frame")
		for child in get_children():
			Server.spawn_environment(Util.generate_id(), environment_type, child.global_position)
	
	queue_free()


