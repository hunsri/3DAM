class_name Compare3DViewManager extends AbstractCompareViewManager

@onready var compare_manager: CompareManager = $"../.."

@onready var compare_3d_environment: Compare3DEnvironment = $VBoxContainer/Compare3DEnvironment

const COMPARE_3D_VIEW_ELEMENT = preload("uid://cjvvtymoclsb2")

var tile: AssetTile2D
var current_display_mode := DisplayOptionsButton.DisplayOptions.SHADED

func set_hdri_background(hdri: Texture2D) -> void:
	if hdri == null:
		compare_3d_environment.compare_3d_world_environment.environment.sky.sky_material = ProceduralSkyMaterial.new()
		return
	
	var sky_material := PanoramaSkyMaterial.new()
	sky_material.panorama = hdri
	
	compare_3d_environment.compare_3d_world_environment.environment.sky.sky_material = sky_material

func create_model_compare_element(asset: AbstractAssetTile, index: int) -> void:
	
	var model_node: Node3D = attach_model_from_tile(asset)
	if model_node == null:
		return
	
	var compare_3d_view_element: Compare3DViewElement = COMPARE_3D_VIEW_ELEMENT.instantiate()
	compare_3d_view_element.name = "Compare3DViewElement_%s" % Time.get_ticks_usec()
	
	compare_3d_environment.assets_root.add_child(compare_3d_view_element)
	
	compare_3d_view_element.setup(model_node, index, compare_3d_environment.get_floor_plane_instance())
	
	apply_current_display_mode(compare_3d_view_element)
	
	compare_3d_environment.hide_empty_note()

func remove_model_compare_element(index: int) -> void:
	
	var element3D: Compare3DViewElement = compare_3d_environment.assets_root.get_child(index)
	
	element3D.remove()
	
	# at this point the removed asset is internally still in the tree
	# so we expect this 1 child element still left in the tree, but it will be removed later 
	if compare_3d_environment.assets_root.get_child_count() == 1:
		compare_3d_environment.display_empty_note()

func set_display_mode(display_mode: DisplayOptionsButton.DisplayOptions) -> void:
	
	current_display_mode = display_mode
	
	for child in compare_3d_environment.assets_root.get_children():
		if child is Compare3DViewElement:
			apply_current_display_mode(child)

func apply_current_display_mode(element: Compare3DViewElement) -> void:
	match current_display_mode:
		DisplayOptionsButton.DisplayOptions.SHADED:
			element.display_as_shaded()
		DisplayOptionsButton.DisplayOptions.UNSHADED:
			element.display_as_unshaded()
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
