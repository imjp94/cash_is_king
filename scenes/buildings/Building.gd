extends Spatial

signal destroy(by, extra)

const Coin = preload("res://scenes/projectile/Coin.gd")
const CoinScene = preload("res://scenes/projectile/Coin.tscn")

onready var anim_player = $AnimationPlayer
onready var mesh_instance = $Root/MeshInstance


func event(by, extra={}):
	pass

func withdraw(by, amount, grade):	
	amount = _on_withdraw(by, amount, grade)
	coins_flow(self, by.pawn, amount, grade)
	return amount

func deposit(by, amount, grade):
	amount = _on_deposit(by, amount, grade)
	coins_flow(by.pawn, self, amount, grade)
	return amount

func destroy(by, extra={}):
	anim_player.play("destroy")
	_on_destroy(by)
	emit_signal("destroy", by, extra)

func _on_withdraw(by, amount, grade):
	return amount

func _on_deposit(by, amount, grade):
	return amount

func _on_destroy(by):
	pass

func coin_flow(from, to, grade):
	anim_player.play_backwards("hit")
	var coin = CoinScene.instance()
	coin.target = to
	get_parent().add_child(coin)
	coin.grade = grade
	coin.global_transform.origin = from.global_transform.origin
	coin._origin = from.global_transform.origin

func coins_flow(from, to, amount, grade):
	amount /= Coin.GRADE_DAMAGE[grade]
	for i in amount:
		coin_flow(from, to, grade)
		yield(get_tree().create_timer(0.1), "timeout")
