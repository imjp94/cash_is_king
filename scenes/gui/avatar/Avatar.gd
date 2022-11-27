tool
extends Control

const Player = preload("res://scenes/player/Player.gd")

export var player_index = -1 setget set_player_index

onready var rank_label = $"%RankLabel"
onready var building_count_label = $"%BuildingCountLabel"


func _ready():
	set_player_index(player_index)
	update_building_count_label()
	update_rank()

func get_owned_buildings(plyr_index, exclude_bank=true):
	var asset_buildings = get_tree().get_nodes_in_group("asset_building")
	var count = asset_buildings.size()
	for i in count:
		var index = count - 1 - i
		var asset_building = asset_buildings[index] # Descending order
		if asset_building.player_index != plyr_index or (asset_building.is_in_group("bank") and exclude_bank):
			asset_buildings.remove(index)
	return asset_buildings

func update_rank():
	var rank = 1
	var building_count = get_owned_buildings(player_index, false).size()
	for player in Player.PLAYER_STACK:
		if player.index == player_index:
			continue
		
		var player_building_count = get_owned_buildings(player.index, false).size()
		if building_count < player_building_count:
			rank += 1

	var rank_text = "%d%s"
	match rank:
		1:
			rank_label.text = rank_text % [rank, "st"]
		2:
			rank_label.text = rank_text % [rank, "nd"]
		_:
			rank_label.text = rank_text % [rank, "th"]

	rank_label.text 

func update_building_count_label():
	building_count_label.text = "%d/%d" % [get_owned_buildings(player_index, false).size(), get_tree().get_nodes_in_group("asset_building").size()]

func _on_asset_building_player_changed(from, to, asset_building):
	update_rank()
	building_count_label.text = "%d/%d" % [get_owned_buildings(player_index, false).size(), get_tree().get_nodes_in_group("asset_building").size()]

func set_color(v):
	var style = get("custom_styles/panel")
	if style:
		style.set("bg_color", v)

func set_player_index(v):
	player_index = v
	if player_index > -1 and player_index < 4:
		set_color(Player.PLAYER_COLOR[player_index])
	else:
		set_color(Color.black)
		
	var player = Player.get_player(player_index)
	
	if not Engine.editor_hint and is_inside_tree():
		if player:
			show()
			for asset_building in get_tree().get_nodes_in_group("asset_building"):
				asset_building.connect("player_changed", self, "_on_asset_building_player_changed", [asset_building])
		else:
			hide()
