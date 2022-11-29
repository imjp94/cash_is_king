tool
extends Spatial

export var margin_x = 5.0 setget set_margin_x
export var margin_z = 5.0 setget set_margin_z
export var center = true setget set_center


func _ready():
	distribute()

func distribute():
	var half = sqrt(get_child_count())
	half = ceil(half)

	var center_offset_x = 0.0
	var center_offset_z = 0.0
	if center:
		center_offset_x = (half * margin_x) / 2.0 - margin_x
		center_offset_z = (half * margin_z) / 2.0 - margin_z
	var i = 0
	for column in half:
		for row in half:
			if i >= get_child_count():
				break
			
			var child = get_child(i)
			child.global_transform.origin = Vector3(margin_x * column - center_offset_x, 0.0, margin_z * row - center_offset_z)
			i += 1

func set_margin_x(v):
	margin_x = v
	distribute()

func set_margin_z(v):
	margin_z = v
	distribute()

func set_center(v):
	center = v
	distribute()
