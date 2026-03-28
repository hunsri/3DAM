@abstract class_name AbstractAssetTile extends Panel

# For implementing different asset tiles for Server and Local view

@abstract func set_highlighted(is_highlighted: bool) -> void

@abstract func get_tile_sublogic() -> TileSubLogic

@abstract func get_asset_info() -> AssetInfo

@abstract func setup_tile(p_asset_handler: AbstractExplorerHandler, asset_info: AssetInfo)
@abstract func is_selected() -> bool

@abstract func get_preview_image() -> Image
