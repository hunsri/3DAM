class_name ServerExchangeManager extends Node

@export var server_exchange_bar: ServerExchangeBar
@export var server_explorer_handler: ServerExplorerHandler
@export var asset_explorer_handler: AssetExplorerHandler

var _selected_assets_for_download: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]
var _selected_assets_for_upload: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]

var _server_handler: ServerHandler

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
	var target_directory := asset_explorer_handler.directory_handler.get_currently_open_directory()
	var category := server_asset.asset_handler.category_handler.get_currently_open_category()
	var asset_name := server_asset.asset_info.package_name
	
	_server_handler.download_asset_from_server(category, asset_name, target_directory)

func set_server_handler(p_server_handler: ServerHandler) -> void:
	_server_handler = p_server_handler
