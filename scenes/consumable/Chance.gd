extends "res://scenes/consumable/Consumable.gd"

const FortuneCatScene = preload("res://scenes/others/fortune_cat/FortuneCat.tscn")

onready var overlay = $Overlay


func _consume(by):
	var inst = FortuneCatScene.instance()
	get_parent().add_child(inst)
	inst.global_transform.origin = global_transform.origin
	overlay.label.bbcode_text = overlay.label.bbcode_text % "$ Fortune Cat $"
	overlay.show()

	yield(overlay, "tree_exited")

	queue_free()
