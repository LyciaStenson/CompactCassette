extends Camera3D

var grabbed : Node3D
var try_grab : bool = false

var dragging : bool = false
var rotating : bool = false

#var previous_mouse_pos : Vector2

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		event.button_index = MOUSE_BUTTON_LEFT
		if event.is_released() && grabbed:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				Input.warp_mouse(unproject_position(grabbed.global_position))
			grabbed = null
	if event.is_action("Drag") or event.is_action("Rotate"):
		if event.is_pressed():
			try_grab = true
		else:
			grabbed = null
	if grabbed:
		if event is InputEventMouseMotion:
			grabbed.drag(event.relative)
		if event.is_action_pressed("ZoomIn") and grabbed:
			grabbed.zoom_in()
		elif event.is_action_pressed("ZoomOut") and grabbed:
			grabbed.zoom_out()

func zoom_in():
	if grabbed:
		grabbed.zoom()

func zoom_out():
	if grabbed:
		grabbed.zoom()

func _physics_process(delta : float) -> void:
	if try_grab:
		var space_state = get_world_3d().direct_space_state
		
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = project_ray_origin(mouse_pos)
		var end = origin + project_ray_normal(mouse_pos) * 1000.0
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var collider : Node = result.collider
			if collider.is_in_group("Grabbable"):
				#previous_mouse_pos = get_viewport().get_mouse_position()
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				grabbed = collider
			elif collider is CassettePlayerButton:
				collider.press()
		else:
			grabbed = null
		try_grab = false
