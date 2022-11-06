extends RigidBody

onready var area = $Area
onready var raycast = $RayCast
onready var anim_player = $AnimationPlayer

var damage = 1
var instigator


func _physics_process(delta):
	if can_pick():
		instigator = null
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
			health.increase(damage)
		anim_player.play("pick")
		yield(anim_player, "animation_finished")
	else:
		if health and instigator:
			health.credit(instigator, damage)

	queue_free()

func can_pick():
	return raycast.is_colliding()
