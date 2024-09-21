extends Node2D

var gridman : Node
var cell_debug : Node

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_host_pressed():
	peer.create_server(int($VBoxContainer/HBoxContainer/LineEdit.text))
	multiplayer.multiplayer_peer = peer

func _on_join_pressed():
	peer.create_client($VBoxContainer/HBoxContainer2/LineEdit2.text, int($VBoxContainer/HBoxContainer2/LineEdit.text))
	multiplayer.multiplayer_peer = peer


func _on_main_ready() -> void:
	gridman = Globals.main.table.gridman
	cell_debug = Globals.cell_debug


func _on_player_connected(id):
	for cell in gridman.grid_dict.keys():
		var pos = gridman.grid_dict[cell]
		gridman.create_object.rpc_id(id, cell.real_name, pos)

func _on_player_disconnected(id):
	pass


func _on_connected_ok():
	pass


func _on_connected_fail():
	pass


func _on_server_disconnected():
	pass
