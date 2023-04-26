extends Node

const TRANSITION_SPEED = 2.0

@onready var music: Array = get_children()
var playing = "Intro"

func _ready():
	music = get_children()

func _process(delta):
	var a: NodePath = playing
	if get_volume(get_node(a)) < 1.0:
		print(music, "a")
		change_volume(get_node(playing), TRANSITION_SPEED*delta)
	
	for track in music:
		if track.name != playing and get_volume(track) != 0.0:
			change_volume(track, -TRANSITION_SPEED*delta)
		

func play(song):
	playing = song

func change_volume(song, change):
	set_volume(song, get_volume(song) + change)

func get_volume(input):
	return db_to_linear(find(input).volume_db)

func set_volume(song, volume):
	volume = clamp(volume, 0.0, 1.0)
	find(song).volume_db = linear_to_db(volume)

func find(input):
	var index = music.find(input)
	if index != -1:
		return music[index]
	else:
		print(input, "   ", music)
		print("Music index not found!")

var i = 0
func _input(event):
	if event.is_action_pressed("debug"):
		playing = music[i].name
		i+=1
