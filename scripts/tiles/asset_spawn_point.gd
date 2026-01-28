extends Node3D
@onready var spring_arm_3d: SpringArm3D = %SpringArm3D

var rotating = false
var mouse_in_container = false

var prev_mouse_position
var next_mouse_position

func _process(delta):
	if not mouse_in_container:
		return
	
	if Input.is_action_just_pressed("rotate"):
		rotating = true
		prev_mouse_position = get_viewport().get_mouse_position()
	if Input.is_action_just_released("rotate"):
		rotating = false
		
	if rotating:
		next_mouse_position = get_viewport().get_mouse_position()
		rotate_y((next_mouse_position.x - prev_mouse_position.x) * .1 * delta)
		rotate_z(-(next_mouse_position.y - prev_mouse_position.y) * .1 * delta)
		rotate_x((next_mouse_position.y - prev_mouse_position.y) * .1 * delta)
		prev_mouse_position = next_mouse_position
	
	if Input.is_action_just_pressed("zoom_in"):
		spring_arm_3d.spring_length -= 0.1
	if Input.is_action_just_pressed("zoom_out"):
		spring_arm_3d.spring_length += 0.1


func _on_sub_viewport_container_mouse_entered() -> void:
	mouse_in_container = true
	
func _on_sub_viewport_container_mouse_exited() -> void:
	mouse_in_container = false
	rotating = false
