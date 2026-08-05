class_name SizeMarker extends Node3D

var _current_range_godot_meter: float = 1
const LOWEST_LABEL_AMOUNT: int = 3 ## below this, switch to lower scale
## size-level 0 represents the smallest used level of a scale e.g. Centimeter
var displayed_scale_size_level = 0

# a bit of a hack with the keys, but allows for potential future sub scales like cm
const GODOT_METER_SCALE_MAP: Dictionary[String, float]= {
	"m  ": 0.01,
	"m ": 0.1,
	"m": 1,
	"m   ": 10
}

func set_display_range_godot_meters(upper_limit: float) -> void:
	_current_range_godot_meter = upper_limit

func _find_optimal_scale_level(used_scale: Dictionary[String, float]) -> int:
	
	var last_key_index_within_range: int = 0
	
	# FIXME index return weird
	for scale_size in used_scale.values():
		var scale_threshold = _current_range_godot_meter / scale_size / LOWEST_LABEL_AMOUNT
		if scale_threshold <= 1:
			return last_key_index_within_range-1
		else:
			last_key_index_within_range += 1
			
	return last_key_index_within_range-1

func update_markers(camera: DebugCamera3D, displayed_upper_bound: float) -> void:
	_current_range_godot_meter = displayed_upper_bound
	
	_clear_markers()
	
	create_scale_markers(camera)

func _clear_markers() -> void:
	for child in get_children():
		child.queue_free()

func create_scale_markers(camera: DebugCamera3D, used_scale: Dictionary[String, float] = GODOT_METER_SCALE_MAP) -> void:
	
	displayed_scale_size_level = _find_optimal_scale_level(used_scale)
	
	var item_scale_size: float = used_scale.values()[displayed_scale_size_level]
	
	var label := Label3D.new()
	
	var last_position: = Vector3(0, 0, 0)
	
	for i in range(1,100):
		
		label = Label3D.new()
		label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
		label.offset = Vector2(10, 0)
		label.scale = Vector3.ONE * camera.size / 10
		
		label.position = last_position + Vector3(0, item_scale_size, 0)
		label.text = str(item_scale_size*i).rstrip("0").rstrip(".")+used_scale.keys()[displayed_scale_size_level]
		last_position = label.position
		
		add_child(label)
		
	
