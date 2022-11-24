extends "res://scenes/consumable/Consumable.gd"

const MonsterPathScene = preload("res://scenes/others/monster/MonsterPath.tscn")

onready var overlay = $Overlay


func _consume(by):
	var inst = MonsterPathScene.instance()
	get_parent().add_child(inst)
	overlay.show()

	yield(overlay, "tree_exited")

	queue_free()
