extends HBoxContainer


onready var container = $Container
onready var attack_label = $AttackIcon/Label
onready var speed_label = $SpeedIcon/Label
onready var weight_label = $WeightIcon/Label
onready var health_label = $HealthIcon/Label


func set_values(perks) -> void:
	container.set_visible(false)
	
	var damage = perks.damage
	var speed = perks.speed
	var weight = perks.weight
	var health_mod = perks.health_mod
	
	health_label.get_parent().set_visible(health_mod != 0)
	health_label.text = str(health_mod)
	
	attack_label.get_parent().set_visible(damage != 0)
	attack_label.text = str(damage)
	
	speed_label.get_parent().set_visible(speed != 0)
	speed_label.text = str(speed)
	
	weight_label.get_parent().set_visible(weight != 0)
	weight_label.text = str(weight)
