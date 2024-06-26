extends Node

var actions := 0
var death_by_wumpus := false
var death_by_pitfall := false
var death_by_ricochet := false
var death_by_defenseless := false

func pause():
	get_tree().paused = true
	
func unpause():
	get_tree().paused = false
