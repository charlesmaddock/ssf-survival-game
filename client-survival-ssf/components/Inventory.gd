extends CanvasLayer


onready var Backdrop = $Backdrop
onready var Wrapper = $Wrapper
onready var Items = $Items
onready var SlotContainer = $Wrapper/Panel/SlotContainer
onready var entity_id = ""


func _ready():
	if Util.is_entity(get_parent()):
		entity_id = get_parent().entity.id
	Server.connect("packet_received", self, "_on_packet_received")
	toggle()


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
						entity.position = available_slot.rect_global_position


func get_available_slot() -> Control:
	for child in SlotContainer.get_children():
		if child.available == true:
			return child
	
	return null


func _physics_process(_delta):
	toggle()


func toggle() -> void:
	Backdrop.set_visible(Input.is_key_pressed(KEY_TAB))
	Wrapper.set_visible(Input.is_key_pressed(KEY_TAB))
	Items.set_visible(Input.is_key_pressed(KEY_TAB))
