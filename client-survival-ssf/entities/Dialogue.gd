extends Node2D

onready var bubble_scene: PackedScene = preload("res://components/SpeechBubble.tscn")
onready var dialogue_collision_node = $DialogueCollision
onready var animation_player_node = $AnimationPlayer


#export(Array, Dictionary) var _dialogues


var _is_player_in_area: bool = false
var _players_in_area: Array = []

var _is_dialogue_finished = true
var bubble: Node2D
var _current_bubble_animation: String = "Talking_Neutral"

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
	

func on_dialogue_finished() -> void:
	_is_dialogue_finished = true
	print("Dialogue is finished!")


func _process(delta):
	if Input.is_action_pressed("ui_accept") && _is_player_in_area:
		_start_next_dialogue()
	if !_is_player_in_area && is_instance_valid(bubble):
		delete_bubble()


func _start_next_dialogue() -> void:
	if !is_instance_valid(bubble):
		bubble = bubble_scene.instance()
		add_child(bubble)
		bubble.connect("dialogue_finished", self, "on_dialogue_finished")
		bubble.global_position += Vector2(0, -60)
	_write_next_dialogue()


func _write_next_dialogue() -> void:
	if _is_dialogue_finished && _dialogue_index < dialogues.size() - 1:
			_is_dialogue_finished = false
			print("Writing this dialogue: ", dialogues[_dialogue_index])
			bubble.write_new_dialogue(dialogues[_dialogue_index]["text"], dialogues[_dialogue_index]["text_speed"])
			_dialogue_index += 1


func delete_bubble() -> void:
	bubble.delete_bubble()
	_dialogue_index = 0


func _on_DialogueArea2D_body_entered(body):
	_is_player_in_area = true
	_players_in_area.append(body.entity.id)


func _on_DialogueArea2D_body_exited(body):
	_players_in_area.erase(body.entity.id)
	if _players_in_area.size() == 0:
		_is_player_in_area = false

