extends Sprite2D

const NUM_POINTS: int = 32
const CANVAS_SIZE: int = 250
const RECOGNIZER_SIZE: float = 250.0
const STROKE_RADIUS: int = 5
const DRAWING_RADIUS: int = 3
const FAIL_SYMBOL: PackedScene = preload("uid://dawarawgixbne")
const NOTE_ALT: CompressedTexture2D = preload("uid://b56qkovby3ft8")
const STAR_PATH = preload("res://assets/symbols/star_path.png")
const DRAWING_COLOR: Color = Color.WHITE
const STROKE_COLOR: Color = Color("88009e")

var background_image: Image
var canvas_texture: ImageTexture
var gesture_points: Array[Vector2]
var normalised_template: Array[Vector2]
var normalised_template_reverse: Array[Vector2]
var chosen_sigil: Sigil
var point_index: int
var path_star_postions: Array[Vector2]
var stroke_brush: Image
var drawing_brush: Image

@onready var path_stars: Node2D = $"../PathStars"

signal drawn_on

func _ready() -> void:
	set_blank_canvas()
	position = get_viewport().get_visible_rect().size / 2
	chosen_sigil = GameInfo.get_current_minigame()
	normalised_template = normalize_points(chosen_sigil.point_cloud)
	# so it isnt direction specific
	var reversed: Array[Vector2] = chosen_sigil.point_cloud.duplicate()
	reversed.reverse()
	normalised_template_reverse = normalize_points(reversed)
	stroke_brush = create_circle_brush(STROKE_RADIUS, STROKE_COLOR)
	drawing_brush = create_circle_brush(DRAWING_RADIUS, DRAWING_COLOR)

# should hopefully make drawing the circle less laggy... (todo: check this later)
func create_circle_brush(radius: int, color: Color) -> Image:
	var diameter: int = radius * 2
	var brush_image: Image = Image.create_empty(diameter, diameter, false, Image.FORMAT_RGBA8)

	for y: int in range(diameter):
		for x: int in range(diameter):
			var distance_from_center : Vector2 = Vector2i(x, y) - Vector2i(radius, radius)
			if distance_from_center.x * distance_from_center.x + distance_from_center.y * distance_from_center.y <= (radius * radius):
				brush_image.set_pixel(x, y, color)
	return brush_image

func paint_texture(pos: Vector2i) -> void:
	draw_image_brush(stroke_brush, pos, STROKE_RADIUS)
	#draw_image_brush(drawing_brush, pos, DRAWING_RADIUS)

func draw_image_brush(brush: Image, pos: Vector2i, radius: int) -> void:
	background_image.blit_rect_mask(brush, brush, Rect2i(Vector2i.ZERO, brush.get_size()), pos - Vector2i(radius, radius))

func normalize_for_display(points: Array[Vector2]) -> Array[Vector2]:
	return translate_to_origin(scale_to(resample(points), RECOGNIZER_SIZE))

func _input(event: InputEvent) -> void:
	if GameInfo.game_paused:
		return

	if Input.is_action_just_pressed("left_click"):
		var local_pos = to_local(event.position)
		if !get_rect().has_point(local_pos): return
		drawn_on.emit()
		set_blank_canvas()
		var pos = to_local(event.position)
		var impos = pos + get_rect().size / 2.0
		paint_texture(impos)
		gesture_points.append(impos)
		canvas_texture.update(background_image)
	elif event is InputEventMouseMotion:
		if Input.is_action_pressed("left_click"):
			var pos: Vector2 = to_local(event.position)
			var impos: Vector2 = pos + get_rect().size / 2.0
			paint_texture(impos)
			canvas_texture.update(background_image)
			if event.relative.length_squared() > 0:
				var num: int = ceili(event.relative.length())
				var target_pos: Vector2 = impos - (event.relative)
				for i: int in num:
					impos = impos.move_toward(target_pos, 1)
					paint_texture(impos)
					gesture_points.append(impos)
			#for point in range(path_star_postions):
				#if get_global_mouse_position().distance_to(path_star_postions[point]) < 1.0:
					#path_stars.get_child(point)

func _on_submit_button_pressed() -> void:
	if recognizable():
		GameEvents.emit_minigame_complete_attempt(true)
		GameInfo.drawing_accuracy += 1
	else:
		GameEvents.emit_minigame_complete_attempt(false)
		var fail_symbol: TextureRect = FAIL_SYMBOL.instantiate()
		add_child(fail_symbol)
		fail_symbol.position = position - Vector2(690, 460)
		set_blank_canvas()
		GameInfo.drawing_accuracy -= 1

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
	if points.size() < 2:
		push_error("not enough points...")
		return points.duplicate()
	var curve: Curve2D = Curve2D.new()
	for i in range(points.size()):
		if i > 0:
			if not points[i - 1].is_equal_approx(points[i]):
				curve.add_point(points[i])
		else:
			curve.add_point(points[i])
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
	for i in range(smallest_size):
		total += drawing[i].distance_to(template[i])
	return total / smallest_size

func centroid(points: Array[Vector2]) -> Vector2:
	# https://stackoverflow.com/questions/12840839/find-the-center-point-of-coordinate-2d-array-c-sharp
	var sum: Vector2 = Vector2.ZERO
	for point in points:
		sum += point
	return sum / points.size()

func set_blank_canvas() -> void:
	gesture_points.clear()
	background_image = NOTE_ALT.get_image()
	canvas_texture = ImageTexture.create_from_image(background_image)
	texture = canvas_texture
