extends Node2D


var entity: Entity


export(bool) var retract = true
export(bool) var start_retracted = false


onready var DamageCollisionShape: CollisionShape2D = $Damage/CollisionShape2D
onready var OutSpikes: Sprite = $OutSpikes
onready var InSpikes: Sprite = $InSpikes


func _ready() -> void:
	return
	if start_retracted == true:
		retract()


func _on_InOutTimer_timeout():
	retract()


func retract() -> void:
	DamageCollisionShape.disabled = !DamageCollisionShape.disabled
	OutSpikes.set_visible(!DamageCollisionShape.disabled)
	InSpikes.set_visible(DamageCollisionShape.disabled)
