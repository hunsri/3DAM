## For visually representing an asset selected for upload/download in the [ServerExchangeBar].
##
## Holds a reference to the corresponding asset tile, which is used to reset the SELECTED status of the tile when the asset is removed from the bar.
## Independently from the asset tile, it shows the name and preview image of the asset.
class_name ExchangeBarAddedAsset extends PanelContainer

## UI element for displaying the name of the asset
@export var _asset_name: Label
## UI element for displaying the preview image of the asset
@export var _asset_texture: TextureRect

## Reference to the corresponding asset tile
## Used for example to reset the SELECTED status of the tile when it is removed from [ServerExchangeBar]
var asset_tile: AbstractAssetTile

## Not in use at the moment
var percentage_loaded: float = 0

## For setting displayed name in the UI element
func set_asset_name(p_asset_name: String) -> void:
	_asset_name.text = p_asset_name

## For setting displayed preview image in the UI element
func set_asset_image(texture: Texture2D) -> void:
	_asset_texture.texture = texture

## Getter for the displayed asset name, independent from the asset tile
func get_asset_name() -> String:
	return _asset_name.text
