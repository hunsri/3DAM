class_name CompareManager extends Node

@onready var details_view_manager: DetailsViewManager = $TabContainer/Details
@onready var compare_3d_view_manager: Compare3DViewManager = $"TabContainer/3D"
@onready var compare_2d_view_manager: Compare2DViewManager = $"TabContainer/2D"

@onready var loading_message: PanelContainer = $LoadingMessage
@onready var tab_container: TabContainer = $TabContainer

var compare_models: Array[AbstractAssetTile]

func _ready() -> void:	
	pre_ignite_tabs()

func remove_model(index: int) -> void:
	
	details_view_manager.remove_model_compare_element(index)
	compare_3d_view_manager.remove_model_compare_element(index)
	compare_2d_view_manager.remove_model_compare_element(index)
	
	compare_models.remove_at(index)

func insert_compare_model_from_tile(tile: AbstractAssetTile, index: int = 0) -> void:
	details_view_manager.create_model_compare_element(tile, index)
	compare_3d_view_manager.create_model_compare_element(tile, index)
	compare_2d_view_manager.create_model_compare_element(tile, index)
	
	compare_models.insert(index, tile)

## Rendering of all tabs, to force shader compilation
## This reduces loading times later on
func pre_ignite_tabs() -> void:
	await get_tree().process_frame

	for tab in tab_container.get_children():
		tab.visible = true
		await get_tree().process_frame
		tab.visible = false
	
	tab_container.get_children()[0].visible = true
	loading_message.visible = false
	
