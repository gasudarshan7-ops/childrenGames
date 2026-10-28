extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control

# Modes: "count", "add_sub", "mult_div", "grid_100"
var current_mode: String = "count"

# Math state
var math_num1: int = 1
var math_num2: int = 1
var math_op: String = "+"
var math_correct_ans: int = 2
var math_problem_lbl: Label
var math_visual_row: HBoxContainer
var math_options_grid: GridContainer

# Counting state
var count_target: int = 3
var count_item_emoji: String = "🍎"
var count_items_box: HBoxContainer
var count_options_grid: GridContainer

func _ready() -> void:
	_build_ui()
	_apply_age_defaults()
	_set_mode(current_mode)

func _apply_age_defaults() -> void:
	match GameManager.current_age_group:
		"toddler":
			current_mode = "count"
		"preschool":
			current_mode = "add_sub"
		"primary":
			current_mode = "mult_div"
		_:
			current_mode = "count"

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.94, 0.98, 0.96)
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
	header.title_key = "mod_numbers"
	vbox.add_child(header)
	
	# Mode Selection Pills
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 12)
	vbox.add_child(mode_bar)
	
	_add_mode_btn(mode_bar, "count", "🍎 Visual Counting", Color(0.2, 0.75, 0.45))
	_add_mode_btn(mode_bar, "add_sub", "➕ Add & Subtract", Color(0.3, 0.65, 0.95))
	_add_mode_btn(mode_bar, "mult_div", "✖️ Multiply & Divide", Color(0.95, 0.5, 0.2))
	_add_mode_btn(mode_bar, "grid_100", "🔢 1 to 100", Color(0.6, 0.45, 0.85))
	
	# Content Viewport Panel
	var content_panel = PanelContainer.new()
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var st = StyleBoxFlat.new()
	st.bg_color = Color.WHITE
	st.set_corner_radius_all(32)
	st.shadow_color = Color(0, 0, 0, 0.08)
	st.shadow_size = 10
	st.content_margin_left = 24
	st.content_margin_right = 24
	st.content_margin_top = 24
	st.content_margin_bottom = 24
	content_panel.add_theme_stylebox_override("panel", st)
	vbox.add_child(content_panel)
	
	# 1. Counting View
	var count_vbox = VBoxContainer.new()
	count_vbox.name = "CountView"
	count_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	count_vbox.add_theme_constant_override("separation", 28)
	content_panel.add_child(count_vbox)
	
	var count_title = Label.new()
	count_title.text = "How many items do you see?"
	count_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_title.add_theme_font_size_override("font_size", 38)
	count_title.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	count_vbox.add_child(count_title)
	
	count_items_box = HBoxContainer.new()
	count_items_box.alignment = BoxContainer.ALIGNMENT_CENTER
	count_items_box.custom_minimum_size = Vector2(0, 180)
	count_vbox.add_child(count_items_box)
	
	count_options_grid = GridContainer.new()
	count_options_grid.columns = 2
	count_options_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count_options_grid.add_theme_constant_override("h_separation", 24)
	count_options_grid.add_theme_constant_override("v_separation", 24)
	count_vbox.add_child(count_options_grid)
	
	# 2. Math Operations View (Add / Sub / Mult / Div)
	var math_vbox = VBoxContainer.new()
	math_vbox.name = "MathView"
	math_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	math_vbox.add_theme_constant_override("separation", 28)
	content_panel.add_child(math_vbox)
	
	math_problem_lbl = Label.new()
	math_problem_lbl.text = "3 + 2 = ?"
	math_problem_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	math_problem_lbl.add_theme_font_size_override("font_size", 68)
	math_problem_lbl.add_theme_color_override("font_color", Color(0.15, 0.45, 0.85))
	math_vbox.add_child(math_problem_lbl)
	
	math_visual_row = HBoxContainer.new()
	math_visual_row.alignment = BoxContainer.ALIGNMENT_CENTER
	math_visual_row.custom_minimum_size = Vector2(0, 120)
	math_vbox.add_child(math_visual_row)
	
	math_options_grid = GridContainer.new()
	math_options_grid.columns = 2
	math_options_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	math_options_grid.add_theme_constant_override("h_separation", 24)
	math_options_grid.add_theme_constant_override("v_separation", 24)
	math_vbox.add_child(math_options_grid)
	
	# 3. 1 to 100 Grid View
	var grid_scroll = ScrollContainer.new()
	grid_scroll.name = "Grid100View"
	grid_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.add_child(grid_scroll)
	
	var grid_100 = GridContainer.new()
	grid_100.columns = 10
	grid_100.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_scroll.add_child(grid_100)
	_populate_100_grid(grid_100)
	
	# Celebration
	celebration = CelebrationModalScript.new()
	add_child(celebration)
	celebration.next_pressed.connect(_on_celebration_next)
	celebration.replay_pressed.connect(_on_celebration_next)

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
	var c_view = find_child("CountView", true, false)
	var m_view = find_child("MathView", true, false)
	var g_view = find_child("Grid100View", true, false)
	
	c_view.visible = (mode_id == "count")
	m_view.visible = (mode_id == "add_sub" or mode_id == "mult_div")
	g_view.visible = (mode_id == "grid_100")
	
	if mode_id == "count":
		_setup_count_problem()
	elif mode_id == "add_sub":
		_setup_math_problem(false)
	elif mode_id == "mult_div":
		_setup_math_problem(true)

