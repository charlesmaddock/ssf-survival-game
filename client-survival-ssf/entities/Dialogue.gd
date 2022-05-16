extends Node2D


onready var dialogue_collision_node = $"DialogueCollision"

export(PackedScene) var bubble : PackedScene
export(Array, Dictionary) var _dialogues

var _is_bubble_finsihed: bool = true
var current_bubble: Node2D
var _current_bubble_index: int = 0


func init():
	pass

func _ready() -> void:
	connect("bubble_finished", self, "_on_bubble_finsihed")


func _on_bubble_finsihed() -> void:
	_is_bubble_finsihed = true


func _process(delta):
	if(Input.is_action_pressed("ui_accept") && _is_bubble_finsihed == true):
		_next_dialogue()

func _next_dialogue() -> void:
	var new_bubble = bubble.instance()
	new_bubble.global_position += Vector2(0, -60)
	new_bubble.init("Hello traveler! \n This is a new line!", Constants.DialogueSpeeds.FAST)
	add_child(new_bubble)

func _on_DialogueCollision_body_entered(body):
	pass # Replace with function body.


func _on_DialogueCollision_body_exited(body):
	pass # Replace with function body.
