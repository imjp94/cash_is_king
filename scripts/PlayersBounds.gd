extends VisibilityNotifier

const Player = preload("res://scenes/player/Player.gd")


func _process(delta):
	update_bounds()

func update_bounds():
	aabb.position = Vector3.ZERO
	aabb.size = Vector3.ZERO
	aabb.end = Vector3.ZERO

	var center = null

	for i in Player.get_player_count():
		var player = Player.get_player(i)
		if is_instance_valid(player.pawn):
			aabb = aabb.expand(player.pawn.global_transform.origin)

			if center == null:
				center = player.pawn.global_transform.origin
			else:
				center += (player.pawn.global_transform.origin - center) / 2.0

	if center != null:
		global_transform.origin = center
