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
const PLAYER_COLOR = [Color("3333ff"), Color("ff3333"), Color("ffff33"), Color("33ff33")]

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
	color = PLAYER_COLOR[get_index()]

func _exit_tree():
	PLAYER_STACK.remove(get_index())

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

		if can_handle:
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
	else:
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

# Keyboard action doesn't have suffix device index - "action". Controller action always come with device index - "action0"
func get_action(action):
	var has_keyboard_player = false
	for player in PLAYER_STACK:
		if player.device_type == DEVICE_TYPE.KEYBOARD:
			has_keyboard_player = true
			break
	var controller_index = max(get_index()-1, 0) if has_keyboard_player else get_index()
	return action if device_type == DEVICE_TYPE.KEYBOARD else "%s%d" % [action,controller_index]

static func get_device_type(event):
	if event is InputEventKey:
		return DEVICE_TYPE.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return DEVICE_TYPE.JOYPAD
	elif event is InputEventMouse:
		return DEVICE_TYPE.MOUSE
	else:
		printerr("Unknown device type from event: ", event)
		return DEVICE_TYPE.ALL

static func get_player_index(dev, dev_type):
	for player in PLAYER_STACK:
		if player.device == dev and player.device_type == dev_type:
			return player.index
	return -1

static func get_player(idx):
	for player in PLAYER_STACK:
		if idx == player.index:
			return player
	return null

static func has_player(dev, dev_type):
	for player in PLAYER_STACK:
		if player.device == dev and player.device_type == dev_type:
			return true
	return false

static func get_player_count():
	return PLAYER_STACK.size()

static func add_player_from_input(event, parent, player_packed_scene):
	var dev = event.device
	var dev_type = get_device_type(event)
	if not has_player(dev, dev_type):
		var new_player = add_player(dev, dev_type, parent, player_packed_scene)
		return new_player
	return null

static func add_player(dev, dev_type, parent, player_packed_scene):
	var new_player = player_packed_scene.instance()
	new_player.device = dev
	new_player.device_type = dev_type
	parent.add_child(new_player)
	return new_player
