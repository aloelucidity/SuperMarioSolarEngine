@tool
class_name OptionAudioDevice
extends OptionString

var audio_device_list: PackedStringArray


func _process(_delta: float) -> void:
	var device_list: PackedStringArray = AudioServer.get_output_device_list()

	if device_list == audio_device_list or value == null:
		return

	# If the selected audio device is removed, reset it to "Default"
	if not value in device_list:
		push_warning("Selected device removed. Resetting to Default.")
		LocalSettings.change_setting("Audio", "device", "Default")

	audio_device_list = device_list
	_update_options()


func _update_options() -> void:
	options.assign(audio_device_list)
	_update_visual_state()
