class_name AssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label
@export var spawn_point: Node3D
@export var tile_sub_logic: TileSubLogic

var asset_handler: AssetExplorerHandler

func _ready() -> void:
	display_preview()

func setup_tile(p_asset_handler: AbstractExplorerHandler, asset_info: AssetInfo):
	set_handler(p_asset_handler)
	set_asset_label(asset_info.asset_name)
	
	var is_supported = AssetUtils.is_file_supported(asset_info.asset_name)
	tile_sub_logic.set_is_supported_asset(is_supported)

func set_handler(p_asset_handler: AssetExplorerHandler) -> void:
	asset_handler = p_asset_handler

func set_asset_label(asset_name: String):
	asset_name_label.text = asset_name

func _on_asset_selection_button_pressed() -> void:
	asset_handler.asset_clicked(asset_name_label.text)

func display_preview() -> void:
	var full_path = asset_handler.dh.get_currently_open_directory() + "/" + asset_name_label.text
	ModelLoader.load_attach_model(full_path, spawn_point)
