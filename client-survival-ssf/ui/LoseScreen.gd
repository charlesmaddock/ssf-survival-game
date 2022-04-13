extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("game_over", self, "_on_game_over")
	set_visible(false)


func _on_game_over():
	set_visible(true)
