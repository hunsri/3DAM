class_name Compare2DEnvironment extends Node

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var debug_camera_3d: DebugCamera3D = $SubViewportContainer/SubViewport/Environment/DebugCamera3D
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

@onready var scale_plus: Button = $"VBoxContainer/scale-plus"
@onready var scale_indicator: Button = $"VBoxContainer/scale-indicator"
@onready var scale_minus: Button = $"VBoxContainer/scale-minus"

var dragging := false
var last_pos := Vector2.ZERO

var zoom_factor: float = 1.0
const BASE_ZOOM: float = 10

#func _process(delta: float) -> void:


func _ready():
	sub_viewport.size_changed.connect(_align_camera)
	sub_viewport_container.gui_input.connect(_on_gui_event)
	
	scale_plus.pressed.connect(_scale_up)
	scale_minus.pressed.connect(_scale_down)
	scale_indicator.pressed.connect(_reset_scale)
	
	debug_camera_3d.size = BASE_ZOOM * zoom_factor

func _align_camera(force_x_align: bool = false) -> void:
	var viewport_size := sub_viewport.get_visible_rect().size
	var aspect := viewport_size.x / viewport_size.y
	
	var visible_height: float = debug_camera_3d.size
	var visible_width: float = debug_camera_3d.size * aspect
	
	# experimental lock to prevent -x out of bounds
	if get_left_camera_border(debug_camera_3d) < 0 || force_x_align:
		debug_camera_3d.position.x = visible_width * 0.5
		
	debug_camera_3d.position.y = visible_height * 0.5

func get_left_camera_border(camera: DebugCamera3D) -> float:
	var viewport_size := camera.get_viewport().get_visible_rect().size
	var aspect := viewport_size.x / viewport_size.y
	
	var horizontal_size := camera.size * aspect
	
	return camera.global_position.x - horizontal_size * 0.5

func _on_gui_event(event: InputEvent):
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		last_pos = event.position
	
	elif event is InputEventMouseMotion and dragging:
		var delta: Vector2 = event.position - last_pos
		# a little hacky, but should keep the dragging speed close to comfort
		var drag_speed: float = -delta.x/100*zoom_factor
		debug_camera_3d.position += Vector3(drag_speed, 0, 0)
		last_pos = event.position
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		debug_camera_3d.position += Vector3(-event.factor/10, 0, 0)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		debug_camera_3d.position += Vector3(event.factor/10, 0, 0)
	
	_align_camera()

func _scale_up():
	var align_x = get_left_camera_border(debug_camera_3d) < 0.5
	
	zoom_factor /= 2
	scale_indicator.text = "%.1f%%" % (zoom_factor*100)
	
	debug_camera_3d.size = BASE_ZOOM * zoom_factor
	
	_align_camera(align_x)

func _scale_down():
	zoom_factor *= 2
	scale_indicator.text = "%.1f%%" % (zoom_factor*100)
	
	debug_camera_3d.size = BASE_ZOOM * zoom_factor
	_align_camera()
	
func _reset_scale():
	zoom_factor = 1
	scale_indicator.text = "%.1f%%" % (zoom_factor*100)
	
	debug_camera_3d.size = BASE_ZOOM * zoom_factor
	_align_camera()
