extends KinematicBody2D


var entity: Entity
var _is_animal = true
var _targeted_player = null

onready var undergroundSprite = $UndergroundSprite
onready var overundergroundSprite = $Sprite
onready var undergroundTimer = $DigTimer
onready var surfaceTimer = $SurfaceTimer


var _underground: bool


func _ready():
	get_node("AI").connect("target_player", self, "_on_target_player")
	_on_SurfaceTimer_timeout()


func _on_target_player(player) -> void:
	_targeted_player = player


func _on_ShootTimer_timeout():
	if _targeted_player != null && _underground == true:
		var dir = (_targeted_player.global_position - global_position).normalized()
		Server.shoot_projectile(global_position, dir, entity.id, entity.team)


func _on_DigTimer_timeout():
	overundergroundSprite.set_visible(false)
	undergroundSprite.set_visible(true)
	surfaceTimer.start(5)
	_underground = false
	get_node("Health").set_invinsible(true) 
	get_node("Movement").set_physics_process(true)


func _on_SurfaceTimer_timeout():
	overundergroundSprite.set_visible(true)
	undergroundSprite.set_visible(false)
	undergroundTimer.start(3)
	_underground = true
	get_node("Health").set_invinsible(false) 
	get_node("Movement").set_physics_process(false)
	
