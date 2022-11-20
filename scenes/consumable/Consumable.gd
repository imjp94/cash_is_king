extends Spatial

signal consumed(by)


func consume(by):
	_consume(by)
	emit_signal("consumed", by)

func _consume(by):
	queue_free()

func _on_Area_body_entered(body):
	consume(body)
