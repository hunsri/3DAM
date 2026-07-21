## Entry point of the software
##
## Loads the identity of the user, and creates one if it doesn't exist.[br][br]
## [color=blue]Note:[/color] This script MUST be included in the main scene, that is loaded on startup
class_name Startup extends Node

## Node holding the LocationSelector scene
## New views are opened by adding them as a child to this node
@export var SCENE_NODE: Node

## Path to the file storing the identity of the user
const ID_FILE_PATH := "user://identity.ini"

## on ready, the identity of the user is loaded, and if it doesn't exist, a new one is created.
## Initiates the scene with local asset view 
func _ready() -> void:
	_create_identity_if_not_exist()
	
	# necessary for wireframes to render in compatibility mode
	RenderingServer.set_debug_generate_wireframes(true)
	
	SCENE_NODE.add_child(Location_Handler.LOCAL_VIEW_UI.instantiate())

## Static function to load the identity of the user from the file specified in [constant ID_FILE_PATH] [br]
## Returns the uuid of the user as a string, or an empty string if loading fails
static func load_identity_uuid() -> String:
	var ret = ""
	var config := ConfigFile.new()
	var error = config.load(ID_FILE_PATH)
	if error == OK:
		ret = config.get_value("user", "uuid", "")
	return ret

## Static function to create a new identity for the user if it doesn't exist
static func _create_identity_if_not_exist() -> void:
	var config := ConfigFile.new()
	var error = config.load(ID_FILE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		config.set_value("user", "uuid", UUID_v4_Utils.v4())
		config.save(ID_FILE_PATH)
