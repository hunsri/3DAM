class_name ServerExchangeManager extends Node

var _selected_assets: Dictionary[AbstractAssetTile, float]

func add_to_selection(asset_tile: AbstractAssetTile) -> void:
	_selected_assets.set(asset_tile, 0)

func remove_from_selection(asset_tile: AbstractAssetTile) -> bool:
	return _selected_assets.erase(asset_tile)
	

func get_selected_assets() -> Dictionary:
	return _selected_assets
