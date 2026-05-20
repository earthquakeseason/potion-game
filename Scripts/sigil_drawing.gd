extends Sprite2D

const NUM_POINTS = 64
const FLAME_POINT_CLOUD: Array[Vector2i] = [Vector2i(165.0, 48.0), Vector2i(134.0, 67.0), Vector2i(134.0, 203.0),
Vector2i(133.0, 104.0), Vector2i(84.0, 192.0), Vector2i(95.0, 132.0)]
var image: Image
var canvas_texture: ImageTexture
var points: Array[Vector2]

func _ready() -> void:
	GameEvents.submit_pressed.connect(_on_submit_pressed)
	image = Image.create_empty(250, 250, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	canvas_texture = ImageTexture.create_from_image(image)
	texture = canvas_texture
	position = get_viewport().get_visible_rect().size / 2

func paint_texture(pos: Vector2i, paint_color: Color) -> void:
	image.fill_rect(Rect2i(pos, Vector2i(1,1)).grow(3), paint_color)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("right_click"):
		var pos = to_local(event.position)
		var impos = pos + get_rect().size / 2.0
		if Input.is_action_just_pressed("left_click"):
			paint_texture(impos, Color.BLACK)
		else:
			paint_texture(impos, Color.WHITE)
		points.append(impos)
		canvas_texture.update(image)
	elif event is InputEventMouseMotion:
		if Input.is_action_pressed("left_click") or Input.is_action_pressed("right_click"):
			var chosen_color: Color
			var pos: Vector2 = to_local(event.position)
			var impos: Vector2 = pos + get_rect().size / 2.0
			if Input.is_action_pressed("left_click"):
				chosen_color = Color.BLACK
			else:
				chosen_color = Color.WHITE
			paint_texture(impos, chosen_color)
			canvas_texture.update(image)
			if event.relative.length_squared() > 0:
				var num = ceili(event.relative.length())
				var target_pos = impos - (event.relative)
				for i in num:
					impos = impos.move_toward(target_pos, 1)
					paint_texture(impos, chosen_color)
					points.append(impos)

func _on_submit_pressed() -> void:
	point_resample()
	pass

func point_resample() -> void:
	# points too small
	if points.size() < 2: return
	var curve: Curve2D = Curve2D.new()
	for point in points:
		curve.add_point(point)
	var total_curve_length: float = curve.get_baked_length()
	var gap_size: float = total_curve_length / NUM_POINTS - 1
	var temp_points: Array[Vector2] = []
	var bounding_points = {"top_right": Vector2(0, 500), "bottom_left": Vector2(500, 0)}
	for i in NUM_POINTS:
		var new_point: Vector2 = curve.sample_baked(i * gap_size)
		if new_point.x < bounding_points.bottom_left.x:
			bounding_points.bottom_left.x = new_point.x
		if new_point.y > bounding_points.bottom_left.y:
			bounding_points.bottom_left.y = new_point.y
		if new_point.x > bounding_points.top_right.x:
			bounding_points.top_right.x = new_point.x
		if new_point.y < bounding_points.top_right.y:
			bounding_points.top_right.y = new_point.y
		temp_points.append(new_point)
		paint_texture(new_point, Color.RED)

	# scaling
	var size = max(bounding_points.top_right.x - bounding_points.bottom_left.x, bounding_points.top_right.y - bounding_points.bottom_left.y);
	var scaled_points: Array[Vector2];
	for i in temp_points.size():
		var qx = (temp_points[i].x - bounding_points.bottom_left.x) / size;
		var qy = (temp_points[i].y - bounding_points.bottom_left.y) / size;
		scaled_points.append(Vector2(qx, qy))
		
	# cloud distance
	
	for i in scaled_points.size():
		
	points = temp_points
	paint_texture(bounding_points.top_right, Color.ORANGE)
	paint_texture(bounding_points.bottom_left, Color.GREEN)
	canvas_texture.update(image)

func distance_with_angle(p1: Vector2, p2: Vector2):
	var dx = p2.x - p1.y;
	var dy = p2.y - p1.y;
	var da = p2.angle() - p1.angle();
	return sqrt(dx * dx + dy * dy + da * da);

func cloud_distance(p1: Vector2, p2: Vector2):
	var matched: Array[bool]
	matched.resize(NUM_POINTS)
	matched.fill(false)
	var sum = 0
	for i in scaled_points.size():
		var index = -1
		var min = +INF
		for j in scaled_points.size():
			# almost certainly wrong
			var d = distance_with_angle(scaled_points[i], scaled_points[j]);
			if (d < min):
				min = d
				index = j
		matched[index] = true
		sum += min
	
	for j in matched.size():
		if !matched[j]:
			var min = +INF;
			for i in scaled_points.size():
				var d = distance_with_angle(scaled_points[i], scaled_points[j]);
				if (d < min):
					min = d
			sum += min;
