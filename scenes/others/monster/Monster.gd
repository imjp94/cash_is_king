extends RigidBody


func _on_Area_body_entered(body):
	if body.collision_layer & 2: # player
		body.broke()
	elif body.collision_layer & 8 == 8: # building
		var building = body.get_parent()
		if building.is_in_group("asset_building"):
			if building.has_player():
				building.destroy(self)
