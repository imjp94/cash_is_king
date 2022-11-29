extends VisibilityNotifier

const Player = preload("res://scenes/player/Player.gd")


func _process(delta):
	update_bounds()

func update_bounds():
	aabb.position = Vector3.ZERO
	aabb.size = Vector3.ZERO
	aabb.end = Vector3.ZERO
	for i in Player.get_player_count():
		var player = Player.get_player(i)
		if player.pawn:
			aabb = aabb.expand(player.pawn.global_transform.origin)
