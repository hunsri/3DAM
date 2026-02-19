class_name AssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label
@export var spawn_point: Node3D
@export var tile_sub_logic: TileSubLogic
@export var sub_viewport: SubViewport

var asset_handler: AssetExplorerHandler
var asset_info: AssetInfo
var package_info: PackageInfo = null #only present if asset_tile is a package

func _ready() -> void:
	
	if asset_info.asset_type == AssetInfo.AssetType.MODEL_3D:
		display_model_preview()
	if asset_info.asset_type == AssetInfo.AssetType.ASSET_PACKAGE:
		display_package_preview() #maybe package preview image

func setup_tile(p_asset_handler: AbstractExplorerHandler, p_asset_info: AssetInfo):
	asset_info = p_asset_info
	
	set_handler(p_asset_handler)
	set_asset_label(p_asset_info.asset_file_name)
	
	if asset_info.asset_type == AssetInfo.AssetType.ASSET_PACKAGE:
		package_info = PackageUtils.load_package_info_from_root(asset_info.get_path_to_local_asset())
	
	var is_supported = AssetUtils.is_file_name_supported(p_asset_info.asset_file_name)
	tile_sub_logic.set_is_supported_asset(is_supported)
	
	# disable selection for exchange if no server is present in the view
	if asset_handler.server_handler == null:
		tile_sub_logic.set_selection_disabled(true)

## Creates an image for usage as a preview inside a package
func get_preview_image() -> Image:
	return sub_viewport.get_texture().get_image()

func set_handler(p_asset_handler: AssetExplorerHandler) -> void:
	asset_handler = p_asset_handler

func set_asset_label(asset_name: String):
	asset_name_label.text = asset_name

func _on_asset_clicked_button_pressed() -> void:
	asset_handler.asset_clicked(asset_name_label.text)

func display_model_preview() -> void:
	var full_path = asset_handler.directory_handler.get_currently_open_directory() + "/" + asset_name_label.text
	ModelLoader.load_attach_model(full_path, spawn_point)

func display_package_preview() -> void:
	
	if package_info == null:
		return
	
	var asset_path = PackageUtils.get_latest_available_package_version(asset_info.get_path_to_local_asset())

	var model_asset_path := PackageUtils.get_path_to_model_asset(asset_path)
	
	ModelLoader.load_attach_model(model_asset_path, spawn_point)

func _on_selection_checkbox_pressed() -> void:
	if is_selected():
		asset_handler.server_handler.server_exchange_manager.add_to_selection(self)
	else:
		asset_handler.server_handler.server_exchange_manager.remove_from_selection(self)

func is_selected() -> bool:
	return tile_sub_logic.selected.button_pressed
