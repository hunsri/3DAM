class_name AssetPopup extends Node

@onready var _close_button: Button = $CloseButton
const ASSET_POPUP = preload("uid://cgdpvd8fr45vj")
@onready var compare_manager: CompareManager = $ScrollContainer/CompareManager

static func create_instance() -> AssetPopup:
	return ASSET_POPUP.instantiate()
	
func _ready() -> void:
	_close_button.pressed.connect(_close_popup)

func setup(asset_tile: AbstractAssetTile, parent_node: Node) -> void:
	parent_node.add_child(self)
	
	compare_manager.insert_compare_model_from_tile(asset_tile)
	
	var element: DetailsElement = compare_manager.details_elements[0]
	
	element.set_to_single_mode()

func _close_popup() -> void:
	self.queue_free()
