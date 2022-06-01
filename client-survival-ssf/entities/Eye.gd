extends Sprite

export(int) var angle_per_second_rotate: int = 10

func _process(delta):
		self.rotate(deg2rad(angle_per_second_rotate) * delta) 
