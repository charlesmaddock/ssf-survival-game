extends Node2D


onready var dialogue_collision_node = $"DialogueCollision"

export(PackedScene) var bubble : PackedScene
export(Array, Dictionary) var _dialogues

var _is_latest_bubbled_added: bool = false
var _current_bubble_index: int = 0


func init():
	pass

func _physics_process(delta):
	if dialogue_collision_node.is


func _ready():
	pass # Replace with function body.


func _process(delta):
	if(Input.is_action_pressed("ui_accept") && _is_latest_bubbled_added == false):
		var new_bubble = bubble.instance()
		print("Im walking over here!")
		new_bubble._bubble_text = "Hello traveler! \n This is a new line!"
		print(self.global_position, " and this is the bubbles pos: ", new_bubble.global_position)
		new_bubble.global_position += Vector2(0, -60)
		add_child(new_bubble)
		_is_latest_bubbled_added = true
		print(self.global_position, " and this is the bubbles pos after adding as child: ", new_bubble.global_position)

func _next_dialogue() -> void:
	pass

func _on_DialogueCollision_body_entered(body):
	pass # Replace with function body.


func _on_DialogueCollision_body_exited(body):
	pass # Replace with function body.
