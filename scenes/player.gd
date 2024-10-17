extends Node3D

@onready var left_click_timer: Timer = $LeftClickTimer
@onready var right_click_timer: Timer = $RightClickTimer

@onready var move_point_y : Node3D = self
@onready var move_point_x : Node3D = move_point_y.get_child(0)
@onready var camera_mount : Node3D = move_point_x.get_child(0)
@onready var camera : Camera3D = camera_mount.get_child(0)

@onready var obj_select: Node2D = $"../../Interface/obj_select"

var gridman

var mouse = Vector2()

var current_collision_mask : int = 1

# pow(2, *layer-to-be-enabled* - 1)
var normal_collision_mask : int = 1
var drag_plane_collision_mask : int = 3

var held_object : Node3D
var selected_object : Node3D

var movement_enabled : bool = false
var build_mode : bool = false

var top_view : bool = false

var sensitivity : float = 0.01

@export var camera_speed : float = 0.1

var camera_speed_relative : float = camera_speed

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("click"):
		#click()
		#
	#if event.is_action_released("click"):
		#stop_click()
	#
	#if event.is_action_pressed("right_click"):
		#right_click()
	#
	#if event.is_action_released("right_click"):
		#stop_right_click()
	#
	#if event.is_action_pressed("zoom_in"):
		#zoom_in()
	#
	#if event.is_action_pressed("zoom_out"):
		#zoom_out()
	#
	#if event.is_action_pressed("top_view"):
		#if camera.projection == camera.PROJECTION_PERSPECTIVE:
			#camera.projection = camera.PROJECTION_ORTHOGONAL
		#else:
			#camera.projection = camera.PROJECTION_PERSPECTIVE
		#top_view = !top_view
		#move_point_x.rotation = Vector3(-(PI/2), 0, 0)
		#pass
	#
	#if event.is_action_pressed("build_mode"):
		#$"../../../../../VBoxContainer/Button".grab_focus()
		#build_mode = true
		#Globals.cell_debug.build_mode_check.button_pressed = build_mode
		#release_held_object()
	#if event.is_action_released("build_mode"):
		#build_mode = false
		#Globals.cell_debug.build_mode_check.button_pressed = build_mode


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		click()
		
	if event.is_action_released("click"):
		stop_click()
	
	if event.is_action_pressed("right_click"):
		right_click()
	
	if event.is_action_released("right_click"):
		stop_right_click()
	
	if event.is_action_pressed("zoom_in"):
		zoom_in()
	
	if event.is_action_pressed("zoom_out"):
		zoom_out()
	
	if event.is_action_pressed("top_view"):
		if camera.projection == camera.PROJECTION_PERSPECTIVE:
			camera.projection = camera.PROJECTION_ORTHOGONAL
		else:
			camera.projection = camera.PROJECTION_PERSPECTIVE
		top_view = !top_view
		move_point_x.rotation = Vector3(-(PI/2), 0, 0)
		pass
	
	if event.is_action_pressed("build_mode"):
		%FocusGrabber.grab_focus()
		build_mode = true
		Globals.cell_debug.build_mode_check.button_pressed = build_mode
		release_held_object()
		obj_select.unselect()
	if event.is_action_released("build_mode"):
		build_mode = false
		Globals.cell_debug.build_mode_check.button_pressed = build_mode

	if movement_enabled and event is InputEventMouseMotion:
		move_point_y.rotate_y(-event.relative.x * sensitivity)
		move_point_x.rotate_x(-event.relative.y * sensitivity)
	if top_view:
		move_point_x.rotation.x = -(PI/2)

func click():
	var raycast = shoot_ray()
	if !raycast.is_empty():
		selected_object = raycast.collider.get_parent()
		#print("selected object ", selected_object, " collider ", raycast.collider)
	if !build_mode:
		left_click_timer.start()


func release_held_object():
	print("release_held_object()")
	if held_object:
		held_object._on_stop_held()
		selected_object = null
		held_object = null


func hold_left():
	print("hold()")
	if build_mode:
		release_held_object()
		return
	obj_select.unselect()
	current_collision_mask = drag_plane_collision_mask
	held_object = selected_object
	
	if held_object is TableObject:
		held_object.start_held(multiplayer.get_unique_id())
	else:
		held_object = null
		current_collision_mask = normal_collision_mask
		

