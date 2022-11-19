extends "res://scenes/equipment/Equipment.gd"

export var shoot_force = 1000.0
export var projectile_push_back_force = 0.0
export(PackedScene) var projectile_ps

onready var shoot_origin = $ShootOrigin


func _attack(extra={}):
	if not projectile_ps:
		return false

	var pos = shoot_origin.global_transform.origin
	var dir = -shoot_origin.global_transform.basis.z
	shoot(pos, dir)

	return true

func shoot(pos, dir):
	if not projectile_ps:
		return false

	var projectile = projectile_ps.instance()
	projectile.instigator = get_equipment_owner().player
	projectile.push_back_force = projectile_push_back_force
	get_equipment_owner().get_parent().add_child(projectile)
	projectile.coin.grade = get_equipment_owner().coin_grade

	projectile.look_at_from_position(pos, pos + dir, shoot_origin.global_transform.basis.y)
	PhysicsServer.body_add_collision_exception(projectile.get_rid(), get_equipment_owner().get_rid())
	projectile.add_central_force(dir * shoot_force)
	
	return projectile
