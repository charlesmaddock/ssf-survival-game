extends Node2D

onready var bubble_scene: PackedScene = preload("res://components/SpeechBubble.tscn")
onready var sprite: Sprite = get_parent().get_node("Sprite")
onready var animationPlayer: AnimationPlayer = sprite.get_node("AnimationPlayer")
onready var dialogue_collision_node = $DialogueCollision
onready var animation_player_node = $AnimationPlayer


#export(Array, Dictionary) var _dialogues


var _is_player_in_area: bool = false
var _players_in_area: Array = []

var _is_dialogue_finished = true
var _is_dialogue_being_deleted = false
var bubble: Node2D
var _current_bubble_animation: String = "Talking_Neutral"

var _is_talking: bool = false
var _is_animaton_to_stop: bool = false

var _dialogue_index = 0
var dialogues: Array = [
	{
	"text": "Hello there Hero!\nWe are in much need of you.",
	"text_speed": "Fast",
	"animation": "Talking_Neutral"
	},
	
	{
	"text": "There's a lovely monstrosity down the road.",
	"text_speed": "Fast",
	"animation": "Talking_Neutral"},
	
	{
	"text": "Would you please defeat it?",
	"text_speed": "Fast",
	"animation": "Talking_Neutral"},
	
	{
	"text": "And remember: do not succumb to it's allure!",
	"text_speed": "Fast",
	"animation": "Talking_Neutral"},
]


func _ready():
	pass


func _process(delta):
	if Input.is_action_pressed("ui_accept") && _is_player_in_area:
		_start_next_dialogue()
	if !_is_player_in_area && is_instance_valid(bubble):
		_delete_bubble()


func on_bubble_deleted() -> void:
	yield(get_tree().create_timer(1), "timeout")
	_reset_settings()
	print("This is the dialogue_index: ", _dialogue_index)


func on_dialogue_finished() -> void:
	_is_dialogue_finished = true
	print("Dialogue is finished!")


func on_changed_talking_state(is_talking: bool) -> void:
	if _is_talking != is_talking:
		_is_talking = is_talking
		if _is_talking:
			print("Telling animationplayer to player this: ", _current_bubble_animation)
			_play_animation(_current_bubble_animation)
		else:
			print("setting animation to stop = true")
			_is_animaton_to_stop = true


func _reset_settings() -> void:
	_dialogue_index = 0
	_is_dialogue_finished = true
	_is_dialogue_being_deleted = false
	_is_talking = false
	_is_animaton_to_stop = false


func _start_next_dialogue() -> void:
	if !is_instance_valid(bubble):
		bubble = bubble_scene.instance()
		add_child(bubble)
		bubble.connect("dialogue_finished", self, "on_dialogue_finished")
		bubble.connect("bubble_deleted", self, "on_bubble_deleted")
		bubble.connect("changed_talking_state", self, "on_changed_talking_state")
		bubble.global_position += Vector2(0, -40)
	_write_next_dialogue()


func _write_next_dialogue() -> void:
	if _is_dialogue_finished && is_instance_valid(bubble) && _is_dialogue_being_deleted != true:
		print("This is the dialogue_index: ", _dialogue_index)
		if !_dialogue_index > dialogues.size() - 1:
			_is_dialogue_finished = false
			_current_bubble_animation = dialogues[_dialogue_index]["animation"]
			print("Writing this dialogue: ", dialogues[_dialogue_index])
			bubble.write_new_dialogue(dialogues[_dialogue_index]["text"], dialogues[_dialogue_index]["text_speed"])
			_dialogue_index += 1
		else: 
			_delete_dialogue_then_bubble("Fast")


func _play_animation(animation) -> void:
	if _is_dialogue_finished == false && is_instance_valid(animationPlayer):
		var dialogue_index: int = _dialogue_index - 1
		if !dialogue_index > dialogues.size() - 1:
			print("Telling animationplayer to play index: ", dialogue_index)
			animationPlayer.play(dialogues[dialogue_index]["animation"], -1, 0.4 / Constants.DialogueSpeeds[dialogues[dialogue_index]["text_speed"]])


func _delete_bubble() -> void:
	_is_dialogue_being_deleted = true
	bubble.delete_bubble()


func _delete_dialogue_then_bubble(tick_speed) -> void:
	_is_dialogue_being_deleted = true
	bubble.delete_dialogue_then_bubble(tick_speed)


func _on_DialogueArea2D_body_entered(body):
	_is_player_in_area = true
	_players_in_area.append(body.entity.id)


func _on_DialogueArea2D_body_exited(body):
	_players_in_area.erase(body.entity.id)
	if _players_in_area.size() == 0:
		_is_player_in_area = false


func on_animation_finished() -> void:
	if _is_animaton_to_stop:
		_is_animaton_to_stop = false
		animationPlayer.stop()
		print("Telling sprite to set frame 0")
		sprite.set_frame(0)
