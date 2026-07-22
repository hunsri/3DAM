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

func _ready() -> void:
    
    # if the WHOLE model is visible at start we assume it is too far away from the camera 
    _model_too_far_on_start = is_aabb_fully_inside_camera(_get_world_aabb(self), spring_arm_3d.get_child(0))
    
    default_spring_arm_transform = spring_arm_3d.transform

func _process(delta: float) -> void:
    if not _model_aligned:
        _model_aligned = _align_model(spring_arm_3d.get_child(0), delta)
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

func _align_model(camera: Camera3D, delta: float) -> bool:
    var too_far: bool = is_aabb_fully_inside_camera(_get_world_aabb(self), camera)
    
    const step = 8
    
    if _model_too_far_on_start:
        if not too_far:
            return true
        spring_arm_3d.spring_length -= delta * step * spring_arm_3d.spring_length
    else:
        if too_far:
            return true
        spring_arm_3d.spring_length += delta * step * spring_arm_3d.spring_length
        
    
    return false


###  AI assisted code below ###

func _get_world_aabb(root: Node3D) -> AABB:
    var result := AABB()
    var has_aabb := false

    for node in root.find_children("*", "MeshInstance3D", true, false):
        var mesh_instance := node as MeshInstance3D

        if mesh_instance.mesh == null:
            continue

        var local_aabb := mesh_instance.get_aabb()

        for corner in _get_aabb_corners(local_aabb):
            var world_corner := mesh_instance.global_transform * corner

            if not has_aabb:
                result = AABB(world_corner, Vector3.ZERO)
                has_aabb = true
            else:
                result = result.expand(world_corner)

    return result


func _get_aabb_corners(aabb: AABB) -> Array[Vector3]:
    var p := aabb.position
    var e := aabb.end

    return [
        Vector3(p.x, p.y, p.z),
        Vector3(e.x, p.y, p.z),
        Vector3(p.x, e.y, p.z),
        Vector3(e.x, e.y, p.z),

        Vector3(p.x, p.y, e.z),
        Vector3(e.x, p.y, e.z),
        Vector3(p.x, e.y, e.z),
        Vector3(e.x, e.y, e.z)
    ]


func is_aabb_fully_inside_camera(aabb: AABB, camera: Camera3D) -> bool:
    var frustum_planes := camera.get_frustum()
    var corners := _get_aabb_corners(aabb)

    for plane in frustum_planes:
        for corner in corners:
            if plane.is_point_over(corner):
                return false

    return true
