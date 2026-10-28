extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control

# Modes: "explore", "sort_game", "quiz"
var current_mode: String = "explore"

var food_items = [
	# Fruits
	{"name": "Apple", "kn_name": "ಸೇಬು", "icon": "🍎", "is_fruit": true, "fact": "Apples are rich in fiber and keep your heart healthy!"},
	{"name": "Banana", "kn_name": "ಬಾಳೆಹಣ್ಣು", "icon": "🍌", "is_fruit": true, "fact": "Bananas give you quick energy to run and play!"},
	{"name": "Mango", "kn_name": "ಮಾವು", "icon": "🥭", "is_fruit": true, "fact": "Mango is the King of Fruits and packed with Vitamin A!"},
	{"name": "Orange", "kn_name": "ಕಿತ್ತಳೆ", "icon": "🍊", "is_fruit": true, "fact": "Oranges are loaded with Vitamin C for strong immunity!"},
	{"name": "Strawberry", "kn_name": "ಸ್ಟ್ರಾಬೆರಿ", "icon": "🍓", "is_fruit": true, "fact": "Strawberries are sweet, delicious, and good for teeth!"},
	{"name": "Watermelon", "kn_name": "ಕಲ್ಲಂಗಡಿ", "icon": "🍉", "is_fruit": true, "fact": "Watermelon keeps you fresh and hydrated on sunny days!"},
	# Vegetables
	{"name": "Carrot", "kn_name": "ಕ್ಯಾರೆಟ್", "icon": "🥕", "is_fruit": false, "fact": "Carrots are rich in Beta-Carotene for bright, sharp eyes!"},
	{"name": "Broccoli", "kn_name": "ಬ್ರೊಕೊಲಿ", "icon": "🥦", "is_fruit": false, "fact": "Broccoli looks like little trees and makes bones strong!"},
	{"name": "Tomato", "kn_name": "ಟೊಮೆಟೊ", "icon": "🍅", "is_fruit": false, "fact": "Juicy red tomatoes protect your skin and cells!"},
	{"name": "Potato", "kn_name": "ಆಲೂಗಡ್ಡೆ", "icon": "🥔", "is_fruit": false, "fact": "Potatoes give your muscles power and carbohydrates!"},
	{"name": "Corn", "kn_name": "ಜೋಳ", "icon": "🌽", "is_fruit": false, "fact": "Sweet golden corn helps your digestion and tummy!"},
	{"name": "Eggplant", "kn_name": "ಬದನೆಕಾಯಿ", "icon": "🍆", "is_fruit": false, "fact": "Eggplants protect brain cells and keep you clever!"}
]

# Sorting Game State
var sort_item: Dictionary
var sort_icon_lbl: Label
var sort_name_lbl: Label
var sort_fact_lbl: Label

# Views
var explore_view: ScrollContainer
var sort_view: VBoxContainer
var grid_container: GridContainer

