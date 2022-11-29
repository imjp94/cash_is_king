tool
extends Camera

signal target_changed(to)
signal pivot_changed(to)
signal aabb_holder_changed(to)

export(NodePath) var target setget set_target
export(NodePath) var pivot setget set_pivot
export(NodePath) var aabb_holder setget set_aabb_holder
export var ratio_to_screen_center = 0.5
export var transition_speed = 1.0
export var fit_margin = 0.0
export(NodePath) var camera_override

var enable_screen_smooth = true


func _process(delta):
	_process_focus(delta)
	_process_fit(delta)

var direction_t = 0.0
func _process_focus(delta):
	var pivot_ref = get_pivot_ref()
	if pivot_ref:
		var to_pos = pivot_ref.global_transform.origin
		var from_pos = global_transform.origin
		global_transform.origin.x = lerp(from_pos.x, to_pos.x, delta * transition_speed)
		global_transform.origin.y = lerp(from_pos.y, to_pos.y, delta * transition_speed)
		global_transform.origin.z = lerp(from_pos.z, to_pos.z, delta * transition_speed)
	
	var target_ref = get_target_ref()
	if target_ref:
		var target_pos = target_ref.global_transform.origin
		if get_viewport() and enable_screen_smooth:
			var screen_center = get_viewport().size / 2.0
			var target_screen_pos = get_viewport().get_camera().unproject_position(target_pos)
			var target_to_center_screen_distance = screen_center.distance_to(target_screen_pos)
			var max_distance_to_screen = max(get_max_distance_to_screen_center(), target_to_center_screen_distance)
			direction_t = target_to_center_screen_distance / max_distance_to_screen
			direction_t = max(direction_t, 0.0)
		else:
			direction_t = lerp(direction_t, 1.0, delta)
		var from_basis = global_transform.basis
		var to_basis = get_look_at_basis(global_transform.origin, target_pos, Vector3.UP)
		global_transform.basis = from_basis.slerp(to_basis, delta * (exp(direction_t)-1.0))

func _process_fit(delta):
	var aabb_holder_ref = get_aabb_holder_ref()
	if not aabb_holder_ref:
		return

	var pivot_ref = get_pivot_ref()
	if not pivot_ref:
		pivot_ref = self

	var fit_aabb = aabb_holder_ref.aabb
	var distance = distance_of(get_aabb_diameter(fit_aabb)) + near + fit_margin
	var dir = aabb_holder_ref.global_transform.origin.direction_to(pivot_ref.global_transform.origin)

	var from_pos = global_transform.origin
	var to_pos = aabb_holder_ref.global_transform.origin + (distance + near + fit_margin) * dir
	global_transform.origin.x = lerp(from_pos.x, to_pos.x, delta * transition_speed)
	global_transform.origin.y = lerp(from_pos.y, to_pos.y, delta * transition_speed)
	global_transform.origin.z = lerp(from_pos.z, to_pos.z, delta * transition_speed)

func get_target_ref():
	var target_ref
	if camera_override:
		var camera_override_ref = get_node_or_null(camera_override)
		if camera_override_ref:
			var camera_override_ref_target = camera_override_ref.call("get_target_ref")
			if camera_override_ref_target:
				target_ref = camera_override_ref_target
	else:
		target_ref = get_aabb_holder_ref()
		if not target_ref:
			target_ref = get_node_or_null(target)

	return target_ref

func get_pivot_ref():
	var pivot_ref
	if camera_override:
		var camera_override_ref = get_node_or_null(camera_override)
		if camera_override_ref:
			var camera_override_ref_pivot = camera_override_ref.call("get_pivot_ref")
			if camera_override_ref_pivot:
				pivot_ref = camera_override_ref_pivot
	else:
		pivot_ref = get_node_or_null(pivot)

	return pivot_ref

func get_aabb_holder_ref():
	var aabb_holder_ref
	if camera_override:
		var camera_override_ref = get_node_or_null(camera_override)
		if camera_override_ref:
			var camera_override_ref_aabb_holder = camera_override_ref.call("get_aabb_holder_ref")
			if camera_override_ref_aabb_holder:
				aabb_holder_ref = camera_override_ref_aabb_holder
	else:
		aabb_holder_ref = get_node_or_null(aabb_holder)

	return aabb_holder_ref

func distance_of(frustum_height):
	return (frustum_height * 0.5) / tan(deg2rad(fov * 0.5))

func get_aabb_diameter(aabb):
	return max(max(aabb.size.x, aabb.size.y), aabb.size.z)

func get_aabb_center(aabb):
	return aabb.position + aabb.size / 2.0

func get_max_distance_to_screen_center():
	return ratio_to_screen_center * min(get_viewport().size.x, get_viewport().size.y)

# TODO: Move to Util
func get_look_at_basis(from, to, up):
	var vx
	var vy
	var vz
	vz = from - to
	vz = vz.normalized()
	vy = up
	vx = vy.cross(vz)

	vy = vz.cross(vx)
	vx = vx.normalized()
	vy = vy.normalized()

	return Basis(vx, vy, vz)

func set_target(path):
	if target != path:
		target = path
		emit_signal("target_changed", target)

func set_pivot(path):
	if pivot != path:
		pivot = path
		emit_signal("pivot_changed", pivot)

func set_aabb_holder(path):
	if aabb_holder != path:
		aabb_holder = path
		emit_signal("aabb_holder_changed", aabb_holder)
