tool
extends "res://scenes/gui/components/list/Item.gd"

export var price = 1 setget set_price

onready var price_label = $"%PriceLabel"


func _ready():
	set_price(price)

func set_price(v):
	price = v
	if price_label:
		price_label.text = "$%d" % price
