extends Control

const Player = preload("res://scenes/player/Player.gd")
const PlayerScn = preload("res://scenes/player/Player.tscn")
const AIScn = preload("res://scenes/player/ai/AI.tscn")

var app_state

onready var character_select_3d = $"%CharacterSelect3D"
onready var btn_list = $ButtonList
onready var next_btn = $"%NextBtn"
onready var ai_count_btn = $"%AICountBtn"

var _next_pressed = false


func _ready():
	next_btn.grab_focus()
	for i in Player.get_player_count():
		var player = Player.get_player(i)
		show_character(player)

	ai_count_btn.disabled = false
	if app_state:
		var game_scn = app_state.get_param("game_scn")
		if game_scn is PackedScene:
			if "Tutorial" in game_scn.resource_path:
				ai_count_btn.disabled = true
	verify_ai_count()

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_start"):
		var player = Player.add_player_from_input(event, $"/root", PlayerScn)
		if player:
			show_character(player)
			verify_ai_count()
		else:
			player = Player.get_player(Player.get_player_index(event.device, Player.get_device_type(event)))
			if player.index != 0: # Cannot remove player 1
				hide_character(player)
				player.queue_free()
			
func show_character(player):
	var character = character_select_3d.get("character%d" % (player.index + 1))
	character.show()
	character.color = player.color

func hide_character(player):
	var character = character_select_3d.get("character%d" % (player.index + 1))
	character.hide()
	character.color = Color.white

func verify_ai_count():
	var ai_count = min(get_ai_count(), get_max_ai_count())
	ai_count = clamp(get_ai_count(), get_min_ai_count(), get_max_ai_count())
	ai_count_btn.text = str(ai_count)

func append_ai_count():
	var ai_count = get_ai_count()
	ai_count += 1
	if ai_count > get_max_ai_count():
		ai_count = 0
	ai_count_btn.text = str(ai_count)
	verify_ai_count()

func _on_NextBtn_pressed():
	verify_ai_count()
	if app_state and not _next_pressed:
		_next_pressed = true
		var game_scn = app_state.get_param("game_scn")
		if game_scn is PackedScene:
			for i in get_ai_count():
				var ai = Player.add_player(-1, 0, $"/root", AIScn)
				show_character(ai)

			if get_ai_count() > 0:	
				yield(get_tree().create_timer(1.5, false), "timeout")
		
		app_state.set_trigger("next")

func _on_BackBtn_pressed():
	if app_state:
		app_state.set_trigger("back")

func _on_AICountBtn_pressed():
	append_ai_count()

func get_min_ai_count():
	return 0 if Player.get_player_count() > 1 else 1

func get_max_ai_count():
	return 4 - Player.get_player_count()

func get_ai_count():
	if not ai_count_btn:
		return 0
	return int(ai_count_btn.text)
