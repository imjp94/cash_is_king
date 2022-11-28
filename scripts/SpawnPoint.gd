tool
extends Spatial

const Player = preload("res://scenes/player/Player.gd")
const CharacterScene = preload("res://scenes/characters/main/Character.tscn")

export var player_index = 0


func spawn():
	if not Player.get_player(player_index):
		return false
	
	var player = Player.PLAYER_STACK[player_index]
	var character = CharacterScene.instance()
	get_parent().add_child(character)
	character.global_transform = global_transform
	character.player = player
	player.set_pawn_np(character.get_path())
	
	return true
