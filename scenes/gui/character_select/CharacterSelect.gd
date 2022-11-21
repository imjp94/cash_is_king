extends Control

var app_state

onready var btn_list = $ButtonList


func _ready():
	btn_list.get_child(0).grab_focus()

func _on_NextBtn_pressed():
	if app_state:
		app_state.set_trigger("next")

func _on_BackBtn_pressed():
	if app_state:
		app_state.set_trigger("back")
