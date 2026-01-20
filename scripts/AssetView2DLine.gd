class_name Asset_View_2D_Line extends HBoxContainer

const ASSET_TILE = preload("uid://dbn3bs55ug33l")
const SERVER_ASSET_TILE = preload("uid://b0vnhbbsnmqva")

var _explorer_handler: AbstractExplorerHandler

func set_explorer_handler(p_explorer_handler: AbstractExplorerHandler):
	_explorer_handler = p_explorer_handler

func populate(assets: Array[AssetInfo]) -> void:
	for i in range(assets.size()):
		add_tile(assets[i])

func add_tile(asset_info: AssetInfo) -> void:
	var tile:AbstractAssetTile
	
	if is_instance_of(_explorer_handler, AssetExplorerHandler):
		tile = ASSET_TILE.instantiate()
	elif is_instance_of(_explorer_handler, ServerExplorerHandler):
		tile = SERVER_ASSET_TILE.instantiate()
		
	add_child(tile)
	tile.setup_tile(_explorer_handler, asset_info)
