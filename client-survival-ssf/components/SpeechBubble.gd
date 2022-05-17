extends Node2D


#onready var ninerect = $"VBoxContainer/Label/NinePatchRect"
onready var vBoxContainer: VBoxContainer = $VBoxContainer
onready var lbltext = $VBoxContainer/Label
onready var timer = $Timer


var TimerSpeeds: Dictionary = {
	"slow": 0.10,
	"medium": 0.04,
	"fast": 0.015
}


var _bubble_text: String = "This is just a test!"
var _bubble_text_length = 0
var _bubble_text_index = 0
var _current_text = ""

var _tick_time: float = TimerSpeeds["medium"]
var _do_erase_text = false
var _do_close = false


func init(new_bubble_text: String, timer_speed: float) -> void:
	_bubble_text = new_bubble_text
	_bubble_text_length = _bubble_text.length()
	
	match(timer_speed):
		Constants.DialogueSpeeds.SLOW:
			_tick_time = TimerSpeeds["slow"]
		Constants.DialogueSpeeds.MEDIUM:
			_tick_time = TimerSpeeds["medium"]
		Constants.DialogueSpeeds.FAST:
			_tick_time = TimerSpeeds["fast"]


func write_new_dialogue(new_bubble_text: String, timer_speed: float) -> void:
	pass

func remove_bubble() -> void:
	print("Queue freeing this bubble now!")
	self.queue_free()


func _erase_text() -> void:
	_do_erase_text = true


func _type_character() -> void:
	print("I should be typing characters!")
	_current_text += _bubble_text[_bubble_text_index]
	lbltext.text = _current_text
	if _bubble_text_index < _bubble_text_length - 1:
		timer.start(_tick_time)
		_bubble_text_index += 1


func _delete_character() -> void:
	if _bubble_text_length > 0:
		_current_text.erase(_bubble_text_length -1, 1)
		lbltext.text = _current_text
		_bubble_text_length -= 1
		timer.start(0.04)


func _on_Timer_timeout():
	if !_do_close:
		if _do_erase_text:
			_delete_character()
		else:
			_type_character()
	elif _do_close && _bubble_text_length == 0:
		remove_bubble()


