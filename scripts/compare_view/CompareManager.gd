class_name CompareManager extends Node

@onready var details_view_manager: DetailsViewManager = $TabContainer/Details
@onready var compare_3d_view_manager: Compare3DViewManager = $"TabContainer/3D"

var compare_models: Array[AbstractAssetTile]

func remove_model(index: int) -> void:
	
	details_view_manager.remove_model_compare_element(index)
	compare_3d_view_manager.remove_model_compare_element(index)
	
	compare_models.remove_at(index)

func insert_compare_model_from_tile(tile: AbstractAssetTile, index: int = 0) -> void:
	details_view_manager.create_model_compare_element(tile, index)
	compare_3d_view_manager.create_model_compare_element(tile, index)
	
	compare_models.insert(index, tile)
