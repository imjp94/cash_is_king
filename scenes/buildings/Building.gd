extends Spatial

const CoinScene = preload("res://scenes/projectile/Coin.tscn")

onready var anim_player = $AnimationPlayer
onready var mesh_instance = $Root/MeshInstance


func event(by, extra={}):
	pass

func withdraw(by, amount):	
	amount = _on_withdraw(by, amount)
	coins_flow(self, by.pawn, amount)
	return amount

func deposit(by, amount):
	amount = _on_deposit(by, amount)
	coins_flow(by.pawn, self, amount)
	return amount

func _on_withdraw(by, amount):
	return amount

func _on_deposit(by, amount):
	return amount

func coin_flow(from, to):
	anim_player.play_backwards("hit")
	var coin = CoinScene.instance()
	coin.target = to
	get_parent().add_child(coin)
	coin.global_transform.origin = from.global_transform.origin
	coin._origin = from.global_transform.origin

func coins_flow(from, to, amount):
	for i in amount:
		coin_flow(from, to)
		yield(get_tree().create_timer(0.1), "timeout")
