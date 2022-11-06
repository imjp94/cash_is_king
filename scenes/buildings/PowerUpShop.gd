extends "res://scenes/buildings/Shop.gd"


func buy(by, extra={}):
	var pawn = by.pawn
	var pawn_health = pawn.get_node_or_null("Health")
	if not pawn_health:
		return false
	if pawn_health.value < 10:
		return false

	pawn_health.deduct(10)
	deposit(by, 10)
	pawn.speed += 2
	pawn.damage += 2
