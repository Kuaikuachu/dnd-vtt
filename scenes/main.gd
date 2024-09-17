extends Node3D

@export var table : Node
@onready var cell_visual: Node3D = $Level/CellVisual

func _ready() -> void:
	Globals.main = self
