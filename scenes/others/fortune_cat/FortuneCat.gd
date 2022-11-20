extends RigidBody

const ProjectileScene = preload("res://scenes/projectile/Projectile.tscn")

signal threshold_reached(by)

export var threshold = 10
export var duration = 20
export var max_upscale = 0.3
export var speed = 1.0
export var navigation_radius = 30.0

onready var collision_shape = $CollisionShape
onready var mesh_instance = $MeshInstance
onready var area = $Area
onready var nav_agent = $NavigationAgent

var current_value setget , get_current_value
var progress setget , get_progress

var _current_value = 0


func _ready():
	get_tree().create_timer(duration).connect("timeout", self, "_on_timeout")

func _physics_process(delta):
	if is_nav_agent_target_reached():
		navigate_random_pos()

	var next_pos = nav_agent.get_next_location()
	var dir = global_transform.origin.direction_to(next_pos)
	dir = dir.normalized()
	var right = dir.x
	var forward = -dir.z

	var vel = (Vector3.FORWARD * forward * speed) + (Vector3.RIGHT * right * speed)
	linear_velocity = vel

func explode():
	for i in _current_value:
		var projectile = ProjectileScene.instance()
		projectile.collision_mask += 16 # Projectile mask, let them collide with each other
		get_parent().add_child(projectile)
		projectile.coin.grade = 2
		projectile.global_transform = global_transform

		var push_dir = global_transform.basis.z.rotated(global_transform.basis.y, rand_range(-2 * PI, 2 * PI))
		push_dir.y += 3.0
		push_dir = push_dir.normalized()
		var shatter_impulse = 10.0
		projectile.apply_central_impulse(push_dir * shatter_impulse)
		projectile.apply_torque_impulse(push_dir * rand_range(1.0, 5.0))
	queue_free()

func navigate_random_pos():
	var target_pos = NavigationServer.map_get_closest_point(nav_agent.get_navigation_map(), get_random_pos())
	nav_agent.set_target_location(target_pos)

func _on_Area_body_entered(body):
	_current_value += body.damage
	if _current_value >= threshold:
		explode()
		emit_signal("threshold_reached", body)

	var new_scale = 1 + (get_progress() * max_upscale)
	collision_shape.scale = Vector3.ONE * new_scale
	mesh_instance.scale = Vector3.ONE * new_scale
	area.scale = Vector3.ONE * new_scale
	body.queue_free()

func _on_timeout():
	queue_free()

func get_current_value():
	return _current_value

func get_progress():
	return _current_value / float(threshold)

func get_random_pos():
	return Vector3(rand_range(-navigation_radius, navigation_radius), 0, rand_range(-navigation_radius, navigation_radius))

func is_nav_agent_target_reached():
	return nav_agent.get_target_location().distance_to(global_transform.origin) <= nav_agent.path_desired_distance
