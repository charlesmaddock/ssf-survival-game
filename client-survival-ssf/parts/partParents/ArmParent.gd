tool
extends Node2D


onready var parent_entity: Entity = get_parent().entity
onready var sprite1: Node = get_node("Sprite1")
onready var sprite2: Node = get_node("Sprite2")
onready var animation: Node = get_node("AnimationPlayer")
onready var attack_timer: Node = get_node("Timer")

var able_to_attack: bool = true
var is_dead: bool = false

export(Texture) var arm_texture: Texture
export(Vector2) var sprite_offset: Vector2
export(float) var arm_separation: float


func _ready():
	Events.connect("player_dead", self, "_on_player_dead")
	Events.connect("player_revived", self, "_on_player_revived")
	get_parent().entity.connect("turned_around", self, "_on_turned_around")
	
	if arm_texture != null:
		sprite1.texture = arm_texture
		sprite2.texture = arm_texture
	
	sprite1.offset = sprite_offset
	sprite2.offset = sprite_offset
	sprite2.offset.x = -sprite_offset.x
	
	sprite1.position.x = arm_separation
	sprite2.position.x = -arm_separation


func _process(delta):
	if Engine.editor_hint:
		if arm_texture != null:
			get_node("Sprite1").texture = arm_texture
			get_node("Sprite2").texture = arm_texture
		
		get_node("Sprite1").position.x = arm_separation
		get_node("Sprite2").position.x = -arm_separation
		
		get_node("Sprite1").offset = sprite_offset
		get_node("Sprite2").offset = sprite_offset
		get_node("Sprite2").offset.x = -sprite_offset.x
		
		update()


func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2(arm_separation, 0), 0.35, Color(1, 1, 1, 1))
		draw_circle(Vector2(arm_separation, 0), 0.2,  Color(0, 0, 0, 1))
		
		draw_circle(Vector2(-arm_separation, 0), 0.35, Color(1, 1, 1, 1))
		draw_circle(Vector2(-arm_separation, 0), 0.2,  Color(0, 0, 0, 1))


func _on_turned_around(dir):
	if dir:
		sprite1.visible = false
		sprite2.visible = true
		
	else:
		sprite1.visible = true
		sprite2.visible = false


func _on_player_revived(id) -> void:
	if id == parent_entity.id:
		is_dead = false


func _on_player_dead(id) -> void:
	if id == parent_entity.id:
		is_dead = true


func _input(event):
	if parent_entity.id == Lobby.my_id && is_dead == false:
		#rotation = global_position.angle_to_point(get_global_mouse_position()) + PI
		
		if Input.is_action_just_pressed("attack") && able_to_attack == true:
			able_to_attack = false
			var dir = (get_global_mouse_position() - global_position).normalized()
			Server.melee_attack(parent_entity.id, dir, parent_entity.team)
			animation.play("attack")
			attack_timer.start()


func _on_Timer_timeout():
	able_to_attack = true
