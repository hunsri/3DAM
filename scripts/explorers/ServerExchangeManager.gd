class_name ServerExchangeManager extends Node

@export var server_exchange_bar: ServerExchangeBar

var _selected_assets_for_download: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]
var _selected_assets_for_upload: Dictionary[AbstractAssetTile, ExchangeBarAddedAsset]

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
