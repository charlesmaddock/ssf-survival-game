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
var _aim_at_target: Node = null
var _aim_pos: Vector2
var _aiming_manually: bool
var _auto_switch_to_closest: bool = true
var _nearby_monsters: Array = []
var _attacking_input: bool = false
var _movement_node: Node
var _walk_dir: Vector2


export(String) var title: String = ""
export(String) var optional_desc: String = ""
export(String) var optional_perk_desc: String = ""
export(String) var optional_con_desc: String = ""

export(float) var weight: float = 20
export(float) var health_modifier: float = 0

export(int) var projectile_type: int 
export(Texture) var arm_texture: Texture
export(Vector2) var sprite_offset: Vector2
export(float) var arm_separation: float = 5.0
export(float) var arm_scale: float = 1.0
export(float) var angle_offset: float = 0
export(float) var cooldown: float = 1
export(float) var freeze_time: float = 0.2
export(float) var anim_speed: float = 1
export(float) var knockback: float = 0
export(float) var enemy_knockback_mod: float = 1
export(bool) var melee: bool = true
export(float) var damage: float = 20
#export(float) var attack_delay: float = 0


func _ready():
	Events.connect("player_dead", self, "_on_player_dead")
	Events.connect("player_revived", self, "_on_player_revived")
	Events.connect("target_entity", self, "_on_target_entity")
	Events.connect("update_target_pos", self, "_on_update_target_pos")
	Events.connect("manual_aim", self, "_on_manual_aim")
	Server.connect("packet_received", self, "_on_packet_recieved")
	
	_movement_node = get_parent().get_node_or_null("Movement")
	
	if get_parent() != null:
		get_parent().entity.connect("turned_around", self, "_on_turned_around")
		get_parent().entity.connect("aim_dir", self, "_on_aim_dir")
		
		var attack_button_vis = get_parent().entity.id == Lobby.my_id && Lobby.auto_aim && Util.is_mobile()
		get_node("CanvasLayer/Container/AttackButton").set_visible(attack_button_vis) 
	
	if arm_texture != null:
		sprite1.texture = arm_texture
	
	sprite1.offset = sprite_offset
	sprite1.position.x = arm_separation
	sprite1.scale = Vector2(arm_scale, arm_scale)
	
	attack_timer.wait_time = cooldown
	#delay_timer.wait_time = attack_delay
	
	yield(get_tree(), "idle_frame")
	get_parent().entity.emit_signal("change_attack_damage", damage)
	get_parent().entity.emit_signal("add_weight", weight)
	get_parent().entity.emit_signal("add_health_modifier", health_modifier)


func _on_target_entity(entity_body: Node, manually_targeted: bool) -> void:
	_aim_at_target = entity_body
	_auto_switch_to_closest = !manually_targeted


func _on_update_target_pos(pos: Vector2) -> void:
	_aim_pos = pos


func _on_manual_aim(val: bool) -> void:
	_aiming_manually = val


func remove() -> void:
	get_parent().entity.emit_signal("remove_health_modifier", health_modifier)
	get_parent().entity.emit_signal("remove_weight", weight)


func _process(delta):
	if Engine.editor_hint:
		if arm_texture != null:
			get_node("Sprite1").texture = arm_texture
		
		get_node("Sprite1").position.x = arm_separation
		get_node("Sprite1").offset = sprite_offset
		
		get_node("Sprite1").scale = Vector2(arm_scale, arm_scale)
		
		update()
	elif parent_entity.id == Lobby.my_id && is_dead == false:
		
		if Lobby.auto_aim == true:
			
			if is_instance_valid(_aim_at_target): 
				if _aim_at_target.global_position.distance_to(global_position) > 180:
					Events.emit_signal("target_entity", null, false)
			
			if is_instance_valid(_aim_at_target) == false && _auto_switch_to_closest == false:
				_auto_switch_to_closest = true
			
			if _auto_switch_to_closest == true:
				var closest_monster: Node = null
				var closest_dist: float = 300.0
				
				for monster in _nearby_monsters:
					var dist: float = monster.global_position.distance_to(global_position)
					if dist < closest_dist:
						closest_monster = monster
						closest_dist = dist
				
				if closest_monster != null:
					if closest_monster != _aim_at_target && parent_entity.id == Lobby.my_id:
						Events.emit_signal("target_entity", closest_monster, false)
			
			if is_instance_valid(_aim_at_target):
				_input_attack_dir = global_position.direction_to(_aim_at_target.global_position + (Vector2.UP * 24))
			
			if _aim_pos != Vector2.ZERO:
				_input_attack_dir = global_position.direction_to(_aim_pos)
		
		var walk_dir = _movement_node.get_input()
		if walk_dir != Vector2.ZERO:
			_walk_dir = walk_dir
		
		var aim_dir: Vector2 = _input_attack_dir
		if Lobby.auto_aim == true && _input_attack_dir == Vector2.ZERO:
			aim_dir = _walk_dir
		
		if aim_dir != Vector2.ZERO && is_dead == false && ((_attacking_input == true || _aiming_manually == true || Input.is_action_pressed("attack")) || Lobby.auto_aim == false):
			if able_to_attack == true:
				able_to_attack = false
				#var dir = (get_global_mouse_position() - global_position).normalized()
				
				var damage_mod: float = 0.5 if Lobby.easy_mode && Util.is_player(get_parent()) == false else 1
				
				if melee == true:
					Server.melee_attack(parent_entity.id, aim_dir, parent_entity.team, damage * damage_mod, enemy_knockback_mod)
				else:
					Server.shoot_projectile(damage * damage_mod, get_parent().global_position + (Vector2.UP * 6), aim_dir, parent_entity.id, parent_entity.team, projectile_type, _movement_node.get_velocity() / 4)
				
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
			attack.init(dir, packet.damage, packet.id, packet.team, packet.knock)
			get_parent().add_child(attack)
			get_parent().entity.emit_signal("knockback", dir * -knockback)


func _on_AttackTimer_timeout():
	able_to_attack = true
	get_parent().entity.emit_signal("is_attacking", false)


func get_sprite():
	return(arm_texture)


func _on_MonsterDetector_body_entered(body):
	if Util.is_entity(body):
		_nearby_monsters.append(body)


func _on_MonsterDetector_body_exited(body):
	_nearby_monsters.erase(body)


func _on_AttackButton_pressed():
	_attacking_input = true


func _on_AttackButton_released():
	_attacking_input = false
