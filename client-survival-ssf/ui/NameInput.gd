extends HBoxContainer


onready var LineEdit = $LineEdit


func _on_SubmitName_pressed():
	submit(LineEdit.text)


func _on_LineEdit_text_entered(new_text):
	submit(new_text)


func submit(name: String):
	var new_client_data = Lobby.my_client_data.duplicate(true)
	new_client_data.name = name
	Server.req_update_client_data(new_client_data)
