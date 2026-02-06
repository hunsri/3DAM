extends Node

var ASSET_VIEW_2D_LINE = preload("uid://dg77jbtit2go")
var LOCATION_BUTTON_GROUP = preload("uid://mu8a2ehudi1e")

func create_tile_line():
	var tile_line = ASSET_VIEW_2D_LINE.instantiate()
	return tile_line
