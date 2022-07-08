extends HBoxContainer


onready var container = $Container
onready var attack_label = $AttackIcon/Label
onready var speed_label = $SpeedIcon/Label
onready var weight_label = $WeightIcon/Label


func set_values(perks) -> void:
	container.set_visible(false)
	
	var damage = perks.damage
	var speed = perks.speed
	var weight = perks.weight
	
	attack_label.get_parent().set_visible(damage != -1)
	attack_label.text = str(damage)
	
	speed_label.get_parent().set_visible(speed != -1)
	speed_label.text = str(speed)
	
	weight_label.get_parent().set_visible(weight != -1)
	weight_label.text = str(weight)
