extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control

# Modes: "stories", "rhymes"
var current_mode: String = "stories"

var story_items = [
	{
		"title": "The Honest Little Squirrel",
		"kn_title": "ಪ್ರಾಮಾಣಿಕ ಪುಟ್ಟ ಅಳಿಲು",
		"icon": "🐿️",
		"pages": [
			{"text": "Once upon a time in a sunny green forest, Sammy the squirrel found a shiny golden nut.", "icon": "🌳 🐿️ 🌰"},
			{"text": "Sammy knew the golden nut belonged to kind Grandpa Beaver, who lost it by the river.", "icon": "🪵 🦫 🌊"},
			{"text": "Sammy ran all the way and returned the nut. Grandpa Beaver smiled and rewarded Sammy with sweet berries!", "icon": "🍓 🐿️ 💖"},
			{"text": "Moral: Honesty always brings true happiness and friendship!", "icon": "⭐ 🌟 🌈"}
		]
	},
	{
		"title": "The Kind Elephant and the Mouse",
		"kn_title": "ದಯಾಳು ಆನೆ ಮತ್ತು ಪುಟ್ಟ ಇಲಿ",
		"icon": "🐘",
		"pages": [
			{"text": "Gobo the big elephant was gentle and helped little animals reach sweet tree leaves.", "icon": "🌿 🐘 🍃"},
			{"text": "One day, a tiny mouse named Pip got stuck inside a hollow log and called for help.", "icon": "🪵 🐭 🆘"},
			{"text": "Gobo gently used his long trunk to roll the log and set little Pip free!", "icon": "🐘 ✨ 🐭"},
			{"text": "Moral: No act of kindness, no matter how small, is ever wasted!", "icon": "💖 🌟 🤝"}
		]
	},
	{
		"title": "The Clever Crow",
		"kn_title": "ಬುದ್ಧಿವಂತ ಕಾಗೆ",
		"icon": "🐦‍⬛",
		"pages": [
			{"text": "On a warm afternoon, a thirsty crow flew across the garden looking for water.", "icon": "☀️ 🐦‍⬛ 🌻"},
			{"text": "He saw a tall clay pitcher with only a little water at the very bottom.", "icon": "🏺 💧 🧐"},
			{"text": "The clever crow picked up small pebbles one by one and dropped them into the pitcher until the water rose!", "icon": "🪨 🏺 💦"},
			{"text": "Moral: Patience and thinking smartly solve every puzzle!", "icon": "🧠 🏆 ⭐"}
		]
	}
]

var rhyme_items = [
	{
		"title": "Twinkle, Twinkle, Little Star",
		"kn_title": "ಟ್ವಿಂಕಲ್ ಟ್ವಿಂಕಲ್ ಲಿಟಲ್ ಸ್ಟಾರ್",
		"icon": "⭐",
		"pages": [
			{"text": "Twinkle, twinkle, little star,\nHow I wonder what you are!", "icon": "✨ ⭐ 🌌"},
			{"text": "Up above the world so high,\nLike a diamond in the sky!", "icon": "💎 🌙 🌠"},
			{"text": "When the blazing sun is gone,\nWhen he nothing shines upon,", "icon": "☀️ 🌆 🌌"},
			{"text": "Then you show your little light,\nTwinkle, twinkle, all the night!", "icon": "⭐ 🌃 ✨"}
		]
	},
	{
		"title": "Row, Row, Row Your Boat",
		"kn_title": "ರೋವ್ ರೋವ್ ರೋವ್ ಯುವರ್ ಬೋಟ್",
		"icon": "⛵",
		"pages": [
			{"text": "Row, row, row your boat,\nGently down the stream,", "icon": "⛵ 🌊 🌲"},
			{"text": "Merrily, merrily, merrily, merrily,\nLife is but a dream!", "icon": "😄 🌈 🎶"}
		]
	}
]

# Reader State
var active_collection: Array = []
var active_book_idx: int = 0
var active_page_idx: int = 0
var reader_panel: PanelContainer
var selector_scroll: ScrollContainer
var reader_text_lbl: Label
var reader_icon_lbl: Label
var reader_title_lbl: Label
var reader_page_lbl: Label
var play_narration_btn: Button

