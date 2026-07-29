@abstract class_name AbstractCompareViewManager extends Node

@abstract func get_compare_manager() -> CompareManager

@abstract func create_model_compare_element(tile: AbstractAssetTile, index: int) -> void

@abstract func remove_model_compare_element(index: int)

@abstract func set_display_mode(display_mode: DisplayOptionsButton.DisplayOptions)
