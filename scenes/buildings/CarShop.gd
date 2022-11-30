extends "res://scenes/buildings/Shop.gd"

const CarScn = preload("res://scenes/equipment/Car.tscn")

var price = 10 # TODO: Proper way to set prices


func buy(by, extra={}):
	var pawn = by.pawn
	var pawn_health = pawn.get_node_or_null("Health")
	if not pawn_health:
		return false
	if pawn_health.value < price:
		return false

	pawn_health.deduct(price)
	deposit(by, price, pawn.coin_grade)
	pawn.vehicle_slot.equipment_scn = CarScn
