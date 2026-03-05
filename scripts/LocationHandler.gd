class_name Location_Handler extends PanelContainer

const LOCAL_VIEW_UI = preload("uid://d2no27480sc8")
const SERVER_VIEW_UI = preload("uid://bo8w8k6tnqxov")
const ADD_SERVER_UI = preload("uid://vopv1427n8vl")
const CATEGORY_SELECTOR = preload("uid://dvb1345451o5v")

@onready var SCENE_NODE = $"../../../../ContextScene"
@export var scene_type: SceneType
@export var location_selector: LocationSelector

@onready var local_icon: TextureRect = $LocationButton/LocalIcon
@onready var server_icon: TextureRect = $LocationButton/ServerIcon
@onready var connection_issue_icon: TextureRect = $LocationButton/ConnectionIssueIcon
@onready var add_server_icon: TextureRect = $LocationButton/AddServerIcon
@onready var location_button: Button = $LocationButton

var current_icon: TextureRect

## only holds a value in case of Server SceneType
var server_address: String

enum SceneType {
	Local,
	Server,
	AddServer
}

func setup(type: SceneType, p_server_address: String = "") -> void:
	scene_type = type
	
	server_address = p_server_address

func _ready():
	location_button.button_group = ResourceManager.LOCATION_BUTTON_GROUP
	
	match scene_type:
		SceneType.Local:
			current_icon = local_icon
		SceneType.Server:
			current_icon = server_icon
		SceneType.AddServer:
			current_icon = add_server_icon
	
	current_icon.visible = true

func _on_location_button_pressed() -> void:
	
	var group_buttons :=  location_button.button_group.get_buttons()
	
	# ensures only one button is marked as pressed at a time
	for button in group_buttons:
		if button != location_button:
			button.button_pressed = false
	
	match scene_type:
		SceneType.Local:
			clear_scene()
			SCENE_NODE.add_child(LOCAL_VIEW_UI.instantiate())
		SceneType.Server:
			clear_scene()
			var server_scene = SERVER_VIEW_UI.instantiate()
			var server_info: ServerInfo = server_scene
			server_info.address = server_address
			SCENE_NODE.add_child(server_info)
		SceneType.AddServer:
			clear_scene()
			var add_server_scene = ADD_SERVER_UI.instantiate()
			var add_server_manager: AddServerManager = add_server_scene
			add_server_manager.setup(location_selector)
			SCENE_NODE.add_child(add_server_manager)
			
	
func clear_scene() -> void:
	var children = SCENE_NODE.get_children()
	for child in children:
		child.free()
