extends Control

var age_buttons: Dictionary = {}
var mascot_label: Label
var mascot_bubble: Label
var stars_label: Label
var play_now_btn: Button
var clouds: Array[Control] = []

func _ready() -> void:
	_build_ui()
	GameManager.stars_updated.connect(_on_stars_updated)
	GameManager.age_group_changed.connect(_on_age_changed)
	LocalizationManager.language_changed.connect(_on_lang_changed)
	_animate_scenery()

func _process(delta: float) -> void:
	# Gentle floating animation for clouds
	for c in clouds:
		c.position.x += 18.0 * delta
		if c.position.x > 1150:
			c.position.x = -250

func _build_ui() -> void:
	# Background sky gradient
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.42, 0.78, 0.98) # Sky blue
	add_child(bg)
	
	# Lush green hill at bottom
	var hill = Panel.new()
	hill.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hill.offset_top = -220
	hill.offset_bottom = 0
	var hill_style = StyleBoxFlat.new()
	hill_style.bg_color = Color(0.35, 0.78, 0.32)
	hill_style.corner_radius_top_left = 180
	hill_style.corner_radius_top_right = 180
	hill.add_theme_stylebox_override("panel", hill_style)
	add_child(hill)
	
	# Floating Clouds
	_spawn_clouds()
	
	# Main Vertical Layout
	var root_vbox = VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_vbox.offset_left = 32
	root_vbox.offset_right = -32
	root_vbox.offset_top = 36
	root_vbox.offset_bottom = -36
	root_vbox.add_theme_constant_override("separation", 20)
	add_child(root_vbox)
	
	# --- Top Navigation Bar ---
	var top_bar = HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 90)
	top_bar.add_theme_constant_override("separation", 16)
	root_vbox.add_child(top_bar)
	
	# Language Toggle (🇬🇧 EN / 🇮🇳 ಕನ್ನಡ)
	var lang_btn = Button.new()
	lang_btn.text = "🌐 " + ("ಕನ್ನಡ" if LocalizationManager.current_language == "en" else "English")
	lang_btn.custom_minimum_size = Vector2(160, 75)
	var lang_style = StyleBoxFlat.new()
	lang_style.bg_color = Color(0.2, 0.65, 0.85)
	lang_style.set_corner_radius_all(24)
	lang_btn.add_theme_stylebox_override("normal", lang_style)
	lang_btn.add_theme_font_size_override("font_size", 26)
	lang_btn.pressed.connect(_on_language_toggle)
	top_bar.add_child(lang_btn)
	
	# Star Counter Pill (Center-left)
	var star_pill = PanelContainer.new()
	var pill_style = StyleBoxFlat.new()
	pill_style.bg_color = Color(1.0, 0.82, 0.15)
	pill_style.set_corner_radius_all(24)
	pill_style.content_margin_left = 22
	pill_style.content_margin_right = 22
	pill_style.content_margin_top = 8
	pill_style.content_margin_bottom = 8
	pill_style.shadow_color = Color(0, 0, 0, 0.12)
	pill_style.shadow_size = 6
	star_pill.add_theme_stylebox_override("panel", pill_style)
	
	var star_box = HBoxContainer.new()
	star_box.add_theme_constant_override("separation", 10)
	var s_icon = Label.new()
	s_icon.text = "⭐"
	s_icon.add_theme_font_size_override("font_size", 34)
	star_box.add_child(s_icon)
	
	stars_label = Label.new()
	stars_label.text = str(GameManager.total_stars)
	stars_label.add_theme_font_size_override("font_size", 32)
	stars_label.add_theme_color_override("font_color", Color(0.25, 0.2, 0.05))
	star_box.add_child(stars_label)
	star_pill.add_child(star_box)
	top_bar.add_child(star_pill)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	
	# Parent Zone Button (🔒 Settings)
	var parent_btn = Button.new()
	parent_btn.text = "🔒 " + LocalizationManager.tr_text("mod_parent")
	parent_btn.custom_minimum_size = Vector2(230, 75)
	var parent_style = StyleBoxFlat.new()
	parent_style.bg_color = Color(0.55, 0.45, 0.85) # Child-friendly purple
	parent_style.set_corner_radius_all(24)
	parent_btn.add_theme_stylebox_override("normal", parent_style)
	parent_btn.add_theme_font_size_override("font_size", 26)
	parent_btn.pressed.connect(_on_parent_zone_pressed)
	top_bar.add_child(parent_btn)
	
	# --- Age Group Selection Tabs ---
	var age_row = HBoxContainer.new()
	age_row.alignment = BoxContainer.ALIGNMENT_CENTER
	age_row.add_theme_constant_override("separation", 14)
	root_vbox.add_child(age_row)
	
	_create_age_button(age_row, "toddler", "age_toddler", Color(1.0, 0.45, 0.6)) # Coral pink
	_create_age_button(age_row, "preschool", "age_preschool", Color(0.2, 0.75, 0.5)) # Bright mint
	_create_age_button(age_row, "primary", "age_primary", Color(0.3, 0.55, 0.95)) # Royal blue
	_update_age_buttons_visual()
	
	# --- Mascot & App Title Header ---
	var header_box = HBoxContainer.new()
	header_box.alignment = BoxContainer.ALIGNMENT_CENTER
	header_box.add_theme_constant_override("separation", 24)
	root_vbox.add_child(header_box)
	
	# Mascot Cute Cartoon
	mascot_label = Label.new()
	mascot_label.text = "🐰"
	mascot_label.add_theme_font_size_override("font_size", 100)
	header_box.add_child(mascot_label)
	
	var title_col = VBoxContainer.new()
	title_col.alignment = BoxContainer.ALIGNMENT_CENTER
	var app_title = Label.new()
	app_title.text = LocalizationManager.tr_text("app_title")
	app_title.add_theme_font_size_override("font_size", 46)
	app_title.add_theme_color_override("font_color", Color.WHITE)
	app_title.add_theme_color_override("font_outline_color", Color(0.1, 0.3, 0.6))
	app_title.add_theme_constant_override("outline_size", 10)
	title_col.add_child(app_title)
	
	mascot_bubble = Label.new()
	mascot_bubble.text = LocalizationManager.tr_text("mascot_welcome")
	mascot_bubble.add_theme_font_size_override("font_size", 24)
	mascot_bubble.add_theme_color_override("font_color", Color(0.95, 1.0, 0.7))
	title_col.add_child(mascot_bubble)
	header_box.add_child(title_col)
	
	# --- Huge Bouncing "PLAY NOW" Button ---
	play_now_btn = Button.new()
	play_now_btn.text = "▶  " + LocalizationManager.tr_text("play_now")
	play_now_btn.custom_minimum_size = Vector2(0, 100)
	var play_style = StyleBoxFlat.new()
	play_style.bg_color = Color(1.0, 0.4, 0.2) # Orange-red vibrant
	play_style.set_corner_radius_all(36)
	play_style.border_width_left = 6
	play_style.border_width_top = 6
	play_style.border_width_right = 6
	play_style.border_width_bottom = 6
	play_style.border_color = Color(1.0, 0.85, 0.3)
	play_style.shadow_color = Color(0, 0, 0, 0.2)
	play_style.shadow_size = 14
	play_style.shadow_offset = Vector2(0, 6)
	play_now_btn.add_theme_stylebox_override("normal", play_style)
	play_now_btn.add_theme_font_size_override("font_size", 40)
	play_now_btn.pressed.connect(_on_play_now_pressed)
	root_vbox.add_child(play_now_btn)
	
	# --- Scrollable Modules Grid ---
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_vbox.add_child(scroll)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	scroll.add_child(grid)
	
	# 10 Educational Category Cards
	_create_category_card(grid, "mod_alphabet", "mod_alphabet_desc", "🔤", Color(0.95, 0.3, 0.4), "alphabet")
	_create_category_card(grid, "mod_numbers", "mod_numbers_desc", "🔢", Color(0.2, 0.75, 0.45), "numbers")
	_create_category_card(grid, "mod_colors_shapes", "mod_colors_shapes_desc", "🎨", Color(0.95, 0.65, 0.15), "colors_shapes")
	_create_category_card(grid, "mod_animals", "mod_animals_desc", "🦁", Color(0.3, 0.65, 0.95), "animals")
	_create_category_card(grid, "mod_fruits", "mod_fruits_desc", "🍎", Color(0.9, 0.35, 0.75), "fruits")
	_create_category_card(grid, "mod_puzzles", "mod_puzzles_desc", "🧩", Color(0.4, 0.4, 0.85), "puzzles")
	_create_category_card(grid, "mod_english", "mod_english_desc", "📖", Color(0.15, 0.75, 0.75), "english")
	_create_category_card(grid, "mod_stories", "mod_stories_desc", "📚", Color(0.85, 0.5, 0.25), "stories")
	_create_category_card(grid, "mod_science", "mod_science_desc", "🔬", Color(0.5, 0.3, 0.85), "science")
	_create_category_card(grid, "mod_rewards", "mod_rewards_desc", "🏆", Color(1.0, 0.75, 0.1), "rewards")

