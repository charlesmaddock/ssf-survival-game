extends Node


signal error_message(msg)
signal player_dead(id)
signal player_revived(id)
signal game_over(won) 
signal add_footstep()
signal switch_rooms(destined_position)
signal follow_w_camera(node2d)


signal target_entity(target_node, manually_targeted)
signal update_target_pos(pos)
signal manual_aim(val)
