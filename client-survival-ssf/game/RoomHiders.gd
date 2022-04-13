extends Control


export(bool) var visible_on_ready


func _ready():
	if visible_on_ready == true:
		set_visible(true)


func _input(event):
	if Input.is_key_pressed(KEY_C):
		set_visible(false)
	else:
		set_visible(true)
