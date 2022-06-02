extends Node


const PLAYERS_PER_ROOM: int = 6
const TILE_SIZE = Vector2(32, 32)
const RECONCILE_POSITION_RATE: float = 0.2



enum AppMode {
	DEVELOPMENT,
	RELEASE
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
  KNOCKBACK
}


enum RoomTypes {
	MOB_ROOM,
	PUZZLE_ROOM,
}


enum ItemTypes {
	PINK_FLUFF,
	FLUFF_BALL,
	FLUFF_ARROW,
	CLOUDER
}


enum EntityTypes {
	PLAYER,
	TREE
}


enum DoorDirectios {
UP,
DOWN,
LEFT,
RIGHT
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
	PLAYER,
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


enum Parts {
	DefaultArm,
	DrillArm,
	HammerArm,
	HeartArm,
	
	DefaultBody,
	ExoSkeleton,
	FishBody,
	
	DefaultLegs,
	BirdLegs,
	BlueShoes,
}


var PartScenes: Dictionary = {
	Parts.DefaultArm:  preload("res://parts/arms/DefaultArm.tscn"),
	Parts.DrillArm:    preload("res://parts/arms/DrillArm.tscn"),
	Parts.HammerArm:   preload("res://parts/arms/HammerArm.tscn"),
	Parts.HeartArm:    preload("res://parts/arms/Heart Arm.tscn"),
	
	Parts.DefaultBody: preload("res://parts/bodies/DefaultBody.tscn"),
	Parts.ExoSkeleton: preload("res://parts/bodies/ExoSkeleton.tscn"),
	Parts.FishBody:    preload("res://parts/bodies/FishBody.tscn"),
	
	Parts.DefaultLegs: preload("res://parts/legs/BirdLegs.tscn"),
	Parts.BirdLegs:    preload("res://parts/legs/BirdLegs.tscn"),
	Parts.BlueShoes:   preload("res://parts/legs/BirdLegs.tscn")
}


var DialogueSpeeds: Dictionary = {
	"Slow": 0.10,
	"Medium": 0.06,
	"Fast": 0.05
}


var item_textures = {
	ItemTypes.FLUFF_BALL: preload("res://assets/sprites/largePoint.png"),
	ItemTypes.PINK_FLUFF: preload("res://assets/sprites/fluff.png"),
	ItemTypes.FLUFF_ARROW: preload("res://assets/sprites/arrow.png"),
	ItemTypes.CLOUDER: preload("res://assets/sprites/clouder.png"),
}


var class_info = [
	{"name": "Sam the Sniper", "tex": load("res://assets/sprites/character.png")},
	{"name": "Ryan the Robot", "tex": load("res://assets/sprites/robot.png")},
	{"name": "Anna the Assassin", "tex": load("res://assets/sprites/coolCharacter.png")},
	{"name": "Romance Scammer", "tex": load("res://assets/sprites/romanceScammer.png")},
]


var app_mode: int = AppMode.DEVELOPMENT if OS.is_debug_build() else AppMode.RELEASE
