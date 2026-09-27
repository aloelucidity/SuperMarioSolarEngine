@tool
class_name AdaptiveInputIcon
extends TextureRect
## Texture representing an input icon that changes based on the most recently used device type.

## Which icon version is displayed by default.
@export_enum("Keyboard", "Controller") var default_texture: String = "Keyboard":
	set(val):
		default_texture = val

		if not is_node_ready():
			return

		if val == "Keyboard":
			texture = IconMap.find(keyboard_input)
		elif val == "Controller":
			texture = IconMap.find(controller_input)

## The kayboard input displayed on this texture. The icon is retrieved from the [IconMap].
@export var keyboard_input: InputEventKey:
	set(val):
		keyboard_input = val

		if default_texture == "Keyboard":
			texture = IconMap.find(keyboard_input)

## The controller input displayed on this texture. The icon is retrieved from the [IconMap].
@export var controller_input: InputEventJoypadButton:
	set(val):
		controller_input = val

		if default_texture == "Controller":
			texture = IconMap.find(controller_input)


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventJoypadButton:
		texture = IconMap.find(controller_input)
	elif event is InputEventKey or event is InputEventMouseButton:
		texture = IconMap.find(keyboard_input)
