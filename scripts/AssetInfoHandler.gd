class_name AssetInfoHandler extends Node

@onready var spawn_point: Node3D = %SpawnPoint
@onready var spring_arm_3d: SpringArm3D = %SpringArm3D

func load_model(path_to_model: String):
	
	reset_model()
	ModelLoader.load_attach_model(path_to_model, spawn_point)

func reset_model():
	for child in spawn_point.get_children():
		child.queue_free()
	
	spawn_point.rotation = Vector3(0,0,0)
	spring_arm_3d.spring_length = 3 #arbitrary distance for now
