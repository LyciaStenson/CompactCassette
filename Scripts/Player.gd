extends Camera3D

var grabbed : Node3D
var try_grab : bool = false

var dragging : bool = false
var rotating : bool = false

@export var draggables_blocker : Node3D

@export var cassette_player : CassettePlayer

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if grabbed && event.button_index == MOUSE_BUTTON_LEFT && event.is_released():
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				Input.warp_mouse(unproject_position(grabbed.global_position))
			grabbed.drop()
			grabbed = null
	if event.is_action("Drag"):
		if event.is_pressed():
			try_grab = true
		else:
			grabbed = null
	if grabbed:
		if event is InputEventMouseMotion:
			grabbed.drag(event.relative)
		if grabbed && event.is_action_pressed("ZoomIn"):
			grabbed.zoom_in()
		elif grabbed && event.is_action_pressed("ZoomOut"):
			grabbed.zoom_out()

func zoom_in():
	if grabbed:
		grabbed.zoom()

func zoom_out():
	if grabbed:
		grabbed.zoom()

func _physics_process(_delta : float) -> void:
	if try_grab:
		var space_state = get_world_3d().direct_space_state
		
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = project_ray_origin(mouse_pos)
		var end = origin + project_ray_normal(mouse_pos) * 1000.0
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.exclude = [draggables_blocker]
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var collider : Node = result.collider
			if collider.is_in_group("Grabbable"):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				grabbed = collider
			elif collider is Clickable3D:
				collider.click()
		else:
			grabbed = null
		try_grab = false
