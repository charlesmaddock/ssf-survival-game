extends KinematicBody2D

export(int) var _strafe_distance: int = 180
export(int) var _dig_time: float = 4
export(int) var _surface_time: float = 3

var entity: Entity
var _is_animal = true
var _targeted_player = null

onready var undergroundSprite = $UndergroundSprite
onready var overundergroundSprite = $Sprite
onready var undergroundTimer = $DigTimer
onready var surfaceTimer = $SurfaceTimer
onready var AI_node = $AI


var _underground: bool


func _ready():
	_on_SurfaceTimer_timeout()


func _on_ShootTimer_timeout():
	_targeted_player = AI_node.get_closest_player()
	if _targeted_player != null && _underground == true:
		var dir = (_targeted_player.global_position - self.global_position).normalized()
		Server.shoot_projectile(global_position, dir, entity.id, entity.team)


func _on_DigTimer_timeout():
	AI_node.strafe_player_behaviour(_strafe_distance)
	overundergroundSprite.set_visible(false)
	undergroundSprite.set_visible(true)
	surfaceTimer.start(_dig_time)
	_underground = false
	get_node("Health").set_invinsible(true) 
	get_node("Movement").set_physics_process(true)


func _on_SurfaceTimer_timeout():
	AI_node.motionless_behaviour()
	overundergroundSprite.set_visible(true)
	undergroundSprite.set_visible(false)
	undergroundTimer.start(_surface_time)
	_underground = true
	get_node("Health").set_invinsible(false) 
	get_node("Movement").set_physics_process(false)
	
	
