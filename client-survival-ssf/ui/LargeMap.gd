extends Panel


func _physics_process(delta):
	if Input.is_key_pressed(KEY_M):
		set_visible(true)
	else:
		set_visible(false)


func _on_TouchScreenButton_pressed():
	set_visible(true)


func _on_TouchScreenButton_released():
	set_visible(false)
