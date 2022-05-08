extends Node2D

export(int) var _number_of_rooms: int = 9



var _room_coordinates: PoolVector2Array = [Vector2(0, 0)]
#generate_rooms generar datan, emittar sedan signal till saker som ska göra allt som behövs
#ha en rect/bitmap och gör en set-cell utifrån den
#array med 2d-åunkter, kolla ifall kollision med andra rum
#is_host skickar packet med all data till clients (icl. host)


func _ready():
	pass 


func _generate_rooms() -> void:
	
	for i in _number_of_rooms:
		if i == 1:
			pass
		
		#generate random room continuation
		#randi() % 4
		
		else: 
			pass
