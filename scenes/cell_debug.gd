extends Node2D

var gridman : Node
@onready var x_box = $VBoxContainer/HBoxContainer/VBoxContainer/XBox
@onready var y_box = $VBoxContainer/HBoxContainer/VBoxContainer2/YBox
@onready var scene_list: ItemList = $VBoxContainer/ItemList

@export var scenes : Array[PackedScene]

var selected_scene : PackedScene

var scenes_dict : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.cell_debug = self
	if !Globals.debug_mode:
		queue_free()
	write_scenes_to_dict()
	write_scenes_to_list()

func write_scenes_to_dict() -> void:
	var i : int = 0
	for scene in scenes:
		var temp = scene.instantiate()
		scenes_dict[temp.real_name] = scene
		temp.queue_free()

func get_scene_from_string(string):
	return scenes_dict.get(string)

func write_scenes_to_list():
	for string in scenes_dict:
		scene_list.add_item(string)

func _on_arrange_button_pressed() -> void:
	gridman.create_object.rpc(scenes_dict.find_key(selected_scene), Vector3(x_box.value, 0, y_box.value))


func _on_main_ready() -> void:
	gridman = Globals.main.table.gridman

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	selected_scene = get_scene_from_string(scene_list.get_item_text(index))
