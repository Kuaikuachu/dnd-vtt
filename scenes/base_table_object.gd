extends Node3D
class_name TableObject

@onready var gridman = Globals.main.table.gridman

@onready var model: Node3D = $Model

@export var real_name : String

@export var y_offset : float = 0.0

var grid_position : Vector2i

var selected : bool = false
var held : bool = false

@rpc("call_local","any_peer")
func move_cell(pos):
	grid_position = gridman.get_cell_from_real_position(pos)
	update_pos.rpc()

@rpc("call_local","any_peer")
func update_pos():
	global_position = gridman.get_cell_real_position(grid_position)

func hide_collisions():
	for i in get_children():
		if i is StaticBody3D:
			i.set_collision_layer_value(1, false)

func return_collisions():
	for i in get_children():
		if i is StaticBody3D:
			i.set_collision_layer_value(1, true)

func start_held():
	held = true
	hide_collisions()

func clicked():
	selected = !selected


func on_held(pos):
	if held:
		global_position = Vector3(pos.x, pos.y + y_offset, pos.z)


@rpc("any_peer")
func update_multiplayer_pos(pos):
	global_position = pos


func _on_stop_held():
	held = false
