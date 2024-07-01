extends Node2D

signal checked_threats(threat)
signal updated_room_number(player_pos)
signal invalid_room(warning)
signal updated_ammo(current_ammo)
signal cleared_threats()
signal updated_player(player_pos)
signal updated_ricochet_room(random_ricochet_room)
signal updated_shot(room_number)
signal shot_into_room(room_number)
signal woke_wumpus()
signal created_bullet()
signal draw_rooms(player_pos, exits)

#The rooms dictionary contains a room number (key) and three exits (values). Eventually I want
#to be able to randomly generate a list of rooms but this adaption only works with the classic
#arrangement of 20 rooms with three exits
const rooms = {1: [2,5,8], 2: [1,3,10], 3: [2,4,12], 4: [3,5,14], 5:[1,4,6],
6: [5,7,15], 7: [6,8,17], 8: [1,7,9], 9: [8,10,18], 10: [2,9,11], 
11: [10,12,19], 12: [3,11,13], 13: [12,14,20], 14: [4,13,15], 
15: [6,14,16], 16: [15,17,20], 17: [7,16,18], 18: [9,17,19], 
19: [11,18,20], 20: [13,16,19]}

var safe_rooms = rooms.keys()
var threat_rooms = {}
var threats = ["sinkhole", "sinkhole", "pitfall", "pitfall", "wumpus"]
var player_pos = -1
var threat : String
var random_room = rooms.keys()
var current_ammo : int
var test_room = "res://room_number.tscn"

@export var starting_ammo : int
@export var ricochet : int

@onready var draw_manager = $"../DrawManager"
@onready var shotgun_sfx = $"../ShotgunSFX"
@onready var ricochet_sfx = $"../RicochetSFX"
@onready var footsteps_sfx = $"../FootstepsSFX"
@onready var sinkhole_sfx = $"../SinkholeSFX"
@onready var wumpus_attacks_sfx = $"../WumpusAttacksSFX"
@onready var pitfall_sfx = $"../PitfallSFX"

func _ready():
	#When the game begins it should set all global variables to their default
	#conditions
	Globals.death_by_wumpus = false
	Globals.death_by_pitfall = false
	Globals.death_by_ricochet = false
	Globals.death_by_defenseless = false
	Globals.actions = 0
	current_ammo = starting_ammo
	#Run the function to populate the cave
	populate_cave()
	check_for_threats()
	draw_manager.recieve_dict(rooms)
	draw_manager.update_player(player_pos)
	#For debug purposes I like to know where the threats are located
	print(threat_rooms)
	updated_room_number.emit(player_pos)
	updated_ammo.emit(current_ammo)
	#I need to programatically connect every instance of the room_manager signals 
	var room_nodes: Array[Node] = get_tree().get_nodes_in_group("rooms")
	for i in room_nodes:
		i.checked_room_number.connect(_check_valid_room)
	
func populate_cave():
	#Iterate through list of threats, shuffle array of safe_rooms to get a random room, add that
	#threat to threat_rooms, remove the listed room from safe_rooms because it's no longer safe
	for threat_counter in threats:
		safe_rooms.shuffle()
		threat_rooms[safe_rooms[0]] = threat_counter
		safe_rooms.remove_at(0)
	#Remove all rooms 1-and-2-spaces away from Wumpus from list of safe rooms (the player should begin
	#within 3 spaces of the Wumpus
	safe_rooms.sort()
	var wumpus_room = threat_rooms.find_key("wumpus")
	#Create an array of rooms adjoining the wumpus' room
	var wumpus_threat_zone = rooms.get(wumpus_room)
	#The first for loop (i) removes the adjoining rooms from the safe room list. The second
	#for loop (j) removes the rooms adjoining to the original rooms, creating a 2-room distance
	for i in wumpus_threat_zone:
		safe_rooms.erase(i)
		for j in rooms.get(i):
			safe_rooms.erase(j)
	#Finally place the player in a random safe room
	safe_rooms.shuffle()
	player_pos = safe_rooms[0]
	move(player_pos)