func _spawn_clouds() -> void:
	var cloud_data = [
		{"pos": Vector2(80, 140), "scale": 1.2, "icon": "☁️"},
		{"pos": Vector2(500, 220), "scale": 0.9, "icon": "☁️"},
		{"pos": Vector2(850, 110), "scale": 1.4, "icon": "☁️"},
		{"pos": Vector2(960, 280), "scale": 0.8, "icon": "⭐"},
		{"pos": Vector2(150, 320), "scale": 0.7, "icon": "✨"}
	]
	for d in cloud_data:
		var c = Label.new()
		c.text = d["icon"]
		c.position = d["pos"]
		c.add_theme_font_size_override("font_size", int(60 * d["scale"]))
		add_child(c)
		clouds.append(c)

func _animate_scenery() -> void:
	# Bouncy mascot animation
	var tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(mascot_label, "position:y", mascot_label.position.y - 15.0, 0.7)
	tw.tween_property(mascot_label, "position:y", mascot_label.position.y, 0.7)
	
	# Gentle pulsing on Play Now button
	var p_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	p_tw.tween_property(play_now_btn, "scale", Vector2(1.02, 1.02), 0.8)
	p_tw.tween_property(play_now_btn, "scale", Vector2(1.0, 1.0), 0.8)

func _create_age_button(parent: Control, age_id: String, lang_key: String, color: Color) -> void:
	var btn = Button.new()
	btn.text = LocalizationManager.tr_text(lang_key)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 68)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_font_size_override("font_size", 23)
	btn.pressed.connect(func():
		SoundManager.play_pop()
		GameManager.set_age_group(age_id)
	)
	parent.add_child(btn)
	age_buttons[age_id] = btn

