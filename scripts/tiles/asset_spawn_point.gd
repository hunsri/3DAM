extends Node3D
@export var spring_arm_3d: SpringArm3D

var rotating = false
var mouse_in_container = false

var prev_mouse_position

var dragging := false
var sensitivity := 0.01
var zoom_speed := 0.1
var distance_delta := 0.0

var moving := false
var moving_sensitivity := 0.001

var default_spring_length: float

func _ready() -> void:
	default_spring_length = spring_arm_3d.spring_length

func _input(event):
	if not mouse_in_container:
		moving = false
		dragging = false
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			moving = false
			dragging = event.pressed
			prev_mouse_position = event.position
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = false
			moving = event.pressed
			prev_mouse_position = event.position
		
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			reset()
	
	if event is InputEventMouseMotion and dragging:
		rotate_y(event.relative.x * sensitivity)
		rotate_x(event.relative.y * sensitivity)
	
	if event is InputEventMouseMotion and moving:
		# moving gets faster, the more zoomed out we are
		spring_arm_3d.position.x -= event.relative.x * moving_sensitivity * (spring_arm_3d.spring_length + 1)
		spring_arm_3d.position.y += event.relative.y * moving_sensitivity * (spring_arm_3d.spring_length + 1)
	
	if event is InputEventMouseButton:
		# zoom gets faster, the further we are zoomed out
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm_3d.spring_length -= zoom_speed * spring_arm_3d.spring_length
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm_3d.spring_length += zoom_speed * spring_arm_3d.spring_length

func _on_sub_viewport_container_mouse_entered() -> void:
	mouse_in_container = true
	
func _on_sub_viewport_container_mouse_exited() -> void:
	mouse_in_container = false
	rotating = false

func reset() -> void:
	rotation = Vector3(0,0,0)
	spring_arm_3d.spring_length = default_spring_length
	spring_arm_3d.position = Vector3(0,0,0)
