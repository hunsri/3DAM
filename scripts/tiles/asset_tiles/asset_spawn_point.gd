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
var default_spring_arm_transform: Transform3D

@export var disable_zoom: bool
@export var disable_position_change: bool

var _model_too_far_on_start: bool
var _model_aligned = false

const COOLDOWN_CYCLES: int = 20 ## Arbitrary set amount of process cycles to wait for

var _cooldown_process_skip = COOLDOWN_CYCLES
var _correction_pass_done = false


func _ready() -> void:
	if !visible:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	default_spring_arm_transform = spring_arm_3d.transform

## Forces a waiting period to give the model enough time to load
## Basically a little hack to ensure model alignment has something to work with
## Returns `true` while in wait cycle, `false` when wait cycle is over
func _wait_cycle() -> bool:
	
	if _cooldown_process_skip > 0:
		_cooldown_process_skip -= 1
		if _cooldown_process_skip == 1: # setting things up on last wait cycle
			# if the WHOLE model is visible at start we assume it is too far away from the camera 
			_model_too_far_on_start = AABB_Utils.is_aabb_fully_inside_camera(AABB_Utils.get_world_aabb(self), spring_arm_3d.get_child(0))
		return true
	
	return false

func _process(delta: float) -> void:
	
	# guard releases once wait cycle is over
	if _wait_cycle():
		return
	
	if not _model_aligned:
		
		# we only need this once to help camera alignment by centering it on the AABB of the model
		var aabb = AABB_Utils.get_world_aabb(self)
		spring_arm_3d.position.y = (aabb.position.y + aabb.size.y/2)
		default_spring_arm_transform = spring_arm_3d.transform
		
		_align_pivot()
		
		_align_model(spring_arm_3d.get_child(0), delta)
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
	
	if event is InputEventMouseMotion and moving and not disable_position_change:
		# moving gets faster, the more zoomed out we are
		spring_arm_3d.position.x -= event.relative.x * moving_sensitivity * (spring_arm_3d.spring_length + 1)
		spring_arm_3d.position.y += event.relative.y * moving_sensitivity * (spring_arm_3d.spring_length + 1)
	
	if event is InputEventMouseButton and not disable_zoom:
		
		# zoom gets faster, the further we are zoomed out
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm_3d.spring_length -= zoom_speed * spring_arm_3d.spring_length
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm_3d.spring_length += zoom_speed * spring_arm_3d.spring_length

## Signal expected to connect from SubViewport Container 
func _on_sub_viewport_container_mouse_entered() -> void:
	mouse_in_container = true

## Signal expected to connect from SubViewport Container 
func _on_sub_viewport_container_mouse_exited() -> void:
	mouse_in_container = false
	rotating = false

func reset() -> void:
	rotation = Vector3(0,0,0)
	spring_arm_3d.spring_length = default_spring_length
	spring_arm_3d.transform = default_spring_arm_transform

func _align_model(camera: Camera3D, delta: float) -> void:
	var too_far: bool = AABB_Utils.is_aabb_fully_inside_camera(AABB_Utils.get_world_aabb(self), camera)
	
	const step = 8 # arbitrary set amount that controls the step speed of the alignment
	
	if _model_too_far_on_start:
		if !too_far:
			_model_aligned = true
			_correction_pass() # resets the alignment flags once
		spring_arm_3d.spring_length -= delta * step * spring_arm_3d.spring_length
	else:
		if too_far:
			_model_aligned = true
			_correction_pass() # resets the alignment flags once
		spring_arm_3d.spring_length += delta * step * spring_arm_3d.spring_length

## Ensures that when rotating the asset the pivot point is set to the center of the bounding box of the asset
func _align_pivot() -> void:
	if self.get_child_count() == 0:
		return
	
	var y_height: float = AABB_Utils.get_world_aabb(self).size.y
	var model: Node3D = self.get_child(0)
	model.position.y = -y_height/2

## Resets the alignment flags, to run alignment again, based on the first alignment result
## Basically running the zooming test a second time, but from a better starting position 
func _correction_pass() -> void:
	
	if _correction_pass_done:
		return
	
	_cooldown_process_skip = COOLDOWN_CYCLES
	_model_aligned = false
	_correction_pass_done = true
