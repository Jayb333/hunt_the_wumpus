extends Control

var master_bus = AudioServer.get_bus_index("Master")
@onready var mute_button = $MarginContainer/MuteButton

func _ready():
	#Load the state of the mute button
	load_mute_settings()
	
func load_mute_settings():
	#This function reads the state of the mute audio button from the config file
	var config = ConfigFile.new()
	var error = config.load("user://mute_settings.cfg")
	#OK is a constant that should return zero. This is a failsafe, if the config file can't
	#be read then set the mute set to the default (off)
	if error != OK:
		mute_audio(false)
		return
	var is_muted = config.get_value("audio", "is_muted", false)
	mute_audio(is_muted)
	update_mute_button_label()

func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_instructions_button_pressed():
	get_tree().change_scene_to_file("res://scenes/instructions_screen.tscn")

func toggle_mute():
	#This function toggles the mute state, performing the opposite action of its current state
	mute_audio(!is_audio_muted())

func mute_audio(mute : bool):
	AudioServer.set_bus_mute(master_bus, mute)
	
func is_audio_muted() -> bool:
	#Returns a true/false value based on whether or not audio is muted
	return AudioServer.is_bus_mute(master_bus)

func update_mute_button_label():
	if is_audio_muted():
		mute_button.text = "Unmute"
	else:
		mute_button.text = "Mute"

func save_mute_settings():
	#Creates a config file that sets the value of the audio bus' current state, mute or not
	var config = ConfigFile.new()
	config.set_value("audio", "is_muted", is_audio_muted())
	config.save("user://mute_settings.cfg")

func _on_mute_button_pressed():
	toggle_mute()
	save_mute_settings()
	update_mute_button_label()
