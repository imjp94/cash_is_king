extends "res://scenes/consumable/Consumable.gd"

const FortuneCatScene = preload("res://scenes/others/fortune_cat/FortuneCat.tscn")

func _consume(by):
	var inst = FortuneCatScene.instance()
	get_parent().add_child(inst)
	inst.global_transform.origin = global_transform.origin
	queue_free()
