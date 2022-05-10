extends ColorRect


export(Color) var win_color
export(Color) var lose_color

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("game_over", self, "_on_game_over")
	set_visible(false)


func _on_game_over(won: bool = false):
	set_visible(true)
	
	if won == true:
		color = win_color
		$Label.text = "Alla bedragare är bekämpade! Ni vann!"
	else:
		color = lose_color
		$Label.text = "Alla spelare är utslagna, ni har förlorat."
