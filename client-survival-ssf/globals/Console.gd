extends CanvasLayer


var error_message_scene: PackedScene = preload("res://ui/ErrorMessagePanel.tscn")
onready var ConsoleContainer = $ConsoleContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary):
	match(packet.type):
		Constants.PacketTypes.SERVER_MESSAGE:
			var e = error_message_scene.instance()
			e.set_text(packet.text)
			ConsoleContainer.add_child(e)
	
