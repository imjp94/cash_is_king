tool
extends RigidBody

const ProjectileScene = preload("res://scenes/projectile/Projectile.tscn")
const Coin = preload("res://scenes/projectile/Coin.gd")
const CoinScene = preload("res://scenes/projectile/Coin.tscn")

signal color_changed(from, to)
signal dead()

export(Coin.GRADE) var coin_grade = Coin.GRADE.SILVER
export var color = Color.white setget set_color
export var speed = 10.0
export var turn_vel = 45.0

onready var health = $Health
onready var health_bar_3d = $HealthBar3D
onready var mesh_instance = $MeshInstance
onready var equipment_slot = $EquipmentSlot
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
	
	var move_x = Input.get_axis("move_left", "move_right")
	var move_y = Input.get_axis("move_down", "move_up")
	move(move_y, move_x)
	var turn_x = Input.get_axis("turn_left", "turn_right")
	var turn_y = Input.get_axis("turn_down", "turn_up")
	turn(turn_y if turn_y else  move_y, turn_x if turn_x else  move_x)

func _unhandled_input(event):
	if not player:
		return
	if not player.can_handle_event(event):
		_can_input = false
		return
	
	if Input.is_action_just_pressed("shoot"):
		attack()

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

func attack():
	if health.value == 0:
		return
	if not equipment_slot.equipment:
		return
	
	var attacked = equipment_slot.equipment.attack()
	if attacked:
		var projectile_count = equipment_slot.equipment.get("projectile_count") # TODO: Better way to get projectile count from equipment
		if not projectile_count:
			projectile_count = 1
		health.deduct(Coin.GRADE_DAMAGE[coin_grade] * projectile_count)

func event():
	if area.get_overlapping_bodies().size() == 0:
		return

	var building_body = area.get_overlapping_bodies()[0]
	var building = building_body.get_parent()
	if "health" in building:
		building.withdraw(player, get_damage(), coin_grade)
	if building.has_method("buy"):
		building.buy(player)

func broke():
	for i in health.value:
		var coin = ProjectileScene.instance()
		coin.collision_mask += 16 # Projectile mask, let them collide with each other
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

func _on_Health_changed(diff):
	if not label3d:
		return
	
	label3d.text = str(health.value)

func _on_Health_credited(creditor, amount):
	if not label3d:
		return
	
	health_bar_3d.health_bar.set_value_pairs(health.get_health_bar_value_pairs())

func _on_Health_credit_timeout(credits):
	if not label3d:
		return
	
	health_bar_3d.health_bar.reset()

	for creditor in credits.keys():
		var target = creditor.pawn
		if not is_instance_valid(target): # TODO: Should return to target's bank instead
			continue
		
		var amount = credits[creditor] / Coin.GRADE_DAMAGE[target.coin_grade]
		target.health.increase(amount)
		for i in amount:
			var coin = CoinScene.instance()
			coin.grade = target.coin_grade
			coin.target = target
			get_parent().add_child(coin)
			coin.global_transform.origin = global_transform.origin
			coin._origin = global_transform.origin
		
			yield(get_tree().create_timer(0.1), "timeout")

func _on_Health_broke(by, credits):
	broke()

func set_color(v):
	var old = color
	color = v
	if mesh_instance:
		mesh_instance.get("material/0").set("albedo_color", color)
	if health_bar_3d:
		health_bar_3d.health_bar.color = color
	if color != old:
		emit_signal("color_changed", old, color)

func _on_player_color_changed(from, to):
	if mesh_instance and player:
		set_color(to)

func set_player(v):
	player = v
	if player:
		_on_player_color_changed(player.color, player.color)
		player.connect("color_changed", self, "_on_player_color_changed")

func get_damage():
	return Coin.GRADE_DAMAGE[coin_grade]
