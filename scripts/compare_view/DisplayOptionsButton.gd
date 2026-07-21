class_name DisplayOptionsButton extends Button

enum DisplayOptions {SHADED, WIREFRAME, UV}

@export var display_mode: DisplayOptions
@onready var details_view: AbstractCompareViewManager = $"../../../.."


func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	details_view.set_display_mode(display_mode)
