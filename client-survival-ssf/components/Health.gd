extends Node2D


export(float) var max_health = 100
export var knockbackable: bool = true
export var show_health_bar: bool = false


onready var Bar = $Bar
onready var DamageArea = $DamageArea
onready var health: float 
onready var health_for_entity_w_id: String = get_parent().entity.id
onready var health_for_entity_team: int = get_parent().entity.team


var _is_dead: bool
var _default_parent_collision_layer: int
var _weight: float = 0


func _ready():
	# Temp: More health for each player in room
	if Util.is_player(get_parent()) == false:
		set_max_health(max_health * Lobby.players_data.size() * 1.1)
	
	if get_child(get_child_count() - 1) is CollisionShape2D:
		$DamageArea/CollisionShape2D.queue_free()
		Util.reparent(self, DamageArea, get_child(get_child_count() - 1))
	
	if get_parent().get("collision_layer") != null:
		_default_parent_collision_layer = get_parent().collision_layer
	Bar.value = max_health
	Bar.set_visible(show_health_bar)
	health = max_health 
	get_parent().entity.connect("take_damage", self, "_on_damage_taken")
	get_parent().entity.connect("heal", self, "_on_heal")
	get_parent().entity.connect("change_weight", self, "_on_change_weight")
	
	Server.connect("packet_received", self, "_on_packet_received")


func set_max_health(val: float) -> void:
	max_health = val
	Bar.max_value = max_health


func get_is_dead() -> bool:
	return _is_dead


func _on_change_weight(weight: float) -> void:
	# Remove old weight mod
	set_max_health(max_health - ((_weight / 100) * 10))
	_weight = weight
	set_max_health(max_health + ((_weight / 100) * 10))
	print("max_health: ", max_health)


func _on_damage_taken(damage, dir: Vector2) -> void:
	take_damage(damage, dir)


func _on_heal(amount: float) -> void:
	if Lobby.is_host == true:
		Server.set_health(health_for_entity_w_id, health + amount, Vector2.ZERO)


func set_invinsible(invinsible: bool) -> void:
	for child in DamageArea.get_children():
		child.set_disabled(invinsible)


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SWITCH_ROOMS:
		if Lobby.is_host && Util.is_player(get_parent()) && Lobby.regen_health_and_revive:
				Server.set_health(health_for_entity_w_id, max_health, Vector2.ZERO)
	if packet.type == Constants.PacketTypes.SET_HEALTH:
		if packet.id == health_for_entity_w_id:
			var decrease_of_health = packet.health < health 
			health = packet.health
			Bar.value = health
			var knockback_dir = Vector2.ZERO
			if knockbackable == true:
				knockback_dir = Vector2(packet.dirX, packet.dirY)
			
			if decrease_of_health == true:
				get_parent().entity.emit_signal("damage_taken", packet.health, knockback_dir)
				damage_flash()
			
			if health <= 0 && _is_dead == false && get_parent().get("collision_layer") != null:
				_is_dead = true
				get_parent().rotation_degrees = 90
				get_parent().collision_layer = 0
				
				var movement_component = get_parent().get_node("Movement")
				if movement_component != null:
					movement_component.set_process(false)
					movement_component.set_physics_process(false)
				
				if health_for_entity_w_id == Lobby.my_id: 
					Events.emit_signal("follow_w_camera", null)
				
				if Util.is_player(get_parent()):
					Events.emit_signal("player_dead", get_parent().entity.id)
			
			if health > 0 && _is_dead == true:
				_is_dead = false
				get_parent().rotation_degrees = 0
				get_parent().collision_layer = _default_parent_collision_layer
				
				var movement_component = get_parent().get_node("Movement")
				if movement_component != null:
					movement_component.set_process(true)
					movement_component.set_physics_process(true)
				
				if Util.is_player(get_parent()):
					if health_for_entity_w_id == Lobby.my_id: 
						Events.emit_signal("follow_w_camera", self)
					Events.emit_signal("player_revived", get_parent().entity.id)
				


func damage_flash() -> void:
	var parent_modulate = get_parent().modulate
	get_parent().modulate = Color(1000, 1000, 1000, parent_modulate.a)
	yield(get_tree().create_timer(0.15), "timeout")
	get_parent().modulate = Color(1, 1, 1, parent_modulate.a)


func take_damage(damage: float, dir: Vector2) -> void:
	if Lobby.is_host == true:
		Server.set_health(health_for_entity_w_id, health - damage, dir.normalized() * (damage * 10))


func _on_DamageArea_area_entered(area):
	if area.has_method("same_creator_or_team"):
		if area.same_creator_or_team(health_for_entity_w_id, health_for_entity_team) == false:
			take_damage(area.get_damage(), area.global_position.direction_to(global_position))
