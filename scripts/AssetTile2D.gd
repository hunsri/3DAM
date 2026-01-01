class_name AssetTile2D extends Panel

@export var asset_name_label: Label

func set_asset_label(asset_name: String):
	asset_name_label.text = asset_name
