extends Area2D
#Clicking on the Area2D emits a signal to the room manager to verify the room
#number clicked.

signal room_sprite_clicked

func _input_event(_viewport, event, _shape_idx):
	
	if event.is_action_pressed("move"):
		room_sprite_clicked.emit("move")
	if event.is_action_pressed("shoot"):
		room_sprite_clicked.emit("shoot")