# --- Counting Mode ---
func _setup_count_problem() -> void:
	var max_count = 5 if GameManager.current_age_group == "toddler" else 10
	count_target = randi_range(1, max_count)
	
	var items = ["🍎", "⭐", "🚗", "🧸", "🐥", "🍭", "⚽", "🎈"]
	count_item_emoji = items.pick_random()
	
	for c in count_items_box.get_children():
		c.queue_free()
		
	for i in range(count_target):
		var lbl = Label.new()
		lbl.text = count_item_emoji
		lbl.add_theme_font_size_override("font_size", 60)
		count_items_box.add_child(lbl)
		
	# Populate 4 choices
	for c in count_options_grid.get_children():
		c.queue_free()
		
	var choices = [count_target]
	while choices.size() < 4:
		var r = randi_range(1, max_count + 3)
		if not r in choices:
			choices.append(r)
	choices.shuffle()
	
	var colors = [Color(0.2, 0.75, 0.45), Color(0.95, 0.5, 0.2), Color(0.3, 0.65, 0.95), Color(0.9, 0.35, 0.75)]
	for i in range(choices.size()):
		var val = choices[i]
		var btn = Button.new()
		btn.text = str(val)
		btn.custom_minimum_size = Vector2(0, 150)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var st = StyleBoxFlat.new()
		st.bg_color = colors[i % colors.size()]
		st.set_corner_radius_all(28)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_font_size_override("font_size", 64)
		btn.pressed.connect(func():
			if val == count_target:
				SoundManager.play_correct()
				GameManager.record_activity("numbers")
				celebration.show_celebration("Awesome! There are " + str(count_target) + " items! ⭐")
			else:
				SoundManager.play_wrong()
		)
		count_options_grid.add_child(btn)

# --- Math Mode ---
func _setup_math_problem(is_advanced: bool) -> void:
	if not is_advanced:
		# Add or Subtract
		math_op = "+" if randf() > 0.4 else "-"
		if math_op == "+":
			math_num1 = randi_range(1, 9)
			math_num2 = randi_range(1, 9)
			math_correct_ans = math_num1 + math_num2
		else:
			math_num1 = randi_range(4, 15)
			math_num2 = randi_range(1, math_num1)
			math_correct_ans = math_num1 - math_num2
	else:
		# Multiply or Divide
		math_op = "×" if randf() > 0.4 else "÷"
		if math_op == "×":
			math_num1 = randi_range(2, 9)
			math_num2 = randi_range(2, 9)
			math_correct_ans = math_num1 * math_num2
		else:
			math_num2 = randi_range(2, 6)
			math_correct_ans = randi_range(2, 6)
			math_num1 = math_num2 * math_correct_ans
			
	math_problem_lbl.text = str(math_num1) + " " + math_op + " " + str(math_num2) + " = ?"
	
	# Visual counters
	for c in math_visual_row.get_children():
		c.queue_free()
	var vis_lbl = Label.new()
	vis_lbl.text = "🔵 ".repeat(mini(math_num1, 10)) + (" + " if math_op == "+" else "   ") + ("🔴 ".repeat(mini(math_num2, 10)) if math_op == "+" else "")
	vis_lbl.add_theme_font_size_override("font_size", 34)
	math_visual_row.add_child(vis_lbl)
	
	# Generate choices
	for c in math_options_grid.get_children():
		c.queue_free()
		
	var choices = [math_correct_ans]
	while choices.size() < 4:
		var r = math_correct_ans + randi_range(-4, 4)
		if r >= 0 and not r in choices:
			choices.append(r)
	choices.shuffle()
	
	var colors = [Color(0.2, 0.75, 0.45), Color(0.95, 0.5, 0.2), Color(0.3, 0.65, 0.95), Color(0.9, 0.35, 0.75)]
	for i in range(choices.size()):
		var val = choices[i]
		var btn = Button.new()
		btn.text = str(val)
		btn.custom_minimum_size = Vector2(0, 150)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var st = StyleBoxFlat.new()
		st.bg_color = colors[i % colors.size()]
		st.set_corner_radius_all(28)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_font_size_override("font_size", 64)
		btn.pressed.connect(func():
			if val == math_correct_ans:
				SoundManager.play_correct()
				GameManager.record_activity("numbers")
				celebration.show_celebration("Super Math Whiz! " + str(val) + " is Correct! ⭐")
			else:
				SoundManager.play_wrong()
		)
		math_options_grid.add_child(btn)

func _populate_100_grid(grid: GridContainer) -> void:
	for i in range(1, 101):
		var btn = Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(85, 85)
		var st = StyleBoxFlat.new()
		var hue = (i % 10) / 10.0
		st.bg_color = Color.from_hsv(hue, 0.45, 0.95)
		st.set_corner_radius_all(14)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_font_size_override("font_size", 26)
		btn.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(str(i))
		)
		grid.add_child(btn)

func _on_celebration_next() -> void:
	if current_mode == "count":
		_setup_count_problem()
	else:
		_setup_math_problem(current_mode == "mult_div")
