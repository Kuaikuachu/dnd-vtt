extends Node3D
class_name TableObject

@onready var gridman = Globals.main.table.gridman

@onready var model: Node3D = $Model

@export var real_name : String

@export var y_offset : float = 0.0

@export var by_grid : bool = false

var grid_position : Vector2i

var selected : bool = false
var held : bool = false


func init_done():
	pass


@rpc("call_local","any_peer", "reliable")
func move_cell(pos):
	if by_grid:
		grid_position = gridman.get_cell_from_real_position(pos)
		update_pos.rpc()
	else:
		Globals.gridman.write_to_dict(self, pos)
		global_position = pos


@rpc("call_local","any_peer", "reliable")
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
