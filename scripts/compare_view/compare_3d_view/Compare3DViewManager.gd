class_name Compare3DViewManager extends AbstractCompareViewManager

@onready var compare_manager: CompareManager = $"../.."
const COMPARE_3D_VIEW_ELEMENT = preload("uid://cjvvtymoclsb2")
#@onready var compare_3d_asset_array: Compare3DAssetArray = $VBoxContainer/Compare3DEnvironment/SubViewportContainer/SubViewport/Environment/Compare3DAssetArray
@onready var assets_root: Node3D = $VBoxContainer/Compare3DEnvironment/SubViewportContainer/SubViewport/Environment/AssetsRoot

var tile: AssetTile2D

func create_model_compare_element(asset: AbstractAssetTile, index: int) -> void:
	
	var model_node: Node3D = attach_model_from_tile(asset)
	if model_node == null:
		return
	
	var compare_3d_view_element: Compare3DViewElement = COMPARE_3D_VIEW_ELEMENT.instantiate()
	compare_3d_view_element.name = "Compare3DViewElement_%s" % Time.get_ticks_usec()
	
	assets_root.add_child(compare_3d_view_element)
	
	compare_3d_view_element.setup(model_node)

func remove_model_compare_element(index: int) -> void:
	
	assets_root.get_child(index).queue_free()

func set_display_mode(display_mode: DisplayOptionsButton.DisplayOptions) -> void:
	pass

func get_compare_manager() -> CompareManager:
	return compare_manager

## Loads the given model from a tile
## Returns the root node of the model on success, null if loading failed
func attach_model_from_tile(asset: AbstractAssetTile) -> Node3D:
	if asset is AssetTile2D:
		tile = asset
	
	if tile == null:
		return null
	
	# BEWARE, no validity check here!!
	# TODO add safe load to model to ModelLoader
	return ModelLoader._load_model(tile.asset_info.get_path_to_local_asset()) 
