extends StaticBody3D
class_name CassettePlayer

var rotation_speed : Vector2

@onready var stop_button : CassettePlayerButton = $StopButton
@onready var play_button : CassettePlayerButton = $PlayButton
@onready var rewind_button : CassettePlayerButton = $RewindButton
@onready var fast_forward_button : CassettePlayerButton = $FastFowardButton

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
	print("Stop Button Pressed")

func play_button_pressed():
	print("Play Button Pressed")

func rewind_button_pressed():
	print("Rewind Button Pressed")

func fast_forward_button_pressed():
	print("Fast Forward Button Pressed")
