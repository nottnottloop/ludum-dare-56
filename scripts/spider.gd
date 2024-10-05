extends CharacterBody3D


const SPEED = 20.0
const JUMP_VELOCITY = 4.5
var control_camera = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir:
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process(delta: float) -> void:
	if control_camera:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("control_camera"):
			control_camera = true
			print("X: %s Y: %s" % [fmod($Camera.rotation_degrees.x, 360.0), fmod($Camera.rotation_degrees.y, 360.0)])
		if event.is_action_released("control_camera"):
			control_camera = false
	if event is InputEventMouseMotion and control_camera:
		$Camera.rotation = Vector3($Camera.rotation.x + (event.get_relative().y * -0.002), $Camera.rotation.y + (event.get_relative().x * -0.002), 0)
