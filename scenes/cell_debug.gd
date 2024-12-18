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
	var filter_array : Array = ["2DTextureTerrain", "2DTextureToken"]
	for string in Globals.celist:
		if filter_array.has(string):
			continue
		scene_list.add_item(string)

func _on_arrange_button_pressed() -> void:
	gridman.create_object.rpc(Globals.celist.find_key(selected_scene), Vector3(x_box.value, 0, y_box.value))


func _on_main_ready() -> void:
	gridman = Globals.main.table.gridman

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	selected_scene = Globals.celist_node.get_scene_from_string(scene_list.get_item_text(index))


func _on_check_box_toggled(toggled_on: bool) -> void:
	if Globals.main.cell_visual:			
		Globals.main.cell_visual.visible = toggled_on
