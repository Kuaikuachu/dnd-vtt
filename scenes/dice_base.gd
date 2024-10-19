extends TableObject
class_name Dice

@export var correction_modifier : float = 15

@export var lin_speed_limit : float = 10
@export var ang_speed_limit : float = 30

@onready var sides: Node3D = $Sides

@onready var authority_timeout: Timer = $AuthorityTimeout

var up_for_calc : bool = false

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready():
	print("created ", name, " on client ", multiplayer.get_unique_id())
	super()
	#set_multiplayer_authority(1)
	#multiplayer_synchronizer.set_multiplayer_authority(1)
	#rpc_multiplayer_authority.rpc(1)
	
	var rand_x = randi_range(-180, 180)
	var rand_y = randi_range(-180, 180)
	var rand_z = randi_range(-180, 180)
	
	self.rotation = Vector3(rand_x, rand_y, rand_z)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority() and not Globals.player.name == "Player" and not Globals.player.name == "1":
		self.freeze = true
		if self.sleeping:
			set_physics_process(false)
		return
	
	if self.angular_velocity.length() + self.linear_velocity.length() < 0.3 and not held:
		calc_up_side()
	else:
		authority_timeout.start()
	
	if held and !self.sleeping:
		#print("supposed to be moving to desired")
		var vel = correction_modifier * global_position.direction_to(desired_position) * global_position.distance_to(desired_position)
		var to_desired = global_position.distance_to(desired_position)
		self.linear_velocity = vel
		if to_desired > 0.5:
			self.angular_velocity = 2 * vel.rotated(Vector3(0,1,0), 90)
		else:
			self.angular_velocity = self.angular_velocity * 0.95


@rpc("call_local","any_peer","reliable")
func roll():
	print("roll()")
	if not is_multiplayer_authority() and not Globals.player.name == "Player":
		return
	
	var lin_r : int = 900
	var random_linear = randi_range(lin_r, lin_r*1.3)
	
	var an_r : int = 150
	var random_angular = Vector3(randi_range(-an_r, an_r),randi_range(-an_r, an_r),randi_range(-an_r, an_r))
	
	var misc_r : int = 100
	var random_misc_1 = randi_range(-misc_r, misc_r)
	var random_misc_2 = randi_range(-misc_r, misc_r)
	
	
	self.call("apply_central_force", Vector3(random_misc_1,random_linear,random_misc_2))
	self.call("apply_torque", random_angular)


func calc_up_side():
	var highest_marker : Marker3D 
	for i in sides.get_children():
		if !highest_marker:
			highest_marker = i
		elif highest_marker.global_position.y < i.global_position.y:
			highest_marker = i
	return highest_marker.name


func start_held(id):
	print(id)
	rpc_multiplayer_authority.rpc(int(str(id)))
	
	held = true
	hide_collisions()
	
	set_physics_process(true)
	
	self.freeze = false
	self.sleeping = false
	
	up_for_calc = true

func _on_stop_held():
	held = false
	return_collisions()
	#print("before", linear_velocity)
	if self.linear_velocity.length() > lin_speed_limit:
		self.linear_velocity = self.linear_velocity.normalized() * lin_speed_limit
	if self.angular_velocity.length() > ang_speed_limit:
		self.angular_velocity = self.angular_velocity.normalized() * ang_speed_limit
	
	
func _on_sleeping_state_changed() -> void:
	if !up_for_calc:
		return
	if self.angular_velocity.length() < 0.1 and self.linear_velocity.length() < 0.1 and not held:
		self.sleeping = true
		print("rolled ", calc_up_side())
		self.freeze = false
		
		up_for_calc = false


func _on_authority_timeout_timeout() -> void:
	print("clearing authority")
	rpc_multiplayer_authority.rpc(1)
