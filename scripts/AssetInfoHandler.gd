class_name AssetInfoHandler extends Node

@onready var spawn_point: Node3D = %SpawnPoint
@onready var spring_arm_3d: SpringArm3D = %SpringArm3D

## stays empty in local view
@export var server_handler: ServerHandler

## provides meta information
@export var asset_meta_info_display: AssetMetaInfoDisplay

var default_spring_length: float

func _ready() -> void:
	asset_meta_info_display.asset_info_handler = self

func load_model(path_to_model: String):
	
	reset_model()
	ModelLoader.load_attach_model(path_to_model, spawn_point)

func reset_model():
	for child in spawn_point.get_children():
		child.queue_free()
	
	spawn_point.reset()
