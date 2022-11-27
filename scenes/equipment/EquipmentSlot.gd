tool
extends Spatial

signal equipment_changed(from, to)

export(PackedScene) var equipment_scn setget set_equipment_scn

var equipment setget set_equipment


func _ready():
	set_equipment_scn(equipment_scn)

func set_equipment_scn(v):
	var old = equipment_scn
	equipment_scn = v
	if equipment_scn != old:
		var inst = null
		if equipment_scn:
			inst = equipment_scn.instance()
			add_child(inst)
		set_equipment(inst)

func set_equipment(v):
	var old = equipment
	equipment = v
	if old:
		old.queue_free()
	emit_signal("equipment_changed", old, equipment)
