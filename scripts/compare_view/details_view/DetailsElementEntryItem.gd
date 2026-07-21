class_name DetailsElementEntryItem extends Node

@export var key: Label
@export var value: Label
@onready var bg_2: Panel = $BG2

func _ready() -> void:
	if self.get_index() % 2 == 0:
		bg_2.visible = true

func setup(p_key: String, p_value: String) -> void:
	key.text = p_key
	value.text = p_value
