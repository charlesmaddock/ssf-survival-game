extends KinematicBody2D


onready var Sprite = $Sprite
onready var PickUpButton = $CanvasLayer/PickUpContainer/PickUpButton


var entity: Entity
var is_player: bool = true


var _armPart:  Node
var _legPart:  Node
var _bodyPart: Node
var _arm_offset: Vector2 = Vector2(1, -32)
var _leg_offset: Vector2 = Vector2(1, -14)
var _body_offset: Vector2 = Vector2(1, -24)
var _arm_child_index: int = 0
var _leg_child_index: int = 1
var _body_child_index: int = 2
var _pickup_cooldown: float

var _inital_leg_parts = [Constants.PartNames.DefaultLegs]
var _inital_body_parts = [Constants.PartNames.DefaultBody]
var _inital_arm_parts = [Constants.PartNames.DefaultShooter]


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	Events.connect("player_dead", self, "_on_player_dead")
	$MyPlayerIndicator.set_visible(entity.id == Lobby.my_id)
	
	set_visible_pickup(false)
	
	if entity.id == Lobby.my_id: 
		Events.emit_signal("follow_w_camera", self)


func _on_player_dead(id) -> void:
	if id == entity.id:
		_set_default_parts()


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.ROOM_LEFT:
			if entity.id == packet.id:
				queue_free()
		Constants.PacketTypes.PICK_UP_PART:
			if packet.player_id == entity.id:
				add_part(packet.part_name)
				
				var overlapped = get_node("Pickup").get_overlapping_areas()
				if overlapped.size() == 1:
					set_visible_pickup(false)
					Events.emit_signal("standing_over_part", null)


func _process(delta):
	_pickup_cooldown += delta


func set_players_data(name: String, className: String) -> void:
	$UsernameLabel.text = name
	#get_node("Sprite").texture = Util.get_sprite_for_class(className)
	_set_default_parts()
	
	Server.ping()


func _set_default_parts() -> void:
	var nameLength = name.length()
	add_part(_inital_leg_parts[nameLength % _inital_leg_parts.size()])
	add_part(_inital_body_parts[nameLength % _inital_body_parts.size()])
	add_part(_inital_arm_parts[nameLength % _inital_arm_parts.size()])


func _input(event):
	if Input.is_action_just_pressed("ui_pickup") && entity.id == Lobby.my_id:
		try_pick_up()


func try_pick_up() -> void:
	if _pickup_cooldown > 0.2:
		_pickup_cooldown = 0.0
		
		var overlapped = get_node("Pickup").get_overlapping_areas()
		
		if not overlapped.empty():
			Server.pick_up_part(overlapped[0].get_parent().get_id(), entity.id, overlapped[0].get_parent().get_part_name())


func add_part(part_name: int) -> void:
	var part: Node = Util.get_instanced_part(part_name)
	_drop_old_part(part.part_type)
	add_child(part)
	if part.part_type == Constants.PartTypes.ARM:
		if is_instance_valid(_armPart):
			_armPart.remove()
			_armPart.queue_free()
		move_child(part, _arm_child_index)
		part.position = _arm_offset
		_armPart = part
	elif part.part_type == Constants.PartTypes.LEG:
		if is_instance_valid(_legPart):
			_legPart.remove()
			_legPart.queue_free()
		move_child(part, _leg_child_index)
		part.position = _leg_offset
		_legPart = part
	elif part.part_type == Constants.PartTypes.BODY:
		if is_instance_valid(_bodyPart):
			_bodyPart.remove()
			_bodyPart.queue_free()
		move_child(part, _body_child_index)
		part.position = _body_offset
		_bodyPart = part


func _drop_old_part(part_type: int) -> void:
	if Lobby.is_host:
		if part_type == Constants.PartTypes.ARM && is_instance_valid(_armPart):
			Server.spawn_pickup(Util.generate_id(), _armPart.part_name, global_position)
		elif part_type == Constants.PartTypes.LEG && is_instance_valid(_legPart):
			Server.spawn_pickup(Util.generate_id(), _legPart.part_name, global_position)
		elif part_type == Constants.PartTypes.BODY && is_instance_valid(_bodyPart):
			Server.spawn_pickup(Util.generate_id(), _bodyPart.part_name, global_position)


func set_visible_pickup(val: bool) -> void:
	PickUpButton.visible = val && Util.is_dead(self) == false && Util.is_mobile()


func _on_Pickup_area_entered(area):
	if entity.id == Lobby.my_id:
		set_visible_pickup(true)
		Events.emit_signal("standing_over_part", area.get_parent())


func _on_Pickup_area_exited(area):
	if entity.id == Lobby.my_id:
		var overlapped = get_node("Pickup").get_overlapping_areas()
		
		if overlapped.empty():
			set_visible_pickup(false)
			Events.emit_signal("standing_over_part", null)
	
#	var pick_up_part_type: int = area.get_parent().get_part_name()
#	var armNode = Util.get_instanced_part(pick_up_part_type)
#	add_child_below_node(get_node("UsernameLabel"), armNode)
#	armNode.position = Vector2(1, -14)
#	_armPart = armNode
#
#	area.get_parent().queue_free()


func _on_PickUpButton_pressed():
	try_pick_up()
