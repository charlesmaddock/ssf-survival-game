extends Node2D


var closed: bool = false


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.START_DOORS:
		$OpenCloseTimer.start()

func _on_OpenCloseTimer_timeout():
	closed = !closed
	$AnimationPlayer.play("open" if closed == true else "close")
