@tool
extends Node
## Settings stored on the user's system.
## This autoload needs to be a tool script since some tools scripts want to read
## from this during editor processing.

signal setting_changed(key, new_value)

const FILE_PATH: String = "user://settings.cfg"
var config: ConfigFile = ConfigFile.new()

## Dictionary of every setting that gets stored to the user's system.
## The key is the JSON-style section name,
## the value is an [Array] of the setting names.
var settings: Dictionary[String, Array] = {
	"General":
		[
			"scale",
			"v_sync",
			"graphics",
			"shaders",
			"rich_presence",
			"motion_controls",
			"rumble_strength",
			"fps_cap",
		],
	"Audio":
		[
			"master_volume",
			"bgm_volume",
			"sfx_volume",
			"voice_volume",
			"music_muted",
			"device",
		],
	"Developer":
		[
			"debug_toggle",
			"debug_toggle_hitboxes",
		],
	"Bindings":
		[
			"right",
			"left",
			"up",
			"down",
			"crouch",
			"jump",
			"spin",
			"dive",
			"groundpound",
		]
}

## Dictionary of every key and its default value.
## The key is the setting name,
## the value is its default value.
var defaults: Dictionary[String, Variant] = {
	# General
	"scale": 1,
	"v_sync": true,
	"graphics": GameState.GraphicsMode.HIGH_RES,
	"shaders": true,
	"rich_presence": true,
	"motion_controls": false,
	"rumble_strength": 1,
	"fps_cap": 2,

	# Audio
	"master_volume": 1.0,
	"bgm_volume": 1.0,
	"sfx_volume": 1.0,
	"voice_volume": 1.0,
	"music_muted": false,
	"device": "Default",

	# Developer
	"debug_toggle": false,
	"debug_toggle_hitboxes": false,

	# Bindings
	"right": Util.get_default_events("right", true),
	"left": Util.get_default_events("left", true),
	"up": Util.get_default_events("up", true),
	"down": Util.get_default_events("down", true),
	"crouch": Util.get_default_events("crouch", true),
	"jump": Util.get_default_events("jump", true),
	"spin": Util.get_default_events("spin", true),
	"dive": Util.get_default_events("dive", true),
	"groundpound": Util.get_default_events("groundpound", true),
}


func _init() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		config.save(FILE_PATH)

	var err = config.load(FILE_PATH)

	if err != OK:
		push_error("Error loading config file!")


## Load a setting [param key] at a category [param section] in the config file.
## Returns its default value as defined in [member defaults] if nothing is found.
func load_setting(section: String, key: String) -> Variant:
	return config.get_value(section, key, defaults.get(key))


## Update a setting [param key] at a category [param section],
## with a new [param value] in the config file.
func change_setting(section: String, key: String, value: Variant) -> void:
	_apply_setting(section, key, value)
	config.save(FILE_PATH)


## Returns whether or not a key exists and has a value.
func has_setting(section: String, key: String) -> void:
	return config.has_section_key(section, key)


func get_section(setting: String) -> Variant:
	for section in settings:
		for key in settings[section]:
			if key == setting:
				return section

	return null


## Sets all settings back to their default values.
func reset_settings() -> void:
	for section in config.get_sections():
		if section not in settings.keys():
			config.erase_section(section)

		for key in config.get_section_keys(section):
			if key not in defaults.keys():
				config.erase_section_key(section, key)

			# Only reset if there's a default value to reset to.
			if defaults.has(key):
				_apply_setting(section, key, defaults.get(key))

	config.save(FILE_PATH)


## Applies the setting change to the config and emits the [signal setting_changed] signal.
func _apply_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	emit_signal(&"setting_changed", key, value)
