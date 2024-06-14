extends Node2D

@onready var illegal_action_label = $IllegalActionLabel
@onready var no_threats_label = $NoThreatsLabel
@onready var wumpus_threat_label = $WumpusThreatLabel
@onready var pitfall_threat_label = $PitfallThreatLabel
@onready var sinkhole_threat_label = $SinkholeThreatLabel
@onready var room_number_label = $RoomNumberLabel
@onready var game_manager = $"../GameManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager.updated_room_number.connect(_update_room_label)
	game_manager.invalid_room.connect(_invalid_room)
	game_manager.checked_threats.connect(_update_threats_label)
	illegal_action_label.text = ""
	#sinkhole_threat_label.text == ""
	#wumpus_threat_label.text == ""
	#pitfall_threat_label.text == ""
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _update_threats_label(threat):
	
	if threat == "sinkhole":
		sinkhole_threat_label.text = "You feel the earth shift."
	if threat == "pitfall":
		pitfall_threat_label.text = "You feel a rush of cold wind."
	if threat == "wumpus":
		wumpus_threat_label.text = "You feel a frightening presence nearby."
	else:
		no_threats_label.text = "You feel safe. For now."
		pass

func _update_room_label(player_pos):
	room_number_label.text = "Room Number: " + str(player_pos)
	_invalid_room("")

func _invalid_room(warning):
	if warning == "same room":
		illegal_action_label.text = "You're already in this room."
	elif warning == "too far":
		illegal_action_label.text = "You can't phase through walls."
	else:
		illegal_action_label.text = ""
