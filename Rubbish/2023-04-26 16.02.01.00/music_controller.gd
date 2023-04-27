extends Node

const TRANSITION_SPEED = 2.0
var phase = 0
var rng = RandomNumberGenerator.new()

@onready var music: Array = get_children()
var playing: String = "Intro"

func _ready():
	rng.randomize()


func _process(delta):
	if phase == 1:
		if not $Transition.playing:
			playing_intro = false
			set_volume("Intro", 0.0)
			phase = 2
			
	if phase == 2:
		if get_volume("Team11") < 1.0:
			change_volume("Team11", TRANSITION_SPEED*delta)
			set_volume("Team2", 1-get_volume("Team11"))
			
		if !($Team11.playing or $Team12.playing or $Team13.playing):
			var temp = rng.randi()%3
			get_node(NodePath("Team1" + str(temp + 1))).play()
		
	if phase == 3:
		if get_volume("Team2") < 1.0:
			change_volume("Team2", TRANSITION_SPEED*delta)
			set_volume("Team11", 1-get_volume("Team11"))
			set_volume("Team12", 1-get_volume("Team12"))
			set_volume("Team13", 1-get_volume("Team13"))
	
	if phase == 4:
		if get_volume("TeamAlt") < 1.0:
			change_volume("TeamAlt", TRANSITION_SPEED*delta)
			set_volume("Team2", 1-get_volume("Team13"))
			set_volume("Team11", 1-get_volume("Team11"))
			set_volume("Team12", 1-get_volume("Team12"))
			set_volume("Team13", 1-get_volume("Team13"))
	elif get_volume("TeamAlt") > 0.0: 
		change_volume("TeamAlt", -TRANSITION_SPEED*delta)
		
			
			
#	if get_volume(playing) < 1.0:
#		change_volume(playing, TRANSITION_SPEED*delta)
#
#	for track in music:
#		if track.name != playing and get_volume(track.name) != 0.0:
#			change_volume(track.name, -TRANSITION_SPEED*delta)
		

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
	var temp: NodePath = NodePath(input)
	var index = music.find(get_node(temp))
	if index != -1:
		return music[index]
	else:
		print(input, "   ", music)
		print("Music index not found!")


# specialized functions, don't copy
func reset():
	rng.randomize()
	$Transition.loop = true


var playing_intro: bool = false
func play_intro():
	$Transition.loop = false
	phase = 1
	set_volume(get_node("Transition"), 1.0)
	
func switch_team():
	if phase == 2: phase = 3
	else: phase = 2

func drop():
	phase = 4
	
