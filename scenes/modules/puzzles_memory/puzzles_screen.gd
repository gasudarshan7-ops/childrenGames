extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control

# Modes: "memory", "jigsaw", "missing"
var current_mode: String = "memory"

# Memory card flip state
var card_icons = ["🐶", "🐱", "🦁", "🍎", "🍌", "⭐", "🚗", "🚀"]
var active_cards: Array = []
var first_card_idx: int = -1
var second_card_idx: int = -1
var is_checking: bool = false
var pairs_found: int = 0
var total_pairs: int = 4
var memory_grid: GridContainer

# Jigsaw state
var jigsaw_grid: GridContainer
var jigsaw_pieces: Array = []
var selected_piece_idx: int = -1

func _ready() -> void:
	_build_ui()
	_apply_age_difficulty()
	_set_mode("memory")

func _apply_age_difficulty() -> void:
	match GameManager.current_age_group:
		"toddler":
			total_pairs = 2 # 4 cards total (2x2)
		"preschool":
			total_pairs = 4 # 8 cards total
		"primary":
			total_pairs = 6 # 12 cards total
		_:
			total_pairs = 4

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.95, 0.94, 0.99)
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
	header.title_key = "mod_puzzles"
	vbox.add_child(header)
	
	# Mode Selection Pills
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 12)
	vbox.add_child(mode_bar)
	
	_add_mode_btn(mode_bar, "memory", "🃏 Card Match", Color(0.4, 0.4, 0.85))
	_add_mode_btn(mode_bar, "jigsaw", "🧩 Picture Jigsaw", Color(0.2, 0.75, 0.5))
	
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
	
	# Memory View
	var mem_scroll = ScrollContainer.new()
	mem_scroll.name = "MemoryView"
	mem_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.add_child(mem_scroll)
	
	memory_grid = GridContainer.new()
	memory_grid.columns = 3 if total_pairs <= 4 else 4
	memory_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	memory_grid.add_theme_constant_override("h_separation", 18)
	memory_grid.add_theme_constant_override("v_separation", 18)
	mem_scroll.add_child(memory_grid)
	
	# Jigsaw View
	var jig_vbox = VBoxContainer.new()
	jig_vbox.name = "JigsawView"
	jig_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	jig_vbox.add_theme_constant_override("separation", 24)
	content_panel.add_child(jig_vbox)
	
	var jig_title = Label.new()
	jig_title.text = "Tap two pieces to swap and arrange the picture!"
	jig_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	jig_title.add_theme_font_size_override("font_size", 30)
	jig_title.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	jig_vbox.add_child(jig_title)
	
	jigsaw_grid = GridContainer.new()
	jigsaw_grid.columns = 3
	jigsaw_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	jigsaw_grid.add_theme_constant_override("h_separation", 14)
	jigsaw_grid.add_theme_constant_override("v_separation", 14)
	jig_vbox.add_child(jigsaw_grid)
	
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
	btn.add_theme_font_size_override("font_size", 22)
	btn.pressed.connect(func():
		SoundManager.play_pop()
		_set_mode(mode_id)
	)
	parent.add_child(btn)

func _set_mode(mode_id: String) -> void:
	current_mode = mode_id
	var mv = find_child("MemoryView", true, false)
	var jv = find_child("JigsawView", true, false)
	mv.visible = (mode_id == "memory")
	jv.visible = (mode_id == "jigsaw")
	
	if mode_id == "memory":
		_start_memory_game()
	elif mode_id == "jigsaw":
		_start_jigsaw_game()

# --- Memory Card Logic ---
func _start_memory_game() -> void:
	pairs_found = 0
	first_card_idx = -1
	second_card_idx = -1
	is_checking = false
	active_cards.clear()
	
	for c in memory_grid.get_children():
		c.queue_free()
		
	var pool = card_icons.duplicate()
	pool.shuffle()
	var selected = pool.slice(0, total_pairs)
	var deck = []
	for s in selected:
		deck.append(s)
		deck.append(s)
	deck.shuffle()
	
	for i in range(deck.size()):
		var icon_str = deck[i]
		var card = Button.new()
		card.custom_minimum_size = Vector2(160, 200)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var back_st = StyleBoxFlat.new()
		back_st.bg_color = Color(0.4, 0.45, 0.85)
		back_st.set_corner_radius_all(24)
		card.add_theme_stylebox_override("normal", back_st)
		card.text = "❓"
		card.add_theme_font_size_override("font_size", 54)
		
		var card_data = {"icon": icon_str, "revealed": false, "btn": card, "index": i}
		active_cards.append(card_data)
		
		card.pressed.connect(func():
			_on_card_tapped(i)
		)
		memory_grid.add_child(card)

