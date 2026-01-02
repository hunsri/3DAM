class_name AssetTile2D extends Panel

@export var asset_name_label: Label

var asset_handler: AssetExplorerHandler

func set_handler(p_asset_handler: AssetExplorerHandler) -> void:
	asset_handler = p_asset_handler

func set_asset_label(asset_name: String):
	asset_name_label.text = asset_name

func _on_asset_selection_button_pressed() -> void:
	asset_handler.asset_clicked(asset_name_label.text)
