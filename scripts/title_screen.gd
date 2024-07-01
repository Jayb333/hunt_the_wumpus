extends Control

var master_bus = AudioServer.get_bus_index("Master")
@onready var mute_button = $MarginContainer/MuteButton

func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_instructions_button_pressed():
	get_tree().change_scene_to_file("res://scenes/instructions_screen.tscn")

func mute_audio(mute : bool):
	AudioServer.set_bus_mute(master_bus, mute)
	
func is_audio_muted() -> bool:
	return AudioServer.is_bus_mute(master_bus)

func toggle_mute():
	mute_audio(!is_audio_muted())
	
func update_mute_button_label():
	if is_audio_muted():
		mute_button.text = "Unmute"
	else:
		mute_button.text = "Mute"

func load_mute_settings():
	var config = ConfigFile.new()
	var error = config.load("user://mute_settings.cfg")
	if error != OK:
		mute_audio(false)
		return
	var is_muted = config.get_value("audio", "is_muted", false)
	mute_audio(is_muted)
	update_mute_button_label()
	
func save_mute_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "is_muted", is_audio_muted())
	config.save("user://mute_settings.cfg")
	
func _ready():
	load_mute_settings()

#func _on_check_box_toggled(toggled_on):
	#AudioServer.set_bus_mute(master_bus, not AudioServer.is_bus_mute(master_bus))
	#save_mute_settings()
	
func _on_mute_button_pressed():
	toggle_mute()
	save_mute_settings()
	update_mute_button_label()
