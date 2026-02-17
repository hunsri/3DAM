class_name ServerExchangeManager extends Node

@export var server_exchange_bar: ServerExchangeBar
@export var server_explorer_handler: ServerExplorerHandler
@export var asset_explorer_handler: AssetExplorerHandler

var _selected_assets_for_download: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]
var _selected_assets_for_upload: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]

var _server_handler: ServerHandler

# workaround to remember asset_info after download
var asset_info_of_current_download: AssetInfo

# and the same for upload
var asset_info_of_current_upload: AssetInfo

enum ExchangeMode {NONE, UPLOAD, DOWNLOAD}
var current_exchange_mode: ExchangeMode = ExchangeMode.NONE

func _ready() -> void:
	server_exchange_bar.set_server_exchange_manager(self)

func set_exchange_mode(exchange_mode: ExchangeMode) -> void:
	if exchange_mode == current_exchange_mode:
		return
	
	current_exchange_mode = exchange_mode
	server_explorer_handler.set_overlay_status(current_exchange_mode)
	asset_explorer_handler.set_overlay_status(current_exchange_mode)	

func add_to_selection(asset_tile: AbstractAssetTile) -> void:
	var added_asset: ExchangeBarAddedAsset = ServerExchangeBar.create_exchange_bar_asset(asset_tile)
	
	if asset_tile is ServerAssetTile2D:
		added_asset.set_asset_name(asset_tile.asset_info.package_name)
		_selected_assets_for_download.set(asset_tile, added_asset)
		server_exchange_bar.add_to_bar(added_asset)
	elif asset_tile is AssetTile2D:
		added_asset.set_asset_name(asset_tile.asset_info.package_name)
		_selected_assets_for_upload.set(asset_tile, added_asset)
		server_exchange_bar.add_to_bar(added_asset)

func get_from_upload_selection(asset_info: AssetInfo) -> AssetTile2D:
	for asset_tile in _selected_assets_for_upload.keys():
		var local_asset_tile: AssetTile2D = asset_tile
		if local_asset_tile.asset_info.package_name == asset_info.package_name:
			return local_asset_tile
	return null

func remove_from_upload_selection(asset_info: AssetInfo) -> bool:
	for asset_tile in _selected_assets_for_upload.keys():
		var local_asset_tile: AssetTile2D = asset_tile
		if local_asset_tile.asset_info.package_name == asset_info.package_name:
			return remove_from_selection(asset_tile)
	return false

func remove_from_selection(asset_tile: AbstractAssetTile) -> bool:
	
	#TODO remove selection status from explorer as well!
	
	if asset_tile is ServerAssetTile2D:
		server_exchange_bar.remove_from_bar(_selected_assets_for_download.get(asset_tile))
		return _selected_assets_for_download.erase(asset_tile)
	elif asset_tile is AssetTile2D:
		server_exchange_bar.remove_from_bar(_selected_assets_for_upload.get(asset_tile))
		return _selected_assets_for_upload.erase(asset_tile)
	
	return false #for the unexpected case that the asset_tile class couldn't be matched

func upload_selected_assets() -> void:
	#TODO upload implementation
	
	print("upload assets: ")
	for key in _selected_assets_for_upload:
		upload_single_asset(key)
		print(key)
		return

		
func upload_single_asset(asset: AssetTile2D) -> void:
	
	asset_info_of_current_upload = asset.asset_info
	var category_name := server_explorer_handler.category_handler.get_currently_open_category()
	
	# uploads the zip archive as part of the response handling in on_request_completed_upload_asset_info
	_server_handler.upload_asset_info(category_name, asset.asset_info)

func on_request_completed_upload_asset_info(_result, response_code, _headers, body):
	print("Response code:", response_code)
	print("Response body:", body.get_string_from_utf8())
	
	if response_code == 200:
		var version: String = asset_info_of_current_upload.version
		
		# We prefer to use the version we just declared when we requested the asset_info POST to the server 
		var res = JSON.parse_string(body.get_string_from_utf8())
		if res != null:
			version = res.version
			
		var category_name := server_explorer_handler.category_handler.get_currently_open_category()
		var directory_name := asset_explorer_handler.directory_handler.get_currently_open_directory()
		var archive_location = ZipUtils.create_zip_from_asset_info(directory_name, asset_info_of_current_upload)
		_server_handler.upload_asset_archive_to_server(category_name, asset_info_of_current_upload.package_name, version, archive_location)

func on_request_completed_upload_asset_archive_to_server(_result, response_code, _headers, body):
	print("ARCHIVE UPLOAD SERVER RESPONSE")
	print("Code:", response_code, "Body:", body.get_string_from_utf8())
	
	if response_code == 200:
		var version: String = asset_info_of_current_upload.version
		
		# We prefer to use the version we just declared when we requested the asset_info POST to the server 
		var res = JSON.parse_string(body.get_string_from_utf8())
		if res != null:
			version = res.version
	
		var tile: AssetTile2D = get_from_upload_selection(asset_info_of_current_upload)
		var image = tile.get_preview_image()
		
		var category_name := server_explorer_handler.category_handler.get_currently_open_category()
		_server_handler.upload_asset_preview_image(category_name, asset_info_of_current_upload.package_name, version, image)

func on_request_completed_upload_asset_preview_image(_result, response_code, _headers, body):
	print("PREVIEW UPLOAD SERVER RESPONSE")
	print("Code:", response_code, "Body:", body.get_string_from_utf8())
	remove_from_upload_selection(asset_info_of_current_upload)

func get_selected_assets_for_download() -> Dictionary:
	return _selected_assets_for_download

func download_selected_assets() -> void:
	
	print("download assets: ")
	for key in _selected_assets_for_download:
		print(key)

		download_single_asset(key)
		#TODO for now only first asset for testing

func download_single_asset(server_asset: ServerAssetTile2D) -> void:
	var category := server_asset.asset_handler.category_handler.get_currently_open_category()
	var package_name := server_asset.asset_info.package_name
	
	# First we make sure that the package structure exists
	_server_handler.download_package_info_for_saving(category, package_name)
	#_server_handler.download_asset_from_server(category, asset_name)
	asset_info_of_current_download = server_asset.asset_info

func on_request_completed_download_package_info_for_saving(_result, response_code, _headers, body):
	print("PACKAGE_INFO REQUEST RESPONSE")
	print("Response code:", response_code)
	print("Response body:", body.get_string_from_utf8())
	
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		print(json)
		
		var package_path := PackageUtils.create_new_package(
			PackageInfo.new(json.package_uuid, json.package_name, json.versions),
			asset_explorer_handler.directory_handler.get_currently_open_directory()
		)
		
		if package_path == "":
			return
		
		#request asset archive
		_server_handler.download_asset_from_server(
			server_explorer_handler.category_handler.get_currently_open_category(),
			json.package_name
			)

func on_request_completed_download_asset_from_server(_result, _response_code, _headers, body):
	if _response_code != 200:
		return
	
	# A bit crazy but it works
	var package_path = asset_explorer_handler.directory_handler.get_currently_open_directory() + "/" + asset_info_of_current_download.package_name
	PackageUtils.insert_asset_version_assets(package_path, asset_info_of_current_download, body)
	
	print("saving under:")
	print(package_path)
	
func set_server_handler(p_server_handler: ServerHandler) -> void:
	_server_handler = p_server_handler
