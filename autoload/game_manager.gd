extends Node

signal age_group_changed(new_group: String)
signal stars_updated(new_total: int)
signal badge_unlocked(badge_id: String, badge_title: String)

enum AgeGroup {
	TODDLER,   # 2-4
	PRESCHOOL, # 4-6
	PRIMARY    # 6-10
}

var current_age_group: String = "preschool" # "toddler", "preschool", "primary"
var total_stars: int = 0
var completed_activities: Dictionary = {
	"alphabet": 0,
	"numbers": 0,
	"colors_shapes": 0,
	"animals": 0,
	"fruits": 0,
	"puzzles": 0,
	"english": 0,
	"stories": 0,
	"science": 0
}

var badges: Dictionary = {
	"first_star": false,
	"abc_explorer": false,
	"number_ninja": false,
	"color_artist": false,
	"animal_friend": false,
	"puzzle_master": false,
	"super_scholar": false
}

var daily_time_limit_minutes: int = 0 # 0 = unlimited
var session_playtime_seconds: float = 0.0

const SAVE_PATH: String = "user://kids_progress.json"

func _ready() -> void:
	load_progress()

func _process(delta: float) -> void:
	session_playtime_seconds += delta

func set_age_group(new_group: String) -> void:
	if new_group in ["toddler", "preschool", "primary"]:
		current_age_group = new_group
		age_group_changed.emit(current_age_group)
		save_progress()

func add_star(amount: int = 1) -> void:
	total_stars += amount
	stars_updated.emit(total_stars)
	SoundManager.play_star()
	
	if total_stars >= 1 and not badges["first_star"]:
		unlock_badge("first_star", "First Star!")
	if total_stars >= 25 and not badges["super_scholar"]:
		unlock_badge("super_scholar", "Super Scholar!")
		
	save_progress()

func record_activity(module_key: String) -> void:
	if completed_activities.has(module_key):
		completed_activities[module_key] += 1
	else:
		completed_activities[module_key] = 1
		
	# Check module badges
	if module_key == "alphabet" and completed_activities[module_key] >= 3:
		unlock_badge("abc_explorer", "Alphabet Explorer")
	elif module_key == "numbers" and completed_activities[module_key] >= 3:
		unlock_badge("number_ninja", "Number Ninja")
	elif module_key == "colors_shapes" and completed_activities[module_key] >= 3:
		unlock_badge("color_artist", "Color Artist")
	elif module_key == "animals" and completed_activities[module_key] >= 3:
		unlock_badge("animal_friend", "Animal Friend")
	elif module_key == "puzzles" and completed_activities[module_key] >= 3:
		unlock_badge("puzzle_master", "Puzzle Master")
		
	save_progress()

func unlock_badge(badge_id: String, badge_title: String) -> void:
	if badges.has(badge_id) and not badges[badge_id]:
		badges[badge_id] = true
		badge_unlocked.emit(badge_id, badge_title)
		SoundManager.play_fanfare()
		save_progress()

func get_recommended_module() -> String:
	match current_age_group:
		"toddler":
			return "alphabet"
		"preschool":
			return "numbers"
		"primary":
			return "science"
		_:
			return "alphabet"

func save_progress() -> void:
	var save_dict = {
		"current_age_group": current_age_group,
		"language": LocalizationManager.current_language,
		"total_stars": total_stars,
		"completed_activities": completed_activities,
		"badges": badges,
		"daily_limit": daily_time_limit_minutes,
		"sound_enabled": SoundManager.sound_enabled,
		"music_enabled": SoundManager.music_enabled,
		"voice_enabled": SoundManager.voice_enabled
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))
		file.close()

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var content = file.get_as_text()
	file.close()
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(content)
	if error == OK:
		var data = test_json_conv.data
		if data is Dictionary:
			current_age_group = data.get("current_age_group", "preschool")
			total_stars = int(data.get("total_stars", 0))
			daily_time_limit_minutes = int(data.get("daily_limit", 0))
			
			var acts = data.get("completed_activities", {})
			for k in acts.keys():
				completed_activities[k] = int(acts[k])
				
			var bdgs = data.get("badges", {})
			for b in bdgs.keys():
				badges[b] = bool(bdgs[b])
				
			var lang = data.get("language", "en")
			LocalizationManager.set_language(lang)
			
			SoundManager.sound_enabled = data.get("sound_enabled", true)
			SoundManager.music_enabled = data.get("music_enabled", true)
			SoundManager.voice_enabled = data.get("voice_enabled", true)

func reset_all_progress() -> void:
	total_stars = 0
	for k in completed_activities.keys():
		completed_activities[k] = 0
	for b in badges.keys():
		badges[b] = false
	save_progress()
	stars_updated.emit(total_stars)
