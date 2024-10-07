extends Node3D

var segment = preload("res://segment.tscn")
var seg
var segments
var length

func web():
	segments =  $"../Spider/Aim".position.distance_to($"../WebPos".position)/0.1
	length = ($"../WebPos".position -$"../Spider/Aim".position)/segments

	seg = segment.instantiate()
	add_child(seg)
	get_child(-1).name = "0"
	get_child(-1).position = $"../WebPos/Pos".position
	get_child(-1).get_child(2).set_node_b(NodePath("../../../WebPos/Pos"))
	for i in range(segments-1):
		seg = segment.instantiate()
		add_child(seg)
		get_child(-1).name = str(i+1)
		get_child(-1).position = $"../WebPos/Pos".position + length*(i+1)
		get_child(-1).get_child(2).set_node_b(get_child(-2).get_path())
		print(i)
		if i == 1:
			print("set")
			var joint = JoltPinJoint3D.new()
			get_child(-1).add_child(joint)
			get_child(-1).get_child(3).set_node_a(NodePath("../"))
			get_child(-1).get_child(3).set_node_b(NodePath("../../../Spider/Aim/Aim"))
func _ready() -> void:
	web()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass
		
