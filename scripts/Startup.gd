class_name Startup extends Node

@export var SCENE_NODE: Node

const ID_FILE_PATH := "user://identity.ini"

func _ready() -> void:
	_create_identity_if_not_exist()
	SCENE_NODE.add_child(Location_Handler.LOCAL_VIEW_UI.instantiate())

func _create_identity_if_not_exist() -> void:
	var config = ConfigFile.new()
	var error = config.load(ID_FILE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		config.set_value("user", "uuid", UUID_v4_Utils.v4())
		config.save(ID_FILE_PATH)
		print(ProjectSettings.globalize_path(ID_FILE_PATH))
