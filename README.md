# Kids Learning & Fun 🌟
### Child-Friendly Educational Games and Learning Support App (Ages 2–10)

Developed with **Godot Engine 4.7** and **GDScript** for Android smartphones and tablets (with cross-platform desktop testing support).

---

## 📱 App Highlights & Architecture

- **Age Adaptability**:
  - **Group 1: Toddlers (2–4 Years)** – Visual flashcards, simple counting, basic colors/shapes, animal sounds, auditory prompts.
  - **Group 2: Preschool (4–6 Years)** – A-Z letters, numbers 1-100, addition & subtraction, fruit & veggie sorting, memory match games.
  - **Group 3: Primary (6–10 Years)** – Multiplication & division, spelling scramble, science simulators (solar system, day/night, weather), logic puzzles.
- **Bilingual Support**: Instant toggle between **English** and **Kannada (ಕನ್ನಡ)** across all modules, voice narrations, and UI text.
- **Child Safety & COPPA Compliant**: 100% offline, zero ads, no telemetry or data collection, no in-app purchases, age-gated parental settings.
- **Audio & Animations**: Procedural audio synthesis for chimes, pops, star fanfares, and TTS speech synthesis with playful mascot animations.

---

## 📁 Project Structure

```
kids_learning_fun/
├── project.godot                     # Godot 4 Engine configuration
├── export_presets.cfg                # Android & Windows export configuration
├── debug.keystore                    # Android debug keystore
├── release.keystore                  # Android release keystore
├── autoload/
│   ├── game_manager.gd               # State, progress tracking, stars, badges & persistence
│   ├── sound_manager.gd              # Procedural audio synthesis, SFX, music & TTS narration
│   └── localization_manager.gd       # Bilingual English & Kannada strings dictionary
├── components/
│   ├── bouncy_button.gd              # Child-friendly squash-and-stretch button
│   ├── header_bar.gd                 # Navigation bar with back, title, stars & audio mute
│   └── celebration_modal.gd          # Reward popups with stars, fanfare & positive feedback
├── scenes/
│   ├── home/
│   │   ├── home_screen.tscn          # Main colorful animated home screen
│   │   └── home_screen.gd
│   ├── modules/
│   │   ├── alphabet/                 # Module A: Flashcards, Tracing & Quiz
│   │   ├── numbers/                  # Module B: Visual Counting, Math (+, -, ×, ÷), 1-100
│   │   ├── colors_shapes/            # Module C: Colors, Shapes & Freehand Drawing Canvas
│   │   ├── animals_birds/            # Module D: Farm, Wild, Birds, Sea Creatures & Sounds
│   │   ├── fruits_veggies/           # Module E: Food Flashcards & Basket Sorting Game
│   │   ├── puzzles_memory/           # Module F: Card Matching & Picture Jigsaws
│   │   ├── english/                  # Module G: Vocabulary, Greetings & Spelling Scramble
│   │   ├── stories_rhymes/           # Module H: Moral Stories & Nursery Rhymes with Audio
│   │   └── science_nature/           # Module I: Day/Night, Planets, 5 Senses & Weather
│   ├── rewards/                      # Trophy Room, Star counter & Badge Showcase
│   └── parent/                       # Protected Parent Dashboard with math gate & controls
├── assets/
│   └── icons/
│       └── app_icon.png              # Child-friendly 512x512 app icon
└── build/
    ├── android/
    │   ├── kids_learning_fun.apk     # Ready-to-install Signed Debug APK (86.5 MB)
    │   └── kids_learning_fun_release.apk # Signed Release APK (78.5 MB)
    └── windows/
        └── KidsLearningFun.exe       # Standalone Windows executable (103 MB)
```

---

## 🚀 How to Install and Run

### 1. Install APK on Android Device
Connect your Android phone or tablet via USB (or transfer the APK via Google Drive/WhatsApp/USB):
```powershell
# Using adb:
adb install -r build/android/kids_learning_fun.apk
```
*Alternatively, copy `kids_learning_fun.apk` or `kids_learning_fun_release.apk` to your phone's Downloads folder, open it in Files, and tap "Install".*

### 2. Run Directly on Windows
Double-click `build/windows/KidsLearningFun.exe` to run and test the complete app on your PC!

### 3. Open in Godot Editor
Open Godot Engine 4.x and import `project.godot` located in:
`C:\Users\hp\.gemini\antigravity\scratch\kids_learning_fun\project.godot`
