extends Node

#This script contains global logic that should be accessible by all scripts

var actions := 0
var death_by_wumpus := false
var death_by_pitfall := false
var death_by_ricochet := false
var death_by_defenseless := false

#For game feel purposes, I needed a way to turn off player input. I'm sure there are more
#efficient ways to check for this process but for the limited scope of this project temporarily pausing
#the game does the job
func pause():
	get_tree().paused = true
	
func unpause():
	get_tree().paused = false
