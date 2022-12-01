extends Spatial

onready var character1 = $Character1
onready var character2 = $Character2
onready var character3 = $Character3
onready var character4 = $Character4

func _ready():
	for i in 4:
		var character = get("character%d" % (i+1))
		character.anim_player.stop() # Stop spawn animation
		character.mesh_instance.set("material/1", null) # TOOD: Better way to stop spawning animation
