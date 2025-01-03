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

@onready var door_animation_player : AnimationPlayer = $DoorAnimationPlayer
@onready var play_button_animation_player : AnimationPlayer = $PlayButtonAnimationPlayer
@onready var rewind_button_animation_player : AnimationPlayer = $RewindButtonAnimationPlayer

@onready var tape_audio_player : AudioStreamPlayer = $TapeAudioStreamPlayer
@onready var hiss_audio_player : AudioStreamPlayer = $HissAudioStreamPlayer

var tape : CassetteTape

func _ready() -> void:
	stop_button.clicked.connect(on_stop_pressed)
	play_button.clicked.connect(on_play_pressed)
	rewind_button.clicked.connect(on_rewind_pressed)
	fast_forward_button.clicked.connect(on_fast_forward_pressed)
	
	door_clickable.clicked.connect(on_door_pressed)

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

func zoom_in():
	pass

func zoom_out():
	pass

func on_stop_pressed():
	var button_unpressed : bool = false
	if play_pressed:
		play_button_animation_player.play_backwards("PlayMechanism")
		play_pressed = false
		button_unpressed = true
	if rewind_pressed:
		rewind_button_animation_player.play_backwards("RewindButton")
		rewind_pressed = false
		button_unpressed = true
	if !button_unpressed && !door_open:
		door_open = true
		door_animation_player.play("OpenDoor")
	if tape:
		tape.playback_position = tape_audio_player.get_playback_position()
	tape_audio_player.stop()
	hiss_audio_player.stop()

func on_play_pressed():
	if !play_pressed:
		play_button_animation_player.play("PlayMechanism")
		play_pressed = true
		await get_tree().create_timer(0.3).timeout
		hiss_audio_player.play()
		await get_tree().create_timer(0.05).timeout
		if !tape_audio_player.playing && tape:
			tape_audio_player.stream = tape.track_1
			tape_audio_player.play(tape.playback_position)

func on_rewind_pressed():
	if !rewind_pressed:
		rewind_button_animation_player.play("RewindButton")
		rewind_pressed = true
		await get_tree().create_timer(0.3).timeout
		hiss_audio_player.play()

func on_fast_forward_pressed():
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
		body.reparent(tape_point)
		body.in_player = true
		body.position = Vector3()
		body.rotation = Vector3()
