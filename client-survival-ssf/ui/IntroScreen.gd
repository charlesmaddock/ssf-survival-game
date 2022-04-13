extends ColorRect


func _ready():
	set_visible(true)
	yield(get_tree().create_timer(5), "timeout")
	set_visible(false)


func _input(event):
	if event is InputEventKey or event is InputEventScreenTouch:
		set_visible(false)
