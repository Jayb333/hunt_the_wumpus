extends Control

#Manages the GUI and updates the various labels. "Illegal_action_label" was originally
#used to warn the player when they clicked on a room they couldn't access but
#I end up using it for miscellaneous messages and didn't bother to rename it.
#What the various functions do is pretty self explanatory. 

@onready var wumpus_threat_label = %WumpusThreatLabel
@onready var pitfall_threat_label = %PitfallThreatLabel
@onready var sinkhole_threat_label = %SinkholeThreatLabel
@onready var room_number_label = %RoomNumberLabel
@onready var illegal_action_label = %IllegalActionLabel
@onready var ammo_label = %AmmoLabel
@onready var game_manager = $"../GameManager"

func _ready():
	game_manager.updated_room_number.connect(_update_room_label)
	game_manager.invalid_room.connect(_invalid_room)
	game_manager.checked_threats.connect(_update_threats_label)
	game_manager.updated_ammo.connect(_update_ammo)
	game_manager.cleared_threats.connect(_clear_threats_label)
	game_manager.updated_ricochet_room.connect(_ricochet_message)
	game_manager.shot_into_room.connect(_shoot_into)
	game_manager.woke_wumpus.connect(_wumpus_wakes)
	illegal_action_label.text = ""
	_clear_threats_label()

func _ricochet_message(random_ricochet_target):
	illegal_action_label.text = "Bullet ricocheted into room " + str(random_ricochet_target[0])
	
func _wumpus_wakes():
	illegal_action_label.text = "Something lumbers in the darkness..."
	
func _shoot_into(room_number):
	illegal_action_label.text = "You shoot into room " + str(room_number)

func _clear_threats_label():
	#Clear the threat messages so they don't persist between actions
	sinkhole_threat_label.text = ""
	wumpus_threat_label.text = ""
	pitfall_threat_label.text = ""

func _update_threats_label(threat):
	match threat:
		"sinkhole":
			sinkhole_threat_label.text = "The earth shifts underfoot."
		"pitfall":
			pitfall_threat_label.text = "A gust of wind blows."
		"wumpus":
			wumpus_threat_label.text = "A terrible presence is near."

func _update_room_label(player_pos):
	room_number_label.text = "Room Number: " + str(player_pos)
	_invalid_room("")

func _invalid_room(warning):
	match warning:
		"same room":
			illegal_action_label.text = "You're already in this room."
		"too far":
			illegal_action_label.text = "Adjoining rooms only."
		"wumpus woke":
			illegal_action_label.text = "Something lumbers in the distance..."
		"sinkhole":
			illegal_action_label.text = "You were carried away!"
			await get_tree().create_timer(2).timeout
			illegal_action_label.text = ""
		_:
			illegal_action_label.text = ""

func _update_ammo(current_ammo):
	ammo_label.text = "Ammo: " + str(current_ammo)

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_title_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
