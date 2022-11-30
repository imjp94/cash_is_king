extends "res://scenes/consumable/Consumable.gd"

const Coin = preload("res://scenes/projectile/Coin.gd")
const CoinScene = preload("res://scenes/projectile/Coin.tscn")
const MonsterPathScene = preload("res://scenes/others/monster/MonsterPath.tscn")

onready var bad_overlay = $BadOverlay
onready var good_overlay = $GoodOverlay


func _consume(by):
	randomize()
	var rng = randf()
	if rng > 0.5:
		var inst = MonsterPathScene.instance()
		get_parent().add_child(inst)
		inst.rotate_y(randf() * 2 * PI)
		bad_overlay.label.bbcode_text = bad_overlay.label.bbcode_text % "Monster Incoming!!!"
		bad_overlay.show()
		yield(bad_overlay, "tree_exited")
	else:
		prize(by)
		good_overlay.show()
		yield(good_overlay, "tree_exited")
	
	queue_free()

func prize(by):
	var amount = 10 + randi() % 41
	good_overlay.label.bbcode_text = good_overlay.label.bbcode_text % ("Won $%d from lottery!" % amount)
	by.health.increase(amount)
