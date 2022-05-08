extends Button


func _ready():
	set_visible(Lobby.is_host)


func _on_RestartButton_pressed():
	Server.restart_game()
