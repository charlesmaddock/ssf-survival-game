extends Node2D


export(bool) var retract = true
export(float) var offset = 0.0


onready var DamageCollisionShape: CollisionShape2D = $Damage/CollisionShape2D
onready var OutSpikes: Sprite = $OutSpikes
onready var InSpikes: Sprite = $InSpikes


func _ready() -> void:
	if retract == true:
		$InOutTimer.start(offset) 


func _on_InOutTimer_timeout():
	DamageCollisionShape.disabled = !DamageCollisionShape.disabled
	OutSpikes.set_visible(!DamageCollisionShape.disabled)
	InSpikes.set_visible(DamageCollisionShape.disabled)
