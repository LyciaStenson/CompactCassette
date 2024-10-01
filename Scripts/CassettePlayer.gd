extends Grabbable

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	#grabbed(Vector2(100.0 * randf_range(0.7, 1.3) * delta, 100.0 * randf_range(0.7, 1.3) * delta));
	pass

func grabbed(relative : Vector2):
	print("relative: " + str(relative.x) + ", " + str(relative.y))
	rotate(Vector3(0.0, 1.0, 0.0), relative.x * 0.01)
	rotate(Vector3(1.0, 0.0, 0.0), relative.y * 0.01)