func stop_click():
	print("stop_click()")
	if build_mode:
		create_object_at_mouse(Globals.celist.find_key(Globals.cell_debug.selected_scene))
		return
	
	var raycast = shoot_ray(normal_collision_mask)
	left_click_timer.stop()
	obj_select.unselect()
	
	if held_object:
		## PUT ON_HOLD_STOP STUFF HERE 
		held_object.return_collisions()
		held_object._on_stop_held()
		
		if raycast.is_empty():
			return
		
		var pos = raycast["position"]
		if held_object is TableObject and not held_object is Dice:
			held_object.move_cell.rpc(pos)
		
		selected_object = null
		held_object = null
	
	current_collision_mask = normal_collision_mask


func right_click():
	right_click_timer.start()


func stop_right_click():
	right_click_timer.stop()
	if movement_enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		movement_enabled = false
		return
		
	if build_mode:
		delete_object_on_cursor()
		selected_object = null
		obj_select.unselect()
		return
	
	var raycast = shoot_ray(normal_collision_mask)
	if !raycast.is_empty():
		selected_object = raycast.collider.get_parent()
		
		obj_select.select(selected_object)
		
		#print("right clicked object ", selected_object, " collider ", raycast.collider)
	else:
		obj_select.unselect()


func hold_right():
	print("hold_right()")
	right_click_timer.stop()
	if !movement_enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		movement_enabled = true

func delete_object_on_cursor():
	var raycast = shoot_ray(normal_collision_mask)
	
	if !raycast.is_empty():
		if raycast.collider is TableObject or Dice:
			raycast.collider.get_parent().self_destruct.rpc()


func zoom_in():
	if camera_mount.position.distance_to(move_point_x.position) > 2:
		camera_mount.global_position += 0.1 * camera_mount.position.distance_to(move_point_x.position) * camera_mount.global_position.direction_to(move_point_x.global_position)
	else:
		pass


func zoom_out():
	if camera_mount.position.distance_to(move_point_x.position) < 50:
		camera_mount.global_position += -0.1 * camera_mount.position.distance_to(move_point_x.position) * camera_mount.global_position.direction_to(move_point_x.global_position)


func _physics_process(delta: float) -> void:
	#print("held object - ",held_object, "selected object - ", selected_object)
	
	if camera.projection == camera.PROJECTION_ORTHOGONAL:
		var zoom = camera_mount.position.distance_to(move_point_x.position)
		camera.size = zoom * 2
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var vertical_dir = Input.get_axis("down", "up")
		
	var direction : Vector3 = (move_point_y.transform.basis * Vector3(input_dir.x, vertical_dir, input_dir.y)).normalized()
	if movement_enabled:
		if direction:
			camera_speed_relative = camera_speed * camera_mount.position.distance_to(move_point_x.position)
			move_point_y.position += direction * camera_speed_relative

	## MANIPULATOR FANCY SHADER LOGIC
	#var raypulator = shoot_ray(drag_plane_collision_mask)
	#if !raypulator.is_empty():
		#Globals.main.cell_visual._set_manipulator_pos(raypulator["position"].x, raypulator["position"].z)
	
	
	## ON HOLD STUFF HERE
	if held_object:
		var raycast = shoot_ray()
		if !raycast.is_empty():
			if held_object is TableObject:
				#print("is table object")
				held_object.on_held(raycast["position"])
				pass


func _process(delta: float) -> void:
	## MANIPULATOR FANCY SHADER LOGIC
	var raypulator = shoot_ray(drag_plane_collision_mask - normal_collision_mask)
	if !raypulator.is_empty() and Globals.main.cell_visual:
		Globals.main.cell_visual._set_manipulator_pos(raypulator["position"].x, raypulator["position"].z)


func shoot_ray(mask = current_collision_mask):
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = mask
	
	var raycast_result = space.intersect_ray(ray_query)
	return raycast_result


func create_object_at_mouse(object_id):
	print(object_id)
	var raycast = shoot_ray(drag_plane_collision_mask)
	if not object_id or raycast.is_empty():
		return
	gridman.create_object.rpc(object_id, raycast["position"])


func _on_main_ready() -> void:
	gridman = Globals.gridman


func _ready() -> void:
	Globals.player = self


func _on_left_click_timer_timeout() -> void:
	hold_left()


func _on_right_click_timer_timeout() -> void:
	hold_right()
