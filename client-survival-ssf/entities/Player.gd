extends KinematicBody2D


onready var Sprite = $Sprite


var entity: Entity
var is_player: bool = true


var _armPart:  Node
var _legPart:  Node
var _bodyPart: Node
var _inital_leg_parts = [Constants.Parts.BirdLegs, Constants.Parts.BlueShoes, Constants.Parts.DefaultLegs]
var _inital_body_parts = [Constants.Parts.ExoSkeleton, Constants.Parts.DefaultBody, Constants.Parts.FishBody]
var _inital_arm_parts = [Constants.Parts.DefaultArm, Constants.Parts.DrillArm, Constants.Parts.HammerArm, Constants.Parts.HeartArm]


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
	
	var legPartType: int = _inital_leg_parts[randi() % _inital_leg_parts.size()]
	var legNode: Node = Util.get_instanced_part(legPartType)
	add_child_below_node($UsernameLabel, legNode)
	legNode.position = Vector2(1, -7)
	_legPart = legNode
	
	var bodyPartType: int = _inital_body_parts[randi() % _inital_body_parts.size()]
	var bodyNode: Node = Util.get_instanced_part(bodyPartType)
	add_child_below_node($UsernameLabel, bodyNode)
	bodyNode.position = Vector2(1, -12)
	_bodyPart = bodyNode
	
	var armPartType: int = _inital_arm_parts[randi() % _inital_arm_parts.size()]
	var armNode: Node = Util.get_instanced_part(armPartType)
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

	var pick_up_part_type: int = area.get_parent().get_part_id()
	var armNode = Util.get_instanced_part(pick_up_part_type)
	add_child(armNode)
	armNode.position = Vector2(1, -14)
	_armPart = armNode
	
	area.get_parent().queue_free()

