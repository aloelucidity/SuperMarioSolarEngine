class_name ShaderToggle
extends Node
## Stops the processing of a shader based on the value of
## [LocalSettings]'s "shaders" option.

@onready var parent: Node = get_parent()

@onready var stored_mode: Node.ProcessMode = parent.process_mode
@onready var stored_mat: Material = parent.material


func _ready() -> void:
	# Wait one process frame to ensure the shaders option has been loaded in..
	# This is done in the UserInterface's OptionsScreen which might be loaded
	# after this node, and thus not have the option initialised before
	# this _ready() runs.
	await get_tree().process_frame

	LocalSettings.setting_changed.connect(_setting_changed)
	_toggle_parent(LocalSettings.load_setting("General", "shaders"))


func _setting_changed(key: String, value: Variant) -> void:
	if key == "shaders":
		_toggle_parent(value)


func _toggle_parent(on: bool) -> void:
	if not on:
		stored_mode = parent.process_mode
		parent.process_mode = Node.PROCESS_MODE_DISABLED
		parent.visible = false

		if parent is CanvasItem:
			stored_mat = parent.material
			parent.material = null
	else:
		parent.process_mode = stored_mode
		parent.material = stored_mat
		parent.visible = true
