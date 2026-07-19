## Script for folding and unfolding a HSplitContainer container
extends Button

@export var is_folding: bool = false
@export var foldable_container: HSplitContainer

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	foldable_container.get_child(0).visible = !is_folding
	foldable_container.get_child(1).visible = is_folding
