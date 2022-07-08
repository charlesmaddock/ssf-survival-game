extends PanelContainer


onready var Title = $MarginContainer/VBoxContainer/Title
onready var Desc = $MarginContainer/VBoxContainer/Desc
onready var Perk = $MarginContainer/VBoxContainer/Perk
onready var Con = $MarginContainer/VBoxContainer/Con
onready var StatsBar = $MarginContainer/VBoxContainer/StatsBar


var show_info_for_part: RigidBody2D = null
var standing_over_part: RigidBody2D = null


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("standing_over_part", self, "_on_standing_over_part")
	set_modulate(Color(modulate.r, modulate.g, modulate.b, 0))
	rect_scale = Vector2.ZERO


func _physics_process(delta):
	var alpha: float = modulate.a
	if show_info_for_part == null:
		set_modulate(Color(modulate.r, modulate.g, modulate.b, clamp(alpha - (delta + alpha/2), 0, 1)))
		rect_scale = Vector2(clamp(rect_scale.x - (delta + rect_scale.x / 4), 0, 1), clamp(rect_scale.x - (delta + rect_scale.x / 4), 0, 1))
	else:
		set_modulate(Color(modulate.r, modulate.g, modulate.b, clamp(alpha + (delta + alpha/3), 0, 1)))
		rect_scale = Vector2(clamp(rect_scale.x + (delta + rect_scale.x / 5), 0, 1), clamp(rect_scale.x + (delta + rect_scale.x / 5), 0, 1))


func _on_standing_over_part(part) -> void:
	standing_over_part = part
	
	# Wait a little bit before displaying item info
	if part != null:
		yield(get_tree().create_timer(0.4), "timeout")
		if standing_over_part == part:
			show_info_for_part = part
			Title.text = show_info_for_part.title
			
			Desc.set_visible(show_info_for_part.desc != "")
			Desc.text = show_info_for_part.desc
			
			Perk.set_visible(show_info_for_part.perk_desc != "")
			Perk.text = show_info_for_part.perk_desc
			
			Con.set_visible(show_info_for_part.con_desc != "")
			Con.text = show_info_for_part.con_desc
			
			StatsBar.set_values(show_info_for_part.perks)
			
			rect_size = Vector2.ZERO
	else:
		standing_over_part = null
		show_info_for_part = null
