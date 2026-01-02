class_name Asset_View_2D_Line extends HBoxContainer

const ASSET_TILE = preload("uid://dbn3bs55ug33l")
var _asset_explorer_handler: AssetExplorerHandler

func set_asset_explorer_handler(p_asset_explorer_handler: AssetExplorerHandler):
	_asset_explorer_handler = p_asset_explorer_handler

func populate(assets: Array[AssetInfo]) -> void:
	for i in range(assets.size()):
		add_tile(assets[i].asset_name)

func add_tile(asset_name: String) -> void:
	var tile:AssetTile2D = ASSET_TILE.instantiate()
	add_child(tile)
	tile.set_asset_label(asset_name)
	tile.set_handler(_asset_explorer_handler)
