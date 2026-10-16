@tool
class_name OptionVolume
extends OptionSlider


func _on_value_changed() -> void:
	value_change_sfx.volume = linear_to_db(value)

	super()
