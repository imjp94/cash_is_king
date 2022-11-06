extends Node

signal empty()
signal full()
signal deducted(diff)
signal increased(diff)
signal changed(diff)

export var default_value = 1.0 setget , get_default_value
export var max_value = 1.0

var value = 0.0 setget set_value, get_value

func _ready():
	_init_value()

func deduct(diff):
	set_value(value - diff)

func increase(diff):
	set_value(value + diff)

func set_unlimited():
	max_value = -1.0

func _init_value():
	value = get_default_value()

func set_value(v):
	var diff = v - value
	var changed = abs(diff) > 0

	if v <= 0:
		changed = value > 0
		value = 0
		if diff < 0:
			emit_signal("deducted", diff)
		emit_signal("empty")
	elif v >= max_value and not is_unlimited():
		changed = value < max_value
		value = max_value
		emit_signal("full")
	else:
		value = max(0.0, v) if is_unlimited() else clamp(v, 0, max_value)
		if diff < 0:
			emit_signal("deducted", diff)
		elif diff > 0:
			emit_signal("increased", diff)

	if changed:
		emit_signal("changed", diff)

func get_value():
	return value

func get_default_value():
	return max(0.0, default_value) if is_unlimited() else clamp(default_value, 0.0, max_value)

func is_unlimited():
	return max_value <= 0
