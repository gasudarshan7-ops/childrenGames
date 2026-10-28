extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control

# Modes: "colors", "shapes", "match", "drawing"
var current_mode: String = "colors"

var colors_data = [
	{"name": "Red", "kn_name": "ಕೆಂಪು", "color": Color(0.95, 0.25, 0.25)},
	{"name": "Blue", "kn_name": "ನೀಲಿ", "color": Color(0.2, 0.55, 0.95)},
	{"name": "Green", "kn_name": "ಹಸಿರು", "color": Color(0.25, 0.78, 0.35)},
	{"name": "Yellow", "kn_name": "ಹಳದಿ", "color": Color(0.98, 0.85, 0.15)},
	{"name": "Orange", "kn_name": "ಕಿತ್ತಳೆ", "color": Color(0.98, 0.55, 0.15)},
	{"name": "Purple", "kn_name": "ನೇರಳೆ", "color": Color(0.65, 0.35, 0.85)},
	{"name": "Pink", "kn_name": "ಗುಲಾಬಿ", "color": Color(0.98, 0.45, 0.65)},
	{"name": "Brown", "kn_name": "ಕಂದು", "color": Color(0.55, 0.35, 0.2)}
]

var shapes_data = [
	{"name": "Circle", "kn_name": "ವೃತ್ತ", "icon": "⭕"},
	{"name": "Square", "kn_name": "ಚೌಕ", "icon": "⏹️"},
	{"name": "Triangle", "kn_name": "ತ್ರಿಕೋನ", "icon": "🔺"},
	{"name": "Star", "kn_name": "ನಕ್ಷತ್ರ", "icon": "⭐"},
	{"name": "Heart", "kn_name": "ಹೃದಯ", "icon": "❤️"},
	{"name": "Diamond", "kn_name": "ವಜ್ರ", "icon": "💠"}
]

# Quiz state
var quiz_target_idx: int = 0
var quiz_question_lbl: Label
var quiz_options_grid: GridContainer

# Drawing state
var draw_lines: Array = [] # Array of {points: PackedVector2Array, color: Color, width: float}
var current_brush_color: Color = Color(0.95, 0.25, 0.25)
var current_stroke: PackedVector2Array = PackedVector2Array()
var is_drawing: bool = false
var draw_canvas: Control

