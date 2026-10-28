extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control

# Modes: "vocab", "spelling", "sentences"
var current_mode: String = "vocab"

var vocab_data = [
	{"word": "Hello", "kn": "ನಮಸ್ಕಾರ (ಹಲೋ)", "icon": "👋", "category": "Greetings"},
	{"word": "Good Morning", "kn": "ಶುಭೋದಯ", "icon": "🌅", "category": "Greetings"},
	{"word": "Thank You", "kn": "ಧನ್ಯವಾದಗಳು", "icon": "🙏", "category": "Greetings"},
	{"word": "Please", "kn": "ದಯವಿಟ್ಟು", "icon": "🤝", "category": "Greetings"},
	{"word": "Book", "kn": "ಪುಸ್ತಕ", "icon": "📖", "category": "School"},
	{"word": "Pencil", "kn": "ಪೆನ್ಸಿಲ್", "icon": "✏️", "category": "School"},
	{"word": "Sun", "kn": "ಸೂರ್ಯ", "icon": "☀️", "category": "Nature"},
	{"word": "Tree", "kn": "ಮರ", "icon": "🌳", "category": "Nature"},
	{"word": "Friend", "kn": "ಸ್ನೇಹಿತ", "icon": "👫", "category": "People"},
	{"word": "Family", "kn": "ಕುಟುಂಬ", "icon": "👨‍👩‍👧‍👦", "category": "People"}
]

var spelling_words = [
	{"word": "CAT", "icon": "🐱"},
	{"word": "DOG", "icon": "🐶"},
	{"word": "SUN", "icon": "☀️"},
	{"word": "STAR", "icon": "⭐"},
	{"word": "BALL", "icon": "⚽"},
	{"word": "BOOK", "icon": "📖"},
	{"word": "FISH", "icon": "🐟"},
	{"word": "BIRD", "icon": "🐦"}
]

# Spelling State
var current_target_word: Dictionary
var letters_needed: Array = []
var letters_entered: Array = []
var word_display_lbl: Label
var word_icon_lbl: Label
var scramble_tile_box: HBoxContainer
var entered_tile_box: HBoxContainer

# Views
var vocab_scroll: ScrollContainer
var spelling_vbox: VBoxContainer
var grid_container: GridContainer

func _ready() -> void:
	_build_ui()
	_populate_vocab()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.93, 0.98, 0.98)
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
	header.title_key = "mod_english"
	vbox.add_child(header)
	
	# Mode Selection
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 14)
	vbox.add_child(mode_bar)
	
	_add_mode_btn(mode_bar, "vocab", "🗣️ Vocabulary & Greetings", Color(0.15, 0.75, 0.75))
	_add_mode_btn(mode_bar, "spelling", "🔤 Spelling Scramble", Color(0.95, 0.5, 0.2))
	
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
	
	# Vocab View
	vocab_scroll = ScrollContainer.new()
	vocab_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vocab_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_panel.add_child(vocab_scroll)
	
	grid_container = GridContainer.new()
	grid_container.columns = 2
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_theme_constant_override("h_separation", 20)
	grid_container.add_theme_constant_override("v_separation", 20)
	vocab_scroll.add_child(grid_container)
	
	# Spelling View
	spelling_vbox = VBoxContainer.new()
	spelling_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	spelling_vbox.add_theme_constant_override("separation", 28)
	spelling_vbox.visible = false
	content_panel.add_child(spelling_vbox)
	
	var sp_title = Label.new()
	sp_title.text = "Spell the word by tapping letters in order!"
	sp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_title.add_theme_font_size_override("font_size", 34)
	sp_title.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	spelling_vbox.add_child(sp_title)
	
	word_icon_lbl = Label.new()
	word_icon_lbl.text = "🐱"
	word_icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_icon_lbl.add_theme_font_size_override("font_size", 96)
	spelling_vbox.add_child(word_icon_lbl)
	
	# Answer slot tiles
	entered_tile_box = HBoxContainer.new()
	entered_tile_box.alignment = BoxContainer.ALIGNMENT_CENTER
	entered_tile_box.custom_minimum_size = Vector2(0, 110)
	entered_tile_box.add_theme_constant_override("separation", 14)
	spelling_vbox.add_child(entered_tile_box)
	
	# Scrambled choices
	scramble_tile_box = HBoxContainer.new()
	scramble_tile_box.alignment = BoxContainer.ALIGNMENT_CENTER
	scramble_tile_box.custom_minimum_size = Vector2(0, 110)
	scramble_tile_box.add_theme_constant_override("separation", 16)
	spelling_vbox.add_child(scramble_tile_box)
	
	var reset_sp_btn = Button.new()
	reset_sp_btn.text = "🔄 Clear Letters"
	reset_sp_btn.custom_minimum_size = Vector2(220, 70)
	var r_st = StyleBoxFlat.new()
	r_st.bg_color = Color(1.0, 0.45, 0.45)
	r_st.set_corner_radius_all(24)
	reset_sp_btn.add_theme_stylebox_override("normal", r_st)
	reset_sp_btn.add_theme_font_size_override("font_size", 26)
	reset_sp_btn.pressed.connect(func():
		SoundManager.play_pop()
		_setup_spelling_round()
	)
	spelling_vbox.add_child(reset_sp_btn)
	
	celebration = CelebrationModalScript.new()
	add_child(celebration)
	celebration.next_pressed.connect(_setup_spelling_round)
	celebration.replay_pressed.connect(_setup_spelling_round)

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
		current_mode = mode_id
		vocab_scroll.visible = (mode_id == "vocab")
		spelling_vbox.visible = (mode_id == "spelling")
		if mode_id == "spelling":
			_setup_spelling_round()
	)
	parent.add_child(btn)

