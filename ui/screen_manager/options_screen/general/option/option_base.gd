@tool
@abstract
class_name OptionBase
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

@export var option_state_unfocused: StyleBox
@export var option_state_focused: StyleBox

var section: String
var key: String

var value: Variant

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var state_container: PanelContainer = %StateContainer
@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var state_label: Label = %State
@onready var arrow_left: TextureRect = %ArrowLeft
@onready var arrow_right: TextureRect = %ArrowRight


func _ready() -> void:
	name_label.text = setting_name

	if Engine.is_editor_hint():
		return

	LocalSettings.connect(&"setting_changed", _update_value)

	focus_entered.connect(set.bindv([&"highlighted", true]))
	focus_exited.connect(set.bindv([&"highlighted", false]))

	# Initialise button
	var saved_val: Variant = LocalSettings.load_setting(section, key)
	_update_value(key, saved_val)


func _input(_event: InputEvent) -> void:
	if not highlighted:
		return

	if Input.is_action_just_pressed(&"ui_left"):
		_on_change_left()
	elif Input.is_action_just_pressed(&"ui_right"):
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

	_update_visual_state()


## Toggles between highlighted and non-highlighted visuals based on [param on].
func _toggle_highlight(on: bool) -> void:
	if on:
		var sfx: SoundEffect = SoundEffect.new()
		sfx.stream = select_stream
		sfx.is_2d = false
		sfx.audio_bus = "UI"
		sfx.play(self)

		animation_player.play(&"arrows_bounce")
		add_theme_stylebox_override(&"panel", option_bg_focused)
		state_container.add_theme_stylebox_override(&"panel", option_state_focused)
		state_label.label_settings.font_color = Color.WHITE
		arrow_left.modulate = Color.WHITE
		arrow_right.modulate = Color.WHITE
	else:
		animation_player.stop()
		add_theme_stylebox_override(&"panel", option_bg_unfocused)
		state_container.add_theme_stylebox_override(&"panel", option_state_unfocused)
		state_label.label_settings.font_color = Color.BLACK
		arrow_left.modulate = Color.TRANSPARENT
		arrow_right.modulate = Color.TRANSPARENT


@abstract
func _on_change_left() -> void


@abstract
func _on_change_right() -> void


## Defines how the option's text is displayed.
@abstract
func _update_visual_state() -> void
