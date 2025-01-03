extends CharacterBody3D
class_name CassetteTape

@export var track_1 : AudioStream
@export var track_2 : AudioStream

@onready var camera : Camera3D = get_viewport().get_camera_3d()

var cassette_player : CassettePlayer
var in_player : bool = false
var dropped_in_player : bool = false

var playback_position : float

func drag(relative : Vector2) -> void:
	if in_player && !dropped_in_player:
		return
	#in_player = false
	#dropped_in_player = false
	velocity = Vector3(relative.x * 0.3, -relative.y * 0.3, 0.0)

func drop():
	dropped_in_player = in_player
	#if in_player:
		#dropped_in_player = true

func zoom_in():
	var zoom : Vector3 = 1.3 * (global_position - camera.global_position).normalized()
	velocity += zoom

func zoom_out():
	var zoom : Vector3 = 1.3 * (global_position - camera.global_position).normalized()
	velocity -= zoom

func _process(_delta : float) -> void:
	if dropped_in_player:
		global_position = cassette_player.tape_point.global_position
		global_rotation = cassette_player.tape_point.global_rotation

func _physics_process(_delta : float) -> void:
	if abs(velocity.x) > 0.05 or abs(velocity.y) > 0.05 or abs(velocity.z) > 0.05:
		velocity.x *= 0.9
		velocity.y *= 0.9
		velocity.z *= 0.9
	else:
		velocity.x = 0.0
		velocity.y = 0.0
		velocity.z = 0.0
	
	move_and_slide()
