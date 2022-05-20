extends AudioStreamPlayer2D

var _LetterSoundDictionary: Dictionary 
var _alphabet: Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var _alphabet_index: int = 0
var _queued_letter_sounds: Array = []


func _ready():
	var LetterSoundsPath = "res://assets/Audio/Samples/AnimalCrossingLetters/"
	var dir = Directory.new()
	dir.open(LetterSoundsPath)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			#break the while loop when get_next() returns ""
			break
		elif !file_name.begins_with("."):
			#get_next() returns a string so this can be used to load the images into an array.
			var soundfile = load(LetterSoundsPath + file_name)
			_LetterSoundDictionary[_alphabet[_alphabet_index]] = soundfile
			_alphabet_index += 1
	print(_LetterSoundDictionary.keys())
	dir.list_dir_end()


func _play_letter_sound(letter_to_be_sounded: String):
	self.play(_LetterSoundDictionary[letter_to_be_sounded])


func _on_letter_typed(letter_name: String) -> void:
	var letter_to_be_sounded: String = letter_name.to_upper()
	if _alphabet.has(letter_to_be_sounded):
		if !self.is_playing() && _queued_letter_sounds.size() == 0:
			_play_letter_sound(letter_to_be_sounded)
		else: 
			_queued_letter_sounds.append(letter_to_be_sounded)
	pass


func _on_LetterSoundAudioPlayer_finished():
	if _queued_letter_sounds.size() > 0:
		_play_letter_sound(_queued_letter_sounds.pop_front())
