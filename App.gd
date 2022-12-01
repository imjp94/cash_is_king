extends Node

export(PackedScene) var splash_screen
export(PackedScene) var start_screen_scn
export(PackedScene) var main_menu_scn
export(PackedScene) var level_select_scn
export(PackedScene) var character_select_scn
export(PackedScene) var setting_scn

onready var app_state = $AppState


func _on_AppState_transited(from, to):
	# Handle previous scene
	var prev_scn = get_node_or_null(from)
	
	# Handle next scene
	var next_scn
	match to:
		"SplashScreen":
			next_scn = splash_screen.instance()
		"StartScreen":
			next_scn = start_screen_scn.instance()
		"MainMenu":
			next_scn = main_menu_scn.instance()
		"LevelSelect":
			next_scn = level_select_scn.instance()
		"CharacterSelect":
			next_scn = character_select_scn.instance()
		"Game":
			var game_scn = app_state.get_param("game_scn")
			next_scn = game_scn.instance()
		"Setting":
			next_scn = setting_scn.instance()
		"Exit":
			get_tree().quit()

	if prev_scn:
		prev_scn.queue_free()

	if next_scn:
		next_scn.name = to
		next_scn.set("app_state", app_state)
		add_child(next_scn)
