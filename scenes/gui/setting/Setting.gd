extends Control

signal done()

onready var volume_slider = $"%VolumeSlider"

var app_state
var game_state


func _ready():
	volume_slider.grab_focus()
	volume_slider.value = AudioServer.get_bus_volume_db(0)

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)

func _on_DoneBtn_pressed():
	if app_state:
		app_state.set_trigger("done")
	if game_state:
		game_state.set_trigger("done")
	emit_signal("done")
