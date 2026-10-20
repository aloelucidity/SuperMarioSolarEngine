extends TabContainer

## The sound effect that plays when scrolling to the left.
@export var tab_left_sfx: SoundEffect
## The sound effect that plays when scrolling to the right.
@export var tab_right_sfx: SoundEffect
## The focus grabber for each tab.
## The array entry index should correspond to the index of the tab.
@export var focus_grabbers: Array[Control]


func _input(_event: InputEvent) -> void:
	var focused_control: Control = get_viewport().gui_get_focus_owner()
	# This logic shouldn't run if none of the tabs are actually focused.
	# Otherwise, the game will let you switch tabs at any time.
	if not is_instance_valid(focused_control) or not is_ancestor_of(focused_control):
		return
	if Input.is_action_just_pressed(&"tab_left") and not current_tab == 0:
		current_tab -= 1
		tab_left_sfx.play(self)
		grab_focus_for_tab(current_tab)
	if Input.is_action_just_pressed(&"tab_right") and not current_tab == get_tab_count() - 1:
		current_tab += 1
		tab_right_sfx.play(self)
		grab_focus_for_tab(current_tab)


func grab_focus_for_tab(tab_idx: int) -> void:
	var control: Control = focus_grabbers[tab_idx]

	if not is_instance_valid(control):
		return

	# Wait a frame so the tab can switch and enable
	# before we try to grab focus.
	await get_tree().process_frame

	control.grab_focus()


func _on_tab_changed(tab: int) -> void:
	grab_focus_for_tab(tab)
