class_name Location_Handler extends PanelContainer

const LOCAL_VIEW_UI = preload("uid://d2no27480sc8")
const SERVER_VIEW_UI = preload("uid://bo8w8k6tnqxov")
const CATEGORY_SELECTOR = preload("uid://dvb1345451o5v")

@onready var SCENE_NODE = $"../../../../ContextScene"
@export var scene_type: SceneType

enum SceneType {
	Local,
	Server,
	AddServer
}

func _ready():
	SCENE_NODE.add_child(LOCAL_VIEW_UI.instantiate())
	
func _on_location_button_pressed() -> void:
	
	match scene_type:
		SceneType.Local:
			clear_scene()
			SCENE_NODE.add_child(LOCAL_VIEW_UI.instantiate())
		SceneType.Server:
			clear_scene()
			SCENE_NODE.add_child(SERVER_VIEW_UI.instantiate())
	
func clear_scene() -> void:
	var children = SCENE_NODE.get_children()
	for child in children:
		child.free()
