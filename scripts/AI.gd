tool
extends "res://scripts/Player.gd"

const StateDirectory = preload("res://addons/imjp94.yafsm/src/StateDirectory.gd")

onready var action_state = $ActionState

var _is_shooting = false
var _is_interacting = false


func _ready():
	action_state.connect("transited", self, "_on_action_state_transited")
	pawn.get_node("NavigationAgent").connect("velocity_computed", self, "_on_nav_agent_velocity_computed")
	pawn.get_node("NavigationAgent").connect("target_reached", self, "_on_nav_agent_target_reached")
	pawn.health.connect("changed", self, "_on_pawn_health_changed")

	for asset_building in get_tree().get_nodes_in_group("asset_building"):
		asset_building.connect("player_changed", self, "_on_asset_building_player_changed", [asset_building])

	action_state.set_param("empty_building", get_empty_buildings().size())

func _unhandled_input(event):
	if Engine.editor_hint:
		return
	# debug with mouse
	if not pawn:
		return

	var nav_agent = pawn.get_node_or_null("NavigationAgent")
	if not nav_agent:
		return
	
	var camera = get_viewport().get_camera()
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000

		var space_state = $"/root/Game".get_world().direct_space_state
		# use global coordinates, not local to node
		var result = space_state.intersect_ray(from, to)
		if not result.empty():
			var target_pos = NavigationServer.map_get_closest_point(nav_agent.get_navigation_map(), result.position)
			nav_agent.set_target_location(target_pos)
			$"/root/Game/Ball".global_transform.origin = target_pos

func _physics_process(delta):
	if Engine.editor_hint:
		return
	if not pawn:
		return
	var nav_agent = pawn.get_node_or_null("NavigationAgent")
	if not nav_agent:
		return
	if nav_agent.is_navigation_finished():
		return

	var next_pos = nav_agent.get_next_location()
	var dir = pawn.global_transform.origin.direction_to(next_pos)
	dir = dir.normalized()
	var right = dir.x
	var forward = -dir.z

	var vel = (Vector3.FORWARD * forward * pawn.speed) + (Vector3.RIGHT * right * pawn.speed)
	nav_agent.set_velocity(vel)

	pawn.turn(forward, right)

	if pawn.global_transform.origin.distance_to(nav_agent.get_target_location()) < 3:
		action_state.set_trigger("in_range")

func shooting_target():
	if not _is_shooting:
		return
	if pawn.health.value == 0:
		action_state.reset(1) # Idle located at index 1, right after Entry
		action_state.erase_param("empty_building")
		action_state.set_param("has_enough_money", false)
		return
	
	pawn.shoot()
	pawn.look_at(action_state.get_param("target").global_transform.origin, Vector3.UP)
	get_tree().create_timer(0.2).connect("timeout", self, "shooting_target")

func interacting():
	if not _is_interacting:
		return

	pawn.event()
	get_tree().create_timer(0.2).connect("timeout", self, "interacting")

func get_empty_buildings(exclude_bank=true):
	var asset_buildings = get_tree().get_nodes_in_group("asset_building")
	var count = asset_buildings.size()
	for i in count:
		var index = count - 1 - i
		var asset_building = asset_buildings[index] # Descending order
		if asset_building.has_player() or asset_building.is_in_group("bank"):
			asset_buildings.remove(index)
	return asset_buildings

func get_bank():
	var asset_buildings = get_tree().get_nodes_in_group("asset_building")
	var count = asset_buildings.size()
	for i in count:
		var index = count - 1 - i
		var asset_building = asset_buildings[index] # Descending order
		if asset_building.player == self and asset_building.is_in_group("bank"):
			return asset_building
	return null

func _on_action_state_transited(from, to):
	if not pawn:
		return
	var nav_agent = pawn.get_node_or_null("NavigationAgent")
	if not nav_agent:
		return

	var to_dir = StateDirectory.new(to)
	
	match to_dir.next():
		"Idle":
			var empty_buildings = get_empty_buildings()
			action_state.set_param("empty_building", empty_buildings.size())
		"Invest":
			match to_dir.next():
				"Depart":
					var empty_buildings = get_empty_buildings()
					if empty_buildings:
						var target = empty_buildings[0]
						var target_pos = NavigationServer.map_get_closest_point(nav_agent.get_navigation_map(), target.global_transform.origin)
						nav_agent.set_target_location(target_pos)
						action_state.set_param("target", target)
						$"/root/Game/Ball".global_transform.origin = target_pos
					else:
						action_state.set_trigger("done")
				"InRange":
					_is_shooting = true
					shooting_target()
				"Arrive":
					var target = action_state.get_param("target")
		"Withdraw":
			match to_dir.next():
				"Depart":
					var target = get_bank()
					var target_pos = NavigationServer.map_get_closest_point(nav_agent.get_navigation_map(), target.global_transform.origin)
					nav_agent.set_target_location(target_pos)
					action_state.set_param("target", target)
					$"/root/Game/Ball".global_transform.origin = target_pos
				"InRange":
					_is_interacting = true
					interacting()
				"Arrive":
					var target = action_state.get_param("target")
				"Finish":
					action_state.set_trigger("done")
				"Exit":
					action_state.erase_param("has_enough_money")

func _on_asset_building_player_changed(from, to, asset_building):
	var empty_buildings = get_empty_buildings()
	action_state.set_param("empty_building", empty_buildings.size())
	if action_state.current == "Invest" and empty_buildings.size() == 0:
		action_state.set_trigger("abort")

	if action_state.current == "Invest/Arrive":
		if asset_building == action_state.get_param("target") and to == self:
			action_state.set_trigger("done")
			_is_shooting = false

func _on_nav_agent_velocity_computed(safe_velocity):
	pawn.linear_velocity = safe_velocity

func _on_nav_agent_target_reached():
	action_state.set_trigger("arrived")

func _on_pawn_health_changed(diff):
	if pawn.health.value >= 10 and _is_interacting:
		_is_interacting = false
		action_state.set_trigger("done")
