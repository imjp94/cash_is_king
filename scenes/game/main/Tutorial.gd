extends "res://scenes/game/main/Game.gd"


onready var portal_area = $PortalArea


func _on_PortalArea_body_entered(body):
	if portal_area.get_overlapping_bodies().size() == Player.get_player_count():
		game_state.set_trigger("end")
		game_state.set_trigger("exit")

func _on_GameState_transited(from, to):
	._on_GameState_transited(from, to)
	match to:
		"End":
			game_score.hide()
