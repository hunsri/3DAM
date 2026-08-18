extends Button

@export var button_pressed_text: String
@export var button_pressed_icon: Texture2D

var button_original_text: String
var button_original_icon: Texture2D

func _ready() -> void:
	button_original_text = text
	button_original_icon = icon

func _pressed() -> void:
	text = button_pressed_text
	icon = button_pressed_icon
	disabled = true
	
