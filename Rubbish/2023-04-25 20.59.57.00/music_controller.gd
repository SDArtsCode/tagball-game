extends Node

const TRANSITION_SPEED = 2.0

var music: Array = get_children()
var playing = "Intro"

func _process(delta):
	if get_volume(playing) < 1.0:
		set_volume(playing, get_volume(playing) + TRANSITION_SPEED*delta)
		




func get_volume(input):
	return db_to_linear(find(input).volume_db)

func set_volume(song, volume):
	if volume <= 1.0:
		find(song).volume_db = linear_to_db(volume)
	else:
		print("Volume over limit, not changing!")

func find(input):
	var index = music.find(input)
	if index != -1:
		return music[index]
	else:
		print("Music index not found!")