func _on_card_tapped(idx: int) -> void:
	if is_checking: return
	var c = active_cards[idx]
	if c["revealed"]: return
	
	SoundManager.play_pop()
	c["revealed"] = true
	c["btn"].text = c["icon"]
	
	# Flip appearance
	var front_st = StyleBoxFlat.new()
	front_st.bg_color = Color(0.95, 0.97, 1.0)
	front_st.set_corner_radius_all(24)
	front_st.border_width_left = 4
	front_st.border_width_top = 4
	front_st.border_width_right = 4
	front_st.border_width_bottom = 4
	front_st.border_color = Color(0.7, 0.8, 0.95)
	c["btn"].add_theme_stylebox_override("normal", front_st)
	
	if first_card_idx == -1:
		first_card_idx = idx
	else:
		second_card_idx = idx
		is_checking = true
		_check_match()

func _check_match() -> void:
	var c1 = active_cards[first_card_idx]
	var c2 = active_cards[second_card_idx]
	
	if c1["icon"] == c2["icon"]:
		# Match!
		SoundManager.play_correct()
		pairs_found += 1
		first_card_idx = -1
		second_card_idx = -1
		is_checking = false
		
		if pairs_found >= total_pairs:
			GameManager.record_activity("puzzles")
			celebration.show_celebration("Memory Genius! You matched all pairs! ⭐")
	else:
		# Mismatch
		SoundManager.play_wrong()
		await get_tree().create_timer(0.9).timeout
		if is_instance_valid(c1["btn"]) and is_instance_valid(c2["btn"]):
			c1["revealed"] = false
			c2["revealed"] = false
			c1["btn"].text = "❓"
			c2["btn"].text = "❓"
			var back_st = StyleBoxFlat.new()
			back_st.bg_color = Color(0.4, 0.45, 0.85)
			back_st.set_corner_radius_all(24)
			c1["btn"].add_theme_stylebox_override("normal", back_st)
			c2["btn"].add_theme_stylebox_override("normal", back_st)
		first_card_idx = -1
		second_card_idx = -1
		is_checking = false

# --- Jigsaw Puzzle Logic ---
func _start_jigsaw_game() -> void:
	selected_piece_idx = -1
	for c in jigsaw_grid.get_children():
		c.queue_free()
		
	# A 3x3 animal cartoon puzzle represented by ordered tiles
	var solution = ["🐘", "🦒", "🦁", "🐵", "🐯", "🐼", "🦊", "🐰", "🐨"]
	jigsaw_pieces = solution.duplicate()
	jigsaw_pieces.shuffle()
	
	for i in range(jigsaw_pieces.size()):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(150, 150)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.93, 0.96, 1.0)
		st.set_corner_radius_all(20)
		st.border_width_left = 3
		st.border_width_top = 3
		st.border_width_right = 3
		st.border_width_bottom = 3
		st.border_color = Color(0.8, 0.88, 0.98)
		btn.add_theme_stylebox_override("normal", st)
		btn.text = jigsaw_pieces[i]
		btn.add_theme_font_size_override("font_size", 64)
		
		btn.pressed.connect(func():
			_on_jigsaw_piece_tapped(i)
		)
		jigsaw_grid.add_child(btn)

func _on_jigsaw_piece_tapped(idx: int) -> void:
	SoundManager.play_pop()
	if selected_piece_idx == -1:
		selected_piece_idx = idx
		# Highlight selected
		var btn: Button = jigsaw_grid.get_child(idx)
		var st = btn.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
		st.border_color = Color(1.0, 0.7, 0.1)
		st.border_width_left = 6
		st.border_width_top = 6
		st.border_width_right = 6
		st.border_width_bottom = 6
		btn.add_theme_stylebox_override("normal", st)
	else:
		# Swap pieces
		var temp = jigsaw_pieces[selected_piece_idx]
		jigsaw_pieces[selected_piece_idx] = jigsaw_pieces[idx]
		jigsaw_pieces[idx] = temp
		
		# Refresh display
		for i in range(jigsaw_grid.get_child_count()):
			var btn: Button = jigsaw_grid.get_child(i)
			btn.text = jigsaw_pieces[i]
			var st = StyleBoxFlat.new()
			st.bg_color = Color(0.93, 0.96, 1.0)
			st.set_corner_radius_all(20)
			st.border_width_left = 3
			st.border_width_top = 3
			st.border_width_right = 3
			st.border_width_bottom = 3
			st.border_color = Color(0.8, 0.88, 0.98)
			btn.add_theme_stylebox_override("normal", st)
			
		selected_piece_idx = -1
		SoundManager.play_correct()
		
		# Check victory
		var solution = ["🐘", "🦒", "🦁", "🐵", "🐯", "🐼", "🦊", "🐰", "🐨"]
		var all_match = true
		for k in range(solution.size()):
			if jigsaw_pieces[k] != solution[k]:
				all_match = false
				break
		if all_match:
			GameManager.record_activity("puzzles")
			celebration.show_celebration("Spectacular! Jigsaw Solved! ⭐")

func _on_celebration_next() -> void:
	if current_mode == "memory":
		_start_memory_game()
	else:
		_start_jigsaw_game()
