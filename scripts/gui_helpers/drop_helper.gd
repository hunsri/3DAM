extends Control

@onready var hover_indicator: ColorRect = $HoverIndicator
@onready var compare_view_manager: AbstractCompareViewManager = $"../../../../../.."

func _ready() -> void:
	mouse_exited.connect(_on_control_mouse_exited)

func _on_control_mouse_exited() -> void:
	hover_indicator.visible = false

func _can_drop_data(at_position, drop_data: Variant):
	if drop_data.payload is AbstractAssetTile:
		hover_indicator.visible = true
		return true
	else:
		return false

func _drop_data(at_position, drop_data: Variant):
	
	hover_indicator.visible = false
	
	var data := drop_data.payload as AbstractAssetTile
	
	var tile: AssetTile2D = data as AssetTile2D
	compare_view_manager.get_compare_manager().insert_compare_model_from_tile(tile)
	
	