func _ready() -> void:
	_build_ui()
	_set_mode("stories")

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.98, 0.95, 0.92)
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
	header.title_key = "mod_stories"
	vbox.add_child(header)
	
	# Mode Selection Pills
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 14)
	vbox.add_child(mode_bar)
	
	_add_mode_btn(mode_bar, "stories", "📖 Moral Stories", Color(0.85, 0.5, 0.25))
	_add_mode_btn(mode_bar, "rhymes", "🎵 Nursery Rhymes", Color(0.3, 0.65, 0.95))
	
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
	
	# Book Selector List View
	selector_scroll = ScrollContainer.new()
	selector_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	selector_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_panel.add_child(selector_scroll)
	
	var sel_vbox = VBoxContainer.new()
	sel_vbox.name = "SelectorBox"
	sel_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sel_vbox.add_theme_constant_override("separation", 20)
	selector_scroll.add_child(sel_vbox)
	
	# Reader Interactive Storybook View
	reader_panel = PanelContainer.new()
	reader_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reader_panel.visible = false
	var r_st = StyleBoxFlat.new()
	r_st.bg_color = Color(1.0, 0.99, 0.97)
	r_st.set_corner_radius_all(28)
	r_st.border_width_left = 4
	r_st.border_width_top = 4
	r_st.border_width_right = 4
	r_st.border_width_bottom = 4
	r_st.border_color = Color(0.9, 0.8, 0.7)
	reader_panel.add_theme_stylebox_override("panel", r_st)
	content_panel.add_child(reader_panel)
	
	var r_vbox = VBoxContainer.new()
	r_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	r_vbox.add_theme_constant_override("separation", 24)
	reader_panel.add_child(r_vbox)
	
	# Top bar inside reader
	var r_top = HBoxContainer.new()
	var close_reader_btn = Button.new()
	close_reader_btn.text = "✖ Close Book"
	close_reader_btn.custom_minimum_size = Vector2(160, 60)
	var cl_st = StyleBoxFlat.new()
	cl_st.bg_color = Color(0.95, 0.45, 0.45)
	cl_st.set_corner_radius_all(18)
	close_reader_btn.add_theme_stylebox_override("normal", cl_st)
	close_reader_btn.add_theme_font_size_override("font_size", 22)
	close_reader_btn.pressed.connect(func():
		SoundManager.play_pop()
		reader_panel.visible = false
		selector_scroll.visible = true
	)
	r_top.add_child(close_reader_btn)
	
	var r_sp = Control.new()
	r_sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r_top.add_child(r_sp)
	
	reader_title_lbl = Label.new()
	reader_title_lbl.text = "Story Title"
	reader_title_lbl.add_theme_font_size_override("font_size", 32)
	reader_title_lbl.add_theme_color_override("font_color", Color(0.25, 0.2, 0.15))
	r_top.add_child(reader_title_lbl)
	
	var r_sp2 = Control.new()
	r_sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r_top.add_child(r_sp2)
	
	reader_page_lbl = Label.new()
	reader_page_lbl.text = "Page 1/4"
	reader_page_lbl.add_theme_font_size_override("font_size", 24)
	reader_page_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	r_top.add_child(reader_page_lbl)
	r_vbox.add_child(r_top)
	
	# Illustration
	reader_icon_lbl = Label.new()
	reader_icon_lbl.text = "🌳 🐿️ 🌰"
	reader_icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reader_icon_lbl.add_theme_font_size_override("font_size", 96)
	r_vbox.add_child(reader_icon_lbl)
	
	# Text
	reader_text_lbl = Label.new()
	reader_text_lbl.text = "Once upon a time..."
	reader_text_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reader_text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reader_text_lbl.custom_minimum_size = Vector2(0, 160)
	reader_text_lbl.add_theme_font_size_override("font_size", 34)
	reader_text_lbl.add_theme_color_override("font_color", Color(0.2, 0.18, 0.15))
	r_vbox.add_child(reader_text_lbl)
	
	# Narration & Page controls
	var ctrl_row = HBoxContainer.new()
	ctrl_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ctrl_row.add_theme_constant_override("separation", 24)
	r_vbox.add_child(ctrl_row)
	
	var prev_page_btn = Button.new()
	prev_page_btn.text = "◀ Prev Page"
	prev_page_btn.custom_minimum_size = Vector2(170, 75)
	var nav_st = StyleBoxFlat.new()
	nav_st.bg_color = Color(0.4, 0.65, 0.95)
	nav_st.set_corner_radius_all(24)
	prev_page_btn.add_theme_stylebox_override("normal", nav_st)
	prev_page_btn.add_theme_font_size_override("font_size", 24)
	prev_page_btn.pressed.connect(func():
		SoundManager.play_pop()
		if active_page_idx > 0:
			active_page_idx -= 1
			_render_page()
	)
	ctrl_row.add_child(prev_page_btn)
	
	play_narration_btn = Button.new()
	play_narration_btn.text = "🔊 Read to Me"
	play_narration_btn.custom_minimum_size = Vector2(220, 75)
	var spk_st = StyleBoxFlat.new()
	spk_st.bg_color = Color(0.25, 0.78, 0.45)
	spk_st.set_corner_radius_all(24)
	play_narration_btn.add_theme_stylebox_override("normal", spk_st)
	play_narration_btn.add_theme_font_size_override("font_size", 26)
	play_narration_btn.pressed.connect(func():
		SoundManager.play_pop()
		SoundManager.speak_text(reader_text_lbl.text)
	)
	ctrl_row.add_child(play_narration_btn)
	
	var next_page_btn = Button.new()
	next_page_btn.text = "Next Page ▶"
	next_page_btn.custom_minimum_size = Vector2(170, 75)
	next_page_btn.add_theme_stylebox_override("normal", nav_st)
	next_page_btn.add_theme_font_size_override("font_size", 24)
	next_page_btn.pressed.connect(func():
		SoundManager.play_pop()
		var total_pages = active_collection[active_book_idx]["pages"].size()
		if active_page_idx < total_pages - 1:
			active_page_idx += 1
			_render_page()
		else:
			# Finished book
			SoundManager.play_correct()
			GameManager.record_activity("stories")
			celebration.show_celebration("Story Completed! Super Reader! ⭐")
	)
	ctrl_row.add_child(next_page_btn)
	
	celebration = CelebrationModalScript.new()
	add_child(celebration)
	celebration.next_pressed.connect(func():
		reader_panel.visible = false
		selector_scroll.visible = true
	)
	celebration.replay_pressed.connect(func():
		active_page_idx = 0
		_render_page()
	)

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

