extends Node3D

const web = preload("res://web.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Release"):
		Globals.connected_nodes= []
		Globals.distances = []
		for i in get_children():
			remove_child(i)
	#print(len(Globals.connected_nodes))
	if Globals.connected_nodes:
		if get_child_count()<len(Globals.connected_nodes):
			var child = web.instantiate()
			add_child(child)
		
		for i in range(len(Globals.connected_nodes)):
			if $"../Spider/Aim".global_position.distance_to(Globals.connected_nodes[i].position) > Globals.distances[i] and Globals.connected_nodes[i].linear_velocity < Vector3(3,3,3):
				Globals.connected_nodes[i].apply_central_impulse(($"../Spider/Aim".global_position-Globals.connected_nodes[i].position).normalized())
			get_child(i).get_child(1).curve.clear_points()
			get_child(i).get_child(1).curve.add_point($"../Spider/Aim".global_position)
			get_child(i).get_child(1).curve.add_point(Globals.connected_nodes[i].global_position)
		
