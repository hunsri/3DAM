@abstract class_name AbstractAssetTile extends Panel

# For implementing different asset tiles for Server and Local view

@abstract func setup_tile(p_asset_handler: AbstractExplorerHandler, asset_info: AssetInfo)
@abstract func is_selected() -> bool
