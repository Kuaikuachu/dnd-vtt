extends Node3D

var last_transform

var extra_transform

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@onready var hand: Node3D = $Hand

@onready var line: Node = $Line

func _ready():
	## REMEMBER EDITOR TRANSFORM
	extra_transform = transform
	visible = false
	hand.visible = false

func _physics_process(delta: float) -> void:
	if name != Globals.player.name:
		visible = true
		hand.visible = true
		set_physics_process(false)
	
	
	multiplayer_synchronizer.set_multiplayer_authority(int(str(name)))
	set_multiplayer_authority(int(str(name)))
	if !is_multiplayer_authority():
		return
	if last_transform != Globals.player.camera.global_transform:
		last_transform = Globals.player.camera.global_transform
		global_transform = last_transform * extra_transform
	
	if Globals.player.mouse_position:
		hand.top_level = true
		hand.global_position = Globals.player.mouse_position
		hand.rotation.y = rotation.y
