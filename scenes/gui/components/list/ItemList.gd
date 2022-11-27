extends ScrollContainer

signal item_selected(index)

onready var hbox = $BG/MarginContainer/HBoxContainer


func _ready():
	if get_child_count() > 0:
		hbox.get_child(0).button.grab_focus()
		for i in hbox.get_child_count():
			var child = hbox.get_child(i)
			child.button.connect("pressed", self, "_on_Item_pressed", [i])

func _on_Item_pressed(index):
	emit_signal("item_selected", index)

func get_item(index):
	return hbox.get_child(index)
