extends Control

const Player = preload("res://scenes/player/Player.gd")
const PlayerScn = preload("res://scenes/player/Player.tscn")

var app_state


func _unhandled_input(event):
	if app_state:
		if Input.is_action_just_pressed("ui_start"):
			Player.add_player_from_input(event, $"/root", PlayerScn)
			app_state.set_trigger("start")
