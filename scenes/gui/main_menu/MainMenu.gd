extends Control

onready var btn_list = $ButtonList

var app_state


func _ready():
	btn_list.get_child(0).grab_focus()

func _on_PlayBtn_pressed():
	if app_state:
		app_state.set_trigger("play")

func _on_SettingBtn_pressed():
	if app_state:
		app_state.set_trigger("setting")

func _on_ExitBtn_pressed():
	if app_state:
		app_state.set_trigger("exit")
