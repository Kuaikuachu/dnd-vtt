extends Node2D

var gridman : Node
@onready var x_box = $VBoxContainer/HBoxContainer/VBoxContainer/XBox
@onready var y_box = $VBoxContainer/HBoxContainer/VBoxContainer2/YBox
@onready var scene_list: ItemList = $VBoxContainer/ItemList
@onready var build_mode_check: CheckBox = $VBoxContainer/CheckBox

var selected_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.cell_debug = self

func write_scenes_to_list():
	for string in Globals.celist:
		scene_list.add_item(string)

func _on_arrange_button_pressed() -> void:
	gridman.create_object.rpc(Globals.celist.find_key(selected_scene), Vector3(x_box.value, 0, y_box.value))


func _on_main_ready() -> void:
	gridman = Globals.main.table.gridman

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	selected_scene = Globals.celist_node.get_scene_from_string(scene_list.get_item_text(index))
