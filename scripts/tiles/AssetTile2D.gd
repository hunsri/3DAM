class_name AssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label
@export var spawn_point: Node3D
@export var tile_sub_logic: TileSubLogic
@export var sub_viewport: SubViewport

var asset_handler: AssetExplorerHandler
var asset_info: AssetInfo

func _ready() -> void:
	display_preview()

func setup_tile(p_asset_handler: AbstractExplorerHandler, p_asset_info: AssetInfo):
	asset_info = p_asset_info
	
	set_handler(p_asset_handler)
	set_asset_label(p_asset_info.asset_file_name)
	
	var is_supported = AssetUtils.is_file_name_supported(p_asset_info.asset_file_name)
	tile_sub_logic.set_is_supported_asset(is_supported)
	
	# disable selection for exchange if no server is present in the view
	if asset_handler.server_handler == null:
		tile_sub_logic.set_selection_disabled(true)

func get_preview_image() -> Image:
	return sub_viewport.get_texture().get_image()

func set_handler(p_asset_handler: AssetExplorerHandler) -> void:
	asset_handler = p_asset_handler

func set_asset_label(asset_name: String):
	asset_name_label.text = asset_name

func _on_asset_clicked_button_pressed() -> void:
	asset_handler.asset_clicked(asset_name_label.text)

func display_preview() -> void:
	var full_path = asset_handler.directory_handler.get_currently_open_directory() + "/" + asset_name_label.text
	ModelLoader.load_attach_model(full_path, spawn_point)

func _on_selection_checkbox_pressed() -> void:
	if is_selected():
		asset_handler.server_handler.server_exchange_manager.add_to_selection(self)
	else:
		asset_handler.server_handler.server_exchange_manager.remove_from_selection(self)

func is_selected() -> bool:
	return tile_sub_logic.selected.button_pressed
