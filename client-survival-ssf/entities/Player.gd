extends KinematicBody2D


onready var Sprite = $Sprite


var entity: Entity
var is_player: bool = true


var _armPart:  Node
var _legPart:  Node
var _bodyPart: Node
var _arm_offset: Vector2 = Vector2(1, -14)
var _leg_offset: Vector2 = Vector2(1, -7)
var _body_offset: Vector2 = Vector2(1, -12)
var _arm_child_index: int = 0
var _leg_child_index: int = 1
var _body_child_index: int = 2

var _inital_leg_parts = [Constants.PartNames.DefaultLegs]
var _inital_body_parts = [Constants.PartNames.DefaultBody]
var _inital_arm_parts = [Constants.PartNames.DefaultArm]


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	$MyPlayerIndicator.set_visible(entity.id == Lobby.my_id)
	
	if entity.id == Lobby.my_id: 
		
		Events.emit_signal("follow_w_camera", self)


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.ROOM_LEFT:
			if entity.id == packet.id:
				queue_free()


func set_players_data(name: String, className: String) -> void:
	$UsernameLabel.text = name
	get_node("Sprite").texture = Util.get_sprite_for_class(className)
	
	var nameLength = name.length()
	
	add_part(_inital_leg_parts[nameLength % _inital_leg_parts.size()])
	add_part(_inital_body_parts[nameLength % _inital_body_parts.size()])
	add_part(_inital_arm_parts[nameLength % _inital_arm_parts.size()])
	
	Server.ping()


func _input(event):
	if Input.is_action_just_pressed("ui_pickup"):
		var overlapped = get_node("Pickup").get_overlapping_areas()
		
		if not overlapped.empty():
			var picked_up_part_name = overlapped[0].get_parent().get_part_name()
			add_part(picked_up_part_name)
			
			overlapped[0].get_parent().queue_free()
			
			if overlapped.size() == 1:
				get_node("PickUpText").visible = false


func add_part(part_name: int) -> void:
	var part: Node = Util.get_instanced_part(part_name)
	add_child(part)
	if part.part_type == Constants.PartTypes.ARM:
		if is_instance_valid(_armPart):
			_armPart.queue_free()
		move_child(part, _arm_child_index)
		part.position = _arm_offset
		_armPart = part
	elif part.part_type == Constants.PartTypes.LEG:
		if is_instance_valid(_legPart):
			_legPart.queue_free()
		move_child(part, _leg_child_index)
		part.position = _leg_offset
		_legPart = part
	elif part.part_type == Constants.PartTypes.BODY:
		if is_instance_valid(_bodyPart):
			_bodyPart.queue_free()
		move_child(part, _body_child_index)
		part.position = _body_offset
		_bodyPart = part


func _on_Pickup_area_entered(area):
	get_node("PickUpText").visible = true


func _on_Pickup_area_exited(area):
	var overlapped = get_node("Pickup").get_overlapping_areas()
	
	if overlapped.empty():
		get_node("PickUpText").visible = false
	
#	var pick_up_part_type: int = area.get_parent().get_part_name()
#	var armNode = Util.get_instanced_part(pick_up_part_type)
#	add_child_below_node(get_node("UsernameLabel"), armNode)
#	armNode.position = Vector2(1, -14)
#	_armPart = armNode
#
#	area.get_parent().queue_free()
