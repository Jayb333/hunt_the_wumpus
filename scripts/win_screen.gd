extends Control

@onready var turn_label = $MarginContainer/TurnLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_label.text = "Turn count: " + str(Globals.actions)

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_title_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
