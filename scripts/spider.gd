extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
var sensitivity = 0.4
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const outline = preload("res://Outline.material")
var lastobj
var xform
var point
var distance
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Skeleton3D/Tail.start()

func _input(event):
	if event is InputEventMouseMotion:
		$SpringArm3D.rotate_x(deg_to_rad(0-event.relative.y * sensitivity))
		rotate_object_local(Vector3.UP,deg_to_rad(0-event.relative.x * sensitivity))
		$SpringArm3D.rotation.z = 0
func _physics_process(delta):


	
	if Input.is_action_just_pressed("Esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_mouse_button_pressed( 1 ):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$"../point".hide()
	if Input.is_action_pressed("Aim") and !point:
		$Skeleton3D/Tail.influence = lerp($Skeleton3D/Tail.influence,1.0,0.1)
		$SpringArm3D/Camera.fov = lerp($SpringArm3D/Camera.fov,50.0,0.2 )
		$SpringArm3D.position.y = lerp($SpringArm3D.position.y,2.0,0.1)
		$Aim.rotation.y = deg_to_rad(clamp($SpringArm3D.rotation_degrees.y,-90,90))
		$Aim.rotation.x = deg_to_rad(clamp($SpringArm3D.rotation_degrees.x,-90,90))

		if Input.is_action_pressed("Shoot"):
			if $SpringArm3D/Camera/RayCast3D.is_colliding() and $SpringArm3D/Camera/RayCast3D.get_collider().is_in_group("obj"):
				$SpringArm3D/Camera/RayCast3D.get_collider().apply_central_force($SpringArm3D/Camera/RayCast3D.get_collider().position.direction_to(global_position)*100)
				if !Globals.connected_nodes.has($SpringArm3D/Camera/RayCast3D.get_collider()):
					Globals.connected_nodes.append($SpringArm3D/Camera/RayCast3D.get_collider())
					Globals.distances.append(position.distance_to($SpringArm3D/Camera/RayCast3D.get_collider().position))
			else:
				$"../point".show()
				$"../point".global_position = $SpringArm3D/Camera/RayCast3D.get_collision_point()
				point = $SpringArm3D/Camera/RayCast3D.get_collision_point()
				distance = $SpringArm3D/Camera/RayCast3D.get_collision_point().distance_to(position)
		if $SpringArm3D/Camera/RayCast3D.is_colliding() and $SpringArm3D/Camera/RayCast3D.get_collider().is_in_group("obj"):
			lastobj = $SpringArm3D/Camera/RayCast3D.get_collider().get_child(0)
			var mat = Material.new()
			mat = $SpringArm3D/Camera/RayCast3D.get_collider().get_child(0).get_surface_override_material(0)
			mat.set_next_pass(outline)
			$SpringArm3D/Camera/RayCast3D.get_collider().get_child(0).set_surface_override_material(0, mat)
		elif lastobj:
			lastobj.get_surface_override_material(0).set_next_pass(null)
			lastobj = null
		else:
			$"../point".show()
			$"../point".global_position = $SpringArm3D/Camera/RayCast3D.get_collision_point()
			$"../test".global_position = $"../point".global_position+$SpringArm3D/Camera/RayCast3D.get_collision_normal()*4
	
			$"../point".look_at($"../test".global_position+Vector3(0.01,0,0) ,Vector3.UP)
	else:
		point = null
		if lastobj:
			lastobj.get_surface_override_material(0).set_next_pass(null)
		$SpringArm3D/Camera.fov = lerp($SpringArm3D/Camera.fov,75.0,0.2 )
		$Skeleton3D/Tail.influence = lerp($Skeleton3D/Tail.influence,0.0,0.1)
		$SpringArm3D.position.y = lerp($SpringArm3D.position.y,1.456,0.1)
	if !is_on_floor() and !point:
		velocity.y -= 1
	
	

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("Forward"):
		if is_on_floor():
			$Skeleton3D/AnimationPlayer.speed_scale = 4
		else:
			$Skeleton3D/AnimationPlayer.speed_scale = 0
		translate_object_local(Vector3.FORWARD*0.5)
	elif Input.is_action_pressed("Back"):
		if is_on_floor():
			$Skeleton3D/AnimationPlayer.speed_scale = -4
		else:
			$Skeleton3D/AnimationPlayer.speed_scale = 0
		translate_object_local(Vector3.BACK*0.5)
	else:
		$Skeleton3D/AnimationPlayer.speed_scale = 0
		velocity.x = lerp(velocity.x,0.0,0.1)
		velocity.z = lerp(velocity.z,0.0,0.1)
		velocity.y = lerp(velocity.y,0.0,0.1)
	$"../Web/Path3D".curve.clear_points()
	if distance:
		distance = lerp(distance, 0.0 , 0.4)
	if point:
		if point.distance_to( position) > distance:
			velocity += (point-position).normalized()*20
		$"../Web/Path3D".curve.clear_points()
		$"../Web/Path3D".curve.add_point($Aim.global_position)
		$"../Web/Path3D".curve.add_point(point)
		if !is_on_floor():
			$Skeleton3D.global_rotation.z = global_position.direction_to(point).z
			#$Skeleton3D.global_rotation.y = global_position.direction_to(point).y
#			rotation.x = lerpf(rotation.x, rotation.direction_to(point).x ,1)
		if point.distance_to( position) < 1:
			print("reset")
			point = null
		
	elif is_on_floor():
		$Skeleton3D.rotation.z = lerp($Skeleton3D.rotation.z, deg_to_rad(90.0) ,0.5)
		#$Skeleton3D.global_rotation.y = lerp($Skeleton3D.global_rotation.y, -90.0 ,1)
	move_and_slide()
