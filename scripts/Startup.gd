class_name Startup extends Node

@export var SCENE_NODE: Node

func _ready() -> void:
	SCENE_NODE.add_child(Location_Handler.LOCAL_VIEW_UI.instantiate())
