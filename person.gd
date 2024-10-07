extends CharacterBody3D

const place = [
	Vector3(-8.694,-0.235,56.349),
	Vector3(-72.162,-0.235,71.673),
	Vector3(-72.162,-0.235,-12.366),
	Vector3(-43.762,-0.235,-44.095),
	Vector3(51.189,-0.235,-49.95),
	
]
const person = preload("res://person.tscn")
var speed = 10

var accel = 10
func _ready():
	if name == "new":
		position = Vector3(98.395,22.288,42.272)
	$Head.global_position = $Human/Armature/Skeleton3D/SkeletonIK3D.global_position
	actor_setup.call_deferred()
	$Human/Armature/Skeleton3D/SkeletonIK3D.start()
	$NavigationAgent3D.target_position = place.pick_random()
	print(place.find($NavigationAgent3D.target_position))
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	if $NavigationAgent3D.process_mode == PROCESS_MODE_INHERIT:
		var nav = $NavigationAgent3D
		if nav.is_navigation_finished():
			return



		var direction = Vector3()
		look_at(nav.get_next_path_position()+Vector3(0.001,0,0), Vector3.UP)
		rotation.x = 0
		rotation.z = 0
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		$Human/AnimationPlayer.play("Walking")
		$Human/AnimationPlayer.speed_scale = 1
		velocity = velocity.lerp(direction * speed, accel * delta)
		move_and_slide()
		if $NavigationAgent3D.is_target_reached() or position.distance_to($NavigationAgent3D.target_position)<15:
			$NavigationAgent3D.target_position = place.pick_random()
	if $Head.global_position.distance_to($Human/Armature/Skeleton3D/SkeletonIK3D.global_position) > 10 and $Human/Armature/Skeleton3D/SkeletonIK3D.is_running():
		print($Head.position.distance_to($Human/Armature/Skeleton3D/SkeletonIK3D.global_position))
		print("fall")
		var new := person.instantiate()
		new.name = "new"
		$"..".add_child(new)

		$Human/Armature/Skeleton3D/PhysicalBoneSimulator3D.process_mode = Node.PROCESS_MODE_INHERIT
		$Human/Armature/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
		$NavigationAgent3D.process_mode = Node.PROCESS_MODE_DISABLED
		$Human/Armature/Skeleton3D/SkeletonIK3D.stop()
	elif $Head.global_position.distance_to($Human/Armature/Skeleton3D/SkeletonIK3D.global_position) > 5:
		print("fixed")
		$Head.apply_central_impulse(($Human/Armature/Skeleton3D/SkeletonIK3D.global_position-$Head.global_position).normalized())
