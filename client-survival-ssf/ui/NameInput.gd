extends LineEdit


func _on_NameInput_text_changed(new_text):
	var new_client_data = Lobby.my_client_data.duplicate(true)
	new_client_data.name = new_text
	Server.req_update_client_data(new_client_data)
