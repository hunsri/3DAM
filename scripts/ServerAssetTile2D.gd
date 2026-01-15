class_name ServerAssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label

var asset_handler: ServerExplorerHandler

func set_handler(p_asset_handler: ServerExplorerHandler) -> void:
	asset_handler = p_asset_handler

func set_asset_label(asset_name: String):
	asset_name_label.text = asset_name

#TODO implement fetching previews
