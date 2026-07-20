class_name DetailsViewManager extends Node

const DETAILS_ELEMENT = preload("uid://vbl42yegec85")

@onready var details_root: HBoxContainer = $VBoxContainer/ScrollContainer/DetailsRoot

func create_details_element(tile: AbstractAssetTile) -> void:
	var detail_item: DetailsElement = DETAILS_ELEMENT.instantiate()
	
	detail_item.setup(tile)
	details_root.add_child(detail_item)
	
	
	
