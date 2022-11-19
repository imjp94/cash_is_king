extends "res://scenes/equipment/Shooter.gd"

const Coin = preload("res://scenes/projectile/Coin.gd")

export var projectile_count = 3


func _attack(extra={}):
	if not projectile_ps:
		return false
	
	var actual_projectile_count = min(projectile_count, get_equipment_owner().health.value / Coin.GRADE_DAMAGE[get_equipment_owner().coin_grade])
	for i in actual_projectile_count:
		var pos = shoot_origin.global_transform.origin
		var dir = -shoot_origin.global_transform.basis.z

		shoot(pos, dir)

		yield(get_tree().create_timer(cooldown / actual_projectile_count), "timeout")

	return true