extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")

var header: Control

# Parental Gate State
var is_unlocked: bool = false
var gate_num1: int = 0
var gate_num2: int = 0
var gate_ans: int = 0
var gate_panel: PanelContainer
var gate_prompt_lbl: Label
var gate_input_line: LineEdit
var gate_error_lbl: Label

# Dashboard View
var dashboard_scroll: ScrollContainer
var music_btn: Button
var sound_btn: Button
var voice_btn: Button
var lang_btn: Button
var age_lbl: Label
var limit_lbl: Label

func _ready() -> void:
	_build_ui()
	_setup_parent_gate()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.95, 0.94, 0.98)
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
	header.title_key = "mod_parent"
	vbox.add_child(header)
	
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
	
	# 1. Parental Gate Panel (Shown first)
	gate_panel = PanelContainer.new()
	gate_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.add_child(gate_panel)
	
	var g_vbox = VBoxContainer.new()
	g_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	g_vbox.add_theme_constant_override("separation", 24)
	gate_panel.add_child(g_vbox)
	
	var lock_ic = Label.new()
	lock_ic.text = "🔒"
	lock_ic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_ic.add_theme_font_size_override("font_size", 80)
	g_vbox.add_child(lock_ic)
	
	var g_title = Label.new()
	g_title.text = LocalizationManager.tr_text("parent_gate_title")
	g_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	g_title.add_theme_font_size_override("font_size", 40)
	g_title.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	g_vbox.add_child(g_title)
	
	gate_prompt_lbl = Label.new()
	gate_prompt_lbl.text = "Grown-ups only! Please calculate: 7 + 8 = ?"
	gate_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gate_prompt_lbl.add_theme_font_size_override("font_size", 30)
	gate_prompt_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	g_vbox.add_child(gate_prompt_lbl)
	
	var in_hbox = HBoxContainer.new()
	in_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	in_hbox.add_theme_constant_override("separation", 16)
	g_vbox.add_child(in_hbox)
	
	gate_input_line = LineEdit.new()
	gate_input_line.custom_minimum_size = Vector2(240, 80)
	gate_input_line.placeholder_text = "Answer"
	gate_input_line.alignment = HORIZONTAL_ALIGNMENT_CENTER
	gate_input_line.add_theme_font_size_override("font_size", 36)
	in_hbox.add_child(gate_input_line)
	
	var enter_btn = Button.new()
	enter_btn.text = "Unlock 🔓"
	enter_btn.custom_minimum_size = Vector2(180, 80)
	var e_st = StyleBoxFlat.new()
	e_st.bg_color = Color(0.2, 0.75, 0.45)
	e_st.set_corner_radius_all(24)
	enter_btn.add_theme_stylebox_override("normal", e_st)
	enter_btn.add_theme_font_size_override("font_size", 28)
	enter_btn.pressed.connect(_on_unlock_pressed)
	in_hbox.add_child(enter_btn)
	
	gate_error_lbl = Label.new()
	gate_error_lbl.text = ""
	gate_error_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gate_error_lbl.add_theme_font_size_override("font_size", 24)
	gate_error_lbl.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	g_vbox.add_child(gate_error_lbl)
	
	# 2. Main Dashboard (Protected)
	dashboard_scroll = ScrollContainer.new()
	dashboard_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dashboard_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	dashboard_scroll.visible = false
	content_panel.add_child(dashboard_scroll)
	
	var d_vbox = VBoxContainer.new()
	d_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	d_vbox.add_theme_constant_override("separation", 24)
	dashboard_scroll.add_child(d_vbox)
	
	# Stats Section
	var stats_card = PanelContainer.new()
	var sc_st = StyleBoxFlat.new()
	sc_st.bg_color = Color(0.96, 0.98, 1.0)
	sc_st.set_corner_radius_all(24)
	sc_st.content_margin_left = 20
	sc_st.content_margin_right = 20
	sc_st.content_margin_top = 20
	sc_st.content_margin_bottom = 20
	stats_card.add_theme_stylebox_override("panel", sc_st)
	d_vbox.add_child(stats_card)
	
	var s_col = VBoxContainer.new()
	s_col.add_theme_constant_override("separation", 10)
	stats_card.add_child(s_col)
	
	var stat1 = Label.new()
	stat1.text = LocalizationManager.tr_text("stats_total_stars") + " " + str(GameManager.total_stars) + " ⭐"
	stat1.add_theme_font_size_override("font_size", 28)
	stat1.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	s_col.add_child(stat1)
	
	var total_acts = 0
	for k in GameManager.completed_activities.keys():
		total_acts += GameManager.completed_activities[k]
	var stat2 = Label.new()
	stat2.text = LocalizationManager.tr_text("stats_activities_done") + " " + str(total_acts) + " 🎮"
	stat2.add_theme_font_size_override("font_size", 28)
	stat2.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	s_col.add_child(stat2)
	
	# Controls Grid
	_add_setting_row(d_vbox, "settings_sound", "Sound Effects", func(btn):
		var state = SoundManager.toggle_sound()
		btn.text = "ON 🔊" if state else "OFF 🔇"
	, "ON 🔊" if SoundManager.sound_enabled else "OFF 🔇")
	
	_add_setting_row(d_vbox, "settings_music", "Background Music", func(btn):
		var state = SoundManager.toggle_music()
		btn.text = "ON 🎵" if state else "OFF 🔇"
	, "ON 🎵" if SoundManager.music_enabled else "OFF 🔇")
	
	_add_setting_row(d_vbox, "settings_language", "App Language", func(btn):
		var new_lang = LocalizationManager.toggle_language()
		btn.text = "🇬🇧 English" if new_lang == "en" else "🇮🇳 ಕನ್ನಡ"
	, "🇬🇧 English" if LocalizationManager.current_language == "en" else "🇮🇳 ಕನ್ನಡ")
	
	# Reset Progress Button
	var reset_btn = Button.new()
	reset_btn.text = "🗑️ " + LocalizationManager.tr_text("settings_reset_progress")
	reset_btn.custom_minimum_size = Vector2(0, 75)
	var rst_st = StyleBoxFlat.new()
	rst_st.bg_color = Color(1.0, 0.4, 0.4)
	rst_st.set_corner_radius_all(24)
	reset_btn.add_theme_stylebox_override("normal", rst_st)
	reset_btn.add_theme_font_size_override("font_size", 26)
	reset_btn.pressed.connect(func():
		GameManager.reset_all_progress()
		SoundManager.play_pop()
		get_tree().change_scene_to_file("res://scenes/home/home_screen.tscn")
	)
	d_vbox.add_child(reset_btn)
	
	# Privacy Section
	var priv_card = PanelContainer.new()
	var pr_st = StyleBoxFlat.new()
	pr_st.bg_color = Color(0.96, 0.98, 0.96)
	pr_st.set_corner_radius_all(24)
	pr_st.content_margin_left = 20
	pr_st.content_margin_right = 20
	pr_st.content_margin_top = 20
	pr_st.content_margin_bottom = 20
	priv_card.add_theme_stylebox_override("panel", pr_st)
	d_vbox.add_child(priv_card)
	
	var pr_vbox = VBoxContainer.new()
	pr_vbox.add_theme_constant_override("separation", 10)
	priv_card.add_child(pr_vbox)
	
	var p_title = Label.new()
	p_title.text = "🛡️ " + LocalizationManager.tr_text("privacy_title")
	p_title.add_theme_font_size_override("font_size", 26)
	p_title.add_theme_color_override("font_color", Color(0.15, 0.5, 0.25))
	pr_vbox.add_child(p_title)
	
	var p_body = Label.new()
	p_body.text = LocalizationManager.tr_text("privacy_body")
	p_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p_body.add_theme_font_size_override("font_size", 20)
	p_body.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	pr_vbox.add_child(p_body)