func _ready() -> void:
	_build_ui()
	_populate_explore()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.97, 0.98, 0.93)
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
	header.title_key = "mod_fruits"
	vbox.add_child(header)
	
	# Mode Bar
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 14)
	vbox.add_child(mode_bar)
	
	_add_mode_btn(mode_bar, "explore", "🍎 Explore & Nutrition", Color(0.9, 0.35, 0.75))
	_add_mode_btn(mode_bar, "sort_game", "🧺 Sorting Basket Game", Color(0.2, 0.75, 0.45))
	
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
	
	# Explore View
	explore_view = ScrollContainer.new()
	explore_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	explore_view.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_panel.add_child(explore_view)
	
	grid_container = GridContainer.new()
	grid_container.columns = 2
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_theme_constant_override("h_separation", 20)
	grid_container.add_theme_constant_override("v_separation", 20)
	explore_view.add_child(grid_container)
	
	# Sort Game View
	sort_view = VBoxContainer.new()
	sort_view.alignment = BoxContainer.ALIGNMENT_CENTER
	sort_view.add_theme_constant_override("separation", 26)
	sort_view.visible = false
	content_panel.add_child(sort_view)
	
	var sort_prompt = Label.new()
	sort_prompt.text = "Is this a Fruit or a Vegetable?"
	sort_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sort_prompt.add_theme_font_size_override("font_size", 38)
	sort_prompt.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	sort_view.add_child(sort_prompt)
	
	# Item showcase card
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(400, 260)
	var c_st = StyleBoxFlat.new()
	c_st.bg_color = Color(0.96, 0.98, 1.0)
	c_st.set_corner_radius_all(30)
	c_st.border_width_left = 4
	c_st.border_width_top = 4
	c_st.border_width_right = 4
	c_st.border_width_bottom = 4
	c_st.border_color = Color(0.8, 0.9, 0.98)
	card.add_theme_stylebox_override("panel", c_st)
	sort_view.add_child(card)
	
	var c_vbox = VBoxContainer.new()
	c_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(c_vbox)
	
	sort_icon_lbl = Label.new()
	sort_icon_lbl.text = "🍎"
	sort_icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sort_icon_lbl.add_theme_font_size_override("font_size", 90)
	c_vbox.add_child(sort_icon_lbl)
	
	sort_name_lbl = Label.new()
	sort_name_lbl.text = "Apple"
	sort_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sort_name_lbl.add_theme_font_size_override("font_size", 36)
	sort_name_lbl.add_theme_color_override("font_color", Color(0.15, 0.45, 0.8))
	c_vbox.add_child(sort_name_lbl)
	
	sort_fact_lbl = Label.new()
	sort_fact_lbl.text = "Rich in fiber and Vitamin C!"
	sort_fact_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sort_fact_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sort_fact_lbl.add_theme_font_size_override("font_size", 22)
	sort_fact_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	sort_view.add_child(sort_fact_lbl)
	
	# Baskets Row
	var baskets_row = HBoxContainer.new()
	baskets_row.alignment = BoxContainer.ALIGNMENT_CENTER
	baskets_row.add_theme_constant_override("separation", 30)
	sort_view.add_child(baskets_row)
	
	var fruit_basket = Button.new()
	fruit_basket.text = "🧺 Fruit Basket\n(ಹಣ್ಣಿನ ಬುಟ್ಟಿ)"
	fruit_basket.custom_minimum_size = Vector2(280, 130)
	var f_st = StyleBoxFlat.new()
	f_st.bg_color = Color(1.0, 0.45, 0.45)
	f_st.set_corner_radius_all(28)
	fruit_basket.add_theme_stylebox_override("normal", f_st)
	fruit_basket.add_theme_font_size_override("font_size", 26)
	fruit_basket.pressed.connect(func():
		_on_basket_chosen(true)
	)
	baskets_row.add_child(fruit_basket)
	
	var veg_basket = Button.new()
	veg_basket.text = "🧺 Veggie Basket\n(ತರಕಾರಿ ಬುಟ್ಟಿ)"
	veg_basket.custom_minimum_size = Vector2(280, 130)
	var v_st = StyleBoxFlat.new()
	v_st.bg_color = Color(0.25, 0.78, 0.45)
	v_st.set_corner_radius_all(28)
	veg_basket.add_theme_stylebox_override("normal", v_st)
	veg_basket.add_theme_font_size_override("font_size", 26)
	veg_basket.pressed.connect(func():
		_on_basket_chosen(false)
	)
	baskets_row.add_child(veg_basket)
	
	celebration = CelebrationModalScript.new()
	add_child(celebration)
	celebration.next_pressed.connect(_setup_sort_round)
	celebration.replay_pressed.connect(_setup_sort_round)

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
		explore_view.visible = (mode_id == "explore")
		sort_view.visible = (mode_id == "sort_game")
		if mode_id == "sort_game":
			_setup_sort_round()
	)
	parent.add_child(btn)

func _populate_explore() -> void:
	for c in grid_container.get_children():
		c.queue_free()
		
	for f in food_items:
		var card = Button.new()
		card.custom_minimum_size = Vector2(0, 200)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.96, 0.98, 1.0)
		st.set_corner_radius_all(28)
		st.border_width_left = 3
		st.border_width_top = 3
		st.border_width_right = 3
		st.border_width_bottom = 3
		st.border_color = Color(0.85, 0.9, 0.98)
		card.add_theme_stylebox_override("normal", st)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = f["icon"]
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 64)
		vbox.add_child(icon_lbl)
		
		var name_lbl = Label.new()
		var n_text = f["kn_name"] if LocalizationManager.current_language == "kn" else f["name"]
		name_lbl.text = n_text + (" (Fruit)" if f["is_fruit"] else " (Veggie)")
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 26)
		name_lbl.add_theme_color_override("font_color", Color(0.15, 0.45, 0.8))
		vbox.add_child(name_lbl)
		
		var fact_lbl = Label.new()
		fact_lbl.text = f["fact"]
		fact_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fact_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fact_lbl.add_theme_font_size_override("font_size", 18)
		fact_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		vbox.add_child(fact_lbl)
		
		card.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(f["name"] + ". " + f["fact"])
		)
		grid_container.add_child(card)

func _setup_sort_round() -> void:
	sort_item = food_items.pick_random()
	sort_icon_lbl.text = sort_item["icon"]
	var n_str = sort_item["kn_name"] if LocalizationManager.current_language == "kn" else sort_item["name"]
	sort_name_lbl.text = n_str
	sort_fact_lbl.text = sort_item["fact"]
	SoundManager.speak_text(sort_item["name"])

func _on_basket_chosen(selected_fruit: bool) -> void:
	if selected_fruit == sort_item["is_fruit"]:
		SoundManager.play_correct()
		GameManager.record_activity("fruits")
		var category_name = "Fruit" if sort_item["is_fruit"] else "Vegetable"
		celebration.show_celebration("Correct! " + sort_item["name"] + " is a " + category_name + "! ⭐")
	else:
		SoundManager.play_wrong()
