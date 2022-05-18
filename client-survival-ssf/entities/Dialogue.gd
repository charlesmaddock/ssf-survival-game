extends Node2D

onready var bubble_scene: PackedScene = preload("res://components/SpeechBubble.tscn")
onready var dialogue_collision_node = $DialogueCollision
onready var animation_player_node = $AnimationPlayer


#export(Array, Dictionary) var _dialogues


var _is_player_in_area: bool = false
var _players_in_area: Array = []

var _is_text_written_out: bool = true
var _is_text_erased: bool = false
var bubble: Node2D
var _current_bubble_animation: String = "Talking_Neutral"

var dialogues: Array = [
	{"text": "Hello there Hero! We are in much need of you. There is currently a monster-virus residing at the end of this dungeon",
	"text_speed": Constants.DialogueSpeeds.MEDIUM,
	"animation": "Talking_Neutral"
	},
	
	{"text": "Would you please defeat it?",
	"text_speed": Constants.DialogueSpeeds.MEDIUM,
	"animation": "Talking_Neutral"},
	
	{"text": "And remember: do not succumb to it's allure!",
	"text_speed": Constants.DialogueSpeeds.MEDIUM,
	"animation": "Talking_Neutral"},
]


func _process(delta):
	if Input.is_action_pressed("ui_accept") && _is_player_in_area:
		_next_dialogue()
	if !_is_player_in_area && is_instance_valid(bubble):
		_remove_bubble()


func _next_dialogue() -> void:
	if !is_instance_valid(bubble):
		bubble = bubble_scene.instance()
		bubble.global_position += Vector2(0, -60)
		bubble.init(dialogues[0]["text"], dialogues[0]["text_speed"])
		add_child(bubble)
	
	else:
		if _is_text_written_out && !_is_text_erased:
			pass
		elif !_is_text_written_out && _is_text_erased:
			pass

func _remove_bubble() -> void:
	bubble.remove_bubble()


func _on_DialogueArea2D_body_entered(body):
	_is_player_in_area = true
	_players_in_area.append(body.entity.id)


func _on_DialogueArea2D_body_exited(body):
	_players_in_area.erase(body.entity.id)
	if _players_in_area.size() == 0:
		_is_player_in_area = false

