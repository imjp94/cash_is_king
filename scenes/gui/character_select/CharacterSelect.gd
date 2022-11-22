extends Control

const Player = preload("res://scenes/player/Player.gd")
const PlayerScn = preload("res://scenes/player/Player.tscn")
const AIScn = preload("res://scenes/player/ai/AI.tscn")

var app_state

onready var character_select_3d = $"%CharacterSelect3D"
onready var btn_list = $ButtonList


func _ready():
	btn_list.get_child(0).grab_focus()
	for i in Player.get_player_count():
		var player = Player.get_player(i)
		show_character(player)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_start"):
		var player = Player.add_player_from_input(event, $"/root", PlayerScn)
		if player:
			show_character(player)

func show_character(player):
	var character = character_select_3d.get("character%d" % (player.index + 1))
	character.show()
	character.color = player.color

func _on_NextBtn_pressed():
	if app_state:
		if Player.get_player_count() == 1: # Spawn AI if there's only one player
			var ai = Player.add_player(-1, 0, $"/root", AIScn)
			show_character(ai)
			
			yield(get_tree().create_timer(2), "timeout")
		
		app_state.set_trigger("next")

func _on_BackBtn_pressed():
	if app_state:
		app_state.set_trigger("back")
