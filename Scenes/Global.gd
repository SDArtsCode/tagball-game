extends Node2D

var first_time = true
var last_picked = -1

var main: Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var map_selection: Array = ["Testmap"]
var curr_map: String


func _ready():
	await get_tree().create_timer(0.01).timeout
	reset_game()

func reset_game():
	rng.randomize()
	first_time = true
	last_picked = -1
	MusicController.reset()
	curr_map = map_selection[rng.randi_range(0, map_selection.size()-1)]
	#main.add_child(load("res://Maps/" + str(curr_map) + ".tscn").instantiate())
	
	
