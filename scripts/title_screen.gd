extends Control



func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_instructions_button_pressed():
	get_tree().change_scene_to_file("res://scenes/instructions_screen.tscn")

func _on_check_box_toggled(toggled_on):
	var sfx_bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(sfx_bus, not AudioServer.is_bus_mute(sfx_bus))
