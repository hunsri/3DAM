class_name AssetSidebarHandler extends Node

@onready var spawn_point: Node3D = %SpawnPoint
@onready var spring_arm_3d: SpringArm3D = %SpringArm3D

@export var model_preview_texture: TextureRect

@export var preview_texture_container: PanelContainer
@export var preview_model_container: SubViewportContainer

## stays empty in local view
@export var server_handler: ServerHandler
## provides meta information
@export var asset_meta_info_display: AssetMetaInfoDisplay
var default_spring_length: float

enum SidebarMode {LOCAL, SERVER}
var _sidebar_mode: SidebarMode

var _latest_clicked_asset: AbstractAssetTile

func _ready() -> void:
	asset_meta_info_display.asset_sidebar_handler = self
	_set_sidebebar_mode(SidebarMode.LOCAL)

func reset_sidebar() -> void:
	reset_model()
	reset_preview_image()
	_set_sidebebar_mode(SidebarMode.LOCAL)

func load_model(path_to_model: String):
	
	reset_model()
	ModelLoader.load_attach_model(path_to_model, spawn_point)

func load_preview_image(image: Image) -> void:
	
	reset_preview_image()
	model_preview_texture.texture = ImageTexture.create_from_image(image)
	

func reset_model():
	for child in spawn_point.get_children():
		child.queue_free()
	
	spawn_point.reset()

func reset_preview_image():
	model_preview_texture.texture = null

func set_latest_clicked_asset(p_latest_clicked_asset: AbstractAssetTile) -> void:
	
	if p_latest_clicked_asset != null:
		if _latest_clicked_asset != null:
			_latest_clicked_asset.get_tile_sublogic().set_highlighted(false)
	reset_sidebar()
	_latest_clicked_asset = p_latest_clicked_asset
	
	if p_latest_clicked_asset is AssetTile2D:
		_set_sidebebar_mode(SidebarMode.LOCAL)
		var tile: AssetTile2D = p_latest_clicked_asset
		var asset_path = tile.get_asset_info().get_path_to_local_asset()
		var asset_info_package = tile.asset_info_of_current_package_version
		
		if asset_info_package != null:
			asset_path = asset_info_package.get_path_to_local_asset()
		
		load_model(asset_path)
		
	elif p_latest_clicked_asset is ServerAssetTile2D:
		_set_sidebebar_mode(SidebarMode.SERVER)
		var server_tile: ServerAssetTile2D = p_latest_clicked_asset
		load_preview_image(server_tile.get_preview_image())
		
func get_latest_clicked_asset() -> AbstractAssetTile:
	return _latest_clicked_asset

func _set_sidebebar_mode(p_sidebar_mode: SidebarMode):
	_sidebar_mode = p_sidebar_mode
	
	match p_sidebar_mode:
		SidebarMode.LOCAL:
			asset_meta_info_display.set_is_local_asset(true)
			preview_texture_container.visible = false
			preview_model_container.visible = true
		SidebarMode.SERVER:
			asset_meta_info_display.set_is_local_asset(false)
			preview_texture_container.visible = true
			preview_model_container.visible = false
