#This script handles updating drawing and updating the graphics.
extends Node2D

@export var bullet_sprite: PackedScene
@onready var game_manager = $"../GameManager"
var location : Vector2
var rooms_dictionary : Dictionary
var room_location : Array
var room_index : Dictionary
var room_nodes : Array
var room_tex = preload("res://sprites/spr_room.png")
var dark_room_tex = preload("res://sprites/spr_room_dark.png")
var new_bullet

func _ready():
	room_nodes = get_tree().get_nodes_in_group("rooms")
	#In order to draw the connecting lines between rooms I need to create an array of every Sprite2D's
	#Vector2 position.
	room_location.append(self.position)
	for i in room_nodes:
		room_location.append(i.position)
	game_manager.updated_player.connect(update_player)
	game_manager.updated_shot.connect(update_shot)
	game_manager.created_bullet.connect(create_bullet)
	game_manager.draw_rooms.connect(draw_rooms)
	
func draw_rooms(player_pos, exits):
	#Every time this function is called it reverts all room sprites to their dark/dithered
	#appearance
	var counter = 0
	#reset all rooms to the dark version
	for i in room_nodes:
		#Because i doesn't produce an integer I need a counter variable to be able to access
		#the index of the room_nodes array
		room_nodes[counter].texture = dark_room_tex
		counter += 1
	#After all rooms are reset to their dithered sprite, I draw the player's current room as bright.
	room_nodes[player_pos-1].texture = room_tex
	#Then I draw all adjoining rooms as bright.
	for i in exits:
		room_nodes[i-1].texture = room_tex
	
func recieve_dict(rooms):
	#This function is called to receive the dictionary of room information from the game manager.
	rooms_dictionary = rooms

func _draw():
	#Draw connecting lines between rooms. First create an array that will contain the Vector2
	#positions of each room's exits.
	var exit_pair = []
	#Next, loop through all available rooms
	for i in rooms_dictionary:
		#For each room(i), loop through exits
		exit_pair.clear()
		for j in rooms_dictionary.get(i):
			#For each exit(j) in a room(i), append the Vector2 positions and draw lines
			exit_pair.append(room_location[j])
			draw_line(room_location[i], room_location[j], Color.RED, 2.0)
			
func update_player(player_pos):
	#Move the player sprite everytime this function is called
	location = room_location[player_pos]
	$PlayerSprite.position = location

func create_bullet():
	#Create the bullet sprite when called
	new_bullet = bullet_sprite.instantiate()
	add_child(new_bullet)
	
func clear_bullet():
	#Destroy the bullet sprite when called
	new_bullet.queue_free()

func update_shot(room_number):
	#Update the bullet sprite when it ricochets
	location = room_location[room_number]
	new_bullet.position = location
