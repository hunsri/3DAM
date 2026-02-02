class_name ServerExchangeManager extends Node

@export var server_exchange_bar: ServerExchangeBar
@export var server_explorer_handler: ServerExplorerHandler
@export var asset_explorer_handler: AssetExplorerHandler

var _selected_assets_for_download: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]
var _selected_assets_for_upload: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]

var _server_handler: ServerHandler

# workaround to remember asset_info after download
var asset_info_of_current_download: AssetInfo

func _ready() -> void:
	server_exchange_bar.set_server_exchange_manager(self)

func add_to_selection(asset_tile: AbstractAssetTile) -> void:
	var added_asset: ExchangeBarAddedAsset = ServerExchangeBar.create_exchange_bar_asset()
	
	if asset_tile is ServerAssetTile2D:
		added_asset.set_asset_name(asset_tile.asset_info.package_name)
		_selected_assets_for_download.set(asset_tile, added_asset)
		server_exchange_bar.add_to_bar(added_asset)
	elif asset_tile is AssetTile2D:
		_selected_assets_for_upload.set(asset_tile, added_asset)
		#TODO add for upload

func remove_from_selection(asset_tile: AbstractAssetTile) -> bool:
	
	if asset_tile is ServerAssetTile2D:
		server_exchange_bar.remove_from_bar(_selected_assets_for_download.get(asset_tile))
	elif asset_tile is AssetTile2D:
		server_exchange_bar.remove_from_bar(_selected_assets_for_upload.get(asset_tile))
	
	return _selected_assets_for_download.erase(asset_tile)

func get_selected_assets_for_download() -> Dictionary:
	return _selected_assets_for_download

func download_selected_assets() -> void:
	
	for key in _selected_assets_for_download:
		download_single_asset(key)
		return #TODO for now only first asset for testing

func download_single_asset(server_asset: ServerAssetTile2D) -> void:
	var category := server_asset.asset_handler.category_handler.get_currently_open_category()
	var asset_name := server_asset.asset_info.package_name
	
	_server_handler.download_asset_from_server(category, asset_name)
	asset_info_of_current_download = server_asset.asset_info

func on_request_completed_download_asset_from_server(_result, _response_code, _headers, body):
	if _response_code != 200:
		print("download failed")
		return
	else:
		print("download successful")
	
	saving_file(body)

## Returns true if saving was successful
func saving_file(data: PackedByteArray) -> bool:	
	var target_directory := _create_package_directory(asset_explorer_handler.directory_handler.get_currently_open_directory())
	if target_directory == "":
		return false
	
	print("saving location: "+ target_directory)
	var file = FileAccess.open(target_directory+"/"+asset_info_of_current_download.package_name+".zip", FileAccess.WRITE)
	if file == null:
		return false
	
	print("start saving")
	
	for i in data.size():
		file.store_8(data.get(i))
	
	file.close()
	print("done saving")
	
	print("start unpacking")
	AssetUtils.extract_assets_zip_archive(target_directory, asset_info_of_current_download.package_name)
	print("done unpacking")
	
	var abs_path: String = ProjectSettings.globalize_path(target_directory)
	if abs_path != "":
		OS.shell_open(abs_path)
	
	return true

## Creates a package directory with asset_info.json
## Returns the path to the package, or an empty string upon failure
func _create_package_directory(target_directory: String) -> String:
	var dir = DirAccess.open(target_directory)
	dir.make_dir(asset_info_of_current_download.package_name)
	
	var package_path = target_directory+"/"+asset_info_of_current_download.package_name
	
	var info_file_path = package_path+"/"+AssetUtils.INFO_FILE_NAME
	var file = FileAccess.open(info_file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(asset_info_of_current_download.raw_json)
		file.close()
		return package_path
	else:
		return ""

func set_server_handler(p_server_handler: ServerHandler) -> void:
	_server_handler = p_server_handler
