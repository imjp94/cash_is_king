extends Control

onready var label = $Label
onready var timer = $Timer


func _on_Overlay_visibility_changed():
	if visible:
		get_tree().paused = true
		timer.start()

func _on_Timer_timeout():
	get_tree().paused = false
	queue_free()
