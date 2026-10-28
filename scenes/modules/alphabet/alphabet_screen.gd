extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control
var current_mode: String = "explore" # "explore", "trace", "quiz", "missing"
var is_uppercase: bool = true

# Alphabet data (A-Z) with icons, phonics and Kannada equivalents
var alphabet_data = [
	{"letter": "A", "word": "Apple", "kn_word": "ಸೇಬು (ಆಪಲ್)", "icon": "🍎", "kn_letter": "ಅ"},
	{"letter": "B", "word": "Ball", "kn_word": "ಚಂಡು (ಬಾಲ್)", "icon": "⚽", "kn_letter": "ಬ"},
	{"letter": "C", "word": "Cat", "kn_word": "ಬೆಕ್ಕು (ಕ್ಯಾಟ್)", "icon": "🐱", "kn_letter": "ಕ"},
	{"letter": "D", "word": "Dog", "kn_word": "ನಾಯಿ (ಡಾಗ್)", "icon": "🐶", "kn_letter": "ಡ"},
	{"letter": "E", "word": "Elephant", "kn_word": "ಆನೆ (ಎಲಿಫೆಂಟ್)", "icon": "🐘", "kn_letter": "ಎ"},
	{"letter": "F", "word": "Fish", "kn_word": "ಮೀನು (ಫಿಶ್)", "icon": "🐟", "kn_letter": "ಫ"},
	{"letter": "G", "word": "Grapes", "kn_word": "ದ್ರಾಕ್ಷಿ (ಗ್ರೇಪ್ಸ್)", "icon": "🍇", "kn_letter": "ಗ"},
	{"letter": "H", "word": "Hat", "kn_word": "ಟೋಪಿ (ಹ್ಯಾಟ್)", "icon": "🎩", "kn_letter": "ಹ"},
	{"letter": "I", "word": "Ice Cream", "kn_word": "ಐಸ್ ಕ್ರೀಮ್", "icon": "🍦", "kn_letter": "ಐ"},
	{"letter": "J", "word": "Juice", "kn_word": "ಹಣ್ಣಿನ ರಸ (ಜ್ಯೂಸ್)", "icon": "🧃", "kn_letter": "ಜ"},
	{"letter": "K", "word": "Kite", "kn_word": "ಗಾಳಿಪಟ (ಕೈಟ್)", "icon": "🪁", "kn_letter": "ಕ"},
	{"letter": "L", "word": "Lion", "kn_word": "ಸಿಂಹ (ಲಯನ್)", "icon": "🦁", "kn_letter": "ಲ"},
	{"letter": "M", "word": "Monkey", "kn_word": "ಕೋತಿ (ಮಂಕಿ)", "icon": "🐵", "kn_letter": "ಮ"},
	{"letter": "N", "word": "Nest", "kn_word": "ಗೂಡು (ನೆಸ್ಟ್)", "icon": "🪺", "kn_letter": "ನ"},
	{"letter": "O", "word": "Orange", "kn_word": "ಕಿತ್ತಳೆ (ಆರೆಂಜ್)", "icon": "🍊", "kn_letter": "ಒ"},
	{"letter": "P", "word": "Pencil", "kn_word": "ಪೆನ್ಸಿಲ್", "icon": "✏️", "kn_letter": "ಪ"},
	{"letter": "Q", "word": "Queen", "kn_word": "ರಾಣಿ (ಕ್ವೀನ್)", "icon": "👑", "kn_letter": "ಕ್ವ"},
	{"letter": "R", "word": "Rainbow", "kn_word": "ಕಾಮನಬಿಲ್ಲು (ರೇನ್‌ಬೋ)", "icon": "🌈", "kn_letter": "ರ"},
	{"letter": "S", "word": "Star", "kn_word": "ನಕ್ಷತ್ರ (ಸ್ಟಾರ್)", "icon": "⭐", "kn_letter": "ಸ"},
	{"letter": "T", "word": "Train", "kn_word": "ರೈಲು (ಟ್ರೈನ್)", "icon": "🚂", "kn_letter": "ಟ"},
	{"letter": "U", "word": "Umbrella", "kn_word": "ಛತ್ರಿ (ಅಂಬ್ರೆಲ್ಲಾ)", "icon": "☂️", "kn_letter": "ಉ"},
	{"letter": "V", "word": "Violin", "kn_word": "ಪಿಟೀಲು (ವಯಲಿನ್)", "icon": "🎻", "kn_letter": "ವ"},
	{"letter": "W", "word": "Watermelon", "kn_word": "ಕಲ್ಲಂಗಡಿ (ವಾಟರ್‌ಮೆಲನ್)", "icon": "🍉", "kn_letter": "ವ"},
	{"letter": "X", "word": "Xylophone", "kn_word": "ಕ್ಸೈಲೋಫೋನ್", "icon": "🎵", "kn_letter": "ಕ್ಸ"},
	{"letter": "Y", "word": "Yacht", "kn_word": "ದೋಣಿ (ಯಾಟ್)", "icon": "⛵", "kn_letter": "ಯ"},
	{"letter": "Z", "word": "Zebra", "kn_word": "ಜೀಬ್ರಾ", "icon": "🦓", "kn_letter": "ಜ"}
]

