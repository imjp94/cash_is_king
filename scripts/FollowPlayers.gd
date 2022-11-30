extends Spatial

const Player = preload("res://scenes/player/Player.gd")

export var axis = Vector3(1.0, 0.0, 1.0)

var _init_origin = Vector3.ZERO


func _ready():
	_init_origin = global_transform.origin

func _process(delta):
	update_bounds()

func update_bounds():
	var center = null
	for i in Player.get_player_count():
		var player = Player.get_player(i)
		if is_instance_valid(player.pawn):
			if center == null:
				center = player.pawn.global_transform.origin
			else:
				center += (player.pawn.global_transform.origin - center) / 2.0
	if center != null:
		global_transform.origin = _init_origin + center * axis
