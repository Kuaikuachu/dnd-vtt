extends Node3D

@export var gridman : Node
@export var grid : Node3D

@onready var multiplayer_spawner: MultiplayerSpawner = $Grid/MultiplayerSpawner

func _ready() -> void:
	multiplayer_spawner.set_multiplayer_authority(1)
	
	
	for i in Globals.celist:
		var packedscene = Globals.celist_node.get_scene_from_string(i)
		multiplayer_spawner.add_spawnable_scene(packedscene.get_path())
	var count = multiplayer_spawner.get_spawnable_scene_count()
	for i in count:
		print(multiplayer_spawner.get_spawnable_scene(i))
