extends Control

export(PackedScene) var tutorial_game
export(PackedScene) var main_game

onready var btn_list = $ButtonList

var app_state


func _ready():
	btn_list.get_child(0).grab_focus()

func _on_TutorialBtn_pressed():
	if app_state:
		app_state.set_param("game_scn", tutorial_game)
		app_state.set_trigger("next")

func _on_MainBtn_pressed():
	if app_state:
		app_state.set_param("game_scn", main_game)
		app_state.set_trigger("next")

func _on_BackBtn_pressed():
	if app_state:
		app_state.set_trigger("back")
