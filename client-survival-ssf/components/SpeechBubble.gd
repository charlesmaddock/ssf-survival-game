extends Node2D

onready var lbltext = $"VBoxContainer/Label"
onready var ninerect = $"VBoxContainer/Label/NinePatchRect"

onready var timer = $"Timer"


var bubble_text = "This is just a test!"
var bubble_text_length = 0
var bubble_text_index = 0
var current_text = ""

var do_close = false

func _ready():
	bubble_text_length = bubble_text.length()
	timer.start(1)
	pass # Replace with function body.



func _on_Timer_timeout():
	if(!do_close):
		current_text += bubble_text[bubble_text_index]
		lbltext.text = current_text
		
		if(bubble_text_index < bubble_text_length - 1):
			timer.start(0.04)
			bubble_text_index += 1
		else:
			if(!do_close):
				do_close = true
				timer.start(1)
	else:
		if(bubble_text_length > 0):
			current_text.erase(bubble_text_length -1, 1)
			lbltext.text = current_text
			bubble_text_length -= 1
			"""
			ninerect.rect_size -= Vector2(6,0)
			ninerect.rect_position += Vector2(3,0)
			"""
			timer.start(0.04)
		else:
			queue_free()
