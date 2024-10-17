extends Node2D

var gridman : Node
var cell_debug : Node

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

const PLAYER_MODEL = preload("res://scenes/player_model.tscn")

var players_models : Dictionary = {}


func _ready() -> void:
	Globals.multiplayer_man = self
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_host_pressed():
	peer.create_server(int($VBoxContainer/HBoxContainer/LineEdit.text))
	multiplayer.multiplayer_peer = peer
	Globals.player.name = str(multiplayer.get_unique_id())
	Globals.player.set_multiplayer_authority(multiplayer.get_unique_id())
	print(Globals.player.name, " is hosting")
	
	#var new_model = create_player_model(1)
	#new_model.visible = false
	#get_parent().add_child(new_model)
	#write_models_dict(1, new_model)

func _on_join_pressed():
	peer.create_client($VBoxContainer/HBoxContainer2/LineEdit2.text, int($VBoxContainer/HBoxContainer2/LineEdit.text))
	multiplayer.multiplayer_peer = peer


func _on_main_ready() -> void:
	gridman = Globals.main.table.gridman
	cell_debug = Globals.cell_debug


func _on_player_connected(id):
	for cell in gridman.grid_dict.keys():
		var pos = gridman.grid_dict[cell]
	
	#var new_model = create_player_model(id)
	#get_parent().add_child(new_model)
	#write_models_dict(id, new_model)

func _on_player_disconnected(id):
	pass


func write_models_dict(id, model):
	if not players_models.has(id):
		players_models[id] = model


func _on_connected_ok():
	Globals.player.name = str(multiplayer.get_unique_id())
	print(Globals.player.name, " connected")
	
	#var new_model = create_player_model(multiplayer.get_unique_id())
	#get_parent().add_child(new_model)
	#write_models_dict(multiplayer.get_unique_id(), new_model)
	#get_parent().add_child(create_player_model(multiplayer.get_unique_id()))


func _on_connected_fail():
	pass


func _on_server_disconnected():
	pass


func create_player_model(id):
	var new_model = PLAYER_MODEL.instantiate()
	#new_model.set_authority(id)
	new_model.set_multiplayer_authority(id)
	return new_model


@rpc("call_local","any_peer","unreliable")
func sync_player_model(id, trans):
	if players_models.has(id):
		players_models[id].global_transform = trans
