extends Node3D

var last_transform

var extra_transform

func _ready():
	## REMEMBER EDITOR TRANSFORM
	extra_transform = transform

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority() or last_transform == Globals.player.camera.global_transform:
		return
	
	
	last_transform = Globals.player.camera.global_transform
	global_transform = last_transform * extra_transform
	#sync_pos.rpc(global_transform)
	Globals.multiplayer_man.sync_player_model.rpc(int(str(Globals.player.name)),global_transform)


@rpc("call_local","any_peer","unreliable")
func sync_pos(transf):
	global_transform = transf