func _update_age_buttons_visual() -> void:
	for id in age_buttons.keys():
		var btn: Button = age_buttons[id]
		if id == GameManager.current_age_group:
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			# Add highlight border
			var style = btn.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
			style.border_width_left = 5
			style.border_width_top = 5
			style.border_width_right = 5
			style.border_width_bottom = 5
			style.border_color = Color.WHITE
			btn.add_theme_stylebox_override("normal", style)
		else:
			btn.modulate = Color(0.8, 0.8, 0.8, 0.85)
			var style = btn.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
			style.border_width_left = 0
			style.border_width_top = 0
			style.border_width_right = 0
			style.border_width_bottom = 0
			btn.add_theme_stylebox_override("normal", style)

func _create_category_card(parent: Control, title_key: String, desc_key: String, icon_char: String, color: Color, module_id: String) -> void:
	var btn = Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 190)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(32)
	style.shadow_color = Color(0, 0, 0, 0.15)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	btn.add_theme_stylebox_override("normal", style)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	btn.add_child(hbox)
	
	var icon_lbl = Label.new()
	icon_lbl.text = icon_char
	icon_lbl.add_theme_font_size_override("font_size", 64)
	hbox.add_child(icon_lbl)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)
	
	var t_lbl = Label.new()
	t_lbl.text = LocalizationManager.tr_text(title_key)
	t_lbl.add_theme_font_size_override("font_size", 28)
	t_lbl.add_theme_color_override("font_color", Color.WHITE)
	t_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(t_lbl)
	
	var d_lbl = Label.new()
	d_lbl.text = LocalizationManager.tr_text(desc_key)
	d_lbl.add_theme_font_size_override("font_size", 18)
	d_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.85))
	d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(d_lbl)
	
	btn.pressed.connect(func():
		SoundManager.play_pop()
		_open_module(module_id)
	)
	parent.add_child(btn)

func _open_module(module_id: String) -> void:
	match module_id:
		"alphabet":
			get_tree().change_scene_to_file("res://scenes/modules/alphabet/alphabet_screen.tscn")
		"numbers":
			get_tree().change_scene_to_file("res://scenes/modules/numbers/numbers_screen.tscn")
		"colors_shapes":
			get_tree().change_scene_to_file("res://scenes/modules/colors_shapes/colors_shapes_screen.tscn")
		"animals":
			get_tree().change_scene_to_file("res://scenes/modules/animals_birds/animals_birds_screen.tscn")
		"fruits":
			get_tree().change_scene_to_file("res://scenes/modules/fruits_veggies/fruits_veggies_screen.tscn")
		"puzzles":
			get_tree().change_scene_to_file("res://scenes/modules/puzzles_memory/puzzles_screen.tscn")
		"english":
			get_tree().change_scene_to_file("res://scenes/modules/english/english_screen.tscn")
		"stories":
			get_tree().change_scene_to_file("res://scenes/modules/stories_rhymes/stories_screen.tscn")
		"science":
			get_tree().change_scene_to_file("res://scenes/modules/science_nature/science_screen.tscn")
		"rewards":
			get_tree().change_scene_to_file("res://scenes/rewards/rewards_screen.tscn")
		"parent":
			get_tree().change_scene_to_file("res://scenes/parent/parent_dashboard.tscn")

func _on_play_now_pressed() -> void:
	SoundManager.play_pop()
	var rec = GameManager.get_recommended_module()
	_open_module(rec)

func _on_parent_zone_pressed() -> void:
	SoundManager.play_pop()
	get_tree().change_scene_to_file("res://scenes/parent/parent_dashboard.tscn")

func _on_language_toggle() -> void:
	SoundManager.play_pop()
	LocalizationManager.toggle_language()

func _on_stars_updated(new_stars: int) -> void:
	if stars_label:
		stars_label.text = str(new_stars)

func _on_age_changed(_new_group: String) -> void:
	_update_age_buttons_visual()

func _on_lang_changed(_new_lang: String) -> void:
	get_tree().reload_current_scene()
