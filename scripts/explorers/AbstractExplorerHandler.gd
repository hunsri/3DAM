@abstract class_name AbstractExplorerHandler extends Node

# Abstract class for implementing the different explorer types for
# the explorers in the Local and Server view

@abstract func reload_explorer()

@abstract func asset_clicked(tile: AbstractAssetTile) -> void
