extends "res://scenes/buildings/Shop.gd"

const CarScn = preload("res://scenes/equipment/Car.tscn")

onready var label3d = $Label3D

var price = 50 # TODO: Proper way to set prices


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

func _on_Area_body_exited(body):
	label3d.hide()

func _on_Area_body_entered(body):
	label3d.text = "Buy Car $%d" %price
	label3d.show()
