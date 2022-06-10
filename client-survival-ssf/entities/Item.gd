extends Area2D


onready var ItemSprite = $Sprite


var entity: Entity
var item_type: int


func init(type: int) -> void:
	item_type = type


func _ready():
	ItemSprite.texture = Constants.item_textures[item_type]


func _on_Item_body_entered(body):
	if Util.is_player(body):
		
		if item_type == Constants.ItemTypes.HEART:
			body.entity.emit_signal("heal", 30.0)
		
		if Lobby.is_host == true:
			Server.despawn_item(entity.id)

