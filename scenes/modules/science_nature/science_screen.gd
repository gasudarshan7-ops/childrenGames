extends Control

const HeaderBarScript = preload("res://components/header_bar.gd")
const CelebrationModalScript = preload("res://components/celebration_modal.gd")

var header: Control
var celebration: Control

# Modes: "day_night", "solar", "senses", "weather"
var current_mode: String = "day_night"

# Day/Night State
var is_daytime: bool = true
var day_night_sky: Panel
var day_icon_lbl: Label
var day_status_lbl: Label

# Planets Data
var planets = [
	{"name": "Sun", "icon": "☀️", "fact": "The Sun is a giant bright star that gives light and warmth to Earth!"},
	{"name": "Mercury", "icon": "🪨", "fact": "Mercury is the smallest planet and closest to the hot Sun!"},
	{"name": "Venus", "icon": "🟡", "fact": "Venus is the hottest planet with thick, swirling clouds!"},
	{"name": "Earth", "icon": "🌍", "fact": "Earth is our beautiful home planet with fresh water, air, and life!"},
	{"name": "Mars", "icon": "🔴", "fact": "Mars is known as the Red Planet and has huge tall volcanoes!"},
	{"name": "Jupiter", "icon": "🪐", "fact": "Jupiter is the biggest giant planet with a famous giant red storm spot!"},
	{"name": "Saturn", "icon": "🪐", "fact": "Saturn is famous for its breathtaking rings made of ice and rock!"}
]

# Senses Data
var senses = [
	{"sense": "Eyes - Sight", "icon": "👁️", "desc": "We see colorful rainbows, books, and flowers with our eyes!"},
	{"sense": "Ears - Hearing", "icon": "👂", "desc": "We listen to beautiful music, birds singing, and voices with our ears!"},
	{"sense": "Nose - Smell", "icon": "👃", "desc": "We smell sweet perfume, baking cookies, and fresh rain with our nose!"},
	{"sense": "Tongue - Taste", "icon": "👅", "desc": "We taste sweet mangoes, salty pretzels, and fresh milk with our tongue!"},
	{"sense": "Hands - Touch", "icon": "✋", "desc": "We feel soft bunny fur, warm blankets, and cold ice with our skin and hands!"}
]

# Weather Data
var weathers = [
	{"name": "Sunny Day", "icon": "☀️", "tip": "Wear sunglasses, drink fresh water, and play outdoors!"},
	{"name": "Rainy Day", "icon": "🌧️", "tip": "Take a colorful umbrella and splash gently in rain boots!"},
	{"name": "Snowy Day", "icon": "❄️", "tip": "Wear a warm woolly jacket and build a happy snowman!"},
	{"name": "Windy Day", "icon": "💨", "tip": "The breeze is blowing! A perfect day to fly a kite!"}
]

# View Containers
var day_vbox: VBoxContainer
var solar_scroll: ScrollContainer
var senses_scroll: ScrollContainer
var weather_scroll: ScrollContainer

func _ready() -> void:
	_build_ui()
	_set_mode("day_night")

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.94, 0.96, 0.98)
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
	header.title_key = "mod_science"
	vbox.add_child(header)
	
	# Mode Bar
	var mode_bar = HBoxContainer.new()
	mode_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_bar.add_theme_constant_override("separation", 10)
	vbox.add_child(mode_bar)
	
	_add_mode_btn(mode_bar, "day_night", "☀️ Day & Night", Color(0.2, 0.65, 0.95))
	_add_mode_btn(mode_bar, "solar", "🪐 Solar System", Color(0.5, 0.35, 0.85))
	_add_mode_btn(mode_bar, "senses", "🖐️ 5 Senses", Color(0.95, 0.5, 0.2))
	_add_mode_btn(mode_bar, "weather", "🌈 Weather", Color(0.25, 0.78, 0.45))
	
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
	
	# 1. Day & Night Simulator
	day_vbox = VBoxContainer.new()
	day_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	day_vbox.add_theme_constant_override("separation", 24)
	content_panel.add_child(day_vbox)
	
	day_night_sky = Panel.new()
	day_night_sky.custom_minimum_size = Vector2(600, 380)
	day_night_sky.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var sky_st = StyleBoxFlat.new()
	sky_st.bg_color = Color(0.4, 0.75, 0.98) # Sky blue
	sky_st.set_corner_radius_all(36)
	day_night_sky.add_theme_stylebox_override("panel", sky_st)
	day_vbox.add_child(day_night_sky)
	
	var sky_vbox = VBoxContainer.new()
	sky_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	day_night_sky.add_child(sky_vbox)
	
	day_icon_lbl = Label.new()
	day_icon_lbl.text = "☀️ ☁️"
	day_icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_icon_lbl.add_theme_font_size_override("font_size", 100)
	sky_vbox.add_child(day_icon_lbl)
	
	day_status_lbl = Label.new()
	day_status_lbl.text = "It is Daytime! The Sun is shining and flowers bloom."
	day_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	day_status_lbl.add_theme_font_size_override("font_size", 28)
	day_status_lbl.add_theme_color_override("font_color", Color.WHITE)
	sky_vbox.add_child(day_status_lbl)
	
	var toggle_day_btn = Button.new()
	toggle_day_btn.text = "🔄 Switch to Night / Day"
	toggle_day_btn.custom_minimum_size = Vector2(300, 80)
	var t_st = StyleBoxFlat.new()
	t_st.bg_color = Color(0.95, 0.55, 0.2)
	t_st.set_corner_radius_all(28)
	toggle_day_btn.add_theme_stylebox_override("normal", t_st)
	toggle_day_btn.add_theme_font_size_override("font_size", 28)
	toggle_day_btn.pressed.connect(_on_day_night_toggled)
	day_vbox.add_child(toggle_day_btn)
	
	# 2. Solar System Scroll
	solar_scroll = ScrollContainer.new()
	solar_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	solar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	solar_scroll.visible = false
	content_panel.add_child(solar_scroll)
	
	var solar_vbox = VBoxContainer.new()
	solar_vbox.name = "SolarBox"
	solar_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	solar_vbox.add_theme_constant_override("separation", 18)
	solar_scroll.add_child(solar_vbox)
	_populate_solar_system(solar_vbox)
	
	# 3. 5 Senses Scroll
	senses_scroll = ScrollContainer.new()
	senses_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	senses_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	senses_scroll.visible = false
	content_panel.add_child(senses_scroll)
	
	var senses_vbox = VBoxContainer.new()
	senses_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	senses_vbox.add_theme_constant_override("separation", 18)
	senses_scroll.add_child(senses_vbox)
	_populate_senses(senses_vbox)
	
	# 4. Weather Scroll
	weather_scroll = ScrollContainer.new()
	weather_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	weather_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	weather_scroll.visible = false
	content_panel.add_child(weather_scroll)
	
	var weather_vbox = VBoxContainer.new()
	weather_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weather_vbox.add_theme_constant_override("separation", 18)
	weather_scroll.add_child(weather_vbox)
	_populate_weather(weather_vbox)
	
	celebration = CelebrationModalScript.new()
	add_child(celebration)

