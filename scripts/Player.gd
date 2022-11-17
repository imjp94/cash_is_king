tool
extends Node

signal color_changed(from, to)
signal pawn_changed(from, to)

enum DEVICE_TYPE {
	ALL = 7 # 111
	KEYBOARD = 1, # 001
	JOYPAD = 1 << 1, # 010
	MOUSE = 1 << 2, # 100
}

const PLAYER_STACK = []

export var enable_input = true
export var device = -1
export(DEVICE_TYPE) var device_type = DEVICE_TYPE.ALL
export var color = Color.blue setget set_color
export(NodePath) var pawn_np setget set_pawn_np

var index = -1 setget , get_index

var pawn


func _ready():
	set_pawn_np(pawn_np)

func _enter_tree():
	PLAYER_STACK.append(self)

func _exit_tree():
	PLAYER_STACK.remove(index)

func _color_changed(from, to):
	pass

func set_color(v):
	var old = color
	color = v
	if color != old:
		_color_changed(old, color)
		emit_signal("color_changed", old, color)

func can_handle_event(event):
	if not enable_input:
		return false
	
	var can_handle = true
	if device >= 0:
		if event.device != device:
			can_handle = false

	if device_type < DEVICE_TYPE.ALL:
		if event is InputEventKey:
			if not (device_type & DEVICE_TYPE.KEYBOARD):
				can_handle = false
		elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if not (device_type & DEVICE_TYPE.JOYPAD):
				can_handle = false
		elif event is InputEventMouse:
			if not (device_type & DEVICE_TYPE.MOUSE):
				can_handle = false

	return can_handle

func _on_pawn_dead():
	set_pawn_np(NodePath())

func set_pawn_np(v):
	pawn_np = v
	if is_inside_tree() and pawn_np:
		var old = pawn
		pawn = get_node_or_null(pawn_np)
		if pawn:
			pawn.set("player", self)
			pawn.connect("dead", self, "_on_pawn_dead")
		if pawn != old:
			emit_signal("pawn_changed", old, pawn)

func get_index():
	return PLAYER_STACK.find(self)
