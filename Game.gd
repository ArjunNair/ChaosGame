extends Control

onready var num_vertices_label = get_node("Panel/VBoxContainer/VBoxContainer/HBoxContainer/NumVertices")
onready var lerp_factor_label = get_node("Panel/VBoxContainer/VBoxContainer2/HBoxContainer/LerpFactor")
onready var point_size_label = get_node("Panel/VBoxContainer/VBoxContainer3/HBoxContainer/PointSize")
onready var orientation_label = get_node("Panel/VBoxContainer/VBoxContainer4/HBoxContainer/OrientationAngle")
onready var points_label = get_node("HBoxContainer/PointsLabel")

var dont_repeat_vertex = false
var previous_vertex = -1
var generate = false
var generating = false
var vertices = []
var points = []
var num_vertices = 3
var lerp_factor = 0.5
var point_size = 1
var orientation_angle = 0
var colored_points = true
var canvas_width = 1024
var canvas_height = 600
var current_point: Vector2 = Vector2.ZERO
var MAX_POINTS = 50000
var POINT_COLORS = [Color.antiquewhite, Color.aqua, Color.chartreuse, Color.crimson, Color.coral, Color.blue, Color.cornflower, Color.darkgreen, Color.darkslateblue, Color.fuchsia]

# Called when the node enters the scene tree for the first time.
func _ready():
	current_point = Vector2(randi() % canvas_width, randi() % canvas_height)
	reset()

func reset():
	generating = false
	randomize()
	vertices = []
	points = []
	point_size_label.text = str(0)
	num_vertices_label.text = str(num_vertices)
	lerp_factor_label.text = str(lerp_factor * 100) + "%"
	point_size_label.text = str(point_size)
	orientation_label.text = str(orientation_angle)
	var origin = Vector2(1024/2 + 70, 600/2 + 5)
	var radius = 300
	var increments = 360/num_vertices
	var angle = orientation_angle
	for i in range(num_vertices):
		var x = int(origin.x + radius * cos(deg2rad(angle)))
		var y = int(origin.y + radius * sin(deg2rad(angle)))
		vertices.append(Vector2(x, y))
		angle += increments

	update()
	
func _draw():
	if not generating:
		for i in range(vertices.size()):
			draw_circle(vertices[i], point_size, POINT_COLORS[i])
	
	for e in points:
		var point = e[0]
		var c= e[1]
		var color = POINT_COLORS[c] if colored_points else Color.white
		color.a = 0.50
		draw_circle(point, point_size, color)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not generate:
		return
	
	generating = true
	randomize()
	for i in range(1000):
		var r = randi() % vertices.size()
		if dont_repeat_vertex:
			while previous_vertex == r:
				r = randi() % vertices.size()
				
		var v = vertices[r]
		current_point = current_point.linear_interpolate(v, lerp_factor)
		points.append([current_point, r])
		previous_vertex = r
		points_label.text = str(points.size())
	update()
	
	if points.size() >= MAX_POINTS:
		_on_GenerateButton_pressed()

	
func _on_GenerateButton_pressed():
	generate = !generate
	if generate:
		$Panel/GenerateButton.text = "Stop"
		reset()
		generating = true
	else:
		$Panel/GenerateButton.text = "Generate"

func _on_VertexSlider_value_changed(value):
	num_vertices = int(value)
	num_vertices_label.text = str(num_vertices)
	reset()

func _on_LerpSlider_value_changed(value):
	lerp_factor = value/100.0
	lerp_factor_label.text = str(lerp_factor * 100) + "%"

func _on_RepeatVertexCheckbox_toggled(button_pressed):
	dont_repeat_vertex = button_pressed

func _on_PointSizeSlider_value_changed(value):
	point_size = value
	point_size_label.text = str(point_size)

func _on_OrientationSlider_value_changed(value):
	orientation_angle = value
	orientation_label.text = str(orientation_angle)
	reset()
	
func _on_ColorVertexCheckbox_toggled(button_pressed):
	colored_points = button_pressed
