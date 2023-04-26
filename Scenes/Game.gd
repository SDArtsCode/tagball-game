extends Node2D


enum {
	START,
	PLAY,
	END
}

var state = START
const START_TIME : int = 3 
const PLAY_TIME : int = 120
@onready var label := $CanvasLayer/CenterContainer/Label
@onready var dim := $CanvasLayer/DimRect
@onready var count := $CanvasLayer/DimRect/CenterContainer2/Countdown
enum GAME_TYPE {
	ONE_V_ONE,
	TWO_V_TWO
}
@export var game_type : GAME_TYPE
var player := preload("res://Scenes/RigidPlayer.tscn")
@onready var spawn_points = [
	$SpawnPoints/S1.global_position,
	$SpawnPoints/S2.global_position,
	$SpawnPoints/S3.global_position,
	$SpawnPoints/S4.global_position
]
var green_players = [
	
]
var pink_players = [
	
]
var green_init_scorer : RigidBody2D = null
var pink_init_scorer : RigidBody2D = null
enum teams {
	GREEN,
	PINK
}
var winner_team : int = -1 

func add_player(team : int, id : int):
	var player_instance = player.instantiate()
	player_instance.team = team
	player_instance.id = id
	player_instance.global_position = spawn_points[id]
	player_instance.connect("max_ball_time_reached", Callable(self, "player_max_ball"))
	add_child(player_instance)
	if team == teams.GREEN:
		green_players.append(player_instance)
	else:
		pink_players.append(player_instance)

func end_play(winner_team : int):
	state = END
	winner_team = player.team
	travel_state()
	
func player_max_ball(player : RigidBody2D):
	if state != PLAY:
		return
	if game_type == GAME_TYPE.ONE_V_ONE:
		end_play(player.team)
	elif game_type == GAME_TYPE.TWO_V_TWO:
		if player.team == teams.GREEN:
			if !green_init_scorer:
				green_init_scorer = player
			else:
				end_play(player.team)
		else:
			if !pink_init_scorer:
				pink_init_scorer = player
			else:
				end_play(player.team)
	
func _ready():
	if game_type == GAME_TYPE.ONE_V_ONE:
		for i in range(0, 2):
			print(i)
			if i < 1:
				add_player(0, i)
			else:
				add_player(1, i)
	elif game_type == GAME_TYPE.TWO_V_TWO:
		for i in range(0, 4):
			if i < 2:
				add_player(0, i)
			else:
				add_player(1, i)
				
	state = START
	call_deferred("travel_state")

func _process(delta):
	if state == START:
		count.text = str(int($Timer.time_left) + 1)
	elif state == PLAY:
		label.text = str(int($Timer.time_left) + 1)
	elif state == END:
		pass
		
func travel_state():
	if state == START:
		dim.show()
		label.hide()
		$Timer.start(START_TIME)
	elif state == PLAY:
		label.show()
		dim.hide()
		$Timer.start(PLAY_TIME)
	elif state == END:
		dim.show()
		label.hide()
		count.text = "WINNER: " + str(teams.keys()[winner_team])
		
func _on_timer_timeout():
	if state == START:
		state = PLAY
		travel_state()
	elif state == PLAY:
		state = END
		travel_state()
