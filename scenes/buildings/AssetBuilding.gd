tool
extends "res://scenes/buildings/Building.gd"

const Player = preload("res://scenes/player/Player.gd")

signal player_changed(from, to)
signal interest_computed(matured_interest)
signal upgraded()

export var player_index = -1 setget set_player_index
export var biddable = true setget set_biddable
export var upgrade_threshold = 50
# Use interest if both specified, else use any variable that is not zero
export var interest = 5
export var interest_rate = 0.05

onready var health = $Health
onready var label3d = $Label3D
onready var area = $Area

var player setget , get_player


func _ready():
	set_player_index(player_index)
	set_biddable(biddable)
	label3d.text = health.to_text()

func event(by, extra={}):
	return withdraw(by, extra.get("amount", 0), extra.get("grade", 0))

func _on_Area_body_entered(projectile):
	if not projectile.instigator: # Coin when drop on floor and pickable
		return
	
	anim_player.play("hit")

	var instigator = projectile.instigator
	if player == instigator:
		health.increase(projectile.damage)
	else:
		if health.credit(instigator, projectile.damage):
			set_player_index(instigator.index)

	projectile.queue_free()

func _on_withdraw(by, amount, grade):
	if health.value <= 0:
		return 0
	if player != by:
		return 0
	
	amount = min(health.value, amount)
	var pawn = player.pawn
	var pawn_health = pawn.get_node_or_null("Health")
	if pawn_health:
		pawn_health.increase(amount)
	health.deduct(amount)
	return amount

func _on_player_changed(from, to):
	pass

var _is_upgraded = false # TODO: Debug purpose only, current building should be directly replaced by new one

func _on_Health_changed(diff):
	if upgrade_threshold > 0 and health.value >= upgrade_threshold and not _is_upgraded:
		# TODO: Debug purpose only, it should popup window to let owner choose what type of building to upgrade to
		interest *= 2
		interest_rate *= 2
		scale *= 1.3
		_is_upgraded = true

		emit_signal("upgraded")

	if not label3d:
		return

	label3d.text = health.to_text()

func _on_Health_credited(creditor, amount):
	if not label3d:
		return
	
	label3d.text = health.to_text()

func _on_Health_broke(by, credits):
	if not label3d:
		return
	
	label3d.text = health.to_text()

	for creditor in credits:
		if by == creditor:
			continue

		var amount = credits[creditor]
		var target = creditor.pawn
		var target_health = target.get_node("Health")
		for i in amount:
			var coin = CoinScene.instance()
			coin.target = target
			get_parent().add_child(coin)
			coin.global_transform.origin = global_transform.origin
			coin._origin = global_transform.origin
			target_health.increase(1)
			yield(get_tree().create_timer(0.1), "timeout")

func _on_Health_credit_timeout(credits):
	if not label3d:
		return
	
	label3d.text = health.to_text()

	for creditor in credits:
		var amount = credits[creditor]
		var target = creditor.pawn
		if not is_instance_valid(target): # TODO: Happens when player dead and havent respawned, should return to creditor's bank
			return
		var target_health = target.get_node("Health")
		for i in amount:
			var coin = CoinScene.instance()
			coin.target = target
			get_parent().add_child(coin)
			coin.global_transform.origin = global_transform.origin
			coin._origin = global_transform.origin
			target_health.increase(1)
			yield(get_tree().create_timer(0.1), "timeout")

func compute_interest(extra_interest_rate):
	if not has_player():
		return
	
	var matured_interest = 0
	if interest > 0:
		matured_interest += interest
	else:
		matured_interest += floor(health.value * interest_rate)
	matured_interest += floor(health.value * extra_interest_rate)
	
	health.increase(matured_interest)

	coins_flow(self, self, matured_interest, 2) # TODO: Dynamically decide coin grade
	emit_signal("interest_computed", matured_interest)

func set_color(v):
	if mesh_instance:
		mesh_instance.get("material/0").set("albedo_color", v)

func set_player_index(v):
	var old = player_index
	player_index = v
	var old_player = Player.get_player(old)
	var player = Player.get_player(player_index)
	if old_player:
		remove_from_group("player%d" % old_player.index)
	if player:
		add_to_group("player%d" % player.index)
	
	if player_index > -1 and player_index < Player.PLAYER_COLOR.size():
		set_color(Player.PLAYER_COLOR[player_index])
	else:
		set_color(Color.white)

	if player_index != old:
		_on_player_changed(old_player, player)
		emit_signal("player_changed", old_player, player)

func get_player():
	return Player.get_player(player_index)

func has_player():
	return !!player

func set_biddable(v):
	biddable = v
	if is_inside_tree():
		area.monitoring = biddable
		label3d.modulate.a = 1.0 if biddable else 0.2
