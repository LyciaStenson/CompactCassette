extends CharacterBody3D
class_name CassetteTape

@export var track_1 : AudioStream
@export var track_2 : AudioStream

@onready var camera : Camera3D = get_viewport().get_camera_3d()

var in_player : bool = false

func drag(relative : Vector2) -> void:
	velocity = Vector3(relative.x * 0.3, -relative.y * 0.3, 0.0)

func zoom_in():
	var zoom : Vector3 = 1.3 * (global_position - camera.global_position).normalized()
	velocity += zoom

func zoom_out():
	var zoom : Vector3 = 1.3 * (global_position - camera.global_position).normalized()
	velocity -= zoom

func _physics_process(_delta : float) -> void:
	if !in_player:
		if abs(velocity.x) > 0.05 or abs(velocity.y) > 0.05 or abs(velocity.z) > 0.05:
			velocity.x *= 0.9
			velocity.y *= 0.9
			velocity.z *= 0.9
		else:
			velocity.x = 0.0
			velocity.y = 0.0
			velocity.z = 0.0
		
		move_and_slide()
