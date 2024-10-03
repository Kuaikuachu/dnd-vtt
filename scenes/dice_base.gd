extends RigidBody3D
class_name Dice

@export var real_name : String = ""

@export var correction_modifier : float = 15

@export var speed_limit : float = 10

@onready var model: Node3D = $Model

@onready var sides: Node3D = $Sides

@onready var authority_timeout: Timer = $AuthorityTimeout

var authority_player : String = ""

var up_for_calc : bool = false

var selected : bool = false
var held : bool = false

var desired_position : Vector3 = Vector3.ZERO

var bodies_interacted : Array

func _init():
	real_name = name


func _ready():
	var rand_x = randi_range(-180, 180)
	var rand_y = randi_range(-180, 180)
	var rand_z = randi_range(-180, 180)
	
	self.rotation = Vector3(rand_x, rand_y, rand_z)


func _physics_process(delta: float) -> void:
	if authority_player != "":
		set_multiplayer_authority(int(authority_player))
	
	## IF NOT AUTHORITY
	if authority_player != Globals.player.name and authority_player != "":
		freeze_unfreeze(true)
		return
	
	if self.angular_velocity.length() + self.linear_velocity.length() < 0.3 and not held:
		calc_up_side()
	else:
		authority_timeout.start()
	
	if held:
		var vel = correction_modifier * global_position.direction_to(desired_position) * global_position.distance_to(desired_position)
		var to_desired = global_position.distance_to(desired_position)
		linear_velocity = vel
		if to_desired > 0.5:
			angular_velocity = 2 * vel.rotated(Vector3(0,1,0), 90)
		else:
			angular_velocity = angular_velocity * 0.95
		#if global_position.distance_to(desired_position) > 0.5:
			#linear_velocity = global_position.direction_to(desired_position) * global_position.distance_to(desired_position)
		#else:
			#linear_velocity = linear_velocity * 0.5
	
	
	## IF SELF IS AUTHORITY
	#if authority_player == Globals.player.name:
		#print("authority is ", authority_player)
		#update_multiplayer_pos.rpc(get_global_transform())
	## SYNC FOR HOST IF NO ONE IS AUTHORITY
	#elif authority_player == "" and Globals.player.name == "1":
		#update_multiplayer_pos.rpc(get_global_transform())
		#freeze_unfreeze(false)
	## IF NOT SELF IS AUTHORITY


func freeze_unfreeze(boolean : bool):
	freeze = boolean


func calc_up_side():
	var highest_marker : Marker3D 
	for i in sides.get_children():
		if !highest_marker:
			highest_marker = i
		elif highest_marker.global_position.y < i.global_position.y:
			highest_marker = i
	return highest_marker.name


func start_held(id):
	freeze_unfreeze(false)
	up_for_calc = true
	hide_collisions()
	held = true
	set_authority_global.rpc(str(id))


func clicked():
	selected = !selected


func on_held(pos):
	var y_offset = 1.5
	if held:
		desired_position = Vector3(pos.x, pos.y + y_offset, pos.z)


@rpc("call_local","any_peer", "reliable")
func move_cell(pos):
	global_position = pos


func hide_collisions():
	self.set_collision_layer_value(3, false)
	for i in get_children():
		if i is StaticBody3D:
			i.set_collision_layer_value(1, false)


func return_collisions():
	self.set_collision_layer_value(3, true)
	for i in get_children():
		if i is StaticBody3D:
			i.set_collision_layer_value(1, true)


@rpc("any_peer", "call_remote", "reliable")
func update_multiplayer_pos(transf : Transform3D):
	self.global_transform = transf


func _on_stop_held():
	return_collisions()
	held = false
	#print("before", linear_velocity)
	if linear_velocity.length() > speed_limit:
		linear_velocity = linear_velocity.normalized() * speed_limit
	if angular_velocity.length() > speed_limit:
		angular_velocity = angular_velocity.normalized() * speed_limit
	#linear_velocity = linear_velocity.clamp(Vector3(-speed_limit,-speed_limit,-speed_limit), Vector3(speed_limit,speed_limit,speed_limit))
	#angular_velocity = angular_velocity.clamp(Vector3(-speed_limit,-speed_limit,-speed_limit) * 2, Vector3(speed_limit,speed_limit,speed_limit) * 2)
	#print("after ", linear_velocity)

func _on_sleeping_state_changed() -> void:
	if !up_for_calc:
		return
	if angular_velocity.length() < 0.1 and linear_velocity.length() < 0.1 and not held:
		sleeping = true
		print("rolled ", calc_up_side())
		print(Globals.player.name, " ", global_position)
		freeze_unfreeze(false)
		
		up_for_calc = false
		set_authority_global.rpc("")
		clear_interacted_authorities()


@rpc("call_local","any_peer","reliable")
func self_destruct():
	Globals.gridman.grid_dict.erase(self)
	queue_free()


@rpc("call_local","reliable","any_peer")
func set_authority_global(string : String = ""):
	authority_player = string


func _on_body_entered(body: Node) -> void:
	if body is Dice:
		bodies_interacted.append(body)
		body.set_authority_global.rpc(authority_player)


func clear_interacted_authorities():
	for body in bodies_interacted:
		if !is_instance_valid(body):
			continue
		body.set_authority_global.rpc("")
		bodies_interacted.clear()


func _on_authority_timeout_timeout() -> void:
	authority_player = ""
