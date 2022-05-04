extends Node


const PLAYERS_PER_ROOM: int = 6


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

enum MobTypes {
	CLOUDER,
	CHOWDER,
	TURRET_CRAWLER,
	BAT,
	MOLE,
	SLIME,
	SMALL_SLIME
}


enum Teams {
	NONE,
	GOOD_GUYS,
	BAD_GUYS
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


var app_mode: int = AppMode.DEVELOPMENT 