func _add_setting_row(parent: Control, key: String, fallback_label: String, callback: Callable, initial_text: String) -> void:
	var hbox = HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 75)
	
	var lbl = Label.new()
	lbl.text = LocalizationManager.tr_text(key) if LocalizationManager.strings["en"].has(key) else fallback_label
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 26)
	lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	hbox.add_child(lbl)
	
	var btn = Button.new()
	btn.text = initial_text
	btn.custom_minimum_size = Vector2(190, 65)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.3, 0.65, 0.95)
	st.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(func():
		SoundManager.play_pop()
		callback.call(btn)
	)
	hbox.add_child(btn)
	parent.add_child(hbox)

func _setup_parent_gate() -> void:
	gate_num1 = randi_range(6, 15)
	gate_num2 = randi_range(5, 12)
	gate_ans = gate_num1 + gate_num2
	gate_prompt_lbl.text = "Grown-ups verification: What is " + str(gate_num1) + " + " + str(gate_num2) + " ?"

func _on_unlock_pressed() -> void:
	var entered = gate_input_line.text.strip_edges()
	if entered == str(gate_ans):
		SoundManager.play_correct()
		is_unlocked = true
		gate_panel.visible = false
		dashboard_scroll.visible = true
	else:
		SoundManager.play_wrong()
		gate_error_lbl.text = LocalizationManager.tr_text("parent_gate_error")
		gate_input_line.text = ""
		_setup_parent_gate()
