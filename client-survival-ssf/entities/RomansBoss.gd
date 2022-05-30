extends KinematicBody2D


export(Vector2) var head_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_scale: Vector2 = Vector2(0.7, 0.7)
export(Vector2) var hand_distance_from_head: Vector2 = Vector2(140, 10)


var entity: Entity
var _is_animal = true

var leftHand: Node
var rightHand: Node


func _ready():
	
	self.set_scale(head_scale)
	var left_hand_id = "RomansBossLeftHand"
	var right_hand_id = "RomansBossRightHand"
	
	var left_hand_position: Vector2
	var right_hand_position: Vector2
	
	if Lobby.is_host == true:
		print("hand distance from head : ", hand_distance_from_head)
		left_hand_position = Vector2((self.global_position.x - hand_distance_from_head.x), (self.global_position.y + hand_distance_from_head.y))
		right_hand_position = Vector2((self.global_position.x + hand_distance_from_head.x), (self.global_position.y + hand_distance_from_head.y))
		
		print(left_hand_position, " and this is rights pos for spawn : ", right_hand_position)
		Server.spawn_mob(left_hand_id, Constants.MobTypes.ROMANS_BOSS_HAND, left_hand_position)
		Server.spawn_mob(right_hand_id, Constants.MobTypes.ROMANS_BOSS_HAND, right_hand_position)
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	leftHand = Util.get_entity(left_hand_id)
	rightHand = Util.get_entity(right_hand_id)
	
	leftHand.set_scale(hand_scale)
	rightHand.set_scale(Vector2(-hand_scale.x, hand_scale.y))
	
	leftHand.init(true, left_hand_position)
	rightHand.init(false, right_hand_position)


#	var left_hand_health_bar: TextureProgress = leftHand.get_node("Health/Bar")
#	var left_hand_health_bar_rect_size_x = left_hand_health_bar.rect_size.x
#
#	print(left_hand_health_bar_rect_size_x)
#
#	left_hand_health_bar.set_scale(Vector2(-1, 1))
#	var left_hand_health_bar_pos = left_hand_health_bar.get_global_position()
#
#	print(left_hand_health_bar_pos)
#	var left_hand_health_bar_new_pos: Vector2 = Vector2(left_hand_health_bar_pos.x - left_hand_health_bar_rect_size_x, left_hand_health_bar_pos.y)
#	print(left_hand_health_bar_new_pos)
#	left_hand_health_bar.set_position(left_hand_health_bar_new_pos)
