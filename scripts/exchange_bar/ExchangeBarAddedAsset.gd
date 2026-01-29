class_name ExchangeBarAddedAsset extends PanelContainer

@export var asset_name: Label

var asset_tile: AbstractAssetTile

var percentage_loaded: float = 0

func set_asset_name(p_asset_name: String) -> void:
	asset_name.text = p_asset_name
