extends ColorRect


onready var label = $Label


func _ready():
	Events.connect("player_dead", self, "_on_player_dead")
	set_visible(false)


func _on_player_dead(id) -> void:
	if id == Lobby.my_id:
		set_visible(true)
		yield(get_tree().create_timer(5), "timeout")
		set_visible(false)
