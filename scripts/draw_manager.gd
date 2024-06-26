extends Node2D

var rooms_dictionary : Dictionary
var room_location : Array
var room_number : Array
var room_index : Dictionary
@onready var player_sprite = $PlayerSprite
@export var bullet_sprite: PackedScene
var new_bullet

func _init():
	pass

func _ready():
	var room_nodes = get_tree().get_nodes_in_group("rooms")
	room_location.append(self.position)
	for i in room_nodes:
		room_location.append(i.position)
	$"../GameManager".updated_player.connect(update_player)
	$"../GameManager".updated_shot.connect(update_shot)
	$"../GameManager".created_bullet.connect(create_bullet)
	
	
func recieve_dict(rooms):
	rooms_dictionary = rooms
	pass

func _draw():
	var exit_pair : Array
	#loop through all available rooms
	for i in rooms_dictionary:
		#For each room(i), loop through exits
		exit_pair.clear()
		for j in rooms_dictionary.get(i):
			exit_pair.append(room_location[j])
			draw_line(room_location[i],room_location[j], Color.RED, 2.0)
			
func update_player(player_pos):
	var transform : Vector2
	transform = room_location[player_pos]
	$PlayerSprite.position = transform

func create_bullet():
	new_bullet = bullet_sprite.instantiate()
	add_child(new_bullet)
	
func clear_bullet():
	new_bullet.queue_free()

func update_shot(room_number):
	var transform : Vector2
	print(room_location[room_number])
	transform = room_location[room_number]
	new_bullet.position = transform
