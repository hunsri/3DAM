class_name Compare3DEnvironment extends PanelContainer
@onready var hide_lookdev_button: Button = $VBoxContainer/HideLookdevButton
@onready var show_lookdev_button: Button = $VBoxContainer/ShowLookdevButton

@onready var lookdev: Node3D = $VBoxContainer/SubViewportContainer/SubViewport/Environment/DebugCamera3D/Lookdev
@onready var assets_root: Node3D = $VBoxContainer/SubViewportContainer/SubViewport/Environment/AssetsRoot
@onready var compare_3d_world_environment: WorldEnvironment = $VBoxContainer/SubViewportContainer/SubViewport/Environment/Compare3DWorldEnvironment

@onready var _floor_plane_reference: MeshInstance3D = $VBoxContainer/SubViewportContainer/SubViewport/EmptyNoteNode/FloorPlaneReference
@onready var _empty_note_node: Node3D = $VBoxContainer/SubViewportContainer/SubViewport/EmptyNoteNode

var lookdev_position: Vector3
var lookdev_hide_position: Vector3

const LOOKDEV_HIDE_SPEED: float = 2.5

func _ready() -> void:
	
	hide_lookdev_button.pressed.connect(_hide_lookdev)
	show_lookdev_button.pressed.connect(_show_lookdev)
	
	lookdev_position = lookdev.position
	# we just need to move it a bit out of view
	lookdev_hide_position += Vector3(0, lookdev_position.y - 0.1, 0)
	
func _hide_lookdev() -> void:
	hide_lookdev_button.visible = false
	show_lookdev_button.visible = true
	
	_move_lookdev_to_point(lookdev_hide_position, LOOKDEV_HIDE_SPEED)
	
func _show_lookdev() -> void:
	hide_lookdev_button.visible = true
	show_lookdev_button.visible = false
	
	_move_lookdev_to_point(lookdev_position, LOOKDEV_HIDE_SPEED)

func _move_lookdev_to_point(target: Vector3, speed: float) -> void:
	var distance := lookdev.position.distance_to(target)
	var duration := distance / speed
	create_tween().tween_property(lookdev, "position", target, duration)

func get_floor_plane_instance() -> MeshInstance3D:
	var ret: MeshInstance3D = _floor_plane_reference.duplicate()
	return ret

func display_empty_note() -> void:
	_empty_note_node.visible = true

func hide_empty_note() -> void:
	_empty_note_node.visible = false
