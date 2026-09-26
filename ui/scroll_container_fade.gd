@tool
class_name ScrollContainerFade
extends Panel
## [Panel] that fades the edges of a [ScrollContainer] to
## better indicate the presence of further content.
##
## To use, instantiate the [ScrollContainerFade] scene "scroll_container_fade.tscn"
## and add it as a parent of your [ScrollContainer]. Then reload the scene.

## The length of the fade effect.
@export_range(0, 32, 1, "hide_control", "or_greater", "suffix:px")
var fade_length: int = 16

## Reference to the child [ScrollContainer].
@onready var scroll_container: ScrollContainer = get_child(0)
## Reference to the [member scroll_container]'s content.
@onready var scroll_container_content: Control = scroll_container.get_child(0)
## Reference to the [member scroll_container]'s internal [VScrollBar].
@onready var scroll_v_bar: VScrollBar = scroll_container.get_v_scroll_bar()


func _ready() -> void:
	clip_children = CanvasItem.CLIP_CHILDREN_ONLY

	if scroll_container == null:
		push_error("The FadeEffect needs a ScrollContainer child to work.")
		return

	if scroll_container_content == null:
		push_error("The ScrollContainer needs content for the FadeEffect to work.")
		return

	# Makes the ScrollContainer fit the FadeEffect panel.
	scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll_container.set_offsets_preset(Control.PRESET_FULL_RECT)
	# Makes the scrollbar unaffected by the fade.
	scroll_container.z_index = 1
	# Makes the contents of the ScrollContainer affected by the fade.
	scroll_container_content.z_index = -1

	scroll_v_bar.value_changed.connect(_change_fade_direction.unbind(1))
	_change_fade_direction()


## Changes the stylebox for this node to the directional mask
## used to create the fade effect.
func _change_fade_direction() -> void:
	add_theme_stylebox_override(&"panel", _get_appropriate_mask())


## Returns a [StyleBoxFlat] with either the top edge, bottom edge, or both edges
## faded based on [member scroll_v_bar]'s scroll ratio.
func _get_appropriate_mask() -> StyleBoxFlat:
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()

	stylebox.bg_color = Color.WHITE

	stylebox.border_color = Color.TRANSPARENT
	stylebox.border_blend = true

	if _get_scroll_ratio() == 0.0:
		stylebox.border_width_top = 0
		stylebox.border_width_bottom = fade_length
	elif _get_scroll_ratio() == 1.0:
		stylebox.border_width_top = fade_length
		stylebox.border_width_bottom = 0
	else:
		stylebox.border_width_top = fade_length
		stylebox.border_width_bottom = fade_length

	return stylebox


## @deprecated: This method will be removed in the future when this issue gets resolved.
## See: [url]https://github.com/godotengine/godot/issues/62043[/url]
## [br][br]
## Returns the scroll ratio of the [member scroll_v_bar].
## This is a workaround to using [member Range.ratio], since that doesn't work properly with [ScrollContainer]s.
func _get_scroll_ratio() -> float:
	# Godot bug: max_value adds the size of the scroll container rect,
	# so we need to correct for that.
	# See: https://github.com/godotengine/godot/issues/62043
	var max_value_corrected = scroll_v_bar.max_value - scroll_container.get_rect().size.y

	return remap(scroll_v_bar.value, 0.0, max_value_corrected, 0.0, 1.0)
