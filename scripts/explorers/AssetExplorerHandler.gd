class_name AssetExplorerHandler extends AbstractExplorerHandler

@export var local_asset_container: MarginContainer
@export var local_folder_container: MarginContainer
var _folder_tiles: Asset_View_2D_Line

@export var directory_handler: DirectoryHandler
@export var asset_sidebar_handler: AssetSidebarHandler

## left empty when in local view
@export var server_handler: ServerHandler

@export var status_overlay: ExplorerStatusOverlay
@export var selector_overlay: SelectorStatusOverlay

var asset_infos: Array[AssetInfo] = []
var folder_dirs: Array[String] = []

func _ready() -> void:
	reload_explorer()

func reload_explorer() -> void:
	remove_all_tiles()
	asset_infos = []
	folder_dirs = []
	asset_infos = _fetch_assets_info(directory_handler.get_currently_open_directory(), folder_dirs)
	populate(asset_infos, folder_dirs)

func asset_clicked(p_asset_tile: AbstractAssetTile) -> void:
	asset_sidebar_handler.set_latest_clicked_asset(p_asset_tile)

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

func populate(assets: Array[AssetInfo], p_folder_dirs: Array[String]):
	add_tile_line(assets)
	_folder_tiles = add_folder_tile_line(p_folder_dirs)

func add_tile_line(assets: Array[AssetInfo]) -> void:
	var tile_line = ResourceManager.create_tile_line()
	tile_line.set_explorer_handler(self)
	tile_line.populate(assets)
	local_asset_container.add_child(tile_line)

func add_folder_tile_line(p_folder_dirs: Array[String]) -> Asset_View_2D_Line:
	var folder_tile_line: Asset_View_2D_Line = ResourceManager.create_tile_line()
	folder_tile_line.set_explorer_handler(self)
	folder_tile_line.populate_folders(p_folder_dirs)
	local_folder_container.add_child(folder_tile_line)
	return folder_tile_line

func remove_all_tiles():
	for child in local_asset_container.get_children():
		child.queue_free()
	
	for child in local_folder_container.get_children():
		child.queue_free()
