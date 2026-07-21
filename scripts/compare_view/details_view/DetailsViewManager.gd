class_name DetailsViewManager extends AbstractCompareViewManager

const DETAILS_ELEMENT = preload("uid://vbl42yegec85")

@onready var details_root: HBoxContainer = $VBoxContainer/ScrollContainer/DetailsRoot

var current_display_mode: DisplayOptionsButton.DisplayOptions = DisplayOptionsButton.DisplayOptions.SHADED

func create_details_element(tile: AbstractAssetTile) -> void:
	var detail_item: DetailsElement = DETAILS_ELEMENT.instantiate()
	
	detail_item.setup(tile)
	apply_current_display_mode(detail_item)
	details_root.add_child(detail_item)
	
	details_root.move_child(detail_item, 1)
	 
func apply_current_display_mode_to_all() -> void:
	for child in details_root.get_children():
		if child is DetailsElement:
			apply_current_display_mode(child)

func apply_current_display_mode(details_element: DetailsElement) -> void:
	match current_display_mode:
		DisplayOptionsButton.DisplayOptions.SHADED:
			details_element.display_as_shaded()
		DisplayOptionsButton.DisplayOptions.WIREFRAME:
			details_element.display_as_wireframe()
		DisplayOptionsButton.DisplayOptions.UV:
			details_element.display_as_uv()

func set_display_mode(display_mode: DisplayOptionsButton.DisplayOptions) -> void:
	current_display_mode = display_mode
	apply_current_display_mode_to_all()
