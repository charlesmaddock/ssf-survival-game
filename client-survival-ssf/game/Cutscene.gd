extends CanvasLayer

export(String) var text1: String
export(Texture) var img1: Texture
export(String) var text2: String
export(Texture) var img2: Texture
export(String) var text3: String
export(Texture) var img3: Texture
export(String) var text4: String
export(Texture) var img4: Texture
export(String) var text5: String
export(Texture) var img5: Texture
export(String) var text6: String
export(Texture) var img6: Texture
export(String) var text7: String
export(Texture) var img7: Texture

onready var display_text = $ColorRect/DisplayText
onready var display_sprite = $ColorRect/DisplaySprite
onready var display_sprite_animator = $ColorRect/DisplaySprite/AnimationPlayer
onready var dialogs: Array = [
	{"img": img1, "text": text1},
	{"img": img2, "text": text2},
	{"img": img3, "text": text3},
	{"img": img4, "text": text4},
	{"img": img5, "text": text5},
	{"img": img6, "text": text6},
	{"img": img7, "text": text7},
]
var dialog_index: int = 0
var text_index: float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventScreenTouch || event is InputEventKey || event is InputEventMouseButton:
		queue_free()


func _process(delta):
	if dialog_index >= dialogs.size():
		queue_free()
		return
	
	var current_dialog = dialogs[dialog_index]
	if text_index >= current_dialog.text.length():
		dialog_index += 1
		text_index = 0
		set_process(false)
		yield(get_tree().create_timer(2), "timeout")
		display_sprite_animator.play("disappear")
		yield(get_tree().create_timer(1.5), "timeout")
		set_process(true)
	else:
		if display_sprite.texture != current_dialog.img:
			display_sprite.texture = current_dialog.img
			display_sprite_animator.play("appear")
		
		text_index += delta * 12
		display_text.text = current_dialog.text.substr(0, int(text_index))
