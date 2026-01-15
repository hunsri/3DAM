class_name AssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label
@export var spawn_point: Node3D

var asset_handler: AssetExplorerHandler

func _ready() -> void:
	display_preview()

func set_handler(p_asset_handler: AssetExplorerHandler) -> void:
	asset_handler = p_asset_handler

func set_asset_label(asset_name: String):
	asset_name_label.text = asset_name

func _on_asset_selection_button_pressed() -> void:
	asset_handler.asset_clicked(asset_name_label.text)

func display_preview() -> void:
	var full_path = asset_handler.dh.get_currently_open_directory() + "/" + asset_name_label.text
	ModelLoader.load_attach_model(full_path, spawn_point)
