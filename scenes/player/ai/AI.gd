tool
extends "res://scenes/player/Player.gd"

const StateDirectory = preload("res://addons/imjp94.yafsm/src/StateDirectory.gd")

onready var action_state = $ActionState

var _is_shooting = false
var _is_interacting = false


func _ready():
	action_state.connect("transited", self, "_on_action_state_transited")

	for asset_building in get_tree().get_nodes_in_group("asset_building"):
		asset_building.connect("player_changed", self, "_on_asset_building_player_changed", [asset_building])

	action_state.set_param("empty_building", get_empty_buildings().size())

	connect("pawn_changed", self, "_on_pawn_changed")

func _unhandled_input(event):
	if Engine.editor_hint:
		return
	# debug with mouse
	if not is_instance_valid(pawn):
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

func _process(delta):
	if Engine.editor_hint:
		return
	if not enable_input:
		return
	if not is_instance_valid(pawn):
		return
	var nav_agent = pawn.get_node_or_null("NavigationAgent")
	if not nav_agent:
		return
	
	var owned_buildings = get_owned_buildings()
	if owned_buildings:
		var building_mature = false
		for owned_building in owned_buildings:
			if owned_building.health.value >= 15:
				building_mature = true
				break
		action_state.set_param("building_mature", building_mature)

	var opponent_buildings = get_buildings(false, [self])
	for opponent_building in opponent_buildings:
		if opponent_building.health <= pawn.health:
			action_state.set_param("can_buy_out", true)
			var target = opponent_building
			action_state.set_param("target", opponent_building)
			navigate_pawn(nav_agent, target)
			if is_nav_agent_target_reached(nav_agent):
				action_state.set_trigger("in_range")

func _physics_process(delta):
	if Engine.editor_hint:
		return
	if not enable_input:
		return
	if not is_instance_valid(pawn):
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
	if not enable_input:
		return
	if not _is_shooting:
		return
	if not is_instance_valid(pawn):
		return
	if pawn.health.value == 0:
		action_state.reset(1) # Idle located at index 1, right after Entry
		action_state.erase_param("empty_building")
		action_state.set_param("has_enough_money", false)
		return
	
	pawn.attack()
	pawn.look_at(action_state.get_param("target").global_transform.origin, Vector3.UP)
	get_tree().create_timer(0.2).connect("timeout", self, "shooting_target")

func interacting():
	if not enable_input:
		return
	if not _is_interacting:
		return
	if not is_instance_valid(pawn):
		_is_interacting = false
		return

	pawn.event()
	get_tree().create_timer(0.2).connect("timeout", self, "interacting")

func get_buildings(exclude_bank=true, exclude_owners=[]):
	var asset_buildings = get_tree().get_nodes_in_group("asset_building")
	var count = asset_buildings.size()
	for i in count:
		var index = count - 1 - i
		var asset_building = asset_buildings[index] # Descending order
		if asset_building.player in exclude_owners or (asset_building.is_in_group("bank") and exclude_bank):
			asset_buildings.remove(index)
	return asset_buildings

func get_empty_buildings(exclude_bank=true):
	var asset_buildings = get_tree().get_nodes_in_group("asset_building")
	var count = asset_buildings.size()
	for i in count:
		var index = count - 1 - i
		var asset_building = asset_buildings[index] # Descending order
		if asset_building.has_player() or (asset_building.is_in_group("bank") and exclude_bank):
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

func get_owned_buildings(exclude_bank=true):
	var asset_buildings = get_tree().get_nodes_in_group("asset_building")
	var count = asset_buildings.size()
	for i in count:
		var index = count - 1 - i
		var asset_building = asset_buildings[index] # Descending order
		if asset_building.player != self or (asset_building.is_in_group("bank") and exclude_bank):
			asset_buildings.remove(index)
	return asset_buildings

func navigate_pawn(nav_agent, target):
	var target_pos = NavigationServer.map_get_closest_point(nav_agent.get_navigation_map(), target.global_transform.origin)
	nav_agent.set_target_location(target_pos)
	var ball = get_node_or_null("../Ball")
	if ball:
		ball.global_transform.origin = target_pos

func is_nav_agent_target_reached(nav_agent):
	return nav_agent.get_target_location().distance_to(pawn.global_transform.origin) <= nav_agent.path_desired_distance

