extends Button
class_name BouncyButton

@export var base_color: Color = Color(0.25, 0.65, 1.0)
@export var click_sound: bool = true

var default_scale: Vector2 = Vector2.ONE
var tween: Tween

func _ready() -> void:
	pivot_offset = size / 2.0
	default_scale = scale
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	resized.connect(_on_resized)

func _on_resized() -> void:
	pivot_offset = size / 2.0

func _on_button_down() -> void:
	if click_sound and SoundManager:
		SoundManager.play_pop()
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", default_scale * 0.92, 0.08)

func _on_button_up() -> void:
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", default_scale * 1.08, 0.15)
	tween.tween_property(self, "scale", default_scale, 0.15)
