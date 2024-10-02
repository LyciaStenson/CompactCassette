extends Camera3D

var grabbed : Grabbable
var try_grab : bool = false

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			try_grab = true
		elif event.is_released():
			grabbed = null
	if event is InputEventMouseMotion and grabbed:
		grabbed.grabbed(event.relative)

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
			if collider is Grabbable:
				grabbed = collider
		else:
			grabbed = null
		try_grab = false