func _on_action_state_transited(from, to):
	if not is_instance_valid(pawn):
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
						action_state.set_param("target", target)
						navigate_pawn(nav_agent, target)
						if is_nav_agent_target_reached(nav_agent):
							action_state.set_trigger("in_range")
					else:
						action_state.set_trigger("done")
				"InRange":
					_is_shooting = true
					shooting_target()
					if is_nav_agent_target_reached(nav_agent):
						action_state.set_trigger("arrived")
				"Arrive":
					var target = action_state.get_param("target")
				"Finish":
					var empty_buildings = get_empty_buildings()
					action_state.set_param("empty_building", empty_buildings.size())
		"Withdraw":
			match to_dir.next():
				"Depart":
					var target = get_bank()
					action_state.set_param("target", target)
					navigate_pawn(nav_agent, target)
					if is_nav_agent_target_reached(nav_agent):
						action_state.set_trigger("in_range")
				"InRange":
					_is_interacting = true
					interacting()
					if is_nav_agent_target_reached(nav_agent):
						action_state.set_trigger("arrived")
				"Arrive":
					var target = action_state.get_param("target")
				"Finish":
					action_state.set_trigger("done")
				"Exit":
					action_state.erase_param("has_enough_money")
		"Harvest":
			match to_dir.next():
				"Depart":
					var owned_buildings = get_owned_buildings()
					if owned_buildings:
						var building_mature = false
						for owned_building in owned_buildings:
							if owned_building.health.value >= 15:
								building_mature = true
								action_state.set_param("target", owned_building)
								navigate_pawn(nav_agent, owned_building)
								break
							if is_nav_agent_target_reached(nav_agent):
								action_state.set_trigger("in_range")
					else:
						action_state.set_trigger("done")
				"InRange":
					_is_interacting = true
					interacting()
					if is_nav_agent_target_reached(nav_agent):
						action_state.set_trigger("arrived")
				"Arrive":
					var target = action_state.get_param("target")
					if target.health.value <= 10:
						_is_interacting = false
						action_state.set_trigger("done")
				"Finish":
					var owned_buildings = get_owned_buildings()
					if owned_buildings:
						var building_mature = false
						for owned_building in owned_buildings:
							if owned_building.health.value >= 15:
								building_mature = true
								break
						action_state.set_param("building_mature", building_mature)
						action_state.set_param("has_enough_money", false)
		"AttackProperty":
			match to_dir.next():
				"Depart":
					var opponent_buildings = get_buildings(false, [self])
					if opponent_buildings:
						var target = opponent_buildings[0]
						action_state.set_param("target", target)
						navigate_pawn(nav_agent, target)
						if is_nav_agent_target_reached(nav_agent):
							action_state.set_trigger("in_range")
					else:
						action_state.set_trigger("done")
				"InRange":
					_is_shooting = true
					shooting_target()
					if is_nav_agent_target_reached(nav_agent):
						action_state.set_trigger("arrived")
				"Arrive":
					var target = action_state.get_param("target")
				"Finish":
					var opponent_buildings = get_buildings(false, [self])
					action_state.set_param("empty_building", opponent_buildings.size())

func _on_asset_building_player_changed(from, to, asset_building):
	var empty_buildings = get_empty_buildings()
	action_state.set_param("empty_building", empty_buildings.size())
	if action_state.current == "Invest" and empty_buildings.size() == 0:
		action_state.set_trigger("abort")

	if action_state.current == "Invest/Arrive":
		if asset_building == action_state.get_param("target") and to == self:
			action_state.set_trigger("done")
			_is_shooting = false

	if from == self:
		asset_building.disconnect("interest_computed", self, "_on_owned_asset_building_interest_computed")
		asset_building.health.disconnect("changed", self, "_on_owned_asset_building_health_changed")
	if to == self:
		asset_building.connect("interest_computed", self, "_on_owned_asset_building_interest_computed", [asset_building])
		asset_building.health.connect("changed", self, "_on_owned_asset_building_health_changed", [asset_building])
		if action_state.current == "AttackProperty/Arrive":
			action_state.set_trigger("done")

func _on_owned_asset_building_interest_computed(matured_interest, asset_building):
	if asset_building.health.value > 15:
		action_state.set_param("building_mature", true)

func _on_owned_asset_building_health_changed(diff, asset_building):
	if action_state.current == "Harvest/Arrive" and diff < 0:
		if asset_building.health.value <= 10:
			_is_interacting = false
			action_state.set_trigger("done")

func _on_nav_agent_velocity_computed(safe_velocity):
	pawn.linear_velocity = safe_velocity

func _on_nav_agent_target_reached():
	action_state.set_trigger("arrived")

func _on_pawn_health_changed(diff):
	if action_state.current == "Withdraw/Arrive":
		if pawn.health.value >= 10 or get_bank().health.value == 0:
			_is_interacting = false
			action_state.set_trigger("done")

func _on_pawn_changed(from, to):
	action_state.restart()
	if to:
		pawn.get_node("NavigationAgent").connect("velocity_computed", self, "_on_nav_agent_velocity_computed")
		pawn.get_node("NavigationAgent").connect("target_reached", self, "_on_nav_agent_target_reached")
		pawn.health.connect("changed", self, "_on_pawn_health_changed")
