@tool
class_name OptionBinding
extends Control


const SELECT_STREAM: AudioStreamWAV = preload("uid://cd61c3e87kith")
const INPUT_ICON_SHADER: ShaderMaterial = preload("uid://6ou0lc3a1jm1")

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

## The type of [InputEvent]s this bind button listens to.[br][br]
## Simply add an unconfigured [InputEvent] of your desired type to the array
## to allow for inputs of the same type to be parsed.
@export var parsable_events: Array[InputEvent]

## How many bindings of the types specified in [member parsable_events] can be bound.
@export var max_bindings: int = 3

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

@export_group("Sound")
@export var press_sfx: SoundEffect

var section: String
var key: String

var bound_inputs: PackedStringArray
var shown_inputs: PackedStringArray

var awaiting_input: bool = false

@onready var state_container: PanelContainer = %StateContainer
@onready var input_container: HBoxContainer = %InputContainer
@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var await_label: Label = %AwaitLabel
@onready var timeout_timer: Timer = %TimeoutTimer


func _ready() -> void:
	name_label.text = setting_name
	input_container.material = INPUT_ICON_SHADER.duplicate()
	input_container.material.set_shader_parameter(&"palette_index", 2)

	await_label.hide()

	if Engine.is_editor_hint():
		return

	focus_entered.connect(set.bindv([&"highlighted", true]))
	focus_exited.connect(set.bindv([&"highlighted", false]))

	# Delete all events attached to the InputMap by default so
	# we have our own control.
	# Make sure the key is named the same as the action in the InputMap.
	InputMap.action_erase_events(key)

	LocalSettings.connect(&"setting_changed", _update_value)

	var saved_val: Variant = LocalSettings.load_setting(section, key)

	for event_name: String in saved_val:
		var event: InputEvent = IconMap.get_associated_event(event_name)

		if _is_valid_event(event):
			_add_input(event)
			_add_input_icon(event)


func _input(event: InputEvent) -> void:
	if not highlighted or not event.is_pressed():
		return

	if not awaiting_input:
		if Input.is_action_just_pressed(&"ui_accept") and bound_inputs.size() < max_bindings:
			_request_input()
		if Input.is_action_just_pressed(&"setting_clear"):
			_clear()
		if Input.is_action_just_pressed(&"setting_reset"):
			_reset()
	elif awaiting_input and _is_valid_event(event) and bound_inputs.size() < max_bindings:
		_on_input_received(event)
		get_viewport().set_input_as_handled()


func _validate_property(property: Dictionary) -> void:
	if property.name == "local_setting":
		var settings: PackedStringArray = []

		for sec: String in LocalSettings.settings:
			for k: String in LocalSettings.settings[sec]:
				settings.append("%s - %s" % [sec, k])

		property.hint |= PROPERTY_HINT_ENUM
		property.hint_string = ",".join(settings)


func _request_input() -> void:
	press_sfx.play(self)
	timeout_timer.start()

	awaiting_input = true

	while awaiting_input:
		awaiting_input = timeout_timer.time_left > 0

		await_label.text =  "Press a button... (%d)" % ceil(timeout_timer.time_left)

		input_container.visible = !awaiting_input
		await_label.visible = awaiting_input

		await get_tree().process_frame


func _on_input_received(event: InputEvent) -> void:
	awaiting_input = false

	await_label.hide()
	input_container.show()

	_add_input(event)
	_add_input_icon(event)

	change_setting(bound_inputs)


## Updates the matching setting in [LocalSettings].
func change_setting(new_value) -> void:
	if local_setting.is_empty():
		return

	LocalSettings.change_setting(section, key, new_value, true)


## Toggles between highlighted and non-highlighted visuals based on [param on].
func _toggle_highlight(on: bool) -> void:
	if on:
		var sfx: SoundEffect = SoundEffect.new()
		sfx.stream = SELECT_STREAM
		sfx.is_2d = false
		sfx.audio_bus = "UI"
		sfx.play(self)

		add_theme_stylebox_override(&"panel", option_bg_focused)
		state_container.add_theme_stylebox_override(&"panel", option_state_focused)

		input_container.material.set_shader_parameter(&"palette_index", 1)
	else:
		add_theme_stylebox_override(&"panel", option_bg_unfocused)
		state_container.add_theme_stylebox_override(&"panel", option_state_unfocused)

		input_container.material.set_shader_parameter(&"palette_index", 2)


## Checks if an event is parsable by using the defined classes in [member parsable_events].
func _is_valid_event(event: InputEvent) -> bool:
	# The event wasn't in the [IconMap].
	if event == null:
		return false

	for event_type: InputEvent in parsable_events:
		if event_type and event.is_class(event_type.get_class()):
			return true

	return false


## Adds the event to the project's [InputMap].
func _add_input(event: InputEvent) -> void:
	var event_name: String = IconMap.get_filtered_name(event)

	if bound_inputs.has(event_name):
		return

	bound_inputs.append(event_name)

	if not InputMap.action_has_event(key, event):
		InputMap.action_add_event(key, event)


func _add_input_icon(event: InputEvent) -> void:
	var event_name: String = IconMap.get_filtered_name(event)

	if shown_inputs.has(event_name):
		return

	shown_inputs.append(event_name)

	var tex_rect: TextureRect = TextureRect.new()

	tex_rect.texture = IconMap.find(event)
	tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex_rect.use_parent_material = true

	input_container.add_child(tex_rect)


func _clear() -> void:
	bound_inputs.clear()
	shown_inputs.clear()

	change_setting(bound_inputs)

	for child: TextureRect in input_container.get_children():
		child.queue_free()


func _reset() -> void:
	_clear()

	var default_inputs: PackedStringArray = LocalSettings.defaults.get(key)

	for input_name: String in default_inputs:
		var input_object: InputEvent = IconMap.get_associated_event(input_name)

		if _is_valid_event(input_object):
			_add_input(input_object)
			_add_input_icon(input_object)

	change_setting(default_inputs)


## Updates the internal value of the setting, and then
## calls the abstracted [method _update_state] method which updates the settings
## visual state depending on how its defined by the derived class.
func _update_value(changed_key: String, new_value: Variant = null) -> void:
	if changed_key != key:
		return

	bound_inputs.clear()
	shown_inputs.clear()

	for child: TextureRect in input_container.get_children():
		child.queue_free()

	# Duplicate to avoid editing the received array.
	var new_values: PackedStringArray = new_value.duplicate()

	for input_name: String in new_values:
		var input_object: InputEvent = IconMap.get_associated_event(input_name)

		if _is_valid_event(input_object):
			_add_input(input_object)
			_add_input_icon(input_object)

	change_setting(bound_inputs)
