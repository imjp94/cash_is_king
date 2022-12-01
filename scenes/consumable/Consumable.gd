extends Spatial

signal consumed(by)
signal timeout()

export var lifetime = 20.0


func _ready():
	get_tree().create_timer(lifetime, false).connect("timeout", self, "_on_timeout")

func consume(by):
	_consume(by)
	emit_signal("consumed", by)

func _consume(by):
	queue_free()

func _on_Area_body_entered(body):
	consume(body)

func _on_timeout():
	emit_signal("timeout")
	queue_free()