func _set_mode(mode_id: String) -> void:
	current_mode = mode_id
	reader_panel.visible = false
	selector_scroll.visible = true
	active_collection = story_items if mode_id == "stories" else rhyme_items
	_populate_selector()

func _populate_selector() -> void:
	var sel_vbox = selector_scroll.get_node("SelectorBox")
	for c in sel_vbox.get_children():
		c.queue_free()
		
	for i in range(active_collection.size()):
		var item = active_collection[i]
		var card = Button.new()
		card.custom_minimum_size = Vector2(0, 160)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.97, 0.96, 1.0)
		st.set_corner_radius_all(28)
		st.border_width_left = 3
		st.border_width_top = 3
		st.border_width_right = 3
		st.border_width_bottom = 3
		st.border_color = Color(0.85, 0.88, 0.98)
		card.add_theme_stylebox_override("normal", st)
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 24)
		card.add_child(hbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = item["icon"]
		icon_lbl.add_theme_font_size_override("font_size", 64)
		hbox.add_child(icon_lbl)
		
		var t_lbl = Label.new()
		var tit = item["kn_title"] if LocalizationManager.current_language == "kn" else item["title"]
		t_lbl.text = tit
		t_lbl.add_theme_font_size_override("font_size", 32)
		t_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		hbox.add_child(t_lbl)
		
		card.pressed.connect(func():
			SoundManager.play_pop()
			_open_book(i)
		)
		sel_vbox.add_child(card)

func _open_book(idx: int) -> void:
	active_book_idx = idx
	active_page_idx = 0
	selector_scroll.visible = false
	reader_panel.visible = true
	var book = active_collection[active_book_idx]
	var tit = book["kn_title"] if LocalizationManager.current_language == "kn" else book["title"]
	reader_title_lbl.text = tit
	_render_page()

func _render_page() -> void:
	var book = active_collection[active_book_idx]
	var pages: Array = book["pages"]
	var page = pages[active_page_idx]
	reader_page_lbl.text = "Page " + str(active_page_idx + 1) + "/" + str(pages.size())
	reader_icon_lbl.text = page["icon"]
	reader_text_lbl.text = page["text"]
	SoundManager.speak_text(page["text"])
