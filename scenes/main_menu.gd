extends Node2D

var main_scene = preload("res://scenes/main.tscn")

@onready var world_node: Node3D = $WorldNode

@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _on_singleplayer_button_up() -> void:
	var main = main_scene.instantiate()
	world_node.add_child(main)
	canvas_layer.visible = false