func _ready() -> void:
	_build_ui()
	_set_mode("colors")

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.98, 0.96, 0.94)
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 24
	vbox.offset_right = -24
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 18)
	add_child(vbox)
	
	header = HeaderBarScript.new()
	header.title_key = "mod_colors_shapes"
	vbox.add_child(header)
	
	# Mode Selection Pills
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 12)
	vbox.add_child(mode_bar)
	
	_add_mode_btn(mode_bar, "colors", "🎨 Colors", Color(0.95, 0.45, 0.2))
	_add_mode_btn(mode_bar, "shapes", "🔷 Shapes", Color(0.2, 0.7, 0.5))
	_add_mode_btn(mode_bar, "match", "❓ Shape Quiz", Color(0.3, 0.6, 0.95))
	_add_mode_btn(mode_bar, "drawing", "🖌️ Coloring Canvas", Color(0.7, 0.35, 0.85))
	
	# Content Viewport Panel
	var content_panel = PanelContainer.new()
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var st = StyleBoxFlat.new()
	st.bg_color = Color.WHITE
	st.set_corner_radius_all(32)
	st.shadow_color = Color(0, 0, 0, 0.08)
	st.shadow_size = 10
	st.content_margin_left = 20
	st.content_margin_right = 20
	st.content_margin_top = 20
	st.content_margin_bottom = 20
	content_panel.add_theme_stylebox_override("panel", st)
	vbox.add_child(content_panel)
	
	# 1. Colors Grid View
	var col_scroll = ScrollContainer.new()
	col_scroll.name = "ColorsView"
	col_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.add_child(col_scroll)
	
	var col_grid = GridContainer.new()
	col_grid.columns = 2
	col_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_grid.add_theme_constant_override("h_separation", 20)
	col_grid.add_theme_constant_override("v_separation", 20)
	col_scroll.add_child(col_grid)
	_populate_colors_grid(col_grid)
	
	# 2. Shapes Grid View
	var shape_scroll = ScrollContainer.new()
	shape_scroll.name = "ShapesView"
	shape_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.add_child(shape_scroll)
	
	var shape_grid = GridContainer.new()
	shape_grid.columns = 2
	shape_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shape_grid.add_theme_constant_override("h_separation", 20)
	shape_grid.add_theme_constant_override("v_separation", 20)
	shape_scroll.add_child(shape_grid)
	_populate_shapes_grid(shape_grid)
	
	# 3. Match / Quiz View
	var quiz_vbox = VBoxContainer.new()
	quiz_vbox.name = "QuizView"
	quiz_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	quiz_vbox.add_theme_constant_override("separation", 28)
	content_panel.add_child(quiz_vbox)
	
	quiz_question_lbl = Label.new()
	quiz_question_lbl.text = "Find the Circle!"
	quiz_question_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quiz_question_lbl.add_theme_font_size_override("font_size", 42)
	quiz_question_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	quiz_vbox.add_child(quiz_question_lbl)
	
	quiz_options_grid = GridContainer.new()
	quiz_options_grid.columns = 2
	quiz_options_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quiz_options_grid.add_theme_constant_override("h_separation", 24)
	quiz_options_grid.add_theme_constant_override("v_separation", 24)
	quiz_vbox.add_child(quiz_options_grid)
	
	# 4. Drawing Canvas View
	var draw_vbox = VBoxContainer.new()
	draw_vbox.name = "DrawingView"
	draw_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.add_child(draw_vbox)
	
	# Palette row
	var pal_row = HBoxContainer.new()
	pal_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pal_row.add_theme_constant_override("separation", 14)
	draw_vbox.add_child(pal_row)
	
	for cd in colors_data:
		var dot = Button.new()
		dot.custom_minimum_size = Vector2(65, 65)
		var dst = StyleBoxFlat.new()
		dst.bg_color = cd["color"]
		dst.set_corner_radius_all(32)
		dot.add_theme_stylebox_override("normal", dst)
		dot.pressed.connect(func():
			SoundManager.play_pop()
			current_brush_color = cd["color"]
		)
		pal_row.add_child(dot)
		
	var clear_btn = Button.new()
	clear_btn.text = "🧹"
	clear_btn.custom_minimum_size = Vector2(70, 65)
	var clr_st = StyleBoxFlat.new()
	clr_st.bg_color = Color(1.0, 0.4, 0.4)
	clr_st.set_corner_radius_all(20)
	clear_btn.add_theme_stylebox_override("normal", clr_st)
	clear_btn.add_theme_font_size_override("font_size", 28)
	clear_btn.pressed.connect(func():
		SoundManager.play_pop()
		draw_lines.clear()
		draw_canvas.queue_redraw()
	)
	pal_row.add_child(clear_btn)
	
	# Drawing Canvas area
	draw_canvas = Control.new()
	draw_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	draw_canvas.draw.connect(_on_draw_canvas)
	draw_canvas.gui_input.connect(_on_draw_input)
	draw_vbox.add_child(draw_canvas)
	
	# Celebration
	celebration = CelebrationModalScript.new()
	add_child(celebration)
	celebration.next_pressed.connect(_setup_quiz_question)
	celebration.replay_pressed.connect(_setup_quiz_question)

func _add_mode_btn(parent: Control, mode_id: String, text: String, color: Color) -> void:
	var btn = Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 65)
	var st = StyleBoxFlat.new()
	st.bg_color = color
	st.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_font_size_override("font_size", 20)
	btn.pressed.connect(func():
		SoundManager.play_pop()
		_set_mode(mode_id)
	)
	parent.add_child(btn)

func _set_mode(mode_id: String) -> void:
	current_mode = mode_id
	var cv = find_child("ColorsView", true, false)
	var sv = find_child("ShapesView", true, false)
	var qv = find_child("QuizView", true, false)
	var dv = find_child("DrawingView", true, false)
	
	cv.visible = (mode_id == "colors")
	sv.visible = (mode_id == "shapes")
	qv.visible = (mode_id == "match")
	dv.visible = (mode_id == "drawing")
	
	if mode_id == "match":
		_setup_quiz_question()

