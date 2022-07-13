extends Node2D


export var _strafe_dist: float = 4
export var _hover_speed: float = 100
export var _slap_speed: float = 300
export var _slap_angle: float = 60
export var _slap_pushout_distance: float = 30
export var _time_before_slap: float = 0.1
export var _slapp_count: int = 2

onready var movement_node: Node2D = self.get_node("Movement")
onready var sprite: Sprite = $Sprite

onready var timer_before_slap: Timer = $TimerBeforeSlap


var entity: Entity
var boss_node: Node2D
var _is_animal = true
var _init_finished = false
var _distance_from_head: float

var _slap_direction: int = 1
var _last_hover_dir: Vector2 = Vector2.ZERO
var _player_slap_dir: Vector2
var _staging_slap: bool = false
var _current_slap_count: int = 0


var _behaviour_state: int = behaviourStates.HOVER_AROUND_HEAD

signal slapping_done()

enum behaviourStates {
	MOTIONLESS,
	KNOCKED_OUT,
	HOVER_AROUND_HEAD,
	SLAP,
} 


func init(distance_from_head: float, boss_node_id: String):
	boss_node = Util.get_entity(boss_node_id)
	_distance_from_head = distance_from_head
#	print(_distance_from_head, "This is my distance from head")
	_last_hover_dir = boss_node.global_position.direction_to(self.global_position)
	
	_init_finished = true

func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	if Lobby.is_host == true:
		timer_before_slap.set_wait_time(_time_before_slap)
		
		_behaviour_state == behaviourStates.HOVER_AROUND_HEAD


func _process(delta) -> void:
	if Lobby.is_host == true:
		if _init_finished:
			
			if _behaviour_state == behaviourStates.HOVER_AROUND_HEAD:
				_last_hover_dir = _last_hover_dir.rotated(deg2rad(_hover_speed * delta * _slap_direction))
				self.global_position = boss_node.global_position + _distance_from_head * _last_hover_dir
				
				if _staging_slap:
						set_motionless_behaviour()
						timer_before_slap.start()
				
			elif _behaviour_state == behaviourStates.SLAP:
				_set_new_pos_in_slap(delta)
				
				if is_hand_in_slap_threshold():
					_next_slap_movement()


func _set_new_pos_in_slap(delta) -> void:
	if Lobby.is_host == true:
		_last_hover_dir = _last_hover_dir.rotated(deg2rad(_slap_speed * delta * _slap_direction))
		self.global_position = boss_node.global_position + _distance_from_head * _last_hover_dir


func is_hand_in_slap_threshold() -> bool:
	var slap_threshold = _player_slap_dir.rotated(deg2rad(_slap_angle * _slap_direction))
	var dist_between_hover_pos_and_threshold = _last_hover_dir.distance_to(slap_threshold)
#	print("this is the dist between thresh and pos: ", dist_between_hover_pos_and_threshold)
	if dist_between_hover_pos_and_threshold < 0.2:
		return true
	else:
		return false


func _next_slap_movement() -> void:
	if Lobby.is_host == true:
		if Lobby.is_host == true:
			_slap_direction *= -1
			_current_slap_count += 1
			
			if _current_slap_count >= _slapp_count:
				_current_slap_count = 0
				_behaviour_state = behaviourStates.MOTIONLESS
				emit_signal("slapping_done")


func set_motionless_behaviour() -> void:
	if Lobby.is_host == true:
		_behaviour_state = behaviourStates.MOTIONLESS
		Server.set_sprite_frame(0, self.entity.id)


func set_knocked_out_behaviour() -> void:
	if Lobby.is_host == true:
		_behaviour_state = behaviourStates.KNOCKED_OUT
		_staging_slap = false
		Server.set_sprite_frame(1, self.entity.id)


func set_hovering_behaviour() -> void:
	if Lobby.is_host == true:
		_staging_slap = false
		_behaviour_state = behaviourStates.HOVER_AROUND_HEAD
		Server.set_sprite_frame(0, self.entity.id)


func set_slapping_behaviour(slap_target) -> void:
	if Lobby.is_host == true:
		_staging_slap = true
		_player_slap_dir = boss_node.global_position.direction_to(slap_target.global_position).normalized()


func _on_TimerBeforeSlap_timeout():
	if Lobby.is_host == true:
		_behaviour_state = behaviourStates.SLAP
		Server.set_sprite_frame(0, self.entity.id)


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.SET_SPRITE_FRAME:
		if packet.id == self.entity.id:
			sprite.set_frame(packet.frame)
