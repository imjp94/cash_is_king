tool
extends Control

export(Texture) var texture setget set_texture
export(String, MULTILINE) var text = "Item" setget set_text

onready var button = $"%Button"
onready var label = $"%Label"


func _ready():
	set_texture(texture)
	set_text(text)

func set_texture(v):
	texture = v
	if is_inside_tree():
		button.get("custom_styles/normal").texture = texture

func set_text(v):
	text = v
	if is_inside_tree():
		label.text = text
