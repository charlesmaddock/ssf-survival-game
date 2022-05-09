extends Control


onready var Panel = $Panel
onready var Name = $Panel/MarginContainer/vbox/Name
onready var ClassName = $Panel/MarginContainer/vbox/Class
onready var ClassSprite: Sprite = $"Panel/MarginContainer/vbox/ClassContainer/SpriteContainer/Sprite"
onready var LeftButton: Button = $"Panel/MarginContainer/vbox/ClassContainer/Left"
onready var RightButton: Button = $"Panel/MarginContainer/vbox/ClassContainer/Right"


var class_index: int = 0
var _client_data: Dictionary = {}


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	
	clear()


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.UPDATE_CLIENT_DATA:
		if _client_data.has("id"):
			var new_client_data = packet.clientData
			if new_client_data.id == _client_data.id:
				set_player_info(new_client_data)


func clear() -> void:
	Panel.set_visible(false)


func set_player_info(client_data: Dictionary) -> void:
	Panel.set_visible(true)
	
	_client_data = client_data
	
	ClassSprite.texture = Util.get_sprite_for_class(client_data.class)
	
	Name.text = client_data.name
	ClassName.text = client_data.class
	
	#LeftButton.set_visible(client_data.id == Lobby.my_id)
	#RightButton.set_visible(client_data.id == Lobby.my_id)


func _on_Left_pressed():
	class_index -= 1
	if class_index < 0:
		class_index = Constants.class_info.size() - 1
	
	var new_class = Constants.class_info[class_index].name
	var client_data = _client_data.duplicate(true)
	client_data.class = new_class
	Server.req_update_client_data(client_data)


func _on_Right_pressed():
	class_index += 1
	if class_index > Constants.class_info.size() - 1:
		class_index = 0
	
	var new_class = Constants.class_info[class_index].name
	var client_data = _client_data.duplicate(true)
	client_data.class = new_class
	Server.req_update_client_data(client_data)
