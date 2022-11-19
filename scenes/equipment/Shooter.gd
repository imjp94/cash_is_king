extends "res://scenes/equipment/Equipment.gd"

export var shoot_force = 1000.0
export(PackedScene) var projectile_ps

onready var shoot_origin = $ShootOrigin


func _attack(extra={}):
	if not projectile_ps:
		return false

	var projectile = projectile_ps.instance()
	projectile.instigator = get_equipment_owner().player
	projectile.damage = damage
	get_equipment_owner().get_parent().add_child(projectile)

	var pos = shoot_origin.global_transform.origin
	var dir = -shoot_origin.global_transform.basis.z
	projectile.global_transform.origin = pos
	PhysicsServer.body_add_collision_exception(projectile.get_rid(), get_equipment_owner().get_rid())
	projectile.add_central_force(dir * shoot_force)

	return true
