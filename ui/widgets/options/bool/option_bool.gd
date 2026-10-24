@tool
class_name OptionBool
extends OptionBase


func _on_change_left() -> void:
	change_setting(!value)


func _on_change_right() -> void:
	change_setting(!value)


func _update_visual_state() -> void:
	state_label.text = "On" if value else "Off"
