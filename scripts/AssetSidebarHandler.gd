class_name AssetSidebarHandler extends Node

@onready var spawn_point: Node3D = %SpawnPoint
@onready var spring_arm_3d: SpringArm3D = %SpringArm3D

## stays empty in local view
@export var server_handler: ServerHandler
## provides meta information
@export var asset_meta_info_display: AssetMetaInfoDisplay
var default_spring_length: float

enum SidebarMode {LOCAL, SERVER}
var _sidebar_mode: SidebarMode = SidebarMode.LOCAL

func _ready() -> void:
	asset_meta_info_display.asset_sidebar_handler = self

func load_model(path_to_model: String):
	
	reset_model()
	ModelLoader.load_attach_model(path_to_model, spawn_point)

func reset_model():
	for child in spawn_point.get_children():
		child.queue_free()
	
	spawn_point.reset()

func set_sidebebar_mode(p_sidebar_mode: SidebarMode):
	_sidebar_mode = p_sidebar_mode
	
	match p_sidebar_mode:
		SidebarMode.LOCAL:
			asset_meta_info_display.set_is_local_asset(true)
		SidebarMode.SERVER:
			asset_meta_info_display.set_is_local_asset(false)
