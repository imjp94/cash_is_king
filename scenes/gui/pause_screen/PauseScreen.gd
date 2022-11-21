extends Control

var game_state


func _unhandled_input(event):
	if game_state:
		if Input.is_action_just_pressed("pause"):
			game_state.set_trigger("resume" if get_tree().paused else "pause")
			visible = !visible

func _on_ResumeBtn_pressed():
	game_state.set_trigger("resume")
	visible = true

func _on_ExitBtn_pressed():
	game_state.set_trigger("exit")
