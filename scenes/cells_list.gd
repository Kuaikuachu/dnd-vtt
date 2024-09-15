extends Node

signal cell_list_ready

@export var scenes : Array[PackedScene]

var scenes_dict : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	write_scenes_to_dict()
	Globals.celist_node = self

func write_scenes_to_dict() -> void:
	var i : int = 0
	for scene in scenes:
		var temp = scene.instantiate()
		scenes_dict[temp.real_name] = scene
		temp.queue_free()
	_update_global_scenes()

func get_scene_from_string(string):
	return scenes_dict.get(string)

func _update_global_scenes():
	Globals.celist = scenes_dict
