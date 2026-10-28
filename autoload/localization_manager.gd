extends Node

signal language_changed(new_lang: String)

var current_language: String = "en" # "en" or "kn"

# Comprehensive localization dictionary
var strings = {
	"en": {
		# Common
		"app_title": "Kids Learning & Fun",
		"app_subtitle": "Play, Learn, Grow!",
		"play_now": "PLAY NOW!",
		"back": "Back",
		"next": "Next",
		"replay": "Replay",
		"stars": "Stars",
		"level": "Level",
		"score": "Score",
		"great_job": "Great Job!",
		"well_done": "Well Done!",
		"super_star": "Super Star!",
		"try_again": "Try Again!",
		"awesome": "Awesome!",
		"keep_it_up": "Keep Going!",
		
		# Age Groups
		"age_toddler": "Toddlers (2-4 Yrs)",
		"age_preschool": "Preschool (4-6 Yrs)",
		"age_primary": "Primary (6-10 Yrs)",
		
		# Categories / Main Buttons
		"mod_alphabet": "Alphabet ABC",
		"mod_alphabet_desc": "Letters, Phonics & Tracing",
		"mod_numbers": "Numbers & Math",
		"mod_numbers_desc": "Counting & Calculations",
		"mod_colors_shapes": "Colors & Shapes",
		"mod_colors_shapes_desc": "Vibrant Colors & Geometries",
		"mod_animals": "Animals & Birds",
		"mod_animals_desc": "Creatures, Sounds & Habitats",
		"mod_fruits": "Fruits & Veggies",
		"mod_fruits_desc": "Healthy Foods & Sorting",
		"mod_puzzles": "Memory & Puzzles",
		"mod_puzzles_desc": "Card Match, Jigsaws & Logic",
		"mod_english": "English Words",
		"mod_english_desc": "Vocabulary, Spelling & Speech",
		"mod_stories": "Stories & Rhymes",
		"mod_stories_desc": "Bedtime Tales & Melodies",
		"mod_science": "Science & Nature",
		"mod_science_desc": "Planets, Senses & Weather",
		"mod_rewards": "Trophy Room",
		"mod_rewards_desc": "Stars, Badges & Achievements",
		"mod_parent": "Parent Zone",
		"mod_parent_desc": "Controls, Progress & Safety",
		
		# Mascot Greetings
		"mascot_welcome": "Hello Friend! What shall we learn today?",
		"mascot_cheer": "You are doing amazing!",
		
		# Parent Dashboard & Safety
		"parent_gate_title": "Grown-ups Verification",
		"parent_gate_prompt": "Please solve this to enter:",
		"parent_gate_error": "Incorrect answer. Try again!",
		"settings_sound": "Sound Effects",
		"settings_music": "Background Music",
		"settings_voice": "Voice Narration",
		"settings_language": "Language",
		"settings_age_group": "Active Age Group",
		"settings_daily_limit": "Daily Play Limit (Minutes)",
		"settings_unlimited": "Unlimited",
		"settings_reset_progress": "Reset Progress",
		"settings_reset_confirm": "Are you sure you want to reset all stars and badges?",
		"privacy_title": "Child Safety & Privacy (COPPA Compliant)",
		"privacy_body": "This app is 100% child-safe, works completely offline, displays ZERO advertisements, contains NO external links or in-app purchases, and does NOT collect or share any personal information.",
		"stats_total_stars": "Total Stars Earned:",
		"stats_activities_done": "Activities Completed:",
		"stats_badges_unlocked": "Badges Unlocked:"
	},
	"kn": {
		# Common
		"app_title": "ಮಕ್ಕಳ ಕಲಿಕೆ ಮತ್ತು ಆಟ",
		"app_subtitle": "ಆಟವಾಡಿ, ಕಲಿಯಿರಿ, ಬೆಳೆಯಿರಿ!",
		"play_now": "ಈಗ ಆಡಿ!",
		"back": "ಹಿಂದಕ್ಕೆ",
		"next": "ಮುಂದೆ",
		"replay": "ಮತ್ತೆ ಆಡಿ",
		"stars": "ನಕ್ಷತ್ರಗಳು",
		"level": "ಹಂತ",
		"score": "ಅಂಕಗಳು",
		"great_job": "ಅದ್ಭುತ ಕೆಲಸ!",
		"well_done": "ಶಾಭಾಸ್!",
		"super_star": "ಸೂಪರ್ ಸ್ಟಾರ್!",
		"try_again": "ಇನ್ನೊಮ್ಮೆ ಪ್ರಯತ್ನಿಸಿ!",
		"awesome": "ಅತ್ಯುತ್ತಮ!",
		"keep_it_up": "ಮುಂದುವರಿಸಿ!",
		
		# Age Groups
		"age_toddler": "ಚಿಣ್ಣರು (2-4 ವರ್ಷ)",
		"age_preschool": "ಶಾಲಾಪೂರ್ವ (4-6 ವರ್ಷ)",
		"age_primary": "ಪ್ರಾಥಮಿಕ (6-10 ವರ್ಷ)",
		
		# Categories / Main Buttons
		"mod_alphabet": "ಅಕ್ಷರಮಾಲೆ (ABC / ವರ್ಣಮಾಲೆ)",
		"mod_alphabet_desc": "ಅಕ್ಷರಗಳು, ಉಚ್ಚಾರಣೆ ಮತ್ತು ಬರವಣಿಗೆ",
		"mod_numbers": "ಸಂಖ್ಯೆಗಳು ಮತ್ತು ಗಣಿತ",
		"mod_numbers_desc": "ಎಣಿಕೆ ಮತ್ತು ಲೆಕ್ಕಾಚಾರಗಳು",
		"mod_colors_shapes": "ಬಣ್ಣಗಳು ಮತ್ತು ಆಕಾರಗಳು",
		"mod_colors_shapes_desc": "ಸುಂದರ ಬಣ್ಣಗಳು ಮತ್ತು ಆಕೃತಿಗಳು",
		"mod_animals": "ಪ್ರಾಣಿಗಳು ಮತ್ತು ಪಕ್ಷಿಗಳು",
		"mod_animals_desc": "ಜೀವಿಗಳು, ಧ್ವನಿಗಳು ಮತ್ತು ವಾಸಸ್ಥಾನ",
		"mod_fruits": "ಹಣ್ಣುಗಳು ಮತ್ತು ತರಕಾರಿಗಳು",
		"mod_fruits_desc": "ಆರೋಗ್ಯಕರ ಆಹಾರ ಮತ್ತು ವಿಂಗಡಣೆ",
		"mod_puzzles": "ನೆನಪಿನ ಶಕ್ತಿ ಮತ್ತು ಒಗಟುಗಳು",
		"mod_puzzles_desc": "ಕಾರ್ಡ್ ಜೋಡಣೆ ಮತ್ತು ಚಿತ್ರಬಂಧ",
		"mod_english": "ಇಂಗ್ಲಿಷ್ ಕಲಿಕೆ",
		"mod_english_desc": "ಪದಕೋಶ, ಕಾಗುಣಿತ ಮತ್ತು ವಾಕ್ಯಗಳು",
		"mod_stories": "ಕಥೆಗಳು ಮತ್ತು ಹಾಡುಗಳು",
		"mod_stories_desc": "ನೀತಿ ಕಥೆಗಳು ಮತ್ತು ಕಂದಪದ್ಯಗಳು",
		"mod_science": "ವಿಜ್ಞಾನ ಮತ್ತು ಪ್ರಕೃತಿ",
		"mod_science_desc": "ಗ್ರಹಗಳು, ಪಂಚೇಂದ್ರಿಯಗಳು ಮತ್ತು ಹವಾಮಾನ",
		"mod_rewards": "ಪ್ರಶಸ್ತಿ ಕೊಠಡಿ",
		"mod_rewards_desc": "ನಕ್ಷತ್ರಗಳು, ಪದಕಗಳು ಮತ್ತು ಸಾಧನೆ",
		"mod_parent": "ಪೋಷಕರ ವಲಯ",
		"mod_parent_desc": "ನಿಯಂತ್ರಣಗಳು, ಪ್ರಗತಿ ಮತ್ತು ಭದ್ರತೆ",
		
		# Mascot Greetings
		"mascot_welcome": "ನಮಸ್ಕಾರ ಗೆಳೆಯಾ! ಇಂದು ಏನು ಕಲಿಯೋಣ?",
		"mascot_cheer": "ನೀವು ಅದ್ಭುತವಾಗಿ ಮಾಡುತ್ತಿದ್ದೀರಿ!",
		
		# Parent Dashboard & Safety
		"parent_gate_title": "ಪೋಷಕರ ಪರಿಶೀಲನೆ",
		"parent_gate_prompt": "ಮುಂದುವರಿಯಲು ಈ ಲೆಕ್ಕ ಬಿಡಿಸಿ:",
		"parent_gate_error": "ತಪ್ಪು ಉತ್ತರ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ!",
		"settings_sound": "ಧ್ವನಿ ಪರಿಣಾಮಗಳು",
		"settings_music": "ಹಿನ್ನೆಲೆ ಸಂಗೀತ",
		"settings_voice": "ಮಾತಿನ ನಿರೂಪಣೆ",
		"settings_language": "ಭಾಷೆ",
		"settings_age_group": "ಪ್ರಸ್ತುತ ವಯೋಮಾನ",
		"settings_daily_limit": "ದೈನಂದಿನ ಆಟದ ಮಿತಿ (ನಿಮಿಷ)",
		"settings_unlimited": "ಅನಿಯಮಿತ",
		"settings_reset_progress": "ಪ್ರಗತಿ ಮರುಹೊಂದಿಸಿ",
		"settings_reset_confirm": "ಎಲ್ಲಾ ನಕ್ಷತ್ರಗಳು ಮತ್ತು ಪದಕಗಳನ್ನು ಮರುಹೊಂದಿಸಲು ನೀವು ಖಚಿತವಾಗಿದ್ದೀರಾ?",
		"privacy_title": "ಮಕ್ಕಳ ಸುರಕ್ಷತೆ ಮತ್ತು ಗೌಪ್ಯತೆ (COPPA)",
		"privacy_body": "ಈ ಅಪ್ಲಿಕೇಶನ್ 100% ಮಕ್ಕಳ ಸುರಕ್ಷಿತವಾಗಿದೆ, ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಸಂಪೂರ್ಣವಾಗಿ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ, ಯಾವುದೇ ಜಾಹೀರಾತುಗಳನ್ನು ಪ್ರದರ್ಶಿಸುವುದಿಲ್ಲ, ಯಾವುದೇ ಬಾಹ್ಯ ಲಿಂಕ್‌ಗಳಿಲ್ಲ ಮತ್ತು ಯಾವುದೇ ವೈಯಕ್ತಿಕ ಮಾಹಿತಿಯನ್ನು ಸಂಗ್ರಹಿಸುವುದಿಲ್ಲ.",
		"stats_total_stars": "ಗಳಿಸಿದ ಒಟ್ಟು ನಕ್ಷತ್ರಗಳು:",
		"stats_activities_done": "ಪೂರ್ಣಗೊಂಡ ಚಟುವಟಿಕೆಗಳು:",
		"stats_badges_unlocked": "ಅನ್‌ಲಾಕ್ ಆದ ಪದಕಗಳು:"
	}
}

func tr_text(key: String) -> String:
	var lang_dict = strings.get(current_language, strings["en"])
	if lang_dict.has(key):
		return lang_dict[key]
	var fallback_dict = strings["en"]
	if fallback_dict.has(key):
		return fallback_dict[key]
	return key

func set_language(lang_code: String) -> void:
	if lang_code in ["en", "kn"]:
		current_language = lang_code
		language_changed.emit(current_language)

func toggle_language() -> String:
	if current_language == "en":
		set_language("kn")
	else:
		set_language("en")
	return current_language
