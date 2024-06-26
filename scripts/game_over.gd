extends Control

@onready var game_over_label = $MarginContainer/GameOverLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	#match Globals:
	if Globals.death_by_wumpus == true:
		game_over_label.text = "The Wumpus eats well tonight."
	if Globals.death_by_pitfall == true:
		game_over_label.text = "You faint well before hitting the bottom. A pleasant mercy."
	if Globals.death_by_ricochet == true:
		game_over_label.text = "The shock barely registers as the shrapnel pierces your brain."
	if Globals.death_by_defenseless == true:
		game_over_label.text = "With no ammo remaining you resign yourself to a gruesome fate."

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_title_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
