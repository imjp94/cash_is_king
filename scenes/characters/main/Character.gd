tool
extends RigidBody

const ProjectileScene = preload("res://scenes/projectile/Projectile.tscn")
const CoinScene = preload("res://scenes/projectile/Coin.tscn")

signal color_changed(from, to)
signal dead()

export var damage = 1
export var speed = 10.0
export var turn_vel = 45.0
export(PackedScene) var projectile_ps
export var shoot_force = 1000.0

onready var health = $Health
onready var mesh_instance = $MeshInstance
onready var shoot_origin = $ShootOrigin
onready var area = $Area
onready var label3d = $Label3D

var player setget set_player

var _pending_look_dir = Vector3.FORWARD
var _can_input = false


func _physics_process(delta):
	if Engine.editor_hint:
		return
	if not player:
		return
	if not _can_input:
		return
	
	var axis_x = Input.get_axis("ui_left", "ui_right")
	var axis_y = Input.get_axis("ui_down", "ui_up")

	move_and_turn(axis_y, axis_x)

func _unhandled_input(event):
	if not player:
		return
	if not player.can_handle_event(event):
		_can_input = false
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		shoot()

	if Input.is_action_just_pressed("event"):
		event()

	_can_input = true

func move_and_turn(forward, right):
	move(forward, right)
	turn(forward, right)

func move(forward, right):
	add_central_force(Vector3.FORWARD * forward * (speed))
	add_central_force(Vector3.RIGHT * right * (speed))
	# linear_velocity = (Vector3.FORWARD * forward * speed) + (Vector3.RIGHT * right * speed)

func turn(forward, right):
	var value = abs(forward) + abs(right)
	var base_transform = Transform() # World Transform

	if value:
		_pending_look_dir = (-base_transform.basis.z * forward + base_transform.basis.x * right)
		_pending_look_dir.y = 0
		_pending_look_dir = _pending_look_dir.normalized()

	value = value / value if value > 0 else 0

	# Use vector2 direction to get signed angled, to determine turn direction
	var control_dir = Vector2(_pending_look_dir.x, _pending_look_dir.z)
	var char_forward = -global_transform.basis.z
	var char_dir = Vector2(char_forward.x, char_forward.z)
	var angle_diff = control_dir.angle_to(char_dir)
	angle_diff *= value

	# turn_vel determine the sensitivity of rotation
	# higher turn_vel result sharper rotation
	var av = Vector3.UP * deg2rad(turn_vel * angle_diff)
	angular_velocity = av

func shoot():
	if not projectile_ps:
		return
	if health.value == 0:
		return

	var projectile = projectile_ps.instance()
	projectile.instigator = player
	projectile.damage = damage
	get_parent().add_child(projectile)
	projectile.global_transform.origin = shoot_origin.global_transform.origin
	PhysicsServer.body_add_collision_exception(projectile.get_rid(), get_rid())
	projectile.add_central_force(-shoot_origin.global_transform.basis.z * shoot_force)
	health.deduct(1)

func event():
	if area.get_overlapping_bodies().size() == 0:
		return

	var building_body = area.get_overlapping_bodies()[0]
	var building = building_body.get_parent()
	if "health" in building:
		building.withdraw(player, damage)
	if building.has_method("buy"):
		building.buy(player)

func _on_Health_changed(diff):
	if not label3d:
		return
	
	label3d.text = health.to_text()

func _on_Health_credited(creditor, amount):
	if not label3d:
		return
	
	label3d.text = health.to_text()

func _on_Health_credit_timeout(credits):
	if not label3d:
		return
	
	label3d.text = health.to_text()

	for creditor in credits.keys():
		var amount = credits[creditor]
		var target = creditor.pawn
		var target_health = target.get_node("Health")
		for i in amount:
			var coin = CoinScene.instance()
			coin.target = target
			get_parent().add_child(coin)
			coin.global_transform.origin = global_transform.origin
			coin._origin = global_transform.origin
			target_health.increase(1)
			yield(get_tree().create_timer(0.1), "timeout")

func _on_Health_broke(by, credits):
	for i in health.value:
		var coin = ProjectileScene.instance()
		get_parent().add_child(coin)
		coin.global_transform = global_transform

		var push_dir = global_transform.basis.z.rotated(global_transform.basis.y, rand_range(-2 * PI, 2 * PI))
		push_dir.y += 3.0
		push_dir = push_dir.normalized()
		var shatter_impulse = 10.0
		coin.apply_central_impulse(push_dir * shatter_impulse)
		coin.apply_torque_impulse(push_dir * rand_range(1.0, 5.0))
	
	emit_signal("dead")
	queue_free()

func _on_player_color_changed(from, to):
	if mesh_instance and player:
		mesh_instance.get("material/0").set("albedo_color", to)
	emit_signal("color_changed", from, to)

func set_player(v):
	player = v
	if player:
		_on_player_color_changed(player.color, player.color)
		player.connect("color_changed", self, "_on_player_color_changed")
