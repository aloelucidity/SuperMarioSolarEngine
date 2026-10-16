@tool
class_name OptionTab
extends OptionBase

@export var tabs: Array[Control]

@export var selected_tab: int = 0:
	set(val):
		if tabs.is_empty():
			return

		selected_tab = clamp(val, 0, tabs.size() - 1)

		_update_visual_state()
		_update_visible_controls()


func _ready() -> void:
	super()

	if not tabs.is_empty():
		_update_visual_state()
		_update_visible_controls()


func _on_change_left() -> void:
	selected_tab = wrapi(selected_tab - 1, 0, tabs.size())


func _on_change_right() -> void:
	selected_tab = wrapi(selected_tab + 1, 0, tabs.size())


func _update_visual_state() -> void:
	state_label.text = tabs[selected_tab].name


func _update_visible_controls() -> void:
	for tab: Control in tabs:
		if tab.name != tabs[selected_tab].name:
			tab.hide()
		else:
			tab.show()
