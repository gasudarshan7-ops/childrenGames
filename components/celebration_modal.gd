extends Control
class_name CelebrationModal

signal next_pressed
signal replay_pressed

var panel: PanelContainer
var title_lbl: Label
var subtitle_lbl: Label
var mascot_lbl: Label
var next_btn: Button
var replay_btn: Button

func _ready() -> void:
	# Full screen overlay
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	visible = false
	
	# Dimmed backdrop
	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.55)
	add_child(dim)
	
	# Center card
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 600)
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(1.0, 1.0, 1.0, 0.98)
	card_style.set_corner_radius_all(40)
	card_style.border_width_left = 10
	card_style.border_width_top = 10
	card_style.border_width_right = 10
	card_style.border_width_bottom = 10
	card_style.border_color = Color(1.0, 0.8, 0.2) # Golden border
	card_style.shadow_color = Color(0, 0, 0, 0.3)
	card_style.shadow_size = 20
	card_style.shadow_offset = Vector2(0, 10)
	card_style.content_margin_left = 40
	card_style.content_margin_right = 40
	card_style.content_margin_top = 40
	card_style.content_margin_bottom = 40
	panel.add_theme_stylebox_override("panel", card_style)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	panel.add_child(vbox)
	
	# Mascot / Trophy Icon
	mascot_lbl = Label.new()
	mascot_lbl.text = "🌟 🏆 🌟"
	mascot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mascot_lbl.add_theme_font_size_override("font_size", 72)
	vbox.add_child(mascot_lbl)
	
	# Title
	title_lbl = Label.new()
	title_lbl.text = LocalizationManager.tr_text("great_job")
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 48)
	title_lbl.add_theme_color_override("font_color", Color(0.15, 0.65, 0.3))
	vbox.add_child(title_lbl)
	
	# Subtitle / Reward
	subtitle_lbl = Label.new()
	subtitle_lbl.text = "+1 Star Added! ⭐"
	subtitle_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_lbl.add_theme_font_size_override("font_size", 34)
	subtitle_lbl.add_theme_color_override("font_color", Color(0.9, 0.6, 0.0))
	vbox.add_child(subtitle_lbl)
	
	# Buttons row
	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 30)
	vbox.add_child(btn_row)
	
	replay_btn = Button.new()
	replay_btn.text = "🔄 " + LocalizationManager.tr_text("replay")
	replay_btn.custom_minimum_size = Vector2(220, 80)
	var rep_style = StyleBoxFlat.new()
	rep_style.bg_color = Color(0.4, 0.65, 0.95)
	rep_style.set_corner_radius_all(30)
	replay_btn.add_theme_stylebox_override("normal", rep_style)
	replay_btn.add_theme_font_size_override("font_size", 30)
	replay_btn.pressed.connect(_on_replay_pressed)
	btn_row.add_child(replay_btn)
	
	next_btn = Button.new()
	next_btn.text = LocalizationManager.tr_text("next") + " ➔"
	next_btn.custom_minimum_size = Vector2(240, 80)
	var nxt_style = StyleBoxFlat.new()
	nxt_style.bg_color = Color(0.2, 0.8, 0.4)
	nxt_style.set_corner_radius_all(30)
	next_btn.add_theme_stylebox_override("normal", nxt_style)
	next_btn.add_theme_font_size_override("font_size", 32)
	next_btn.pressed.connect(_on_next_pressed)
	btn_row.add_child(next_btn)

func show_celebration(praise_text: String = "", award_star: bool = true) -> void:
	if praise_text != "":
		title_lbl.text = praise_text
	else:
		var praises = ["great_job", "well_done", "super_star", "awesome"]
		title_lbl.text = LocalizationManager.tr_text(praises.pick_random())
		
	replay_btn.text = "🔄 " + LocalizationManager.tr_text("replay")
	next_btn.text = LocalizationManager.tr_text("next") + " ➔"
	
	if award_star:
		GameManager.add_star(1)
		subtitle_lbl.text = "+1 Star Added! ⭐"
	else:
		subtitle_lbl.text = LocalizationManager.tr_text("keep_it_up")
		
	SoundManager.play_fanfare()
	visible = true
	
	# Punch pop-in animation
	panel.scale = Vector2(0.5, 0.5)
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.4)

func hide_celebration() -> void:
	visible = false

func _on_next_pressed() -> void:
	SoundManager.play_pop()
	hide_celebration()
	next_pressed.emit()

func _on_replay_pressed() -> void:
	SoundManager.play_pop()
	hide_celebration()
	replay_pressed.emit()
