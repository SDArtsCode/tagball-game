extends Node2D


# Called when the node enters the scene tree for the first time.
var maps = {
	"tagball_arena" : preload("res://Maps/Testmap.tscn")
}
# @export_group(String) var map_name = ""
func _ready():
	Global.main = self
	scale.x = DisplayServer.window_get_size().x/1920.0
	scale.y = DisplayServer.window_get_size().y/1152.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
