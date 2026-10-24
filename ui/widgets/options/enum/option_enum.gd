@tool
class_name OptionEnum
extends OptionBase

@export var options: Array[StringName]


func _on_change_left() -> void:
	if options.is_empty():
		return

	var new_value: int = wrapi(value - 1, 0, options.size())
	change_setting(new_value)


func _on_change_right() -> void:
	if options.is_empty():
		return

	var new_value: int = wrapi(value + 1, 0, options.size())
	change_setting(new_value)


func _update_visual_state() -> void:
	if options.is_empty():
		state_label.text = "NULL"
	else:
		state_label.text = options[value]