func _populate_vocab() -> void:
	for c in grid_container.get_children():
		c.queue_free()
		
	for v in vocab_data:
		var card = Button.new()
		card.custom_minimum_size = Vector2(0, 180)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.95, 0.98, 1.0)
		st.set_corner_radius_all(28)
		st.border_width_left = 3
		st.border_width_top = 3
		st.border_width_right = 3
		st.border_width_bottom = 3
		st.border_color = Color(0.8, 0.9, 0.98)
		card.add_theme_stylebox_override("normal", st)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = v["icon"]
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 64)
		vbox.add_child(icon_lbl)
		
		var word_lbl = Label.new()
		word_lbl.text = v["word"]
		word_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		word_lbl.add_theme_font_size_override("font_size", 30)
		word_lbl.add_theme_color_override("font_color", Color(0.15, 0.45, 0.8))
		vbox.add_child(word_lbl)
		
		var kn_lbl = Label.new()
		kn_lbl.text = v["kn"]
		kn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		kn_lbl.add_theme_font_size_override("font_size", 22)
		kn_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		vbox.add_child(kn_lbl)
		
		card.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(v["word"])
		)
		grid_container.add_child(card)

# --- Spelling Logic ---
func _setup_spelling_round() -> void:
	current_target_word = spelling_words.pick_random()
	var word_str: String = current_target_word["word"]
	word_icon_lbl.text = current_target_word["icon"]
	SoundManager.speak_text(word_str)
	
	letters_needed.clear()
	for i in range(word_str.length()):
		letters_needed.append(word_str[i])
		
	letters_entered.clear()
	
	# Update slots
	_refresh_entered_slots()
	
	# Scramble letters
	for c in scramble_tile_box.get_children():
		c.queue_free()
		
	var scrambled = letters_needed.duplicate()
	scrambled.shuffle()
	
	for ch in scrambled:
		var tile = Button.new()
		tile.text = ch
		tile.custom_minimum_size = Vector2(95, 95)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.3, 0.65, 0.95)
		st.set_corner_radius_all(20)
		tile.add_theme_stylebox_override("normal", st)
		tile.add_theme_font_size_override("font_size", 48)
		tile.pressed.connect(func():
			_on_scramble_letter_tapped(tile, ch)
		)
		scramble_tile_box.add_child(tile)

func _refresh_entered_slots() -> void:
	for c in entered_tile_box.get_children():
		c.queue_free()
		
	var word_len = letters_needed.size()
	for i in range(word_len):
		var slot = PanelContainer.new()
		slot.custom_minimum_size = Vector2(95, 95)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.94, 0.96, 1.0)
		st.set_corner_radius_all(20)
		st.border_width_left = 3
		st.border_width_top = 3
		st.border_width_right = 3
		st.border_width_bottom = 3
		st.border_color = Color(0.75, 0.85, 0.95)
		slot.add_theme_stylebox_override("panel", st)
		
		var lbl = Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 48)
		lbl.add_theme_color_override("font_color", Color(0.15, 0.45, 0.8))
		
		if i < letters_entered.size():
			lbl.text = letters_entered[i]
		else:
			lbl.text = "_"
		slot.add_child(lbl)
		entered_tile_box.add_child(slot)

func _on_scramble_letter_tapped(btn: Button, char_val: String) -> void:
	SoundManager.play_pop()
	btn.disabled = true
	btn.modulate = Color(0.7, 0.7, 0.7, 0.5)
	
	letters_entered.append(char_val)
	_refresh_entered_slots()
	
	if letters_entered.size() == letters_needed.size():
		var spelled = "".join(letters_entered)
		if spelled == current_target_word["word"]:
			SoundManager.play_correct()
			GameManager.record_activity("english")
			celebration.show_celebration("Awesome Spelling! " + spelled + "! ⭐")
		else:
			SoundManager.play_wrong()
			await get_tree().create_timer(0.6).timeout
			_setup_spelling_round()
