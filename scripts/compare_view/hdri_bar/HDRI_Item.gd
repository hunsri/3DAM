class_name HDRI_Item extends Node
@onready var hdri_bar: HDRI_Bar = $"../../.."

@export var texture_rect: TextureRect
@export var name_label: Label
@export var button: Button
var hdr: Texture2D = null

var path_to_hdr: String

func _ready():
	button.pressed.connect(_on_button_pressed)

func setup(p_path_to_hdr: String) -> void:
	path_to_hdr = p_path_to_hdr
	
	hdr = load_hdr_from_file(path_to_hdr)
	
	texture_rect.texture = hdr
	
	button.tooltip_text = path_to_hdr.get_basename().get_file()
	name_label.text = path_to_hdr.get_basename().get_file()

func load_hdr_from_file(path: String) -> Texture2D:
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(img)

func _on_button_pressed():
	hdri_bar.compare_3d_view_manager.set_hdri_background(hdr)
