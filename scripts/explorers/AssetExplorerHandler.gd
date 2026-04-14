## Main explorer handler for the asset explorer
##
## Responsible for fetching the assets in a directory and populating the explorer with tiles representing those assets.
class_name AssetExplorerHandler extends AbstractExplorerHandler

@export var local_asset_container: MarginContainer  ## holds the asset tiles
@export var local_folder_container: MarginContainer	## holds the folder tiles
var _folder_tiles: Asset_View_2D_Line

@export var directory_handler: DirectoryHandler			## enables interactions with the [DirectorySelector] of the scene
@export var asset_sidebar_handler: AssetSidebarHandler  ## enables interactions with the asset sidebar of the scene
## left empty when in local view
@export var server_handler: ServerHandler ## enables interactions with the server, null when in local view

@export var status_overlay: ExplorerStatusOverlay	## overlay to disable interactions
@export var selector_overlay: SelectorStatusOverlay ## overlay to disable interactions

## holds the AssetInfo of the assets in the currently open directory, excluding folders
var asset_infos: Array[AssetInfo] = []
## holds the paths of the folders in the currently open directory, excluding asset-packages, which are handled as assets
var folder_dirs: Array[String] = []

func _ready() -> void:
	reload_explorer()

## Reloads the explorer by fetching the assets in the current directory and populating the explorer with tiles representing those assets. [br]
## Also adds folder tiles for any subdirectories found.
func reload_explorer() -> void:
	remove_all_tiles()
	asset_infos = []
	folder_dirs = []
	asset_infos = _fetch_assets_info(directory_handler.get_currently_open_directory(), folder_dirs)
	populate(asset_infos, folder_dirs)

## Sets the currently clicked asset for the current explorer
## Used for updating the asset sidebar with the information of the clicked asset [br][br]
## [param p_asset_tile] the tile that was clicked
func asset_clicked(p_asset_tile: AbstractAssetTile) -> void:
	asset_sidebar_handler.set_latest_clicked_asset(p_asset_tile)

## Sets the overlay of the explorer to the given exchange mode
## Used to disable interaction with the explorer while an upload or download selection is in progress
func set_overlay_status(exchange_mode: ServerExchangeManager.ExchangeMode) -> void:
	if status_overlay != null:
		status_overlay.set_overlay(exchange_mode)
	if selector_overlay != null:
		selector_overlay.set_overlay(exchange_mode)
	
	match exchange_mode:
		ServerExchangeManager.ExchangeMode.UPLOAD:
			_folder_tiles.disable_folder_tiles()
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			_folder_tiles.enable_folder_tiles()
		ServerExchangeManager.ExchangeMode.NONE:
			_folder_tiles.enable_folder_tiles()

## Fetches all assets in a directory, including Asset-Packages [br]
## The folders that are found that aren't packages can be retrieved through the given
## [param out_found_folder_dirs] [br][br]
## Returns an array of [AssetInfo]
func _fetch_assets_info(directory: String, out_found_folder_dirs: Array[String] = []) -> Array[AssetInfo]:
	
	var ret: Array[AssetInfo] = []
	
	var dir_access = DirAccess.open(directory)
	
	if dir_access == null:
		return []
		
	dir_access.list_dir_begin()
	var asset_file_name = dir_access.get_next()
	while asset_file_name != "":
		var asset_path: String = directory+"/"+asset_file_name
		
		# We don't want to return folders that aren't packages
		if dir_access.dir_exists(asset_path):
			if not PackageUtils.is_target_package(asset_path):
				# Those get added to the out parameter instead
				out_found_folder_dirs.append(asset_path)
				asset_file_name = dir_access.get_next()
				continue
		
		ret.append(AssetInfo.new(asset_file_name, asset_path))
		asset_file_name = dir_access.get_next()
	
	return ret

## For populating the explorer with tiles representing the given assets and folders [br]
## [param assets] the assets to create asset tiles for [br]
## [param p_folder_dirs] the folders to create folder tiles for
func populate(assets: Array[AssetInfo], p_folder_dirs: Array[String]):
	add_tile_line(assets)
	_folder_tiles = add_folder_tile_line(p_folder_dirs)

## Adds a tile line, containing tiles representing the given assets, to the explorer [br]
## [param assets] the assets to create asset tiles for
func add_tile_line(assets: Array[AssetInfo]) -> void:
	var tile_line = ResourceManager.create_tile_line()
	tile_line.set_explorer_handler(self)
	tile_line.populate(assets)
	local_asset_container.add_child(tile_line)

## Adds a folder tile line, containing tiles representing the given folders, to the explorer [br]
## [param p_folder_dirs] the folders to create folder tiles for
func add_folder_tile_line(p_folder_dirs: Array[String]) -> Asset_View_2D_Line:
	var folder_tile_line: Asset_View_2D_Line = ResourceManager.create_tile_line()
	folder_tile_line.set_explorer_handler(self)
	folder_tile_line.populate_folders(p_folder_dirs)
	local_folder_container.add_child(folder_tile_line)
	return folder_tile_line

## Removes all tiles from the explorer, including both asset tiles and folder tiles [br]
func remove_all_tiles():
	for child in local_asset_container.get_children():
		child.queue_free()
	
	for child in local_folder_container.get_children():
		child.queue_free()
