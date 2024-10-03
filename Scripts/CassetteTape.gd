extends CharacterBody3D

@export var camera : Camera3D

func grabbed(relative : Vector2) -> void:
	velocity = Vector3(relative.x * 0.3, -relative.y * 0.3, 0.0)

func zoom():
	var test : Vector3 = (global_position - camera.global_position).normalized()
	velocity += test

func _physics_process(delta : float) -> void:
	if abs(velocity.x) > 0.05 or abs(velocity.y) > 0.05:
		#position += Vector3(speed.x * delta, -speed.y * delta, 0.0)
		velocity.x *= 0.9
		velocity.y *= 0.9
	else:
		velocity.x = 0.0
		velocity.y = 0.0
	
	move_and_slide()
