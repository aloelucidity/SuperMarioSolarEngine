extends Control

@export var option_desc_label: RichTextLabel

var highlighted_option: Control:
	set(val):
		highlighted_option = val

		if (
			is_instance_valid(option_desc_label) and 
			"setting_description" in highlighted_option
		):
			option_desc_label.text = highlighted_option.setting_description


func _ready() -> void:
	get_window().gui_focus_changed.connect(_on_focus_changed)


func _on_focus_changed(focus_owner: Control) -> void:
	if focus_owner is OptionBase:
		highlighted_option = focus_owner
