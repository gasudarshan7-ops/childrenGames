extends PanelContainer
class_name HeaderBar

signal back_pressed

@export var title_key: String = ""

var title_label: Label
var stars_label: Label
var sound_btn: Button
var back_btn: Button

func _ready() -> void:
	custom_minimum_size = Vector2(0, 110)
	
	# Background style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.55, 0.9, 0.95)
	style.corner_radius_bottom_left = 30
	style.corner_radius_bottom_right = 30
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	style.shadow_color = Color(0, 0, 0, 0.15)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	add_theme_stylebox_override("panel", style)
	
	# Build layout
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(hbox)
	
	# Back Button
	back_btn = Button.new()
	back_btn.text = "⬅ " + LocalizationManager.tr_text("back")
	back_btn.custom_minimum_size = Vector2(140, 75)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(1.0, 0.4, 0.45)
	btn_style.set_corner_radius_all(25)
	back_btn.add_theme_stylebox_override("normal", btn_style)
	var hover_style = btn_style.duplicate()
	hover_style.bg_color = Color(1.0, 0.5, 0.55)
	back_btn.add_theme_stylebox_override("hover", hover_style)
	back_btn.add_theme_font_size_override("font_size", 28)
	back_btn.pressed.connect(_on_back_pressed)
	hbox.add_child(back_btn)
	
	# Title
	title_label = Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.text = LocalizationManager.tr_text(title_key) if title_key != "" else "Kids Learning"
	title_label.add_theme_font_size_override("font_size", 34)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(title_label)
	
	# Stars Pill
	var star_pill = PanelContainer.new()
	var pill_style = StyleBoxFlat.new()
	pill_style.bg_color = Color(1.0, 0.8, 0.1)
	pill_style.set_corner_radius_all(22)
	pill_style.content_margin_left = 18
	pill_style.content_margin_right = 18
	pill_style.content_margin_top = 6
	pill_style.content_margin_bottom = 6
	star_pill.add_theme_stylebox_override("panel", pill_style)
	
	var star_box = HBoxContainer.new()
	var star_icon = Label.new()
	star_icon.text = "⭐"
	star_icon.add_theme_font_size_override("font_size", 28)
	star_box.add_child(star_icon)
	
	stars_label = Label.new()
	stars_label.text = str(GameManager.total_stars)
	stars_label.add_theme_font_size_override("font_size", 28)
	stars_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	star_box.add_child(stars_label)
	star_pill.add_child(star_box)
	hbox.add_child(star_pill)
	
	# Sound Toggle
	sound_btn = Button.new()
	sound_btn.text = "🔊" if SoundManager.sound_enabled else "🔇"
	sound_btn.custom_minimum_size = Vector2(75, 75)
	var snd_style = StyleBoxFlat.new()
	snd_style.bg_color = Color(0.3, 0.75, 0.4)
	snd_style.set_corner_radius_all(25)
	sound_btn.add_theme_stylebox_override("normal", snd_style)
	sound_btn.add_theme_font_size_override("font_size", 30)
	sound_btn.pressed.connect(_on_sound_toggle)
	hbox.add_child(sound_btn)
	
	GameManager.stars_updated.connect(_on_stars_updated)
	LocalizationManager.language_changed.connect(_on_lang_changed)

func set_title(key_or_text: String) -> void:
	title_key = key_or_text
	if title_label:
		title_label.text = LocalizationManager.tr_text(title_key)

func _on_back_pressed() -> void:
	SoundManager.play_pop()
	back_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/home/home_screen.tscn")

func _on_sound_toggle() -> void:
	var state = SoundManager.toggle_sound()
	sound_btn.text = "🔊" if state else "🔇"

func _on_stars_updated(val: int) -> void:
	if stars_label:
		stars_label.text = str(val)

func _on_lang_changed(_lang: String) -> void:
	if back_btn:
		back_btn.text = "⬅ " + LocalizationManager.tr_text("back")
	if title_label and title_key != "":
		title_label.text = LocalizationManager.tr_text(title_key)
