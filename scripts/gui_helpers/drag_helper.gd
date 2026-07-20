extends Control

@onready var asset_tile: AbstractAssetTile = $"../.."

func _get_drag_data(at_position):
	
	var root_preview := Control.new()
	
	if asset_tile is not AssetTile2D:
		return
		
	var preview := asset_tile.duplicate(Node.DUPLICATE_USE_INSTANTIATION)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.modulate.a = 0.8
	preview.preview_mode = true
	# for centering the preview around the mouse pointer
	root_preview.add_child(preview)
	root_preview.custom_minimum_size = preview.get_combined_minimum_size()
	preview.position = -root_preview.custom_minimum_size * 0.5
	set_drag_preview(root_preview)
	
	return {"source": self, "payload": asset_tile}
