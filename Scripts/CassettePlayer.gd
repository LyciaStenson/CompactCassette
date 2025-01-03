extends StaticBody3D
class_name CassettePlayer

var rotation_speed : Vector2

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

func drag(relative : Vector2) -> void:
	rotation_speed += relative * 0.005

func drop():
	pass

func zoom_in():
	pass

func zoom_out():
	pass

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
	tape_audio_player.stop()
	hiss_audio_player.stop()
	stop_button_animation_player.play("StopButton")
	if tape && play_pressed:
		tape.playback_position = tape_audio_player.get_playback_position()
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
			tape_audio_player.stream = tape.track_1
			tape_audio_player.play(tape.playback_position)

func on_rewind_pressed():
	if !rewind_pressed:
		unpress_buttons()
		tape_audio_player.stop()
		rewind_button_animation_player.play("RewindButton")
		rewind_pressed = true
		await get_tree().create_timer(0.3).timeout
		hiss_audio_player.play()

func on_fast_forward_pressed():
	if !fast_forward_pressed:
		unpress_buttons()
		tape_audio_player.stop()
		fast_forward_button_animation_player.play("FastForwardButton")
		fast_forward_pressed = true
		await get_tree().create_timer(0.3).timeout
		hiss_audio_player.play()

func on_door_pressed():
	if door_open:
		door_animation_player.play_backwards("OpenDoor")
	else:
		door_animation_player.play("OpenDoor")
	door_open = !door_open

func body_entered_area(body : Node3D):
	if door_open && body is CassetteTape && !body.in_player:
		tape = body
		tape.cassette_player = self
		print("Setting in_player true")
		body.in_player = true

func body_exited_area(body : Node3D):
	if door_open && body == tape:
		print("Setting in_player false")
		tape = null
		body.in_player = false
