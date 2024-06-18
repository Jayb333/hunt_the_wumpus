extends Sprite2D
#This script emits a signal to the parent game manager to pass the room
#number. This scene isn't instantiated until runtime. 

@onready var room_number_label = $RoomNumberLabel
@export var room_number : int
var check_input: String 
signal checked_room_number

func _ready():
	$Area2D.room_sprite_clicked.connect(_room_sprite_clicked)
	$RoomNumberLabel.text = str(room_number)
	pass

func _room_sprite_clicked(check_input):
	if check_input == "move":
		checked_room_number.emit(room_number, check_input)
		#print("You are moving to " + str(room_number))
	if check_input == "shoot":
		checked_room_number.emit(room_number, check_input)
		#print("You are shooting into " + str(room_number))
	
	pass