func _add_mode_btn(parent: Control, mode_id: String, text: String, color: Color) -> void:
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
		_set_mode(mode_id)
	)
	parent.add_child(btn)

func _set_mode(mode_id: String) -> void:
	current_mode = mode_id
	day_vbox.visible = (mode_id == "day_night")
	solar_scroll.visible = (mode_id == "solar")
	senses_scroll.visible = (mode_id == "senses")
	weather_scroll.visible = (mode_id == "weather")

func _on_day_night_toggled() -> void:
	SoundManager.play_pop()
	is_daytime = !is_daytime
	var sky_st = StyleBoxFlat.new()
	sky_st.set_corner_radius_all(36)
	
	if is_daytime:
		sky_st.bg_color = Color(0.4, 0.75, 0.98) # Blue
		day_icon_lbl.text = "☀️ ☁️"
		day_status_lbl.text = "It is Daytime! The Sun is shining and flowers bloom."
		SoundManager.speak_text("Daytime! The sun is shining.")
	else:
		sky_st.bg_color = Color(0.1, 0.12, 0.28) # Deep night
		day_icon_lbl.text = "🌙 ⭐ 🦉"
		day_status_lbl.text = "It is Nighttime! The Moon & Stars sparkle while animals sleep."
		SoundManager.speak_text("Nighttime! The moon and stars sparkle.")
		
	day_night_sky.add_theme_stylebox_override("panel", sky_st)
	GameManager.record_activity("science")

func _populate_solar_system(parent: Control) -> void:
	for p in planets:
		var card = Button.new()
		card.custom_minimum_size = Vector2(0, 160)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.95, 0.96, 1.0)
		st.set_corner_radius_all(26)
		card.add_theme_stylebox_override("normal", st)
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 24)
		card.add_child(hbox)
		
		var ic = Label.new()
		ic.text = p["icon"]
		ic.add_theme_font_size_override("font_size", 64)
		hbox.add_child(ic)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(vbox)
		
		var nl = Label.new()
		nl.text = p["name"]
		nl.add_theme_font_size_override("font_size", 30)
		nl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		vbox.add_child(nl)
		
		var fl = Label.new()
		fl.text = p["fact"]
		fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fl.add_theme_font_size_override("font_size", 20)
		fl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		vbox.add_child(fl)
		
		card.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(p["name"] + ". " + p["fact"])
		)
		parent.add_child(card)

func _populate_senses(parent: Control) -> void:
	for s in senses:
		var card = Button.new()
		card.custom_minimum_size = Vector2(0, 160)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.96, 0.98, 0.95)
		st.set_corner_radius_all(26)
		card.add_theme_stylebox_override("normal", st)
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 24)
		card.add_child(hbox)
		
		var ic = Label.new()
		ic.text = s["icon"]
		ic.add_theme_font_size_override("font_size", 64)
		hbox.add_child(ic)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(vbox)
		
		var nl = Label.new()
		nl.text = s["sense"]
		nl.add_theme_font_size_override("font_size", 30)
		nl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		vbox.add_child(nl)
		
		var dl = Label.new()
		dl.text = s["desc"]
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dl.add_theme_font_size_override("font_size", 20)
		dl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		vbox.add_child(dl)
		
		card.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(s["sense"] + ". " + s["desc"])
		)
		parent.add_child(card)

func _populate_weather(parent: Control) -> void:
	for w in weathers:
		var card = Button.new()
		card.custom_minimum_size = Vector2(0, 160)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.94, 0.97, 1.0)
		st.set_corner_radius_all(26)
		card.add_theme_stylebox_override("normal", st)
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 24)
		card.add_child(hbox)
		
		var ic = Label.new()
		ic.text = w["icon"]
		ic.add_theme_font_size_override("font_size", 64)
		hbox.add_child(ic)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(vbox)
		
		var nl = Label.new()
		nl.text = w["name"]
		nl.add_theme_font_size_override("font_size", 30)
		nl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		vbox.add_child(nl)
		
		var tl = Label.new()
		tl.text = w["tip"]
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tl.add_theme_font_size_override("font_size", 20)
		tl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		vbox.add_child(tl)
		
		card.pressed.connect(func():
			SoundManager.play_pop()
			SoundManager.speak_text(w["name"] + ". " + w["tip"])
		)
		parent.add_child(card)
