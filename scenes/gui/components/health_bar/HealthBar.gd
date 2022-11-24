tool
extends Panel

export(Color) var color = Color.blue setget set_color
export(float, -1.0, 1.0) var v1 = -1.0 setget set_v1
export(Color) var c1 = Color.red setget set_c1
export(float, -1.0, 1.0) var v2 = -1.0 setget set_v2
export(Color) var c2 = Color.yellow setget set_c2
export(float, -1.0, 1.0) var v3 = -1.0 setget set_v3
export(Color) var c3 = Color.green setget set_c3
export(float, -1.0, 1.0) var v4 = -1.0 setget set_v4
export(Color) var c4 = Color.purple setget set_c4

onready var bar1 = $Bar1
onready var bar2 = $Bar2
onready var bar3 = $Bar3
onready var bar4 = $Bar4


func _ready():
	set_color(color)

func reset():
	for i in 4:
		call("set_v%d" % (i+1), -1)

# Take arrays of {value, color} then sort and assign accordingly
func set_value_pairs(value_pairs):
	value_pairs.sort_custom(self, "sort_value_pair")
	for i in value_pairs.size():
		var value_pair = value_pairs[i]
		call("set_v%d" % (i+1), value_pair.value)
		call("set_c%d" % (i+1), value_pair.color)

func sort_value_pair(a, b):
	return a.value > b.value

func set_color(v):
	color = v
	var style = get("custom_styles/panel")
	if style:
		style.set("bg_color", color)

func set_v1(v):
	v1 = v
	if bar1:
		if v1 >= 0:
			bar1.rect_size.x = rect_size.x * v1
			bar1.modulate.a = 1.0
		else:
			bar1.modulate.a = 0.0

func set_c1(v):
	c1 = v
	if bar1:
		var style = bar1.get("custom_styles/panel")
		if style:
			style.set("bg_color", c1)

func set_v2(v):
	v2 = v
	if bar2:
		if v2 >= 0:
			bar2.rect_size.x = rect_size.x * v2
			bar2.modulate.a = 1.0
		else:
			bar2.modulate.a = 0.0

func set_c2(v):
	c2 = v
	if bar2:
		var style = bar2.get("custom_styles/panel")
		if style:
			style.set("bg_color", c2)

func set_v3(v):
	v3 = v
	if bar3:
		if v3 >= 0:
			bar3.rect_size.x = rect_size.x * v3
			bar3.modulate.a = 1.0
		else:
			bar3.modulate.a = 0.0

func set_c3(v):
	c3 = v
	if bar3:
		var style = bar3.get("custom_styles/panel")
		if style:
			style.set("bg_color", c3)

func set_v4(v):
	v4 = v
	if bar4:
		if v4 >= 0:
			bar4.rect_size.x = rect_size.x * v4
			bar4.modulate.a = 1.0
		else:
			bar4.modulate.a = 0.0

func set_c4(v):
	c4 = v
	if bar4:
		var style = bar4.get("custom_styles/panel")
		if style:
			style.set("bg_color", c4)
