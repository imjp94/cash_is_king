extends NavigationObstacle


func _ready():
	NavigationServer.agent_set_map(get_rid(), get_parent().get_world().get_navigation_map())
