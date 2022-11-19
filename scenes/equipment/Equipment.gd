extends Spatial

export var damage = 1.0
export var cooldown = 0.5

var _last_attack_timestamp = -1


func attack(extra={}):
	if not is_cooldowned():
		return false
	
	var can_attack = _attack(extra)
	if not can_attack:
		return false
	
	_last_attack_timestamp = OS.get_system_time_msecs()
	return true

func _attack(extra={}):
	return true

func is_cooldowned():
	return (OS.get_system_time_msecs() - _last_attack_timestamp) / 1000.0 >= cooldown

func get_equipment_owner():
	return get_parent().get_parent()
