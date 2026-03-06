class_name ExchangeBarAddedAsset extends PanelContainer

@export var _asset_name: Label
@export var _asset_texture: TextureRect

var asset_tile: AbstractAssetTile

var percentage_loaded: float = 0

func set_asset_name(p_asset_name: String) -> void:
	_asset_name.text = p_asset_name

func set_asset_image(texture: Texture2D) -> void:
	_asset_texture.texture = texture

func get_asset_name() -> String:
	return _asset_name.text
