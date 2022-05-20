extends Node2D


onready var vBoxContainer: VBoxContainer = $VBoxContainer
onready var dialogue_node: Node2D = self.get_parent()
onready var LetterSoundAudioPlayer = dialogue_node.get_node("LetterSoundAudioPlayer")
onready var lbltext = $VBoxContainer/Label
onready var timer = $Timer


var _bubble_text: String = ""
var _bubble_text_length = 0
var _bubble_text_index = 0
var _current_text = ""
var _tick_time: String = "Medium"

var _new_bubble_text: String
var _new_tick_time: String
var _new_bubble_text_length = 0

var _first_dialogue: bool = true
var _do_close = false
var _is_there_new_dialogue = false


signal dialogue_finished()
signal bubble_deleted()
signal changed_talking_state(is_talking)
signal letter_typed(letter_typed)


func _ready():
	vBoxContainer.visible = false
	connect("letter_typed", LetterSoundAudioPlayer, "_on_letter_typed")


func write_new_dialogue(new_bubble_text: String, tick_speed: String) -> void:
	_is_there_new_dialogue = true
	_new_bubble_text = new_bubble_text
	_new_tick_time = tick_speed
	
	if _first_dialogue == true:
		_first_dialogue = false
		_bubble_text_length = _bubble_text.length()
		vBoxContainer.visible = true
		_start_timer(tick_speed)
	else:
		_start_timer(_tick_time)


func _instantiate_new_dialogue() -> void:
	_is_there_new_dialogue = false
	_bubble_text = _new_bubble_text
	_tick_time = _new_tick_time
	_bubble_text_length = _bubble_text.length()


func _start_timer(tick_speed) -> void:
	var new_tick_speed = Constants.DialogueSpeeds[tick_speed]
	timer.start(new_tick_speed)


func delete_dialogue_then_bubble(tick_speed) -> void:
	_new_bubble_text = ""
	_tick_time = tick_speed
	_do_close = true
	_start_timer(_tick_time)


func delete_bubble() -> void:
	emit_signal("changed_talking_state", false)
	emit_signal("bubble_deleted")
	self.queue_free()


func _type_character() -> void:
	emit_signal("changed_talking_state", true)
	_current_text += _bubble_text[_bubble_text_index]
	var letter_typed = _current_text[-1]
	emit_signal("letter_typed", letter_typed)
	lbltext.text = _current_text
	if !_bubble_text_index > _bubble_text_length - 1:
		_bubble_text_index += 1
	_start_timer(_tick_time)


func _delete_character() -> void:
	if !_bubble_text_index < -1:
		_current_text.erase(_bubble_text_length -1, 1)
		lbltext.text = _current_text
		_bubble_text_length -= 1
		_bubble_text_index -= 1
		emit_signal("changed_talking_state", false)
	_start_timer(_tick_time)


func _on_Timer_timeout():
	timer.stop()
	if _is_there_new_dialogue:
		if _current_text == "":
			_instantiate_new_dialogue()
			_type_character()
		else:
			_delete_character()
	else:
		if !_do_close:
			if _current_text != _bubble_text:
				_type_character()
			else:
				emit_signal("changed_talking_state", false)
				emit_signal("dialogue_finished")
		else:
			if _current_text != "":
				_delete_character()
			else:
				#yield(get_tree().create_timer(Constants.DialogueSpeeds[_tick_time]), "timeout")
				delete_bubble()

