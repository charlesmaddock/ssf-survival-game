extends Sprite


func _ready():
	if get_parent().entity.id == Lobby.my_id: 
		set_visible(true)
		yield(get_tree().create_timer(5), "timeout")
		set_visible(false)
	else:
		set_visible(false)

