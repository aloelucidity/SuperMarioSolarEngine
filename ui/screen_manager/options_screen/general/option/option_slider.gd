@tool
class_name OptionSlider
extends Control

const select_stream: AudioStreamWAV = preload("res://ui/sfx/select.wav")

@export var highlighted: bool:
	set(val):
		highlighted = val

		if is_node_ready():
			_toggle_highlight(val)

@export var local_setting: String:
	set(val):
		local_setting = val

		section = val.get_slice(" - ", 0)
		key = val.get_slice(" - ", 1)

@export_group("Visuals")
@export var setting_icon: Texture2D:
	set(val):
		setting_icon = val

		if is_instance_valid(icon):
			icon.texture = val

@export var setting_name: String:
	set(val):
		setting_name = val

		if is_instance_valid(name_label):
			name_label.text = val

@export_multiline() var setting_description: String = ""

@export var option_bg_unfocused: StyleBox
@export var option_bg_focused: StyleBox

@export_group("Sound")

@export var value_change_sfx: SoundEffect

@export_category("Range")
@export var min_value: float = 0.0:
	set(val):
		min_value = val

		if is_instance_valid(slider):
			slider.min_value = val

@export var max_value: float = 100.0:
	set(val):
		max_value = val

		if is_instance_valid(slider):
			slider.max_value = val

@export var step: float = 1.0:
	set(val):
		step = val

		if is_instance_valid(slider):
			slider.step = val

@export var value: float = 0.0:
	set(val):
		value = clamp(val, min_value, max_value)

var section: String
var key: String

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var slider: HSlider = %Slider
@onready var percentage: Label = %Percentage


func _ready() -> void:
	name_label.text = setting_name

	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value

	if Engine.is_editor_hint():
		return

	LocalSettings.connect(&"setting_changed", _update_value)

	focus_entered.connect(set.bindv([&"highlighted", true]))
	focus_exited.connect(set.bindv([&"highlighted", false]))

	var saved_val: Variant = LocalSettings.load_setting(section, key)
	_update_value(key, saved_val)


func _input(_event: InputEvent) -> void:
	if not highlighted:
		return

	if Input.is_action_pressed(&"ui_left"):
		_on_change_left()
	elif Input.is_action_pressed(&"ui_right"):
		_on_change_right()


func _validate_property(property: Dictionary) -> void:
	if property.name == "local_setting":
		var settings: PackedStringArray = []

		for sec: String in LocalSettings.settings:
			for k: String in LocalSettings.settings[sec]:
				settings.append("%s - %s" % [sec, k])

		property.hint |= PROPERTY_HINT_ENUM
		property.hint_string = ",".join(settings)


## Updates the matching setting in [LocalSettings].
func change_setting(new_value) -> void:
	if local_setting.is_empty():
		return

	LocalSettings.change_setting(section, key, new_value)


## Updates the internal value of the setting, and then
## calls the abstracted [method _update_state] method which updates the settings
## visual state depending on how its defined by the derived class.
func _update_value(changed_key: String, new_value: Variant = null) -> void:
	if changed_key != key:
		return

	value = new_value

	_on_value_changed()


## Toggles between highlighted and non-highlighted visuals based on [param on].
func _toggle_highlight(on: bool) -> void:
	if on:
		var sfx: SoundEffect = SoundEffect.new()
		sfx.stream = select_stream
		sfx.is_2d = false
		sfx.audio_bus = "UI"
		sfx.play(self)

		add_theme_stylebox_override(&"panel", option_bg_focused)
	else:
		add_theme_stylebox_override(&"panel", option_bg_unfocused)


func _on_change_left() -> void:
	var new_value = clamp(value - step, min_value, max_value)

	if new_value == value:
		return

	LocalSettings.change_setting(section, key, new_value)


func _on_change_right() -> void:
	var new_value = clamp(value + step, min_value, max_value)

	if new_value == value:
		return

	LocalSettings.change_setting(section, key, new_value)


func _on_value_changed() -> void:
	if is_instance_valid(slider) and is_instance_valid(percentage):
		slider.value = value
		percentage.text = "%d%%" % remap(value, min_value, max_value, 0.0, 100.0)

	if is_instance_valid(value_change_sfx):
		value_change_sfx.play(self)
