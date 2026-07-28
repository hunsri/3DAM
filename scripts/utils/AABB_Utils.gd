class_name AABB_Utils extends Node

static func get_world_aabb(root: Node3D) -> AABB:
	var result := AABB()
	var has_aabb := false

	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D

		if mesh_instance.mesh == null:
			continue

		var local_aabb := mesh_instance.get_aabb()

		for corner in get_aabb_corners(local_aabb):
			var world_corner := mesh_instance.global_transform * corner

			if not has_aabb:
				result = AABB(world_corner, Vector3.ZERO)
				has_aabb = true
			else:
				result = result.expand(world_corner)

	return result


static func get_aabb_corners(aabb: AABB) -> Array[Vector3]:
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


static func is_aabb_fully_inside_camera(aabb: AABB, camera: Camera3D) -> bool:
	var frustum_planes := camera.get_frustum()
	var corners := get_aabb_corners(aabb)

	for plane in frustum_planes:
		for corner in corners:
			if plane.is_point_over(corner):
				return false

	return true
