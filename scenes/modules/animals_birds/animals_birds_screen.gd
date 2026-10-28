extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control

# Modes: "all", "domestic", "wild", "birds", "sea", "quiz"
var current_filter: String = "all"

var animals_data = [
	# Domestic
	{"name": "Dog", "kn_name": "ನಾಯಿ", "icon": "🐶", "sound": "Woof Woof!", "type": "domestic", "habitat": "Farm / Home"},
	{"name": "Cat", "kn_name": "ಬೆಕ್ಕು", "icon": "🐱", "sound": "Meow Meow!", "type": "domestic", "habitat": "Home"},
	{"name": "Cow", "kn_name": "ಹಸು", "icon": "🐮", "sound": "Moo Moo!", "type": "domestic", "habitat": "Farm"},
	{"name": "Horse", "kn_name": "ಕುದುರೆ", "icon": "🐴", "sound": "Neigh!", "type": "domestic", "habitat": "Farm"},
	{"name": "Sheep", "kn_name": "ಕುರಿ", "icon": "🐑", "sound": "Baa Baa!", "type": "domestic", "habitat": "Farm"},
	# Wild
	{"name": "Lion", "kn_name": "ಸಿಂಹ", "icon": "🦁", "sound": "Roaaar!", "type": "wild", "habitat": "Jungle"},
	{"name": "Tiger", "kn_name": "ಹುಲಿ", "icon": "🐯", "sound": "Grrr!", "type": "wild", "habitat": "Jungle"},
	{"name": "Elephant", "kn_name": "ಆನೆ", "icon": "🐘", "sound": "Trumpet Pawoo!", "type": "wild", "habitat": "Jungle"},
	{"name": "Monkey", "kn_name": "ಕೋತಿ", "icon": "🐵", "sound": "Ooh Ooh Aah Aah!", "type": "wild", "habitat": "Jungle Trees"},
	{"name": "Bear", "kn_name": "ಕರಡಿ", "icon": "🐻", "sound": "Growl!", "type": "wild", "habitat": "Forest"},
	# Birds
	{"name": "Parrot", "kn_name": "ಗಿಳಿ", "icon": "🦜", "sound": "Squawk!", "type": "birds", "habitat": "Sky / Trees"},
	{"name": "Owl", "kn_name": "ಗೂಬೆ", "icon": "🦉", "sound": "Hoot Hoot!", "type": "birds", "habitat": "Night Trees"},
	{"name": "Peacock", "kn_name": "ನವಿಲು", "icon": "🦚", "sound": "Mayura Screech!", "type": "birds", "habitat": "Gardens"},
	{"name": "Duck", "kn_name": "ಬಾತುಕೋಳಿ", "icon": "🦆", "sound": "Quack Quack!", "type": "birds", "habitat": "Pond / Water"},
	# Sea
	{"name": "Dolphin", "kn_name": "ಡಾಲ್ಫಿನ್", "icon": "🐬", "sound": "Click Whistle!", "type": "sea", "habitat": "Ocean"},
	{"name": "Whale", "kn_name": "ತಿಮಿಂಗಿಲ", "icon": "🐋", "sound": "Deep Song!", "type": "sea", "habitat": "Deep Sea"},
	{"name": "Octopus", "kn_name": "ಆಕ್ಟೋಪಸ್", "icon": "🐙", "sound": "Splash!", "type": "sea", "habitat": "Coral Reef"},
	{"name": "Crab", "kn_name": "ಏಡಿ", "icon": "🦀", "sound": "Click Clack!", "type": "sea", "habitat": "Beach Shore"}
]

var grid_container: GridContainer
var quiz_view: VBoxContainer
var scroll_view: ScrollContainer
var quiz_question_lbl: Label
var quiz_options_grid: GridContainer
var quiz_target: Dictionary