# Mode containers
var explore_container: Control
var quiz_container: Control
var trace_container: Control
var mode_buttons: Dictionary = {}

# Quiz state
var quiz_target_idx: int = 0
var quiz_question_lbl: Label
var quiz_options_grid: GridContainer

# Tracing state
var trace_letter_lbl: Label
var trace_points: Array[Vector2] = []
var is_tracing: bool = false
var trace_canvas: Control

func _ready() -> void:
	_build_ui()
	_set_mode("explore")

func _build_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.95, 0.96, 1.0)
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 24
	vbox.offset_right = -24
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 18)
	add_child(vbox)
	
	# Header
	header = HeaderBarScript.new()
	header.title_key = "mod_alphabet"
	vbox.add_child(header)
	
	# Mode Selection Pills
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 12)
	vbox.add_child(mode_bar)
	
	_add_mode_btn(mode_bar, "explore", "🔤 Flashcards", Color(0.3, 0.65, 0.95))
	_add_mode_btn(mode_bar, "quiz", "❓ Letter Quiz", Color(0.95, 0.5, 0.2))
	_add_mode_btn(mode_bar, "trace", "✏️ Tracing", Color(0.2, 0.75, 0.45))
	
	# Toggle Upper / Lowercase
	var case_btn = Button.new()
	case_btn.text = "Aa ⇄ aA"
	case_btn.custom_minimum_size = Vector2(130, 60)
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(0.6, 0.45, 0.85)
	c_style.set_corner_radius_all(18)
	case_btn.add_theme_stylebox_override("normal", c_style)
	case_btn.add_theme_font_size_override("font_size", 22)
	case_btn.pressed.connect(func():
		SoundManager.play_pop()
		is_uppercase = !is_uppercase
		_refresh_explore_grid()
	)
	mode_bar.add_child(case_btn)
	
	# Content Viewport Area
	var content_area = PanelContainer.new()
	content_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var area_style = StyleBoxFlat.new()
	area_style.bg_color = Color.WHITE
	area_style.set_corner_radius_all(32)
	area_style.shadow_color = Color(0, 0, 0, 0.08)
	area_style.shadow_size = 10
	area_style.shadow_offset = Vector2(0, 4)
	area_style.content_margin_left = 20
	area_style.content_margin_right = 20
	area_style.content_margin_top = 20
	area_style.content_margin_bottom = 20
	content_area.add_theme_stylebox_override("panel", area_style)
	vbox.add_child(content_area)
	
	# 1. Explore Flashcards View
	explore_container = ScrollContainer.new()
	explore_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	explore_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_area.add_child(explore_container)
	
	var explore_grid = GridContainer.new()
	explore_grid.name = "ExploreGrid"
	explore_grid.columns = 3
	explore_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	explore_grid.add_theme_constant_override("h_separation", 16)
	explore_grid.add_theme_constant_override("v_separation", 16)
	explore_container.add_child(explore_grid)
	_populate_explore_grid(explore_grid)
	
	# 2. Quiz View
	quiz_container = VBoxContainer.new()
	quiz_container.alignment = BoxContainer.ALIGNMENT_CENTER
	quiz_container.add_theme_constant_override("separation", 30)
	content_area.add_child(quiz_container)
	
	quiz_question_lbl = Label.new()
	quiz_question_lbl.text = "Find the letter A!"
	quiz_question_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quiz_question_lbl.add_theme_font_size_override("font_size", 42)
	quiz_question_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	quiz_container.add_child(quiz_question_lbl)
	
	quiz_options_grid = GridContainer.new()
	quiz_options_grid.columns = 2
	quiz_options_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quiz_options_grid.add_theme_constant_override("h_separation", 24)
	quiz_options_grid.add_theme_constant_override("v_separation", 24)
	quiz_container.add_child(quiz_options_grid)
	
	# 3. Tracing View
	trace_container = VBoxContainer.new()
	trace_container.alignment = BoxContainer.ALIGNMENT_CENTER
	trace_container.add_theme_constant_override("separation", 20)
	content_area.add_child(trace_container)
	
	var trace_top = HBoxContainer.new()
	trace_top.alignment = BoxContainer.ALIGNMENT_CENTER
	trace_top.add_theme_constant_override("separation", 24)
	trace_container.add_child(trace_top)
	
	var prev_l_btn = Button.new()
	prev_l_btn.text = "◀"
	prev_l_btn.custom_minimum_size = Vector2(70, 70)
	var p_st = StyleBoxFlat.new()
	p_st.bg_color = Color(0.4, 0.65, 0.95)
	p_st.set_corner_radius_all(20)
	prev_l_btn.add_theme_stylebox_override("normal", p_st)
	prev_l_btn.add_theme_font_size_override("font_size", 30)
	prev_l_btn.pressed.connect(func():
		SoundManager.play_pop()
		quiz_target_idx = (quiz_target_idx - 1 + alphabet_data.size()) % alphabet_data.size()
		_setup_trace_letter()
	)
	trace_top.add_child(prev_l_btn)
	
	trace_letter_lbl = Label.new()
	trace_letter_lbl.text = "Letter A"
	trace_letter_lbl.add_theme_font_size_override("font_size", 40)
	trace_letter_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	trace_top.add_child(trace_letter_lbl)
	
	var next_l_btn = Button.new()
	next_l_btn.text = "▶"
	next_l_btn.custom_minimum_size = Vector2(70, 70)
	next_l_btn.add_theme_stylebox_override("normal", p_st)
	next_l_btn.add_theme_font_size_override("font_size", 30)
	next_l_btn.pressed.connect(func():
		SoundManager.play_pop()
		quiz_target_idx = (quiz_target_idx + 1) % alphabet_data.size()
		_setup_trace_letter()
	)
	trace_top.add_child(next_l_btn)
	
	# Tracing Canvas area
	trace_canvas = Control.new()
	trace_canvas.custom_minimum_size = Vector2(500, 500)
	trace_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	trace_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	trace_canvas.draw.connect(_on_trace_canvas_draw)
	trace_canvas.gui_input.connect(_on_trace_canvas_input)
	trace_container.add_child(trace_canvas)
	
	var clear_trace_btn = Button.new()
	clear_trace_btn.text = "🧹 Clear Strokes"
	clear_trace_btn.custom_minimum_size = Vector2(240, 70)
	var clr_st = StyleBoxFlat.new()
	clr_st.bg_color = Color(1.0, 0.45, 0.45)
	clr_st.set_corner_radius_all(22)
	clear_trace_btn.add_theme_stylebox_override("normal", clr_st)
	clear_trace_btn.add_theme_font_size_override("font_size", 26)
	clear_trace_btn.pressed.connect(func():
		SoundManager.play_pop()
		trace_points.clear()
		trace_canvas.queue_redraw()
	)
	trace_container.add_child(clear_trace_btn)
	
	# Celebration popup
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
	btn.add_theme_font_size_override("font_size", 22)
	btn.pressed.connect(func():
		SoundManager.play_pop()
		_set_mode(mode_id)
	)
	parent.add_child(btn)
	mode_buttons[mode_id] = btn

