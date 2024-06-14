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
var threat
var random_room = rooms.keys()
@onready var threat_label = $"../GUI/ThreatLabel"
#@onready var default_cave = $"."
var test_room = "res://room_number.tscn"

signal checked_threats(threat)
signal updated_room_number(player_pos)
signal invalid_room(warning)

func _init():
	populate_cave()
	
	
func _ready():
	check_for_threats()
	print(threat_rooms)
	updated_room_number.emit(player_pos)
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
	print("The player is in room " + str(player_pos))
	
func _check_valid_room(room_number, check_input):
	#check player input
	for i in rooms.get(room_number):
		#print("You clicked on :" + str(room_number))
		#print("This room has the following exits :" + str(rooms.get(room_number)))
		#print(i)
		#print("Player is in room :" + str(player_pos))
		if room_number == player_pos:
			#print("You're already in this room.")
			invalid_room.emit("same room")
			break
		elif i == player_pos:
			#this is a legal space, now check for input
			if check_input == "shoot":
				shoot(room_number)
				break
			elif check_input == "move":
				move(room_number)
				break
		else: 
			#print("Illegal Move")
			invalid_room.emit("too far")
			
			
func shoot(room_number):
	pass

func move(room_number):
	player_pos = room_number
	#print("You moved to :" + str(player_pos))
	updated_room_number.emit(player_pos)
	check_for_threats()

func check_for_threats():
	for i in rooms.get(player_pos):
		for j in threats:
			#print(i)
			#print(j)
			if threat_rooms.get(i) == j:
				checked_threats.emit(str(j))
				print(j)
			else:
				checked_threats.emit("")
				#continue
	#Check adjacent rooms for threats
	##print(rooms.get(player_pos))
	#for i in rooms.get(player_pos):
		#print(i)
		#print(threat_rooms.get(i))
		##print("threat rooms: " + str(threat_rooms.get(i)))
		##print("list of threats: " + str(threats))
		#if str(threat_rooms.has(i)):
			##checked_threats.emit(str(i))
			#print("FOUND THREAT: " + str(threat_rooms.has(i)))
			#print(i)
		#else:
			#print("no threat")
		##
		##if threat_rooms.find_key(rooms.get(player_pos)):
			##print("Threat found")
		##print("Print i " + str(i))
		##print("Print rooms adjacent to player: " + str(rooms.get(player_pos)))
		##if threats == threat_rooms.get(i):
			##print("Threat found")
		##print("Print threat rooms " + str(threat_rooms))
		##if threat_rooms.get(i) == threats:
			##print("Threat!")
	##checked_threats.emit("")	
	pass
