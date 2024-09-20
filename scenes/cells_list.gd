extends Node

signal cell_list_ready

var custom_2d_terrain_dir : String

var cell_debug_loaded : bool = false
var customs_finished : bool = false

@export var scenes : Array[PackedScene]

var scenes_dict : Dictionary
var name_to_texture : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_custom_directories()
	
	
	write_scenes_to_dict()
	Globals.celist_node = self
	add_custom()


@rpc("any_peer", "call_local")
func sync_name_to_texture(dict):
	name_to_texture = dict

func add_custom_directories():
	var path : String = OS.get_executable_path().get_base_dir()
	print(path)
	var dir = DirAccess.open(path)
	if !dir.dir_exists("custom"):
		dir.make_dir("custom")
	dir.change_dir("custom")
	
	if !dir.dir_exists("2dterrain"):
		dir.make_dir("2dterrain")
	dir.change_dir("2dterrain")
	custom_2d_terrain_dir = dir.get_current_dir()


func write_scenes_to_dict() -> void:
	for scene in scenes:
		write_to_dict(scene)
	_update_global_scenes()


func write_to_dict(scene, custom_name : String = "") -> void:
	var temp = scene.instantiate()
	var f_name
	
	if custom_name.is_empty():
		f_name = temp.real_name
	else:
		f_name = custom_name
	scenes_dict[f_name] = scene
	
	temp.queue_free()


func get_scene_from_string(string):
	return scenes_dict.get(string)

func _update_global_scenes():
	Globals.celist = scenes_dict


func add_custom():
	var custom_terrain_list : Array[String] = []
	for t_name in DirAccess.get_files_at("res://custom/2dterrain"):
		if t_name.find(".import") == -1:
			custom_terrain_list.append(t_name)
	
	for t_name in DirAccess.get_files_at(custom_2d_terrain_dir):
		var complete_path = custom_2d_terrain_dir + "/" + t_name
		
		var image = Image.new()
		image.load(complete_path)
		
		var new_texture = ImageTexture.create_from_image(image)
		
		name_to_texture[t_name] = new_texture
	
		var terrain = scenes[0].instantiate()
		var scene = PackedScene.new()
		scene.pack(terrain)
		write_to_dict(scene, t_name)
	
	for t_name in custom_terrain_list.size():
		name_to_texture[custom_terrain_list[t_name]] = load("res://custom/2dterrain/" + custom_terrain_list[t_name])
		
		var terrain = scenes[0].instantiate()
		var scene = PackedScene.new()
		scene.pack(terrain)
		write_to_dict(scene, custom_terrain_list[t_name])
	
	if cell_debug_loaded:
		Globals.cell_debug.write_scenes_to_list()
	customs_finished = true


func _on_cell_debug_ready() -> void:
	if customs_finished:
		Globals.cell_debug.write_scenes_to_list()
	cell_debug_loaded = true
