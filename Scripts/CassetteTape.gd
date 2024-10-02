extends Grabbable

#var speed : Vector2

func grabbed(relative : Vector2) -> void:
	#speed = relative * 0.215
	#velocity = Vector3(relative.x, relative.y, 0.0)
	apply_central_force(Vector3(relative.x, relative.y, 0.0))

#func _physics_process(delta : float) -> void:
	#if abs(speed.x) > 0.05 or abs(speed.y) > 0.05:
		#position += Vector3(speed.x * delta, -speed.y * delta, 0.0)
		#speed.x *= 0.9
		#speed.y *= 0.9
	#else:
		#speed.x = 0.0
		#speed.y = 0.0