func _set_mode(mode_id: String) -> void:
	current_mode = mode_id
	explore_container.visible = (mode_id == "explore")
	quiz_container.visible = (mode_id == "quiz")
	trace_container.visible = (mode_id == "trace")
	
	if mode_id == "quiz":
		_setup_quiz_question()
	elif mode_id == "trace":
		_setup_trace_letter()

func _populate_explore_grid(grid: GridContainer) -> void:
	for item in alphabet_data:
		var card = Button.new()
		card.custom_minimum_size = Vector2(0, 180)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.96, 0.97, 1.0)
		st.set_corner_radius_all(24)
		st.border_width_left = 3
		st.border_width_top = 3
		st.border_width_right = 3
		st.border_width_bottom = 3
		st.border_color = Color(0.85, 0.9, 0.98)
		card.add_theme_stylebox_override("normal", st)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vbox)
		
		var char_lbl = Label.new()
		char_lbl.name = "LetterLabel"
		var disp_char = item["letter"] if is_uppercase else item["letter"].to_lower()
		char_lbl.text = disp_char
		char_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		char_lbl.add_theme_font_size_override("font_size", 54)
		char_lbl.add_theme_color_override("font_color", Color(0.15, 0.5, 0.9))
		vbox.add_child(char_lbl)
		
		var icon_lbl = Label.new()
		icon_lbl.text = item["icon"]
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 42)
		vbox.add_child(icon_lbl)
		
		var word_lbl = Label.new()
		var word_text = item["kn_word"] if LocalizationManager.current_language == "kn" else item["word"]
		word_lbl.text = word_text
		word_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		word_lbl.add_theme_font_size_override("font_size", 20)
		word_lbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
		vbox.add_child(word_lbl)
		
		card.pressed.connect(func():
			SoundManager.play_pop()
			var speak = item["letter"] + " for " + item["word"]
			SoundManager.speak_text(speak)
		)
		grid.add_child(card)

