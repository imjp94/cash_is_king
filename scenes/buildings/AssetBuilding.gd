tool
extends "res://scenes/buildings/Building.gd"

signal player_changed(from, to)
signal interest_computed(matured_interest)

# Use interest if both specified, else use any variable that is not zero
export var interest = 5
export var interest_rate = 0.05
export(NodePath) var player_np setget set_player_np

onready var health = $Health
onready var label3d = $Label3D

var player setget set_player


func _ready():
	set_player_np(player_np)
	label3d.text = health.to_text()

func event(by, extra={}):
	return withdraw(by, extra.get("amount", 0))

func _on_Area_body_entered(projectile):
	if not projectile.instigator: # Coin when drop on floor and pickable
		return
	
	anim_player.play("hit")

	var instigator = projectile.instigator
	if player == instigator:
		health.increase(projectile.damage)
	else:
		if health.credit(instigator, projectile.damage):
			set_player(instigator)

	projectile.queue_free()

func _on_withdraw(by, amount):
	if health.value <= 0:
		return 0
	if player != by:
		return 0
	
	var pawn = player.pawn
	var pawn_health = pawn.get_node_or_null("Health")
	if pawn_health:
		pawn_health.increase(amount)
	health.deduct(amount)
	return amount

func _on_player_changed(from, to):
	pass

func _on_Health_changed(diff):
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

	coins_flow(self, self, matured_interest)
	emit_signal("interest_computed", matured_interest)

func set_player_np(v):
	player_np = v
	if is_inside_tree():
		set_player(get_node_or_null(player_np))

func set_player(v):
	var old = player
	player = v
	if player != old and player != null:
		if old:
			remove_from_group("player%d" % old.index)
		add_to_group("player%d" % player.index)
		if mesh_instance:
			mesh_instance.get("material/0").set("albedo_color", player.color)
		_on_player_changed(old, player)
		emit_signal("player_changed", old, player)

func has_player():
	return !!player
