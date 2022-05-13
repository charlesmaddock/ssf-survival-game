extends Resource
class_name dialogue



func init(text: String, mood, answer_options: bool, array_of_answers: Array, array_of_answer_results: Array) -> void:
	_text = text
	_mood = mood
	_answer_options = answer_options
	_array_of_answers = array_of_answers
	_array_of_answer_results = array_of_answer_results
