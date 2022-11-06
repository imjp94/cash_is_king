extends "res://scripts/Health.gd"

signal credit_started()
signal credit_timeout()
signal broke(by, credits)
signal credited(creditor, amount)

export var credit_duration = 10.0

var credits = {}

var _credit_timer


func credit(creditor, amount):
	if credits.empty():
		if not _credit_timer:
			_credit_timer = get_tree().create_timer(credit_duration)
			_credit_timer.connect("timeout", self, "_on_credit_timeout")
		emit_signal("credit_started")
	
	if _credit_timer:
		_credit_timer.time_left = credit_duration
	
	if not credits.has(creditor):
		credits[creditor] = 0
	
	credits[creditor] += amount
	emit_signal("credited", creditor, amount)

	if credits[creditor] >= value:
		increase(credits[creditor])
		var credits_copy = credits.duplicate(true)
		credits.clear()
		emit_signal("broke", creditor, credits_copy)
		return true
	return false

func _on_credit_timeout():
	var credits_copy = credits.duplicate(true)
	credits.clear()
	_credit_timer = null
	emit_signal("credit_timeout", credits_copy)

func to_text():
	var fs = str(value)
	if credits:
		var creditors = credits.keys()
		fs += "{"
		for creditor in creditors:
			fs += " Player %s: %d " % [creditor.index+1, credits[creditor]]
		fs += "}"
	
	return fs
