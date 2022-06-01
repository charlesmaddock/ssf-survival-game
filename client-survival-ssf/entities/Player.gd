extends KinematicBody2D


onready var Sprite = $Sprite


var entity: Entity
var is_player: bool = true

var _armPart:  Node
var _legPart:  Node
var _bodyPart: Node

var legArray: Array = [
	preload("res://parts/legs/Default Legs.tscn"),
	preload("res://parts/legs/BlueShoes.tscn"),
	preload("res://parts/legs/BirdLegs.tscn")
	]

var bodyArray: Array = [
	preload("res://parts/bodies/DefaultBody.tscn"),
	preload("res://parts/bodies/FishBody.tscn"),
	preload("res://parts/bodies/ExoSkeleton.tscn")
	]

var armArray: Array = [
	preload("res://parts/arms/DefaultArm.tscn"),
	preload("res://parts/arms/HammerArm.tscn"),
	preload("res://parts/arms/DrillArm.tscn")
	]


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.ROOM_LEFT:
			if entity.id == packet.id:
				queue_free()


func set_players_data(name: String, className: String) -> void:
	$UsernameLabel.text = name
	get_node("Sprite").texture = Util.get_sprite_for_class(className)
	
	var nameLength = name.length()
	
	var legNode = legArray[nameLength % legArray.size()].duplicate(true).instance()
	add_child_below_node($UsernameLabel, legNode)
	legNode.position = Vector2(1, -7)
	_legPart = legNode
	
	var bodyNode = bodyArray[nameLength % bodyArray.size()].duplicate(true).instance()
	add_child_below_node($UsernameLabel, bodyNode)
	bodyNode.position = Vector2(1, -12)
	_bodyPart = bodyNode
	
	var armNode = armArray[nameLength % armArray.size()].duplicate(true).instance()
	add_child_below_node($UsernameLabel, armNode)
	armNode.position = Vector2(1, -14)
	_armPart = armNode
	
	Server.ping()


func _input(event):
	if Input.is_action_just_pressed("ui_pickup"):
		var overlapped = get_node("Pickup").get_overlapping_areas()
		
		if not overlapped.empty():
			_armPart.queue_free()
			
			var armNode = Constants.PartScenes[overlapped[0].get_parent().get_part_id()].duplicate(true).instance()
			add_child_below_node(get_node("UsernameLabel"), armNode)
			armNode.position = Vector2(1, -14)
			_armPart = armNode
			
			overlapped[0].get_parent().queue_free()
			
			if overlapped.size() == 1:
				get_node("PickUpText").visible = false


func _on_Pickup_area_entered(area):
	get_node("PickUpText").visible = true


func _on_Pickup_area_exited(area):
	var overlapped = get_node("Pickup").get_overlapping_areas()
	
	if overlapped.empty():
		get_node("PickUpText").visible = false
