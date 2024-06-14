extends Area2D
#Clicking on the sprite emits a signal to check the room number from the parent node.
#var room_number
signal room_sprite_clicked

func _input_event(viewport, event, shape_idx):
	
	if event.is_action_pressed("move"):
		#print("I have checked the room.")
		room_sprite_clicked.emit("move")
	if event.is_action_pressed("shoot"):
		#print("I have checked the room.")
		room_sprite_clicked.emit("shoot")
