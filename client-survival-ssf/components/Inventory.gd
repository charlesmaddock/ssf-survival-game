extends CanvasLayer


onready var Backdrop = $Backdrop
onready var Wrapper = $Wrapper
onready var Items = $Items
onready var SlotContainer = $Wrapper/Panel/HBox/SlotContainer
onready var CraftingSlots = $Wrapper/Panel/HBox/CraftingContainer/CraftingSlots
onready var entity_id = ""


var _all_slots: Array
var _dragging_item: Area2D = null
var _is_mine: bool
var _open: bool


func _ready():
	if Util.is_entity(get_parent()):
		entity_id = get_parent().entity.id
		_is_mine = entity_id == Lobby.my_id
	Server.connect("packet_received", self, "_on_packet_received")
	
	for child in SlotContainer.get_children():
		if child.has_method("try_set_item"):
			_all_slots.append(child)
	
	for child in CraftingSlots.get_children():
		if child.has_method("try_set_item"):
			_all_slots.append(child)
	
	toggle(false)


func _on_packet_received(packet: Dictionary) -> void:
	match(packet.type):
		Constants.PacketTypes.ADD_TO_INVENTORY:
			if entity_id == packet.id:
				var entity = Util.get_entity(packet.item_id)
				if entity != null:
					
					var available_slot: Control = get_available_slot()
					if available_slot != null:
						if entity.get_parent() != null:
							 entity.get_parent().remove_child(entity)
						Items.add_child(entity)
						available_slot.try_set_item(entity, true)
						entity.connect("pressed_item", self, "_on_pressed_item")
						entity.connect("dropped_item", self, "_on_dropped_item")


func _on_pressed_item(item) -> void:
	_dragging_item = item


func _on_dropped_item(item) -> void:
	var closest_dist = 9999
	var closest_slot = null
	for child in _all_slots:
		var slot_centre_pos = child.rect_global_position + child.rect_size / 2
		var dist = slot_centre_pos.distance_to(item.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_slot = child
	
	closest_slot.try_set_item(item, true)
	_dragging_item = null


func get_available_slot() -> Control:
	for child in SlotContainer.get_children():
		if child.available == true:
			return child
	
	return null


func _input(event):
	if Input.is_action_just_pressed("open_inventory"):
		toggle()


func _physics_process(delta):
	if is_instance_valid(_dragging_item):
		_dragging_item.global_position = _dragging_item.global_position.linear_interpolate(_dragging_item.get_global_mouse_position(), delta * 10)


func toggle(open: bool = !_open) -> void:
	_open = open
	Backdrop.set_visible(_open && _is_mine)
	Wrapper.set_visible(_open && _is_mine)
	Items.set_visible(_open && _is_mine)
