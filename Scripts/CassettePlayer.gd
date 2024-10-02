extends Grabbable

var speed : Vector2

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	#grabbed(Vector2(100.0 * randf_range(0.7, 1.3) * delta, 100.0 * randf_range(0.7, 1.3) * delta));
	pass

func _physics_process(delta):
	if abs(speed.x) > 0.05 or abs(speed.y) > 0.05:
		rotate(Vector3(0.0, 1.0, 0.0), speed.x * delta)
		rotate(Vector3(1.0, 0.0, 0.0), speed.y * delta)
		speed.x *= 0.95
		speed.y *= 0.95
	else:
		speed.x = 0.0
		speed.y = 0.0
	print(speed)

func grabbed(relative : Vector2):
	speed += relative * 0.01
	#rotate(Vector3(0.0, 1.0, 0.0), relative.x * 0.01)
	#rotate(Vector3(1.0, 0.0, 0.0), relative.y * 0.01)
