extends StaticBody3D
class_name CassettePlayer

var rotation_speed : Vector2

var velocity : Vector3

@onready var tape_point : Node3D = $TapePoint

@onready var stop_button : Clickable3D = $StopButton
@onready var play_button : Clickable3D = $PlayButton
@onready var rewind_button : Clickable3D = $RewindButton
@onready var fast_forward_button : Clickable3D = $FastFowardButton

var door_open : bool = false
@onready var door_clickable : Clickable3D = $DoorClickable

var play_pressed : bool = false
var rewind_pressed : bool = false
var fast_forward_pressed : bool = false

@onready var door_animation_player : AnimationPlayer = $DoorAnimationPlayer

@onready var stop_button_animation_player : AnimationPlayer = $StopButtonAnimationPlayer
@onready var play_button_animation_player : AnimationPlayer = $PlayButtonAnimationPlayer
@onready var rewind_button_animation_player : AnimationPlayer = $RewindButtonAnimationPlayer
@onready var fast_forward_button_animation_player : AnimationPlayer = $FastFowardButtonAnimationPlayer

@onready var tape_audio_player : AudioStreamPlayer = $TapeAudioStreamPlayer
@onready var hiss_audio_player : AudioStreamPlayer = $HissAudioStreamPlayer

@onready var camera : Camera3D = get_viewport().get_camera_3d()

var tape : CassetteTape

func _ready() -> void:
	stop_button.clicked.connect(on_stop_pressed)
	play_button.clicked.connect(on_play_pressed)
	rewind_button.clicked.connect(on_rewind_pressed)
	fast_forward_button.clicked.connect(on_fast_forward_pressed)
	
	door_clickable.clicked.connect(on_door_pressed)

func _process(delta):
	if tape:
		if fast_forward_pressed:
			tape.playback_position += delta * 2.0
			tape.playback_position = clampf(tape.playback_position, 0.0, tape.track_1.get_length())
		elif rewind_pressed:
			tape.playback_position -= delta * 2.0
			tape.playback_position = clampf(tape.playback_position, 0.0, tape.track_1.get_length())

func _physics_process(delta : float) -> void:
	if abs(rotation_speed.x) > 0.05 or abs(rotation_speed.y) > 0.05:
		rotate(Vector3(0.0, 1.0, 0.0), rotation_speed.x * delta)
		rotate(Vector3(1.0, 0.0, 0.0), rotation_speed.y * delta)
		rotation_speed.x *= 0.95
		rotation_speed.y *= 0.95
	else:
		rotation_speed.x = 0.0
		rotation_speed.y = 0.0
	
	if abs(velocity.x) > 0.05 or abs(velocity.y) > 0.05 or abs(velocity.z) > 0.05:
		velocity.x *= 0.9
		velocity.y *= 0.9
		velocity.z *= 0.9
	else:
		velocity.x = 0.0
		velocity.y = 0.0
		velocity.z = 0.0
	global_position += velocity * delta

func drag(relative : Vector2) -> void:
	rotation_speed += relative * 0.005

func drop():
	pass

func zoom_in():
	var zoom : Vector3 = 1.3 * (global_position - camera.global_position).normalized()
	velocity += zoom

func zoom_out():
	var zoom : Vector3 = 1.3 * (global_position - camera.global_position).normalized()
	velocity -= zoom

func unpress_buttons() -> bool:
	var button_unpressed : bool = false
	if play_pressed:
		play_button_animation_player.play("PlayMechanism", -1, -3.0, true)
		play_pressed = false
		button_unpressed = true
	if rewind_pressed:
		rewind_button_animation_player.play("RewindButton", -1, -3.0, true)
		rewind_pressed = false
		button_unpressed = true
	if fast_forward_pressed:
		fast_forward_button_animation_player.play("FastForwardButton", -1, -3.0, true)
		fast_forward_pressed = false
		button_unpressed = true
	return !button_unpressed && !door_open

func on_stop_pressed():
	stop_button_animation_player.play("StopButton")
	if tape && play_pressed:
		tape.playing = false
		tape.playback_position = tape_audio_player.get_playback_position()
		print("Set playback to ", tape_audio_player.get_playback_position())
	tape_audio_player.stop()
	hiss_audio_player.stop()
	if unpress_buttons():
		door_open = true
		await get_tree().create_timer(0.1).timeout
		door_animation_player.play("OpenDoor")

func on_play_pressed():
	if !play_pressed:
		unpress_buttons()
		play_button_animation_player.play("PlayMechanism")
		play_pressed = true
		await get_tree().create_timer(0.3).timeout
		hiss_audio_player.play()
		await get_tree().create_timer(0.1).timeout
		if !tape_audio_player.playing && tape:
			tape.playing = true
			tape_audio_player.stream = tape.track_1
			tape_audio_player.volume_db = tape.volume
			tape_audio_player.play(tape.playback_position)

func on_rewind_pressed():
	if !rewind_pressed:
		unpress_buttons()
		tape_audio_player.stop()
		rewind_button_animation_player.play("RewindButton")
		rewind_pressed = true
		await get_tree().create_timer(0.3).timeout
		hiss_audio_player.play()
		if tape:
			tape.playing = true

func on_fast_forward_pressed():
	if !fast_forward_pressed:
		unpress_buttons()
		tape_audio_player.stop()
		fast_forward_button_animation_player.play("FastForwardButton")
		fast_forward_pressed = true
		await get_tree().create_timer(0.3).timeout
		hiss_audio_player.play()
		if tape:
			tape.playing = true

func on_door_pressed():
	if door_open:
		door_animation_player.play_backwards("OpenDoor")
	else:
		door_animation_player.play("OpenDoor")
	door_open = !door_open

func body_entered_area(body : Node3D):
	if !tape && door_open && body is CassetteTape && !body.in_player:
		tape = body
		tape.cassette_player = self
		body.in_player = true

func body_exited_area(body : Node3D):
	if door_open && body == tape:
		tape = null
		body.in_player = false
