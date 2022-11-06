extends Spatial

const Player = preload("res://scripts/Player.gd")
const Character = preload("res://scenes/characters/main/Character.tscn")

export var spawn_time = 3.0
export var overall_interest_rate = 0.0

onready var play_time_label = $PlayTimeLabel

var play_time = 0.0 setget , get_play_time
var player0_spawn_point = Vector3.ZERO
var player1_spawn_point = Vector3.ZERO

var _play_time = 0.0
var _last_play_timestamp = 0


func _ready():
	for player in Player.PLAYER_STACK:
		set("player%d_spawn_point" % player.index, player.pawn.global_transform.origin)
		player.pawn.connect("dead", self, "_on_player_pawn_dead", [player])
	for asset_building in get_tree().get_nodes_in_group("asset_building"):
		asset_building.connect("player_changed", self, "_on_asset_building_player_changed", [asset_building])

	start_play_time()
	update_time_label()

func _on_asset_building_player_changed(from, to, asset_building):
	for player in Player.PLAYER_STACK:
		if get_tree().get_nodes_in_group("player%d" % player.index).size() == 0:
			print("player%d lose" % player.index)
			return

func _on_player_pawn_dead(player):
	yield(get_tree().create_timer(spawn_time), "timeout")

	var character = Character.instance()
	add_child(character)
	character.global_transform.origin = get("player%d_spawn_point" % player.index)
	player.set_pawn_np(character.get_path())

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
