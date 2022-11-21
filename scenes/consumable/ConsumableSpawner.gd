extends Timer

export(PackedScene) var consumable_scn
export(NodePath) var nav_mesh_inst_np setget set_nav_mesh_inst_np
export var spawn_radius = 30.0

var nav_mesh_inst


func _ready():
	set_nav_mesh_inst_np(nav_mesh_inst_np)
	connect("timeout", self, "_on_timeout")

func _on_timeout():
	spawn()

func spawn():
	if not consumable_scn:
		return

	var inst = consumable_scn.instance()
	get_parent().add_child(inst)
	inst.global_transform.origin = get_random_nav_pos()

func get_random_nav_pos():
	var target_pos = Vector3.ZERO
	if nav_mesh_inst:
		var random_pos = Vector3(rand_range(-spawn_radius, spawn_radius), 0, rand_range(-spawn_radius, spawn_radius))
		target_pos = NavigationServer.map_get_closest_point(NavigationServer.region_get_map(nav_mesh_inst.get_region_rid()), random_pos)
	return target_pos

func set_nav_mesh_inst_np(v):
	nav_mesh_inst_np = v
	if nav_mesh_inst_np:
		nav_mesh_inst = get_node_or_null(nav_mesh_inst_np)
