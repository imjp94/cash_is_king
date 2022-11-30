extends RigidBody

const ProjectileScene = preload("res://scenes/projectile/Projectile.tscn")


func _on_Area_body_entered(body):
	if body.collision_layer & 2: # player
		body.broke()
	elif body.collision_layer & 8 == 8: # building
		var building = body.get_parent()
		if building.is_in_group("asset_building"):
			if building.has_player():
				if building.is_in_group("bank"):
					building.health.deduct(10)
					building.anim_player.play("destroy")
					
					yield(building.anim_player, "animation_finished")

					building.anim_player.play("RESET")
				else:
					building.destroy(self)
