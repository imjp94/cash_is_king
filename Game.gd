extends Spatial

signal player_lost(player)
signal player_won(player)

const Player = preload("res://scripts/Player.gd")
const Character = preload("res://scenes/characters/main/Character.tscn")

export var start_on_ready = true
export var spawn_time = 3.0
export var overall_interest_rate = 0.0

onready var game_state = $GameState
onready var play_time_label = $PlayTimeLabel

var play_time = 0.0 setget , get_play_time
var player0_spawn_point = Vector3.ZERO
var player1_spawn_point = Vector3.ZERO

var _play_time = 0.0
var _last_play_timestamp = 0
var _winners = []
var _losers = []


func _ready():
	for player in Player.PLAYER_STACK:
		set("player%d_spawn_point" % player.index, player.pawn.global_transform.origin)
		player.pawn.connect("dead", self, "_on_player_pawn_dead", [player])
	for asset_building in get_tree().get_nodes_in_group("asset_building"):
		asset_building.connect("player_changed", self, "_on_asset_building_player_changed", [asset_building])

	start_play_time()
	update_time_label()

	if start_on_ready:
		game_state.set_trigger("start")

func _on_GameState_transited(from, to):
	match to:
		"Entry":
			pass
		"Run":
			pass
		"Pause":
			pass
		"End":
			for winner in _winners:
				winner.enable_input = false
				print("player%d won" % winner.index)
			for loser in _losers:
				loser.enable_input = false
				print("player%d lost" % loser.index)
		"Exit":
			pass

func _on_asset_building_player_changed(from, to, asset_building):
	if not from:
		return
	if from in _losers:
		return
	
	var loser
	if asset_building.is_in_group("bank") or get_tree().get_nodes_in_group("player%d" % from.index).size() == 0:
		loser = from

	if loser:
		_losers.append(from)

		if asset_building.is_in_group("bank"):
			for asset_building in get_tree().get_nodes_in_group("asset_building"):
				if asset_building.player != to:
					asset_building.set_player_np(to.get_path())

		emit_signal("player_lost", loser)
		if Player.PLAYER_STACK.size() - 1 == _losers.size():
			var winner = to
			_winners.append(winner)
			emit_signal("player_won", winner)
			game_state.set_trigger("end")

func _on_player_pawn_dead(player):
	player.set_pawn_np(NodePath())
	
	yield(get_tree().create_timer(spawn_time), "timeout")

	var character = Character.instance()
	add_child(character)
	character.global_transform.origin = get("player%d_spawn_point" % player.index)
	player.set_pawn_np(character.get_path())
	player.pawn.connect("dead", self, "_on_player_pawn_dead", [player])

func _on_TurnTimer_timeout():
	if get_play_time() > 60000 and overall_interest_rate < 0.5:
		overall_interest_rate += 0.01
	
	for asset_building in get_tree().get_nodes_in_group("asset_building"):
		asset_building.call("compute_interest", overall_interest_rate)

func update_time_label():
	play_time_label.text = str(floor(get_play_time() / 1000))
	get_tree().create_timer(1.0).connect("timeout", self, "update_time_label")

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
