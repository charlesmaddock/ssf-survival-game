tool
extends Node2D
var part_type: int = Constants.PartTypes.LEG
var part_name: int = Constants.PartNames.DefaultLegs


onready var sprite1: Node = get_node("Sprite1")
onready var sprite2: Node = get_node("Sprite2")

var walk_state: bool = false
var movement_node: Node

export(float) var walk_speed: float = 160
export(Texture) var leg_texture: Texture
export(Vector2) var sprite_offset: Vector2
export(float) var leg_separation: float = 5
export(float) var leg_scale: float = 1

export(String) var title: String = ""
export(String) var optional_desc: String = ""
export(String) var optional_perk_desc: String = ""
export(String) var optional_con_desc: String = ""


func _ready():
	var timer = get_node("Timer")
	timer.wait_time = 0.3 - round(walk_speed/200)/10
	timer.wait_time = clamp(timer.wait_time, 0.05, 10)
	
	if Util.is_entity(get_parent()):
		movement_node = get_parent().get_node("Movement")
		
		get_parent().entity.connect("turned_around", self, "_on_turned_around")
		
		yield(get_tree(), "idle_frame")
		if movement_node != null:
			get_parent().entity.emit_signal("change_movement_speed", walk_speed)
	
	if leg_texture != null:
		sprite1.texture = leg_texture
		sprite2.texture = leg_texture
	
	sprite1.offset = sprite_offset
	sprite2.offset = sprite_offset
	
	sprite1.position.x =  leg_separation/2
	sprite2.position.x = -leg_separation/2
	
	sprite1.scale = Vector2(leg_scale, leg_scale)
	sprite2.scale = Vector2(leg_scale, leg_scale)


func _process(delta):
	if Engine.editor_hint:
		if leg_texture != null:
			get_node("Sprite1").texture = leg_texture
			get_node("Sprite2").texture = leg_texture
		
		get_node("Sprite1").offset = sprite_offset
		get_node("Sprite2").offset = sprite_offset
		
		get_node("Sprite1").position.x =  leg_separation/2
		get_node("Sprite2").position.x = -leg_separation/2
		
		get_node("Sprite1").scale = Vector2(leg_scale, leg_scale)
		get_node("Sprite2").scale = Vector2(leg_scale, leg_scale)
		
		update()


func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2(leg_separation/2,  1),  0.35, Color(1, 1, 1, 1))
		draw_circle(Vector2(leg_separation/2,  1),  0.2,  Color(0, 0, 0, 1))
		draw_circle(Vector2(-leg_separation/2, 1),  0.35, Color(1, 1, 1, 1))
		draw_circle(Vector2(-leg_separation/2, 1),  0.2,  Color(0, 0, 0, 1))


func _on_turned_around(dir):
	if dir:
		scale.x = -1
	else:
		scale.x = 1


func _flip_direction():
	sprite1.flip_h = !sprite1.flip_h
	sprite2.flip_h = !sprite2.flip_h
	
	sprite1.offset.x = -sprite1.offset.x
	sprite2.offset.x = -sprite2.offset.x


func _on_Timer_timeout():
	if movement_node == null:
		return
	if movement_node.walking == false:
		walk_state = false
		sprite1.rotation_degrees = 0
		sprite2.rotation_degrees = 0
	else:
		walk_state = !walk_state
		if walk_state == true:
			sprite1.rotation_degrees =-60
			sprite2.rotation_degrees = 60
		else:
			sprite1.rotation_degrees = 0
			sprite2.rotation_degrees = 0


func get_sprite():
	return(leg_texture)
