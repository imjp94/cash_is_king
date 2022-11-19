extends "res://scenes/equipment/Shooter.gd"

export var projectile_count = 5
export var spread_angle_max = 30.0
export var spread_angle_min = -30.0


func _attack(extra={}):
	if not projectile_ps:
		return false

	var angle_step = (spread_angle_max - spread_angle_min) / (projectile_count - 1) if projectile_count > 1 else (spread_angle_max - spread_angle_min) / 2

	for i in projectile_count:
		var angle_offset = i * angle_step
		var pos = shoot_origin.global_transform.origin
		var dir = (-shoot_origin.global_transform.basis.z).rotated(shoot_origin.global_transform.basis.y, deg2rad(spread_angle_min + (angle_step * i)))
		dir = dir.normalized()
		shoot(pos, dir)

	return true
