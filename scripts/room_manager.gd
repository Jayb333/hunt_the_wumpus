extends Sprite2D
#This script contains the logic of the individual rooms. It emits a signal to
#to pass its information to the game manager. 

signal checked_room_number
@export var room_number : int

func _ready():
	$Area2D.room_sprite_clicked.connect(_room_sprite_clicked)
	$RoomNumberLabel.text = str(room_number)

func _room_sprite_clicked(check_input):
	#After receiving the player's input, emit a signal to the game manager with the room number
	#and type of input: left click to move, right click to shoot.
	if check_input == "move":
		checked_room_number.emit(room_number, check_input)
	if check_input == "shoot":
		print("You are shooting into " + str(room_number))
		checked_room_number.emit(room_number, check_input)
		
		
