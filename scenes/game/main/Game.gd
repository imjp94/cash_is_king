extends Spatial

signal player_lost(player)
signal player_won(player)

const Player = preload("res://scenes/player/Player.gd")
const Character = preload("res://scenes/characters/main/Character.tscn")

export var start_on_ready = true
export var spawn_time = 3.0
export var overall_interest_rate = 0.0

onready var game_state = $GameState
onready var play_turn_label = $"%PlayTurnLabel"
onready var play_time_label = $"%PlayTimeLabel"
onready var pause_screen = $PauseScreen
onready var game_score = $GameScore
onready var turn_timer = $TurnTimer

var app_state
var play_time = 0.0 setget , get_play_time

var _play_time = 0.0
var _last_play_timestamp = 0
var _winners = []
var _losers = []


func _ready():
	pause_screen.game_state = game_state
	game_score.game_state = game_state
	for asset_building in get_tree().get_nodes_in_group("asset_building"):
		asset_building.connect("player_changed", self, "_on_asset_building_player_changed", [asset_building])

	update_turn_label()
	update_time_label()

	if start_on_ready:
		game_state.set_trigger("start")

func _on_GameState_transited(from, to):
	match from:
		"Pause":
			get_tree().paused = false
	
	match to:
		"Entry":
			pass
		"Run":
			start_play_time()
			if from == "Entry":
				for spawn_point in get_tree().get_nodes_in_group("spawn_point"):
					if spawn_point.spawn():
						var player = Player.PLAYER_STACK[spawn_point.player_index]
						player.pawn.connect("dead", self, "_on_player_pawn_dead", [player])
		"Pause":
			end_play_time()
			get_tree().paused = true
		"End":
			for winner in _winners:
				winner.enable_input = false
				print("player%d won" % winner.index)
				game_score.message.bbcode_text = game_score.message.bbcode_text % [winner.color.to_html(), winner.index + 1]
			for loser in _losers:
				loser.enable_input = false
				print("player%d lost" % loser.index)
			game_score.show()
		"Exit":
			for player in Player.PLAYER_STACK:
				player.enable_input = true
			for ai in get_tree().get_nodes_in_group("ai"):
				ai.get_parent().remove_child(ai)
				ai.queue_free()
			if app_state:
				app_state.set_trigger("finish")

func _on_asset_building_player_changed(from, to, asset_building):
	if not from:
		return
	if from in _losers:
		return
	
	var loser
	var has_more_bank = false
	var has_building = get_tree().get_nodes_in_group("player%d" % from.index).size() > 0
	for bank in get_tree().get_nodes_in_group("bank"):
		if bank == asset_building:
			continue
		if bank.player_index == from.index:
			has_more_bank = true
			break
	
	if not has_building or not has_more_bank:
		loser = from

	if loser:
		_losers.append(from)

		if asset_building.is_in_group("bank"):
			for asset_building in get_tree().get_nodes_in_group("asset_building"):
				if asset_building.player == loser:
						if not has_more_bank:
							asset_building.player_index = to.index
		loser.pawn.disconnect("dead", self, "_on_player_pawn_dead")
		loser.pawn.queue_free()
		emit_signal("player_lost", loser)
		if Player.PLAYER_STACK.size() - 1 == _losers.size():
			var winner = to
			_winners.append(winner)
			emit_signal("player_won", winner)
			game_state.set_trigger("end")

func _on_player_pawn_dead(player):
	player.set_pawn_np(NodePath())
	
	yield(get_tree().create_timer(spawn_time, false), "timeout")

	for spawn_point in get_tree().get_nodes_in_group("spawn_point"):
		if spawn_point.player_index == player.index:
			spawn_point.spawn()
			for bank in get_tree().get_nodes_in_group("bank"):
				if bank.player_index == player.index:
					var default_pawn_health = player.pawn.health.value # This is the default health set in inspector
					var amount = min(bank.health.value, default_pawn_health)
					bank.health.deduct(amount)
					player.pawn.health.value = amount
					break
			break
	player.pawn.connect("dead", self, "_on_player_pawn_dead", [player])

func _on_TurnTimer_timeout():
	update_turn_label()
	if get_play_time() > 300000 and overall_interest_rate < 0.3:
		overall_interest_rate += 0.01
	
	for asset_building in get_tree().get_nodes_in_group("asset_building"):
		asset_building.call("compute_interest", overall_interest_rate)

func update_turn_label():
	var turn = int(get_play_time() / (turn_timer.wait_time * 1000))
	play_turn_label.text = "Turn %d" % turn

func update_time_label():
	play_time_label.text = str(floor(get_play_time() / 1000))
	get_tree().create_timer(1.0, false).connect("timeout", self, "update_time_label")

func start_play_time():
	if is_playing():
		return
	
	_last_play_timestamp = OS.get_ticks_msec()

func end_play_time():
	if not is_playing():
		return
	
	_play_time += OS.get_ticks_msec() - _last_play_timestamp
	_last_play_timestamp = NAN

func is_playing():
	return not is_nan(_last_play_timestamp)

func get_play_time():
	if is_playing():
		return _play_time + OS.get_ticks_msec() - _last_play_timestamp
	return _play_time

func get_winners():
	return _winners.duplicate()

func get_losers():
	return _losers.duplicate()
