extends TableObject
class_name TerrainObject

func _on_stop_held():
	held = false
	var new_grid_pos = gridman.get_cell_from_real_position(global_position)
	grid_position = new_grid_pos
	gridman.write_to_dict(self, global_position)
