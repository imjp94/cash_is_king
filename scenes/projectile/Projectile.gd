extends RigidBody

onready var coin = $Coin
onready var area = $Area
onready var raycast = $RayCast

var damage setget , get_damage
var push_back_force = 0.0
var instigator


func _ready():
	coin.anim_player.stop(true)
	coin.rotation.x = deg2rad(90)

func _physics_process(delta):
	if can_pick():
		collision_mask += 16
		instigator = null
		coin.anim_player.play("idle")
		coin.rotation.x = 0
		set_physics_process(false)

func _on_Area_body_entered(body):
	var pawn = instigator.pawn if instigator else null
	if body == pawn or body == self:
		return
	if body.is_in_group("projectile"):
		return
	
	var health = body.get_node_or_null("Health")

	if can_pick():
		if health:
			health.increase(get_damage())
		coin.anim_player.play("pick")
		yield(coin.anim_player, "animation_finished")
	else:
		if health and instigator:
			var dir = -global_transform.basis.z
			body.add_central_force(dir * push_back_force)
			health.credit(instigator, get_damage())
			body.damaged()

	queue_free()

func can_pick():
	return raycast.is_colliding()

func get_damage():
	if not is_inside_tree():
		return 1
	return coin.GRADE_DAMAGE[coin.grade]

func _on_Projectile_sleeping_state_changed():
	if sleeping:
		mode = MODE_STATIC