func _refresh_explore_grid() -> void:
	var grid = explore_container.get_node("ExploreGrid")
	for i in range(grid.get_child_count()):
		var card = grid.get_child(i)
		var item = alphabet_data[i]
		var lbl = card.find_child("LetterLabel", true, false) as Label
		if lbl:
			lbl.text = item["letter"] if is_uppercase else item["letter"].to_lower()

# --- Quiz Mode Logic ---
func _setup_quiz_question() -> void:
	# Pick random letter
	quiz_target_idx = randi() % alphabet_data.size()
	var target = alphabet_data[quiz_target_idx]
	
	if LocalizationManager.current_language == "kn":
		quiz_question_lbl.text = "ಅಕ್ಷರವನ್ನು ಗುರುತಿಸಿ: " + target["letter"] + " (" + target["kn_word"] + " " + target["icon"] + ")"
	else:
		quiz_question_lbl.text = "Find the letter: " + target["letter"] + "  " + target["icon"]
		
	SoundManager.speak_text("Find the letter " + target["letter"])
	
	# Clear previous options
	for child in quiz_options_grid.get_children():
		child.queue_free()
		
	# Pick 3 wrong options + 1 correct option
	var options = [target["letter"]]
	while options.size() < 4:
		var rnd = alphabet_data[randi() % alphabet_data.size()]["letter"]
		if not rnd in options:
			options.append(rnd)
	options.shuffle()
	
	var colors = [Color(0.95, 0.4, 0.4), Color(0.3, 0.7, 0.4), Color(0.3, 0.55, 0.95), Color(0.95, 0.7, 0.2)]
	
	for i in range(options.size()):
		var letter_opt = options[i]
		var opt_btn = Button.new()
		opt_btn.custom_minimum_size = Vector2(0, 160)
		opt_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var st = StyleBoxFlat.new()
		st.bg_color = colors[i % colors.size()]
		st.set_corner_radius_all(30)
		opt_btn.add_theme_stylebox_override("normal", st)
		opt_btn.text = letter_opt
		opt_btn.add_theme_font_size_override("font_size", 64)
		
		opt_btn.pressed.connect(func():
			_on_quiz_option_selected(letter_opt, target["letter"])
		)
		quiz_options_grid.add_child(opt_btn)

func _on_quiz_option_selected(selected: String, target: String) -> void:
	if selected == target:
		SoundManager.play_correct()
		GameManager.record_activity("alphabet")
		celebration.show_celebration("Great Job! That's " + target + "! ⭐")
	else:
		SoundManager.play_wrong()
		quiz_question_lbl.text = "Try again! Find " + target + " 😊"

# --- Tracing Mode Logic ---
func _setup_trace_letter() -> void:
	var target = alphabet_data[quiz_target_idx]
	trace_letter_lbl.text = "Trace: " + target["letter"] + " " + target["icon"]
	trace_points.clear()
	trace_canvas.queue_redraw()
	SoundManager.speak_text("Trace letter " + target["letter"])

func _on_trace_canvas_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			is_tracing = true
			trace_points.append(event.position)
			trace_canvas.queue_redraw()
		else:
			is_tracing = false
			if trace_points.size() > 20:
				SoundManager.play_correct()
				GameManager.record_activity("alphabet")
				celebration.show_celebration("Beautiful Tracing! ⭐")
	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if is_tracing:
			trace_points.append(event.position)
			trace_canvas.queue_redraw()

func _on_trace_canvas_draw() -> void:
	var rect = trace_canvas.get_rect()
	var center = rect.size / 2.0
	
	# Draw background guideline card
	trace_canvas.draw_rect(Rect2(Vector2.ZERO, rect.size), Color(0.97, 0.98, 1.0), true, -1.0)
	
	# Draw faint dotted/transparent guide letter in background
	var target_char = alphabet_data[quiz_target_idx]["letter"]
	var font = ThemeDB.fallback_font
	if font:
		trace_canvas.draw_string(font, center + Vector2(-110, 140), target_char, HORIZONTAL_ALIGNMENT_CENTER, -1, 380, Color(0.82, 0.86, 0.92))
		
	# Draw child's colorful finger trail
	if trace_points.size() > 1:
		for i in range(1, trace_points.size()):
			trace_canvas.draw_line(trace_points[i - 1], trace_points[i], Color(1.0, 0.35, 0.55), 22.0, true)
