## Class for managing the exchange of assets between the local machine and the server.
##
## Handles the responses to the requests made by the [ServerHandler] related to: [br]
## - Downloading assets from the server[br]
## - Uploading assets to the server[br][br]
## Also manages the selection of assets for upload and download and communicates with the [ServerExchangeBar] to display the
## selected assets and the progress of the exchange.
class_name ServerExchangeManager extends Node

## Exchange bar element for displaying the selected assets and the progress of the exchange.
@export var server_exchange_bar: ServerExchangeBar
## Handles the display of the server assets
@export var server_explorer_handler: ServerExplorerHandler
## Handles the display of the local assets
@export var asset_explorer_handler: AssetExplorerHandler

## Contains all assets that are currently selected for download from the server.
var _selected_assets_for_download: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]
## Contains all assets that are currently selected for upload to the server.
var _selected_assets_for_upload: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]

## Reference to the [ServerHandler] [br]
## Set upon ready through [method ServerExchangeManager.set_server_handler] from within the [ServerHandler]
var _server_handler: ServerHandler

## workaround to remember asset_info after download
var asset_info_of_current_download: AssetInfo

## workaround to remember asset_info after upload
var asset_info_of_current_upload: AssetInfo

## Modes to indicate the type of the planned exchange
enum ExchangeMode {NONE, UPLOAD, DOWNLOAD}
## Mode of the exchange process with the server.
var current_exchange_mode: ExchangeMode = ExchangeMode.NONE

## Setup for the connection between [ServerExchangeManager] and [ServerExchangeBar]
func _ready() -> void:
	server_exchange_bar.set_server_exchange_manager(self)

## Sets the current exchange mode and updates the overlays in the explorers accordingly.
func set_exchange_mode(exchange_mode: ExchangeMode) -> void:
	if exchange_mode == current_exchange_mode:
		return
	
	current_exchange_mode = exchange_mode
	server_explorer_handler.set_overlay_status(current_exchange_mode)
	asset_explorer_handler.set_overlay_status(current_exchange_mode)

## Adds a given asset tile to the selection for upload or download depending on the type of the asset tile and adds it to the exchange bar.
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

## Returns the local asset tile that corresponds to the given asset info from the upload selection.
func get_from_upload_selection(asset_info: AssetInfo) -> AssetTile2D:
	for asset_tile in _selected_assets_for_upload.keys():
		var local_asset_tile: AssetTile2D = asset_tile
		if local_asset_tile.asset_info.package_name == asset_info.package_name:
			return local_asset_tile
	return null

## Removes the local asset tile that corresponds to the given asset info from the upload selection.
## Returns true if the asset tile was found and removed, false otherwise.[br][br]
## [color=blue]Note:[/color] It is recommended to use [method ServerExchangeManager.remove_from_selection] directly.
func remove_from_upload_selection(asset_info: AssetInfo) -> bool:
	for asset_tile in _selected_assets_for_upload.keys():
		var local_asset_tile: AssetTile2D = asset_tile
		if local_asset_tile.asset_info.package_name == asset_info.package_name:
			return remove_from_selection(asset_tile)
	return false

## Removes the server asset tile that corresponds to the given asset info from the download selection.
## Returns true if the asset tile was found and removed, false otherwise.[br][br]
## [color=blue]Note:[/color] It is recommended to use [method ServerExchangeManager.remove_from_selection] directly.
func remove_from_download_selection(asset_info: AssetInfo) -> bool:
	for asset_tile in _selected_assets_for_download.keys():
		var server_asset_tile: ServerAssetTile2D = asset_tile
		if server_asset_tile.asset_info.package_name == asset_info.package_name:
			return remove_from_selection(asset_tile)
	return false

## Removes the given asset tile from the selection for upload or download depending on the type of the asset tile and
## removes it from the exchange bar. [br][br]
## Returns true if the asset tile was found and removed, false otherwise.
func remove_from_selection(asset_tile: AbstractAssetTile) -> bool:
	
	if asset_tile is ServerAssetTile2D:
		server_exchange_bar.remove_from_bar(_selected_assets_for_download.get(asset_tile))
		return _selected_assets_for_download.erase(asset_tile)
	elif asset_tile is AssetTile2D:
		server_exchange_bar.remove_from_bar(_selected_assets_for_upload.get(asset_tile))
		return _selected_assets_for_upload.erase(asset_tile)
	
	return false #for the unexpected case that the asset_tile class couldn't be matched

## Uploads the currently selected assets to the server [br][br]
## [color=yellow]Warning:[/color] For now, only the first asset in the selection is uploaded for testing purposes.
## This will be changed in the future to allow multiple uploads at once.
func upload_selected_assets() -> void:
	for key in _selected_assets_for_upload:
		upload_single_asset(key)
		return

