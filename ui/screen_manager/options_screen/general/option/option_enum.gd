@tool
class_name OptionEnum
extends OptionBase

@export var options: Array[StringName]


func _on_change_left() -> void:
	var new_value: int = wrapi(value - 1, 0, options.size())
	change_setting(new_value)


func _on_change_right() -> void:
	var new_value: int = wrapi(value + 1, 0, options.size())
	change_setting(new_value)


func _update_visual_state() -> void:
	state_label.text = options[value]