func _populate_colors_grid(grid: GridContainer) -> void:
	for cd in colors_data:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 180)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var st = StyleBoxFlat.new()
		st.bg_color = cd["color"]
		st.set_corner_radius_all(30)
		btn.add_theme_stylebox_override("normal", st)
		
		var name_str = cd["kn_name"] if LocalizationManager.current_language == "kn" else cd["name"]
		btn.text = name_str
		btn.add_theme_font_size_override("font_size", 38)
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.4))
		btn.add_theme_constant_override("outline_size", 8)
		
		btn.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(cd["name"])
		)
		grid.add_child(btn)

func _populate_shapes_grid(grid: GridContainer) -> void:
	for sd in shapes_data:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 180)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.93, 0.95, 0.99)
		st.set_corner_radius_all(30)
		st.border_width_left = 4
		st.border_width_top = 4
		st.border_width_right = 4
		st.border_width_bottom = 4
		st.border_color = Color(0.75, 0.85, 0.98)
		btn.add_theme_stylebox_override("normal", st)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		btn.add_child(vbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = sd["icon"]
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 72)
		vbox.add_child(icon_lbl)
		
		var name_lbl = Label.new()
		var n_text = sd["kn_name"] if LocalizationManager.current_language == "kn" else sd["name"]
		name_lbl.text = n_text
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 30)
		name_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		vbox.add_child(name_lbl)
		
		btn.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(sd["name"])
		)
		grid.add_child(btn)

func _setup_quiz_question() -> void:
	quiz_target_idx = randi() % shapes_data.size()
	var target = shapes_data[quiz_target_idx]
	
	var q_text = "ಯಾವ ಆಕಾರವು " + target["kn_name"] + "?" if LocalizationManager.current_language == "kn" else "Find the " + target["name"] + "!"
	quiz_question_lbl.text = q_text
	SoundManager.speak_text("Find the " + target["name"])
	
	for c in quiz_options_grid.get_children():
		c.queue_free()
		
	var choices = [target]
	while choices.size() < 4:
		var r = shapes_data.pick_random()
		if not r in choices:
			choices.append(r)
	choices.shuffle()
	
	for sd in choices:
		var btn = Button.new()
		btn.text = sd["icon"]
		btn.custom_minimum_size = Vector2(0, 160)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.92, 0.96, 1.0)
		st.set_corner_radius_all(30)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_font_size_override("font_size", 80)
		btn.pressed.connect(func():
			if sd["name"] == target["name"]:
				SoundManager.play_correct()
				GameManager.record_activity("colors_shapes")
				celebration.show_celebration("Super! That is the " + target["name"] + "! ⭐")
			else:
				SoundManager.play_wrong()
		)
		quiz_options_grid.add_child(btn)

# --- Canvas Drawing ---
func _on_draw_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			is_drawing = true
			current_stroke = PackedVector2Array()
			current_stroke.append(event.position)
		else:
			is_drawing = false
			if current_stroke.size() > 1:
				draw_lines.append({"points": current_stroke.duplicate(), "color": current_brush_color, "width": 14.0})
				draw_canvas.queue_redraw()
	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if is_drawing:
			current_stroke.append(event.position)
			draw_canvas.queue_redraw()

func _on_draw_canvas() -> void:
	var rect = draw_canvas.get_rect()
	draw_canvas.draw_rect(Rect2(Vector2.ZERO, rect.size), Color(0.98, 0.98, 0.98), true)
	
	for line in draw_lines:
		var pts: PackedVector2Array = line["points"]
		if pts.size() > 1:
			for i in range(1, pts.size()):
				draw_canvas.draw_line(pts[i - 1], pts[i], line["color"], line["width"], true)
				
	if is_drawing and current_stroke.size() > 1:
		for i in range(1, current_stroke.size()):
			draw_canvas.draw_line(current_stroke[i - 1], current_stroke[i], current_brush_color, 14.0, true)
