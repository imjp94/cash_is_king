tool
extends "res://scenes/buildings/AssetBuilding.gd"

export var coin_grade = 0 setget set_coin_grade


func _ready():
	set_coin_grade(coin_grade)

func _on_upgraded():
	if coin_grade >= 2:
		return
	
	set_coin_grade(coin_grade + 1)
	_is_upgraded = coin_grade >= 2
	# TODO: Set from inspector instead of hardcoded
	if not _is_upgraded:
		match coin_grade:
			Coin.GRADE.COPPER:
				set_upgrade_threshold(100)
			Coin.GRADE.SILVER:
				set_upgrade_threshold(200)
			Coin.GRADE.GOLD:
				set_upgrade_threshold(-1)

func set_coin_grade(v):
	coin_grade = v
	if mesh_instance:
		var color = Coin.GRADE_COLOR[v]
		mesh_instance.get("material/2").set("albedo_color", color)
		mesh_instance.get("material/2").set("emission", color)
	if player_index > -1:
		var player = get_player()
		if player:
			if is_instance_valid(player.pawn):
				player.pawn.coin_grade = coin_grade
