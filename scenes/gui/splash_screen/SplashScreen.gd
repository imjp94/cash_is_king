extends Control

var app_state

func _on_Timer_timeout():
	if app_state:
		app_state.set_trigger("done")
