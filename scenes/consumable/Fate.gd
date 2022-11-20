extends "res://scenes/consumable/Consumable.gd"

const MonsterPathScene = preload("res://scenes/others/monster/MonsterPath.tscn")


func _consume(by):
	var inst = MonsterPathScene.instance()
	get_parent().add_child(inst)
	queue_free()