## Uploads the given asset to the server by first uploading the asset info, then the asset archive and finally the preview image.
## The responses to these requests are handled in the corresponding methods: [br]
## - [method ServerExchangeManager.on_request_completed_upload_asset_info] [br]
## - [method ServerExchangeManager.on_request_completed_upload_asset_archive_to_server] [br]
## - [method ServerExchangeManager.on_request_completed_upload_asset_preview_image] [br][br]
func upload_single_asset(asset: AssetTile2D) -> void:
	
	var asset_info_upload: AssetInfo
	if asset.asset_info_of_current_package_version != null:
		# in case the asset is a package, we want to send the asset info of the current version
		asset_info_upload = asset.asset_info_of_current_package_version
	else:
		asset_info_upload = asset.asset_info
	
	asset_info_of_current_upload = asset_info_upload
	var category_name := server_explorer_handler.category_handler.get_currently_open_category()
	
	# uploads the zip archive as part of the response handling in on_request_completed_upload_asset_info
	_server_handler.upload_asset_info(category_name, asset_info_upload)

## Response handling for the upload process
## Handles the response to the asset info upload request by uploading the asset archive to the server.
func on_request_completed_upload_asset_info(_result, response_code, _headers, body):
	
	if response_code == 200:
		var version: String = asset_info_of_current_upload.version
		
		# We prefer to use the version we just declared when we requested the asset_info POST to the server 
		var res = JSON.parse_string(body.get_string_from_utf8())
		if res != null:
			version = res.version
			
		var category_name := server_explorer_handler.category_handler.get_currently_open_category()
		var archive_location = ZipUtils.create_zip_from_asset_info(asset_info_of_current_upload)
		
		_server_handler.upload_asset_archive_to_server(category_name, asset_info_of_current_upload.package_name, version, archive_location)

## Response handling for the upload process
## Handles the response to the asset archive upload request by uploading the preview image to the server.
func on_request_completed_upload_asset_archive_to_server(_result, response_code, _headers, body):

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

## Response handling for the upload process
## Handles the response to the preview image upload request by removing the asset from the upload selection and reloading the server explorer to display the newly uploaded asset.
func on_request_completed_upload_asset_preview_image(_result, _response_code, _headers, _body):

	remove_from_upload_selection(asset_info_of_current_upload)
	server_explorer_handler.reload_explorer_from_server()

## Returns the dictionary containing the currently selected assets for download.
func get_selected_assets_for_download() -> Dictionary:
	return _selected_assets_for_download

## Downloads the currently selected assets from the server [br][br]
## [color=yellow]Warning:[/color] For now, only the first asset in the selection is downloaded for testing purposes.
## This will be changed in the future to allow multiple downloads at once.
func download_selected_assets() -> void:
	
	for key in _selected_assets_for_download:
		download_single_asset(key)
		#TODO for now only first asset for testing

## Downloads the given asset from the server by first preparing the local package structure and then requesting the asset archive from the server.[br][br]
## The responses to these requests are handled in the corresponding methods:[br][br]
## - [method ServerExchangeManager.on_request_completed_download_package_info_for_saving] [br]
## - [method ServerExchangeManager.on_request_completed_download_asset_from_server]
func download_single_asset(server_asset: ServerAssetTile2D) -> void:
	var category := server_asset.asset_handler.category_handler.get_currently_open_category()
	var package_name := server_asset.asset_info.package_name
	
	asset_info_of_current_download = server_asset.asset_info
	
	# First we make sure that the package structure exists
	_server_handler.download_package_info_for_saving(category, package_name)

## Prepares the local package structure for the incoming asset by requesting the package info from the server.
func on_request_completed_download_package_info_for_saving(_result, response_code, _headers, body):
	
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		
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

## Handles the incoming asset archive by extracting it, saving the asset and refreshing the explorer.
func on_request_completed_download_asset_from_server(_result, _response_code, _headers, body):
	if _response_code != 200:
		return
	
	var package_path = asset_explorer_handler.directory_handler.get_currently_open_directory() + "/" + asset_info_of_current_download.package_name
	var package_version_path = PackageUtils.insert_package_version_assets(package_path, asset_info_of_current_download, body)
	
	AssetUtils.create_asset_info_file(asset_info_of_current_download, package_version_path)
	remove_from_download_selection(asset_info_of_current_download)
	asset_explorer_handler.reload_explorer()

## Sets the reference to the [ServerHandler] for making requests to the server [br][br]
## [color=yellow]Warning:[/color] This method should only be called from within the [ServerHandler] upon ready
func set_server_handler(p_server_handler: ServerHandler) -> void:
	_server_handler = p_server_handler
