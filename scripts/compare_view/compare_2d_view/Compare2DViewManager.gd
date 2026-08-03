class_name Compare2DViewManager extends AbstractCompareViewManager

@onready var compare_manager: CompareManager = $"../.."

@onready var assets_root: Node3D = $VBoxContainer/Compare2dEnvironment/SubViewportContainer/SubViewport/Environment/AssetsRoot

const COMPARE_3D_VIEW_ELEMENT = preload("uid://cjvvtymoclsb2")

var tile: AssetTile2D
var current_display_mode := DisplayOptionsButton.DisplayOptions.SHADED
	
func create_model_compare_element(asset: AbstractAssetTile, index: int) -> void:
	
	var model_node: Node3D = attach_model_from_tile(asset)
	if model_node == null:
		return
	
	# reusing the Compare3DViewElement for 2D view
	var compare_2d_view_element: Compare3DViewElement = COMPARE_3D_VIEW_ELEMENT.instantiate()
	compare_2d_view_element.name = "Compare2DViewElement_%s" % Time.get_ticks_usec()
	
	assets_root.add_child(compare_2d_view_element)
	
	compare_2d_view_element.setup(model_node)
	
	apply_current_display_mode(compare_2d_view_element)

func remove_model_compare_element(index: int) -> void:
	
	assets_root.get_child(index).queue_free()

func set_display_mode(display_mode: DisplayOptionsButton.DisplayOptions) -> void:
	
	current_display_mode = display_mode
	
	for child in assets_root.get_children():
		if child is Compare3DViewElement:
			apply_current_display_mode(child)

func apply_current_display_mode(element: Compare3DViewElement) -> void:
	match current_display_mode:
		DisplayOptionsButton.DisplayOptions.SHADED:
			element.display_as_shaded()
		DisplayOptionsButton.DisplayOptions.WIREFRAME:
			element.display_as_wireframe()
		DisplayOptionsButton.DisplayOptions.UV:
			element.display_as_uv()

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
