extends Node2D


export(float) var max_health = 100


onready var Bar = $Bar
onready var HealthCollisionShape = $DamageArea/CollisionShape2D
onready var health: float 
onready var health_for_entity_w_id: String = get_parent().entity.id
onready var health_for_entity_team: int = get_parent().entity.team


var _is_dead: bool
var _default_parent_collision_layer: int


func _ready():
	# Temp: 20% more health for each player in room
	max_health += max_health * Lobby.players_data.size() * 0.2
	
	if get_parent().get("collision_layer") != null:
		_default_parent_collision_layer = get_parent().collision_layer
	Bar.max_value = max_health
	Bar.value = max_health
	health = max_health 
	get_parent().entity.connect("take_damage", self, "_on_damage_taken")
	Server.connect("packet_received", self, "_on_packet_received")
	
	


func get_is_dead() -> bool:
	return _is_dead


func _on_damage_taken(damage, dir: Vector2) -> void:
	take_damage(damage, dir)


func set_invinsible(invinsible: bool) -> void:
	HealthCollisionShape.set_disabled(invinsible)


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SWITCH_ROOMS:
		if Util.is_player(get_parent()):
				Server.set_health(health_for_entity_w_id, max_health, Vector2.ZERO)
	if packet.type == Constants.PacketTypes.SET_HEALTH:
		if packet.id == health_for_entity_w_id:
			health = packet.health
			Bar.value = health
			var knockback_dir = Vector2(packet.dirX, packet.dirY)
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
				yield(get_tree().create_timer(2), "timeout")
				
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
					Events.emit_signal("player_revived", get_parent().entity.id)
				


func damage_flash() -> void:
	var parent_modulate = get_parent().modulate
	get_parent().modulate = Color(1000, 0, 0, parent_modulate.a)
	yield(get_tree().create_timer(0.1), "timeout")
	get_parent().modulate = Color(1, 1, 1, parent_modulate.a)


func take_damage(damage: float, dir: Vector2) -> void:
	if Lobby.is_host == true:
		Server.set_health(health_for_entity_w_id, health - damage, dir.normalized() * (damage * 10))


func _on_DamageArea_area_entered(area):
	if area.has_method("same_creator_or_team"):
		if area.same_creator_or_team(health_for_entity_w_id, health_for_entity_team) == false:
			take_damage(area.get_damage(), area.global_position.direction_to(global_position))
