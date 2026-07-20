extends Control

func _can_drop_data(at_position, drop_data: Variant):
	if drop_data.payload is AbstractAssetTile:
		return true
	else:
		return false

func _drop_data(at_position, drop_data: Variant):
	
	var data := drop_data.payload as AbstractAssetTile
	
	print(data.get_asset_info().asset_file_name)
	print(data.get_asset_info().get_path_to_local_asset())
	print(data.get_asset_info().asset_type as AssetInfo.AssetType)
	
