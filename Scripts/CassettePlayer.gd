extends StaticBody3D
class_name CassettePlayer

var rotation_speed : Vector2

@onready var tape_point : Node3D = $TapePoint

@onready var stop_button : CassettePlayerButton = $StopButton
@onready var play_button : CassettePlayerButton = $PlayButton
@onready var rewind_button : CassettePlayerButton = $RewindButton
@onready var fast_forward_button : CassettePlayerButton = $FastFowardButton

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var audio_player : AudioStreamPlayer3D = $AudioStreamPlayer3D

var tape : CassetteTape

func _ready() -> void:
	stop_button.pressed.connect(stop_button_pressed)
	play_button.pressed.connect(play_button_pressed)
	rewind_button.pressed.connect(rewind_button_pressed)
	fast_forward_button.pressed.connect(fast_forward_button_pressed)

func _physics_process(delta : float) -> void:
	if abs(rotation_speed.x) > 0.05 or abs(rotation_speed.y) > 0.05:
		rotate(Vector3(0.0, 1.0, 0.0), rotation_speed.x * delta)
		rotate(Vector3(1.0, 0.0, 0.0), rotation_speed.y * delta)
		rotation_speed.x *= 0.95
		rotation_speed.y *= 0.95
	else:
		rotation_speed.x = 0.0
		rotation_speed.y = 0.0

func drag(relative : Vector2) -> void:
	rotation_speed += relative * 0.01

func zoom_in():
	pass

func zoom_out():
	pass

func stop_button_pressed():
	audio_player.stop()
	#animation_player.play("OpenDoor")
	print("Stop Button Pressed")

func play_button_pressed():
	if !audio_player.playing && tape:
		audio_player.stream = tape.track_1
		audio_player.play(0.0)
	print("Play Button Pressed")

func rewind_button_pressed():
	print("Rewind Button Pressed")

func fast_forward_button_pressed():
	print("Fast Forward Button Pressed")

func body_entered_area(body : Node3D):
	if body is CassetteTape && body.is_physics_processing():
		tape = body
		body.reparent(tape_point)
		body.in_player = true
		body.position = Vector3()
		body.rotation = Vector3()
		#body.set_physics_process(false)
		#body.position = tape_point.position
