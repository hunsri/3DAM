class_name Asset_View_2D_Line extends Control

const ASSET_TILE = preload("uid://dbn3bs55ug33l")
const SERVER_ASSET_TILE = preload("uid://b0vnhbbsnmqva")
const FOLDER_TILE = preload("uid://dr5hq7so1kcmq")

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

#--------------------------#
# Special cases down below #
#--------------------------#

## Special case for displaying folders
func populate_folders(folder_dirs: Array[String]) -> void:
	for i in range(folder_dirs.size()):
		add_folder_tile(folder_dirs[i])
		
func add_folder_tile(folder_dir: String) -> void:
	var folder_tile: FolderTile
	
	folder_tile = FOLDER_TILE.instantiate()
	add_child(folder_tile)
	folder_tile.setup_tile(_explorer_handler, folder_dir)
