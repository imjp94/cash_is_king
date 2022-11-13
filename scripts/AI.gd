tool
extends "res://scripts/Player.gd"

onready var action_state = $ActionState


func _ready():
	action_state.connect("transited", self, "_on_action_state_transited")
	pawn.get_node("NavigationAgent").connect("velocity_computed", self, "_on_nav_agent_velocity_computed")

func _unhandled_input(event):
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

func _on_action_state_transited(from, to):
	pass

func _on_nav_agent_velocity_computed(safe_velocity):
	pawn.linear_velocity = safe_velocity
