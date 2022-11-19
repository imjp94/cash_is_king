extends "res://scenes/equipment/Shooter.gd"

export var projectile_count = 3


func _attack(extra={}):
	if not projectile_ps:
		return false

	for i in projectile_count:
		var projectile = projectile_ps.instance()
		projectile.instigator = get_equipment_owner().player
		projectile.damage = damage
		get_equipment_owner().get_parent().add_child(projectile)

		var pos = shoot_origin.global_transform.origin
		var dir = -shoot_origin.global_transform.basis.z
		projectile.global_transform.origin = pos
		PhysicsServer.body_add_collision_exception(projectile.get_rid(), get_equipment_owner().get_rid())
		projectile.add_central_force(dir * shoot_force)

		yield(get_tree().create_timer(cooldown / projectile_count), "timeout")

	return true