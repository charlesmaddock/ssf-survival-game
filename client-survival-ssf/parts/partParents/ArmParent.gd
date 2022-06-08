tool
extends Node2D
var part_type: int = Constants.PartTypes.ARM
var part_name: int = Constants.PartNames.DefaultArm


onready var parent_entity: Entity = get_parent().entity
onready var sprite1: Node = get_node("Sprite1")
#onready var sprite2: Node = get_node("Sprite2")
onready var animation: Node = get_node("AnimationPlayer")
onready var attack_timer: Node = get_node("AttackTimer")
onready var delay_timer: Node = get_node("DelayTimer")


var attack_scene: PackedScene = preload("res://entities/Attack.tscn")
var able_to_attack: bool = true
var is_dead: bool = false
var _input_attack_dir: Vector2 = Vector2(0, 0)


export(int) var projectile_type: int 
export(Texture) var arm_texture: Texture
export(Vector2) var sprite_offset: Vector2
export(float) var arm_separation: float = 5.0
export(float) var arm_scale: float = 1
export(float) var angle_offset: float = 0
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
		get_parent().entity.connect("aim_dir", self, "_on_aim_dir")
	
	if arm_texture != null:
		sprite1.texture = arm_texture
	sprite1.offset = sprite_offset
	sprite1.position.x = arm_separation
	sprite1.scale = Vector2(arm_scale, arm_scale)
	
	attack_timer.wait_time = cooldown
	#delay_timer.wait_time = attack_delay
	
	print(get_parent().get_name())


func _process(delta):
	if Engine.editor_hint:
		if arm_texture != null:
			get_node("Sprite1").texture = arm_texture
		
		get_node("Sprite1").position.x = arm_separation
		get_node("Sprite1").offset = sprite_offset
		
		get_node("Sprite1").scale = Vector2(arm_scale, arm_scale)
		
		update()
	elif parent_entity.id == Lobby.my_id && is_dead == false:
		if _input_attack_dir != Vector2.ZERO:
			if able_to_attack == true:
				able_to_attack = false
				#var dir = (get_global_mouse_position() - global_position).normalized()
				
				if melee == true:
					Server.melee_attack(parent_entity.id, _input_attack_dir, parent_entity.team, damage)
				else:
					Server.shoot_projectile(global_position, _input_attack_dir, parent_entity.id, parent_entity.team, projectile_type)
				
				#get_parent().entity.emit_signal("attack_freeze", freeze_time)
				get_parent().entity.emit_signal("is_attacking", true)
				animation.play("attack", -1, anim_speed)
				attack_timer.start()


func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2(arm_separation, 0), 0.35, Color(1, 1, 1, 1))
		draw_circle(Vector2(arm_separation, 0), 0.2,  Color(0, 0, 0, 1))


func _on_turned_around(dir):
	if dir:
		scale.x = -1
	else:
		scale.x = 1


func _on_aim_dir(dir) -> void:
	_input_attack_dir = dir


func _on_player_revived(id) -> void:
	if id == parent_entity.id:
		is_dead = false


func _on_player_dead(id) -> void:
	if id == parent_entity.id:
		is_dead = true


func _on_packet_recieved(packet: Dictionary):
	if packet.type == Constants.PacketTypes.MELEE_ATTACK:
		if packet.id == get_parent().entity.id:
			var attack = attack_scene.instance()
			var dir = Vector2(packet.dirX, packet.dirY)
			attack.init(dir, packet.damage, packet.id, packet.team)
			get_parent().add_child(attack)
			get_parent().entity.emit_signal("knockback", dir * -knockback)


func _on_AttackTimer_timeout():
	able_to_attack = true
	get_parent().entity.emit_signal("is_attacking", false)


func get_sprite():
	return(arm_texture)
