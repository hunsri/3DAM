class_name ExchangeBarAddedAsset extends PanelContainer

@export var _asset_name: Label

var asset_tile: AbstractAssetTile

var percentage_loaded: float = 0

func set_asset_name(p_asset_name: String) -> void:
	_asset_name.text = p_asset_name

func get_asset_name() -> String:
	return _asset_name.text
