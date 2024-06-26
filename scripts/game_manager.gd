extends Node2D

var rooms = {1: [2,5,8], 2: [1,3,10], 3: [2,4,12], 4: [3,5,14], 5:[1,4,6],
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
@export var starting_ammo : int
@export var ricochet : int
var current_ammo : int
var test_room = "res://room_number.tscn"
@onready var shotgun = $"../shotgun"

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

func _ready():
	Globals.death_by_wumpus = false
	Globals.death_by_pitfall = false
	Globals.death_by_ricochet = false
	Globals.death_by_defenseless = false
	Globals.actions = 0
	populate_cave()
	$"../DrawManager".recieve_dict(rooms)
	$"../DrawManager".update_player(player_pos)
	check_for_threats()
	current_ammo = starting_ammo
	print(threat_rooms)
	updated_room_number.emit(player_pos)
	updated_ammo.emit(current_ammo)
	var rooms: Array[Node] = get_tree().get_nodes_in_group("rooms")
	for room in rooms:
		room.checked_room_number.connect(_check_valid_room)
		
func populate_cave():
	#Iterate through list of threats, shuffle array of safe_rooms to get a random room, add that
	#threat to threat_rooms, remove the listed room from safe_rooms because it's no longer safe
	for threat_counter in threats:
		safe_rooms.shuffle()
		threat_rooms[safe_rooms[0]] = threat_counter
		print("Remove room " + str(safe_rooms[0]))
		safe_rooms.remove_at(0)
	#Remove all rooms 1-and-2-spaces away from Wumpus from list of safe rooms (the player should begin
	#within 3 spaces of the Wumpus
	safe_rooms.sort()
	var wumpus_room = threat_rooms.find_key("wumpus")
	var wumpus_threat_zone = []
	wumpus_threat_zone = rooms.get(wumpus_room)
	print("Wumpus is in room: " + str(wumpus_room))
	#Iterate through Wumpus threat zone to append second layer of adjacency
	for i in wumpus_threat_zone:
		print("Remove room " + str(i))
		safe_rooms.erase(i)
		for j in rooms.get(i):
			print("Remove room " + str(j))
			safe_rooms.erase(j)
	print(safe_rooms)
	#Finally place the player in a random safe room
	safe_rooms.shuffle()
	player_pos = safe_rooms[0]
	#check_for_threats()
	move(player_pos)

func _check_valid_room(room_number, check_input):
	#Check for type of input, move or shoot. The counter variable is used to trigger an invalid
	#room. If the loop cycles 3 or more times it means
	var counter = 0
	for i in rooms.get(room_number):
		print(rooms.get(room_number))
		counter += 1
		if room_number == player_pos:
			#print("You're already in this room.")
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
		elif counter >= 3: 
			print(i)
			invalid_room.emit("too far")
			
			
func shoot(room_number):
	shotgun.play()
	#create array of random random targets
	Globals.pause()
	var random_ricochet_target = rooms.get(room_number)
	$"../DrawManager".create_bullet()
	current_ammo -= 1
	updated_ammo.emit(current_ammo)
	updated_shot.emit(room_number)
	shot_into_room.emit(room_number)
	await get_tree().create_timer(1).timeout
	#for loop iterates up to ricochet value, default 5
	for ricochet_count in ricochet:
		#Check if room number has a threat
		print(room_number)
		if room_number == player_pos:
			dead("bullet")
			break
		match threat_rooms.get(room_number):
			"wumpus":
				win_the_game()
				break
			_:
				random_ricochet_target = rooms.get(room_number)
				random_ricochet_target.shuffle()
				room_number = random_ricochet_target[0]
				updated_ricochet_room.emit(random_ricochet_target)
				updated_shot.emit(room_number)
				await get_tree().create_timer(1).timeout
	if current_ammo <= 0:
		dead("defenseless")
	else:
		wumpus_wakes()
	Globals.unpause()
	$"../DrawManager".clear_bullet()
	
func move(room_number):
	#get_tree().paused = true
	Globals.pause()
	player_pos = room_number
	await get_tree().create_timer(.5).timeout
	#get_tree().paused = false
	Globals.unpause()
	updated_room_number.emit(player_pos)
	check_for_threats()
	updated_player.emit(player_pos)
	draw_rooms.emit(player_pos, rooms.get(player_pos))
	
func _cleared_threats():
	cleared_threats.emit()

func check_for_threats():
	_cleared_threats()
	print("Print threat rooms key " + str(threat_rooms.get(player_pos)))
	match threat_rooms.get(player_pos):
		"sinkhole":
			random_room.shuffle()
			move(random_room[0])
			invalid_room.emit("sinkhole")
			#print a message
		"pitfall":
			dead("pitfall")
		"wumpus":
			dead("wumpus")
			
	for i in rooms.get(player_pos):
		for j in threats:
			if threat_rooms.get(i) == j:
				checked_threats.emit(str(j))
				
func dead(killed_by):
	match killed_by:
		"wumpus":
			Globals.death_by_wumpus = true
		"pitfall":
			Globals.death_by_pitfall = true
		"bullet":
			Globals.death_by_ricochet = true
		"defenseless":
			Globals.death_by_defenseless = true
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	
func wumpus_wakes():
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
