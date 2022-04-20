extends Area2D


onready var ItemSprite = $Sprite


var entity: Entity
var item_type: int
var force: Vector2

var _mouse_over: bool
var _dragging: bool
var _inventory_slot 


signal pressed_item(item)
signal dropped_item(item)


func init(type: int) -> void:
	item_type = type


func _ready():
	ItemSprite.texture = Constants.item_textures[item_type]


func get_inventory_slot() -> Control:
	return _inventory_slot


func set_inventory_slot(slot: Control) -> void:
	_inventory_slot = slot


func _input(event):
	if Input.is_action_just_pressed("attack") && _mouse_over:
		emit_signal("pressed_item", self)
		_dragging = true
	
	if Input.is_action_just_released("attack") && _dragging:
		_dragging = false
		emit_signal("dropped_item", self)


func _on_Item_body_entered(body):
	if Util.is_entity(body):
		if Lobby.is_host == true:
			Server.add_to_inventory(body.entity.id, entity.id)
			Server.despawn_item(entity.id)


func _on_Item_mouse_entered():
	_mouse_over = true


func _on_Item_mouse_exited():
	_mouse_over = false
