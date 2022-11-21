extends Control

onready var message = $"%Message"

var game_state


func _unhandled_input(event):
	if game_state:
		if game_state.current == "End" and Input.is_action_just_pressed("ui_accept"):
			game_state.set_trigger("exit")
			hide()