func _ready() -> void:
	_build_ui()
	_populate_animals()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.93, 0.97, 0.95)
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
	header.title_key = "mod_animals"
	vbox.add_child(header)
	
	# Filter bar
	var filter_bar = HBoxContainer.new()
	filter_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	filter_bar.add_theme_constant_override("separation", 10)
	vbox.add_child(filter_bar)
	
	_add_filter_btn(filter_bar, "all", "🐾 All", Color(0.3, 0.65, 0.95))
	_add_filter_btn(filter_bar, "domestic", "🏡 Farm", Color(0.2, 0.75, 0.45))
	_add_filter_btn(filter_bar, "wild", "🦁 Wild", Color(0.95, 0.5, 0.2))
	_add_filter_btn(filter_bar, "birds", "🦜 Birds", Color(0.7, 0.4, 0.85))
	_add_filter_btn(filter_bar, "sea", "🐬 Sea", Color(0.15, 0.75, 0.75))
	_add_filter_btn(filter_bar, "quiz", "❓ Quiz", Color(1.0, 0.4, 0.5))
	
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
	
	# Grid Scroll
	scroll_view = ScrollContainer.new()
	scroll_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_view.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_panel.add_child(scroll_view)
	
	grid_container = GridContainer.new()
	grid_container.columns = 2
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_theme_constant_override("h_separation", 20)
	grid_container.add_theme_constant_override("v_separation", 20)
	scroll_view.add_child(grid_container)
	
	# Quiz Container
	quiz_view = VBoxContainer.new()
	quiz_view.alignment = BoxContainer.ALIGNMENT_CENTER
	quiz_view.add_theme_constant_override("separation", 28)
	quiz_view.visible = false
	content_panel.add_child(quiz_view)
	
	quiz_question_lbl = Label.new()
	quiz_question_lbl.text = "Who says 'Woof Woof'?"
	quiz_question_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quiz_question_lbl.add_theme_font_size_override("font_size", 42)
	quiz_question_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	quiz_view.add_child(quiz_question_lbl)
	
	quiz_options_grid = GridContainer.new()
	quiz_options_grid.columns = 2
	quiz_options_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quiz_options_grid.add_theme_constant_override("h_separation", 24)
	quiz_options_grid.add_theme_constant_override("v_separation", 24)
	quiz_view.add_child(quiz_options_grid)
	
	celebration = CelebrationModalScript.new()
	add_child(celebration)
	celebration.next_pressed.connect(_setup_quiz)
	celebration.replay_pressed.connect(_setup_quiz)

func _add_filter_btn(parent: Control, filter_id: String, text: String, color: Color) -> void:
	var btn = Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 65)
	var st = StyleBoxFlat.new()
	st.bg_color = color
	st.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_font_size_override("font_size", 21)
	btn.pressed.connect(func():
		SoundManager.play_pop()
		current_filter = filter_id
		if filter_id == "quiz":
			scroll_view.visible = false
			quiz_view.visible = true
			_setup_quiz()
		else:
			scroll_view.visible = true
			quiz_view.visible = false
			_populate_animals()
	)
	parent.add_child(btn)

func _populate_animals() -> void:
	for c in grid_container.get_children():
		c.queue_free()
		
	for a in animals_data:
		if current_filter != "all" and a["type"] != current_filter:
			continue
			
		var card = Button.new()
		card.custom_minimum_size = Vector2(0, 180)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.95, 0.97, 1.0)
		st.set_corner_radius_all(28)
		st.border_width_left = 3
		st.border_width_top = 3
		st.border_width_right = 3
		st.border_width_bottom = 3
		st.border_color = Color(0.82, 0.88, 0.96)
		card.add_theme_stylebox_override("normal", st)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(vbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = a["icon"]
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 64)
		vbox.add_child(icon_lbl)
		
		var name_lbl = Label.new()
		var n_text = a["kn_name"] if LocalizationManager.current_language == "kn" else a["name"]
		name_lbl.text = n_text
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 28)
		name_lbl.add_theme_color_override("font_color", Color(0.15, 0.45, 0.8))
		vbox.add_child(name_lbl)
		
		var snd_lbl = Label.new()
		snd_lbl.text = a["sound"]
		snd_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		snd_lbl.add_theme_font_size_override("font_size", 20)
		snd_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		vbox.add_child(snd_lbl)
		
		card.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(a["name"] + " says " + a["sound"])
		)
		grid_container.add_child(card)

func _setup_quiz() -> void:
	quiz_target = animals_data.pick_random()
	
	if LocalizationManager.current_language == "kn":
		quiz_question_lbl.text = "ಯಾವ ಪ್ರಾಣಿಯು '" + quiz_target["sound"] + "' ಧ್ವನಿ ಮಾಡುತ್ತದೆ?"
	else:
		quiz_question_lbl.text = "Which animal says '" + quiz_target["sound"] + "'?"
		
	SoundManager.speak_text("Who says " + quiz_target["sound"])
	
	for c in quiz_options_grid.get_children():
		c.queue_free()
		
	var choices = [quiz_target]
	while choices.size() < 4:
		var r = animals_data.pick_random()
		if not r in choices:
			choices.append(r)
	choices.shuffle()
	
	for a in choices:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 160)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.92, 0.96, 1.0)
		st.set_corner_radius_all(30)
		btn.add_theme_stylebox_override("normal", st)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		btn.add_child(vbox)
		
		var ic = Label.new()
		ic.text = a["icon"]
		ic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ic.add_theme_font_size_override("font_size", 64)
		vbox.add_child(ic)
		
		var nl = Label.new()
		nl.text = a["kn_name"] if LocalizationManager.current_language == "kn" else a["name"]
		nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nl.add_theme_font_size_override("font_size", 26)
		nl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		vbox.add_child(nl)
		
		btn.pressed.connect(func():
			if a["name"] == quiz_target["name"]:
				SoundManager.play_correct()
				GameManager.record_activity("animals")
				celebration.show_celebration("Wonderful! The " + a["name"] + " says " + a["sound"] + "! ⭐")
			else:
				SoundManager.play_wrong()
		)
		quiz_options_grid.add_child(btn)
