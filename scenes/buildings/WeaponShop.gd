extends "res://scenes/buildings/Shop.gd"

onready var weapon_list = $"%WeaponList"
onready var weapon_list_3d = $WeaponList3D

var customer

func _unhandled_input(event):
	if customer:
		$Viewport.input(event) # TODO: Dirty hacks to pass input to viewport

func _on_Area_body_entered(body):
	customer = body.player
	weapon_list_3d.show()

func _on_Area_body_exited(body):
	customer = null
	weapon_list_3d.hide()

func _on_WeaponList_item_selected(index):
	if customer:
		var weapon_item = weapon_list.get_item(index)
		var pawn = customer.pawn
		if pawn.health.value < weapon_item.price:
			return
		
		pawn.health.deduct(weapon_item.price)
		deposit(customer, weapon_item.price, pawn.coin_grade)
		customer.pawn.equipment_slot.equipment_scn = weapon_item.weapon_scn
