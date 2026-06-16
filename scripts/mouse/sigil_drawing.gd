extends Sprite2D

const NUM_POINTS: int = 32
const CANVAS_SIZE: int = 250
const RECOGNIZER_SIZE: float = 250.0

var image: Image
var canvas_texture: ImageTexture
var gesture_points: Array[Vector2]
var normalised_template: Array[Vector2]
var normalised_template_reverse: Array[Vector2]
var chosen_sigil: Sigil

const ESSENCE_EXTRACTION = preload("uid://e6sonp1fgd23")

func _ready() -> void:
	GameEvents.submit_pressed.connect(_on_submit_pressed)
	image = Image.create_empty(CANVAS_SIZE, CANVAS_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	canvas_texture = ImageTexture.create_from_image(image)
	texture = canvas_texture
	position = get_viewport().get_visible_rect().size / 2
	chosen_sigil = GameInfo.get_current_minigame()
	normalised_template = normalize_points(chosen_sigil.point_cloud)
	# so it isnt direction specific
	var reversed: Array[Vector2] = chosen_sigil.point_cloud.duplicate()
	reversed.reverse()
	normalised_template_reverse = normalize_points(reversed)

func paint_texture(pos: Vector2i, paint_color: Color) -> void:
	image.fill_rect(Rect2i(pos, Vector2i(1,1)).grow(3), paint_color)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		var local_pos = to_local(event.position)
		if !get_rect().has_point(local_pos): return
		image.fill(Color.WHITE)
		gesture_points.clear()
		var pos = to_local(event.position)
		var impos = pos + get_rect().size / 2.0
		paint_texture(impos, Color.BLACK)
		gesture_points.append(impos)
		canvas_texture.update(image)
	elif event is InputEventMouseMotion:
		if Input.is_action_pressed("left_click"):
			var pos: Vector2 = to_local(event.position)
			var impos: Vector2 = pos + get_rect().size / 2.0
			paint_texture(impos, Color.BLACK)
			canvas_texture.update(image)
			if event.relative.length_squared() > 0:
				var num = ceili(event.relative.length())
				var target_pos = impos - (event.relative)
				for i in num:
					impos = impos.move_toward(target_pos, 1)
					paint_texture(impos, Color.BLACK)
					gesture_points.append(impos)

func _on_submit_pressed() -> void:
	if recognizable(): GameEvents.emit_minigame_complete_attempt(true)
	else: GameEvents.emit_minigame_complete_attempt(false)

func recognizable() -> bool:
	if gesture_points.size() < 2: return false
	var normalised_drawing: Array[Vector2] = normalize_points(gesture_points)
	var distance_forward: float = calculate_path_distance(normalised_drawing, normalised_template)
	var distance_reverse: float = calculate_path_distance(normalised_drawing, normalised_template_reverse)
	var best_distance: float = min(distance_forward, distance_reverse)

	print(best_distance)
	return best_distance <= chosen_sigil.match_threshold

func normalize_points(points: Array[Vector2]) -> Array[Vector2]:
	var resampled = resample(points)
	var rotated = rotate_to_zero(resampled)
	var scaled = scale_to(rotated, RECOGNIZER_SIZE)
	var centered_points  = translate_to_origin(scaled)
	return centered_points

func resample(points: Array[Vector2]) -> Array[Vector2]:
	# points too small
	if points.size() < 2: return points.duplicate()

	var curve: Curve2D = Curve2D.new()
	for point in points:
		curve.add_point(point)
	var total_curve_length: float = curve.get_baked_length()
	if total_curve_length == 0.0:
		var temp_points: Array[Vector2]
		temp_points.resize(NUM_POINTS)
		temp_points.fill(points[0])
		return temp_points
	var result: Array[Vector2]
	result.resize(NUM_POINTS)

	for i in range(NUM_POINTS):
		var gap_size: float = (i * total_curve_length) / (NUM_POINTS - 1)
		result[i] = curve.sample_baked(gap_size) 
	return result

func rotate_to_zero(points: Array[Vector2]) -> Array[Vector2]:
	var center: Vector2 = centroid(points)
	var angle: float = atan2(points[0].y - center.y, points[0].x - center.x)
	return rotate_by(points, -angle, center)

func rotate_by(points: Array[Vector2], angle: float, center: Vector2) -> Array[Vector2]:
	var cos_angle: float = cos(angle)
	var sin_angle: float = sin(angle)
	var temp_points: Array[Vector2]
	for point in points:
		var q: Vector2 = point - center
		temp_points.append(Vector2(q.x * cos_angle - q.y * sin_angle, q.x * sin_angle + q.y * cos_angle) + center)
	return temp_points

func create_bounding_box(points: Array[Vector2]) -> Rect2:
	var min_x: float = points[0].x
	var max_x: float = points[0].x
	var min_y: float = points[0].y
	var max_y: float = points[0].y
	for point in points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	var width: float = max_x - min_x
	var height: float = max_y - min_y
	return Rect2(min_x, min_y, width, height)

func scale_to(points: Array[Vector2], size: float) -> Array[Vector2]:
	var bounding_box = create_bounding_box(points);
	var scale_factor = size / max(bounding_box.size.x, bounding_box.size.y)
	var temp_points: Array[Vector2]
	for point in points:
		temp_points.append(Vector2((point.x - bounding_box.position.x) * scale_factor, (point.y - bounding_box.position.y) * scale_factor))
	return temp_points

func translate_to_origin(points: Array[Vector2]) -> Array[Vector2]:
	var center: Vector2 = centroid(points)
	var temp_points: Array[Vector2]
	for point in points:
		temp_points.append(point - center)
	return temp_points

func calculate_path_distance(drawing: Array[Vector2], template: Array[Vector2]) -> float:
	var total: float = 0.0
	var smallest_size: int = min(drawing.size(), template.size())
	for i in smallest_size:
		total += drawing[i].distance_to(template[i])
	return total / smallest_size

func centroid(points: Array[Vector2]) -> Vector2:
	# https://stackoverflow.com/questions/12840839/find-the-center-point-of-coordinate-2d-array-c-sharp
	var sum: Vector2 = Vector2.ZERO
	for point in points:
		sum += point
	return sum / points.size()
