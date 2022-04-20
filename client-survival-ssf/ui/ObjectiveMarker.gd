extends Panel


onready var ChipsLeft = $ChipsLeft
onready var PlayersLeft = $PlayersLeft


var dead_player_ids: Array
var nodes_freed: Array = []
var total_nodes: int = 0


func _ready():
	Events.connect("player_dead", self, "_on_player_dead")
	Server.connect("packet_received", self, "_on_packet_received")
	
	for e in Util.get_game_node().get_node("Entities").get_children():
		var entity: Node2D = e
		if entity.get("node_id") != null: # is freeable node
			total_nodes += 1


func _on_packet_received(packet: Dictionary):
	pass


func _on_player_dead(id) -> void:
	if dead_player_ids.find(id) == -1:
		dead_player_ids.append(id)
