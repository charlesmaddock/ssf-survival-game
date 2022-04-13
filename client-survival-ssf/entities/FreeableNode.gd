extends Node2D


onready var TextureProgress = $TextureProgress
onready var HackedNodeSprite = $Hacked


var _freed: bool = false
var _players_nearby: Array = []
var _progress: float = 0


onready var node_id = self.name


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func was_first_freer(id: String) -> bool:
	if _players_nearby.size() == 0:
		return true
	else:
		return _players_nearby[0].get_id() == id


func get_is_freed() -> bool:
	return _freed


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.NODE_FREED:
			if packet.id == node_id:
				_freed = true
				HackedNodeSprite.set_visible(false)
				TextureProgress.value = 100


func _process(delta):
	if _freed == false:
		if _players_nearby.size() > 0:
			_progress += delta * 13
		elif _progress > 0:
			_progress -= delta * 15
		
		TextureProgress.value = _progress
		
		if _progress > 99.9 && Lobby.is_host:
			Server.send_free_node(node_id)


func _on_FreeArea_body_entered(body):
	if body is KinematicBody2D && body.get("is_player"):
		_players_nearby.append(body)


func _on_FreeArea_body_exited(body):
	if body is KinematicBody2D && body.get("is_player"):
		_players_nearby.erase(body)
