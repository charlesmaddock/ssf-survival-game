extends Node


const PLAYERS_PER_ROOM: int = 6
const TILE_SIZE = Vector2(32, 32)
const RECONCILE_POSITION_RATE: float = 0.2


enum AppMode {
	DEVELOPMENT,
	RELEASE
}


enum ExitDirections {
	NORTH,
	EAST,
	WEST,
}


enum PacketTypes {
  SERVER_MESSAGE,
  CONNECTED,
  UPDATE_CLIENT_DATA,
  HOST_ROOM,
  ROOM_HOSTED,
  JOIN_ROOM,
  ROOM_JOINED,
  LEAVE_ROOM,
  ROOM_LEFT,
  START_GAME,
  GAME_STARTED,
  SET_INPUT,
  SET_PLAYER_POS,
  REQUEST_RECONCILIATION,
  RECONCILE_PLAYER_POS,
  SET_HEALTH,
  SHOOT_PROJECTILE,
  MELEE_ATTACK,
  SPAWN_MOB,
  DESPAWN_MOB,
  SPAWN_ENVIRONMENT,
  DESPAWN_ENVIRONMENT,
  SPAWN_ITEM,
  DESPAWN_ITEM,
  ADD_TO_INVENTORY,
  SWITCH_ROOMS,
  COMPLETE_ROOM,
  ROOMS_GENERATED,
  PING,
  SPAWN_PART,
  KNOCKBACK,
  PICK_UP_PART,
  DROP_PART,
}


enum RoomTypes {
	START,
	SPIKES,
	CHIP,
	QUESTION,
	REVIVE,
	LOOT,
	BOSS
}


enum ItemTypes {
	HEART
}


enum EnvironmentTypes {
	SPIKES,
	CHIP,
	HEART_CHEST,
	PART_CHEST,
	REVIVE_DISK
}


enum ProjectileTypes {
	RED_BULLET = 0,
	BLUE_BULLET = 1,
	KISS = 2
}


enum MobTypes {
	CLOUDER,
	CHOWDER,
	TURRET_CRAWLER,
	MINI_TURRET_CRAWLER,
	BAT,
	MOLE,
	SLIME,
	SMALL_SLIME,
	LOVE_BULL,
	ROMANS_BOSS,
	ROMANS_BOSS_HAND,
}


enum Teams {
	NONE,
	GOOD_GUYS,
	BAD_GUYS
}


enum collisionLayers {
	PLAYER = 0,
	ITEM,
	DAMAGE,
	SOLID,
	HEALTH,
	BASE,
	ANIMAL,
	IS_IN_ROOM,
	PICKUP,
}


enum DialogueSpeedKeywords {
	SLOW,
	MEDIUM,
	FAST
}


enum DialogueMoods {
	NEUTRAL,
	HAPPY,
	ANGRY,
	SAD,
	FLUSTERED
}


enum PartTypes {
	ARM,
	LEG,
	BODY,
}


enum PartNames {
	DefaultArm,
	DrillArm,
	HammerArm,
	HeartArm,
	DefaultShooter,
	MiniGun,
	HttpsKeyArm,
	TwoFactorArm,
	
	DefaultBody,
	ExoSkeleton,
	FishBody,
	CookieBlockerBody,
	FireWallBody,
	VPNBody,
	
	DefaultLegs,
	BirdLegs,
	BlueShoes,
}


enum RoomDifficulties {
	EASY,
	MEDIUM,
	HARD
}


var part_difficulties: Dictionary = {
	RoomDifficulties.EASY: [PartNames.DefaultArm, PartNames.HttpsKeyArm, PartNames.ExoSkeleton, PartNames.CookieBlockerBody, PartNames.BirdLegs, PartNames.VPNBody],
	RoomDifficulties.MEDIUM: [PartNames.HeartArm, PartNames.HammerArm, PartNames.FireWallBody, PartNames.BlueShoes, PartNames.TwoFactorArm],
	RoomDifficulties.HARD: [PartNames.FishBody, PartNames.MiniGun, PartNames.DrillArm]
}


var PartScenes: Dictionary = {
	PartNames.DefaultArm:  		preload("res://parts/arms/DefaultArm.tscn"),
	PartNames.DrillArm:    		preload("res://parts/arms/DrillArm.tscn"),
	PartNames.HammerArm:   		preload("res://parts/arms/HammerArm.tscn"),
	PartNames.HeartArm:    		preload("res://parts/arms/Heart Arm.tscn"),
	PartNames.DefaultShooter:	preload("res://parts/arms/DefaultShooter.tscn"),
	PartNames.MiniGun		:	preload("res://parts/arms/MiniGun.tscn"),
	PartNames.HttpsKeyArm:		preload("res://parts/arms/HttpsKeyArm.tscn"),
	PartNames.TwoFactorArm:		preload("res://parts/arms/TwoFactorArm.tscn"),
	
	PartNames.DefaultBody: 		preload("res://parts/bodies/DefaultBody.tscn"),
	PartNames.ExoSkeleton: 		preload("res://parts/bodies/ExoSkeleton.tscn"),
	PartNames.FishBody:    		preload("res://parts/bodies/FishBody.tscn"),
	PartNames.CookieBlockerBody:preload("res://parts/bodies/CookieBlockerBody.tscn"),
	PartNames.FireWallBody:		preload("res://parts/bodies/FireWallBody.tscn"),
	PartNames.VPNBody:			preload("res://parts/bodies/VPNBody.tscn"),
	
	PartNames.DefaultLegs: 		preload("res://parts/legs/DefaultLegs.tscn"),
	PartNames.BirdLegs:    		preload("res://parts/legs/BirdLegs.tscn"),
	PartNames.BlueShoes:   		preload("res://parts/legs/BlueShoes.tscn")
}


var DialogueSpeeds: Dictionary = {
	"Slow": 0.10,
	"Medium": 0.06,
	"Fast": 0.05
}


var item_textures = {
	ItemTypes.HEART: preload("res://assets/sprites/heart.png"),
}


var class_info = [
	{"name": "Sam the Sniper", "tex": load("res://assets/sprites/character.png")},
	{"name": "Ryan the Robot", "tex": load("res://assets/sprites/robot.png")},
	{"name": "Anna the Assassin", "tex": load("res://assets/sprites/coolCharacter.png")},
	{"name": "Romance Scammer", "tex": load("res://assets/sprites/romanceScammer.png")},
]


var app_mode: int = AppMode.DEVELOPMENT if OS.is_debug_build() else AppMode.RELEASE
