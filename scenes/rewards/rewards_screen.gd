extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")

var header: Control

var badge_definitions = [
	{"id": "first_star", "title": "First Step!", "kn_title": "ಮೊದಲ ಹೆಜ್ಜೆ!", "icon": "🌟", "desc": "Earn your very first star!"},
	{"id": "abc_explorer", "title": "ABC Explorer", "kn_title": "ಅಕ್ಷರ ಅನ್ವೇಷಕ", "icon": "🔤", "desc": "Complete 3 Alphabet activities!"},
	{"id": "number_ninja", "title": "Number Ninja", "kn_title": "ಸಂಖ್ಯಾ ವೀರ", "icon": "🔢", "desc": "Master 3 Math challenges!"},
	{"id": "color_artist", "title": "Color Artist", "kn_title": "ಬಣ್ಣದ ಮಾಂತ್ರಿಕ", "icon": "🎨", "desc": "Explore 3 Color & Shape games!"},
	{"id": "animal_friend", "title": "Animal Friend", "kn_title": "ಪ್ರಾಣಿ ಮಿತ್ರ", "icon": "🦁", "desc": "Learn about 3 animal worlds!"},
	{"id": "puzzle_master", "title": "Puzzle Master", "kn_title": "ಒಗಟು ಪರಿಣತ", "icon": "🧩", "desc": "Solve 3 card & jigsaw puzzles!"},
	{"id": "super_scholar", "title": "Super Scholar", "kn_title": "ಸೂಪರ್ ವಿದ್ವಾಂಸ", "icon": "🎓", "desc": "Earn 25 total stars!"}
]

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.98, 0.96, 0.9)
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
	header.title_key = "mod_rewards"
	vbox.add_child(header)
	
	# Trophy Banner
	var banner = PanelContainer.new()
	banner.custom_minimum_size = Vector2(0, 150)
	var b_st = StyleBoxFlat.new()
	b_st.bg_color = Color(1.0, 0.78, 0.15)
	b_st.set_corner_radius_all(30)
	b_st.content_margin_left = 24
	b_st.content_margin_right = 24
	b_st.content_margin_top = 16
	b_st.content_margin_bottom = 16
	banner.add_theme_stylebox_override("panel", b_st)
	vbox.add_child(banner)
	
	var b_hbox = HBoxContainer.new()
	b_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	b_hbox.add_theme_constant_override("separation", 24)
	banner.add_child(b_hbox)
	
	var trophy_ic = Label.new()
	trophy_ic.text = "🏆"
	trophy_ic.add_theme_font_size_override("font_size", 80)
	b_hbox.add_child(trophy_ic)
	
	var b_text_col = VBoxContainer.new()
	b_text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	var tot_lbl = Label.new()
	tot_lbl.text = "Trophy Room & Badges"
	tot_lbl.add_theme_font_size_override("font_size", 34)
	tot_lbl.add_theme_color_override("font_color", Color(0.25, 0.2, 0.05))
	b_text_col.add_child(tot_lbl)
	
	var star_sum_lbl = Label.new()
	star_sum_lbl.text = "Total Stars: " + str(GameManager.total_stars) + " ⭐"
	star_sum_lbl.add_theme_font_size_override("font_size", 28)
	star_sum_lbl.add_theme_color_override("font_color", Color(0.35, 0.28, 0.05))
	b_text_col.add_child(star_sum_lbl)
	b_hbox.add_child(b_text_col)
	
	# Scrollable Badges Grid
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	scroll.add_child(grid)
	
	for bd in badge_definitions:
		var is_unlocked = GameManager.badges.get(bd["id"], false)
		
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 190)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var c_st = StyleBoxFlat.new()
		c_st.bg_color = Color(1.0, 1.0, 1.0) if is_unlocked else Color(0.92, 0.92, 0.92)
		c_st.set_corner_radius_all(28)
		c_st.border_width_left = 4
		c_st.border_width_top = 4
		c_st.border_width_right = 4
		c_st.border_width_bottom = 4
		c_st.border_color = Color(1.0, 0.8, 0.2) if is_unlocked else Color(0.8, 0.8, 0.8)
		c_st.content_margin_left = 18
		c_st.content_margin_right = 18
		c_st.content_margin_top = 18
		c_st.content_margin_bottom = 18
		card.add_theme_stylebox_override("panel", c_st)
		
		var c_vbox = VBoxContainer.new()
		c_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(c_vbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = bd["icon"] if is_unlocked else "🔒"
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 58)
		c_vbox.add_child(icon_lbl)
		
		var title_lbl = Label.new()
		var tit = bd["kn_title"] if LocalizationManager.current_language == "kn" else bd["title"]
		title_lbl.text = tit
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_lbl.add_theme_font_size_override("font_size", 26)
		title_lbl.add_theme_color_override("font_color", Color(0.15, 0.5, 0.2) if is_unlocked else Color(0.5, 0.5, 0.5))
		c_vbox.add_child(title_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = bd["desc"]
		desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 18)
		desc_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4) if is_unlocked else Color(0.6, 0.6, 0.6))
		c_vbox.add_child(desc_lbl)
		
		grid.add_child(card)
