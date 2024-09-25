extends Node

@export var grid_horizontal : int = 20
@export var grid_vertical : int = 10
@export var grid_y_height : float = 0.01

@export var grid : Node3D

var top_left : Vector2 = Vector2.ZERO

var grid_dict : Dictionary = {}


func _ready() -> void:
	Globals.gridman = self
	
	top_left = Vector2(grid_horizontal / 2, grid_vertical / 2)
	
	if grid_horizontal % 2 == 1:
		top_left += Vector2(0.5,0)
	if grid_vertical % 2 == 1:
		top_left += Vector2(0,0.5)


func get_cell_real_position(pos : Vector2i) -> Vector3:
	if pos.x < 0: 
		pos.x = 0
	elif pos.x > grid_horizontal - 1:
		pos.x = grid_horizontal - 1
	if pos.y < 0:
		pos.y = 0 
	elif pos.y > grid_vertical - 1:
		pos.y = grid_vertical - 1
	
	var cell_real_pos : Vector3 = Vector3(top_left.x - pos.x - 0.5, grid_y_height, top_left.y - pos.y - 0.5)
	return cell_real_pos

func get_cell_from_real_position(pos : Vector3) -> Vector2i:
	var x_grid
	var y_grid
	
	x_grid = coord_to_cell_transition(pos.x, true)
	y_grid = coord_to_cell_transition(pos.z, false)
	
	return Vector2i(x_grid,y_grid)

func coord_to_cell_transition(coord : float, horizontal : bool) -> int:
	var cell_coord : int
	if coord > 0:
		cell_coord = ceil(coord)
	else:
		cell_coord = floor(coord + 1)
	if horizontal:
		cell_coord = -(cell_coord - grid_horizontal / 2)
	else:
		cell_coord = -(cell_coord - grid_vertical / 2)
	return cell_coord

@rpc("call_local", "any_peer")
func create_object(object_id, pos):
	var object
	print("obj_id ",object_id)
	if object_id is PackedScene:
		object = object_id
		print("packed scene")
	else:
		print("scene from string VVV")
		object = Globals.celist_node.get_scene_from_string(object_id)
	print("obj ",object)
	var new_obj = object.instantiate()
	print("new obj ",new_obj.name)
	#print("name to texture ", Globals.celist_node.name_to_texture)
	if new_obj is TextureTerrain or new_obj is TextureToken:
		new_obj.apply_mat(Globals.celist_node.name_to_texture[object_id])
		
	write_to_dict(new_obj, pos)
	grid.add_child(new_obj)
	new_obj.move_cell(pos)
	if new_obj is TableObject:
		new_obj.init_done()



func write_to_dict(object : Node3D, pos : Vector3):
	if grid_dict.erase(object):
		if Globals.debug_mode:
			#print("object existed, deleted and written again")
			pass
	else:
		if Globals.debug_mode:
			#print("object didnt exist, writing")
			pass
	grid_dict[object] = pos
