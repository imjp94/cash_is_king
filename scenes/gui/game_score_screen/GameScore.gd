extends Control

onready var message = $"%Message"

var game_state

var _timestamp = -1


func _ready():
	connect("visibility_changed", self, "_on_visibility_changed")

func _unhandled_input(event):
	if _timestamp < 0:
		return
	if game_state:
		if game_state.current == "End" and Input.is_action_just_pressed("ui_accept"):
			var elasped = OS.get_system_time_msecs() - _timestamp
			if elasped < 3000:
				return
			
			game_state.set_trigger("exit")
			hide()

func _on_visibility_changed():
	if visible:
		_timestamp = OS.get_system_time_msecs()
	else:
		_timestamp = -1
