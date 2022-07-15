extends StaticBody2D


var entity: Entity
var _dropped: bool
var _part_name: int


var part_difficulties: Dictionary = {
	Constants.RoomDifficulties.EASY: [Constants.PartNames.VPNBody],
	
	#Constants.RoomDifficulties.EASY: [Constants.PartNames.DefaultArm, Constants.PartNames.HttpsKeyArm, Constants.PartNames.ExoSkeleton, Constants.PartNames.CookieBlockerBody, Constants.PartNames.BirdLegs, Constants.PartNames.VPNBody],
	Constants.RoomDifficulties.MEDIUM: [Constants.PartNames.HeartArm, Constants.PartNames.HammerArm, Constants.PartNames.FireWallBody, Constants.PartNames.BlueShoes, Constants.PartNames.TwoFactorArm],
	Constants.RoomDifficulties.HARD: [Constants.PartNames.FishBody, Constants.PartNames.MiniGun, Constants.PartNames.DrillArm]
}


func _ready():
	entity.connect("damage_taken", self, "_on_damage_taken")
	
	var room_difficulty: int = Util.get_room(entity.room_id).get_difficulty()
	var parts: Array = []
	
	if room_difficulty == Constants.RoomDifficulties.EASY:
		parts = part_difficulties[Constants.RoomDifficulties.EASY]
	elif room_difficulty == Constants.RoomDifficulties.MEDIUM:
		parts = part_difficulties[Constants.RoomDifficulties.EASY] + part_difficulties[Constants.RoomDifficulties.MEDIUM]
	elif room_difficulty == Constants.RoomDifficulties.HARD:
		parts = part_difficulties[Constants.RoomDifficulties.EASY] + part_difficulties[Constants.RoomDifficulties.MEDIUM] + part_difficulties[Constants.RoomDifficulties.HARD]
	
	_part_name = parts[randi() % parts.size()]


func generate_part() -> int:
	return _part_name


func _on_damage_taken(health, dir) -> void:
	if Lobby.is_host == true:
		if health <= 0 && _dropped == false:
			var part_name = generate_part()
			_dropped = true
			Server.spawn_pickup(Util.generate_id(), part_name, global_position + (Vector2.ONE * 2))
