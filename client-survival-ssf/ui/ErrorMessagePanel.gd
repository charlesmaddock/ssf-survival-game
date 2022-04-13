extends PanelContainer


func set_text(text: String) -> void:
	$"MarginContainer/Label".text = text


func _on_Timer_timeout():
	queue_free()
