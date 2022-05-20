tool
extends Node2D


onready var parent_entity: Entity = get_parent().entity
onready var sprite1: Node = get_node("Sprite1")
onready var sprite2: Node = get_node("Sprite2")
onready var animation: Node = get_node("AnimationPlayer")
onready var attack_timer: Node = get_node("AttackTimer")
onready var delay_timer: Node = get_node("DelayTimer")

var attack_scene: PackedScene = preload("res://entities/Attack.tscn")

var able_to_attack: bool = true
var is_dead: bool = false
var attack_dir: Vector2 = Vector2(0, 0)

export(Texture) var arm_texture: Texture
export(Vector2) var sprite_offset: Vector2
export(float) var arm_separation: float
export(float) var cooldown: float = 1
export(float) var freeze_time: float = 0.2
export(float) var anim_speed: float = 1
export(float) var knockback: float = 0
export(bool) var melee: bool = true
export(float) var damage: float = 20
#export(float) var attack_delay: float = 0


func _ready():
	Events.connect("player_dead", self, "_on_player_dead")
	Events.connect("player_revived", self, "_on_player_revived")
	Server.connect("packet_received", self, "_on_packet_recieved")
	
	if get_parent() != null:
		get_parent().entity.connect("turned_around", self, "_on_turned_around")
		get_parent().entity.connect("move_dir", self, "_on_move_dir")
	
	if arm_texture != null:
		sprite1.texture = arm_texture
	sprite1.offset = sprite_offset
	sprite1.position.x = arm_separation
	
	attack_timer.wait_time = cooldown
	#delay_timer.wait_time = attack_delay


func _process(delta):
	if Engine.editor_hint:
		if arm_texture != null:
			get_node("Sprite1").texture = arm_texture
		
		get_node("Sprite1").position.x = arm_separation
		
		get_node("Sprite1").offset = sprite_offset
		
		update()


func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2(arm_separation, 0), 0.35, Color(1, 1, 1, 1))
		draw_circle(Vector2(arm_separation, 0), 0.2,  Color(0, 0, 0, 1))


func _on_turned_around(dir):
	if dir:
		scale.x = -1
	else:
		scale.x = 1


func _on_move_dir(dir) -> void:
	attack_dir = dir


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
			#var dir = (get_global_mouse_position() - global_position).normalized()
			
			if melee == true:
				Server.melee_attack(parent_entity.id, attack_dir, parent_entity.team, damage)
			else:
				Server.shoot_projectile(global_position, attack_dir, parent_entity.id, parent_entity.team)
			
			get_parent().entity.emit_signal("attack_freeze", freeze_time)
			get_parent().entity.emit_signal("knockback", attack_dir * -knockback)
			animation.play("attack", -1, anim_speed)
			attack_timer.start()


func _on_packet_recieved(packet: Dictionary):
	if packet.type == Constants.PacketTypes.MELEE_ATTACK:
		if packet.id == get_parent().entity.id:
			var attack = attack_scene.instance()
			var dir = Vector2(packet.dirX, packet.dirY)
			attack.init(dir, packet.damage, packet.id, packet.team)
			get_parent().add_child(attack)


func _on_AttackTimer_timeout():
	able_to_attack = true
	get_parent().entity.emit_signal("is_attacking", false)
