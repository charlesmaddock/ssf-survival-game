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
#var do_close = false

func init(new_bubble_text: String, timer_speed: float) -> void:
	_bubble_text = new_bubble_text
	match(timer_speed):
		Constants.DialogueSpeeds.SLOW:
			_tick_time = TimerSpeeds["slow"]
		Constants.DialogueSpeeds.MEDIUM:
			_tick_time = TimerSpeeds["medium"]
		Constants.DialogueSpeeds.FAST:
			_tick_time = TimerSpeeds["fast"]


func _ready():
	_bubble_text_length = _bubble_text.length()


func remove_bubble() -> void:
	self.queue_free()


func _on_Timer_timeout():
	#if(!do_close):
	if _bubble_text_index == 0 && !vBoxContainer.is_visible():
		yield(get_tree().create_timer(0.20), "timeout")
		vBoxContainer.set_visible(true)
	
	_current_text += _bubble_text[_bubble_text_index]
	lbltext.text = _current_text
	
	if _bubble_text_index < _bubble_text_length - 1:
		timer.start(_tick_time)
		_bubble_text_index += 1
	else:
		timer.stop()
	
	""""
	else:
		if(!do_close):
			do_close = true
			timer.start(1)
	"""
	"""
	else:
		if(_bubble_text_length > 0):
			_current_text.erase(_bubble_text_length -1, 1)
			lbltext.text = _current_text
			_bubble_text_length -= 1
			
			ninerect.rect_size -= Vector2(6,0)
			ninerect.rect_position += Vector2(3,0)
			
			timer.start(0.04)
		else:
			queue_free()
	"""
