extends Node3D
class_name TableObject

@onready var gridman = Globals.main.table.gridman

@onready var model: Node3D = $Model

@export var real_name : String

@export var y_offset : float = 0.0

@export var by_grid : bool = false

var desired_position : Vector3 = Vector3.ZERO

var grid_position : Vector2i

var selected : bool = false
var held : bool = false

func init_done():
	pass

func _ready():
	rpc_multiplayer_authority.rpc(1)

func hide_collisions():
	if self is Dice:
		self.call_deferred("set_collision_layer_value", 3, false)
	for i in get_children():
		if i is StaticBody3D:
			i.set_collision_layer_value(1, false)


func return_collisions():
	if self is Dice:
		self.call_deferred("set_collision_layer_value", 3, true)
	for i in get_children():
		if i is StaticBody3D:
			i.set_collision_layer_value(1, true)


func start_held(id):
	print(id)
	rpc_multiplayer_authority.rpc(int(str(id)))
	
	held = true
	hide_collisions()
	
	set_physics_process(true)


func clicked():
	selected = !selected


func on_held(pos):
	if held:
		print("on_held")
		desired_position = Vector3(pos.x, pos.y + y_offset, pos.z)
		if !(self is Dice):
			global_position = desired_position


func _on_stop_held():
	held = false
	return_collisions()
	
	if by_grid:
		pass


@rpc("call_local","any_peer","reliable")
func self_destruct():
	Globals.gridman.grid_dict.erase(self)
	queue_free()


@rpc("call_local","any_peer","reliable")
func rpc_multiplayer_authority(id):
	set_multiplayer_authority(id)

@rpc("call_local", "any_peer", "reliable")
func move_cell(pos):
	if by_grid:
		var new_grid_pos = gridman.get_cell_from_real_position(pos)
		global_position = gridman.get_cell_real_position(new_grid_pos)
	else:
		global_position = pos
