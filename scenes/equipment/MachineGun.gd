extends "res://scenes/equipment/Shooter.gd"

export var projectile_count = 3


func _attack(extra={}):
	if not projectile_ps:
		return false

	for i in projectile_count:
		var pos = shoot_origin.global_transform.origin
		var dir = -shoot_origin.global_transform.basis.z

		shoot(pos, dir)

		yield(get_tree().create_timer(cooldown / projectile_count), "timeout")

	return true