func _check_valid_room(room_number, check_input):
	#Check for type of input, move or shoot. The counter variable is used to trigger an invalid
	#room. 
	var counter = 0
	for i in rooms.get(room_number):
		counter += 1
		if room_number == player_pos:
			invalid_room.emit("same room")
			break
		elif i == player_pos:
			#this is a legal space, now check for input
			match check_input:
				"shoot":
					Globals.actions += 1
					shoot(room_number)
					break
				"move":
					Globals.actions += 1
					move(room_number)
					break
		#If the loop cycles 3 or more times it means the player chose an invalid room
		elif counter >= 3: 
			invalid_room.emit("too far")
			
func shoot(room_number):
	shotgun_sfx.play()
	#I pause the game when performing an action to turn off inputs until it's finished.
	Globals.pause()
	#create array of random random targets
	var random_ricochet_target = rooms.get(room_number)
	draw_manager.create_bullet()
	current_ammo -= 1
	updated_ammo.emit(current_ammo)
	updated_shot.emit(room_number)
	shot_into_room.emit(room_number)
	await get_tree().create_timer(1).timeout
	#For loop iterates up to ricochet value, default 5
	for ricochet_count in ricochet:
		#First check if the player is in a room with a bullet
		if room_number == player_pos:
			dead("bullet")
			break
		#Next check if the player shoots the wumpus. If not, move the bullet to a random adjoining
		#room
		match threat_rooms.get(room_number):
			"wumpus":
				win_the_game()
				break
			_:
				#Shuffle through an array of rooms adjoining the bullet's current position
				ricochet_sfx.play()
				random_ricochet_target = rooms.get(room_number)
				random_ricochet_target.shuffle()
				room_number = random_ricochet_target[0]
				updated_ricochet_room.emit(random_ricochet_target)
				updated_shot.emit(room_number)
				await get_tree().create_timer(1).timeout
	if current_ammo <= 0:
		#Kill the player if they run out of ammo
		dead("defenseless")
	else:
		wumpus_wakes()
	Globals.unpause()
	draw_manager.clear_bullet()
	
func move(room_number):
	footsteps_sfx.play()
	#I pause the game when performing an action to turn off inputs until it's finished.
	Globals.pause()
	player_pos = room_number
	await get_tree().create_timer(.5).timeout
	Globals.unpause()
	updated_room_number.emit(player_pos)
	check_for_threats()
	updated_player.emit(player_pos)
	draw_rooms.emit(player_pos, rooms.get(player_pos))
	
func _cleared_threats():
	cleared_threats.emit()

func check_for_threats():
	_cleared_threats()
	#Checks if the player is in a room with a threat
	match threat_rooms.get(player_pos):
		"sinkhole":
			Globals.pause()
			footsteps_sfx.stream_paused = true
			sinkhole_sfx.play()
			await sinkhole_sfx.finished
			random_room.shuffle()
			Globals.unpause()
			move(random_room[0])
			invalid_room.emit("sinkhole")
		"pitfall":
			Globals.pause()
			pitfall_sfx.play()
			await pitfall_sfx.finished
			dead("pitfall")
		"wumpus":
			Globals.pause()
			wumpus_attacks_sfx.play()
			await wumpus_attacks_sfx.finished
			dead("wumpus")
	#If the player is not in a room with a threat, evaluate each adjoining room for threats
	#and update the threat labels
	for i in rooms.get(player_pos):
		for j in threats:
			if threat_rooms.get(i) == j:
				checked_threats.emit(str(j))
				
func dead(killed_by):
	#Sets the global variable that determines which game over screen you see
	match killed_by:
		"wumpus":
			Globals.death_by_wumpus = true
		"pitfall":
			Globals.death_by_pitfall = true
		"bullet":
			Globals.death_by_ricochet = true
		"defenseless":
			Globals.death_by_defenseless = true
	Globals.unpause()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	
func wumpus_wakes():
	#If the player doesn't hit anything with a shot the wumpus may wake up or
	#remain in the same room
	var new_wumpus_room
	var wumpus_wake_chance = randi_range(0,4)
	match wumpus_wake_chance:
		1, 2, 3:
			new_wumpus_room = rooms.get(threat_rooms.find_key("wumpus"))
			new_wumpus_room.shuffle()
			woke_wumpus.emit()
			threat_rooms.erase(threat_rooms.find_key("wumpus"))
			threat_rooms[new_wumpus_room[0]] = "wumpus"
			check_for_threats()
		_: 
			pass

func win_the_game():
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
