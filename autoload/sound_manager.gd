extends Node

var sound_enabled: bool = true
var music_enabled: bool = true
var voice_enabled: bool = true

var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer

# Cache of procedural audio streams
var cached_sfx: Dictionary = {}

func _ready() -> void:
	# Create persistent audio stream players
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	
	voice_player = AudioStreamPlayer.new()
	voice_player.name = "VoicePlayer"
	add_child(voice_player)
	
	# Generate procedural audio clips
	_generate_procedural_sounds()
	_start_gentle_bgm()

func _generate_procedural_sounds() -> void:
	cached_sfx["pop"] = _synthesize_pop()
	cached_sfx["correct"] = _synthesize_arpeggio([523.25, 659.25, 783.99, 1046.5], 0.08) # C5, E5, G5, C6
	cached_sfx["wrong"] = _synthesize_arpeggio([349.23, 293.66], 0.15) # Gentle low notes F4, D4
	cached_sfx["star"] = _synthesize_twinkle()
	cached_sfx["fanfare"] = _synthesize_fanfare()

# Generates 16-bit Mono AudioStreamWAV procedurally
func _create_wav_stream(samples: PackedFloat32Array, sample_rate: int = 22050) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	var byte_array = PackedByteArray()
	byte_array.resize(samples.size() * 2)
	
	for i in range(samples.size()):
		var clamped = clampf(samples[i], -1.0, 1.0)
		var val_int = int(clamped * 32767.0)
		# Little endian 16-bit
		byte_array[i * 2] = val_int & 0xFF
		byte_array[i * 2 + 1] = (val_int >> 8) & 0xFF
		
	stream.data = byte_array
	return stream

func _synthesize_pop() -> AudioStreamWAV:
	var rate = 22050
	var dur = 0.09
	var total_samples = int(rate * dur)
	var samples = PackedFloat32Array()
	samples.resize(total_samples)
	
	for i in range(total_samples):
		var t = float(i) / rate
		var freq = 400.0 + (1.0 - t / dur) * 600.0 # pitch drop pop
		var env = exp(-t * 35.0)
		samples[i] = sin(t * TAU * freq) * env * 0.7
	return _create_wav_stream(samples, rate)

func _synthesize_arpeggio(freqs: Array, note_duration: float) -> AudioStreamWAV:
	var rate = 22050
	var total_dur = note_duration * freqs.size() + 0.2
	var total_samples = int(rate * total_dur)
	var samples = PackedFloat32Array()
	samples.resize(total_samples)
	
	for n in range(freqs.size()):
		var f = freqs[n]
		var start_time = n * note_duration
		var start_idx = int(start_time * rate)
		var note_samples = int((note_duration + 0.2) * rate)
		for s in range(note_samples):
			var idx = start_idx + s
			if idx < total_samples:
				var t = float(s) / rate
				var env = exp(-t * 6.0)
				# Sine with soft 2nd harmonic for warm marimba/chime sound
				var tone = sin(t * TAU * f) * 0.6 + sin(t * TAU * f * 2.0) * 0.2
				samples[idx] += tone * env * 0.4
				
	return _create_wav_stream(samples, rate)

func _synthesize_twinkle() -> AudioStreamWAV:
	var rate = 22050
	var dur = 0.45
	var total_samples = int(rate * dur)
	var samples = PackedFloat32Array()
	samples.resize(total_samples)
	
	for i in range(total_samples):
		var t = float(i) / rate
		var freq = 1200.0 + sin(t * 40.0) * 300.0
		var env = (1.0 - t / dur) * exp(-t * 4.0)
		samples[i] = (sin(t * TAU * freq) * 0.5 + sin(t * TAU * freq * 1.5) * 0.25) * env
	return _create_wav_stream(samples, rate)

func _synthesize_fanfare() -> AudioStreamWAV:
	var chords = [523.25, 659.25, 783.99, 1046.5, 1318.51] # C, E, G, C, E
	return _synthesize_arpeggio(chords, 0.1)

func _start_gentle_bgm() -> void:
	# Synthesize a gentle 4-bar soothing lullaby music loop
	var rate = 22050
	var notes = [261.63, 329.63, 392.00, 329.63, 293.66, 349.23, 440.00, 349.23] # C, E, G, E, D, F, A, F
	var beat_len = 0.5
	var total_dur = beat_len * notes.size()
	var total_samples = int(rate * total_dur)
	var samples = PackedFloat32Array()
	samples.resize(total_samples)
	
	for n in range(notes.size()):
		var f = notes[n]
		var start_time = n * beat_len
		var start_idx = int(start_time * rate)
		var note_samples = int(beat_len * 1.5 * rate)
		for s in range(note_samples):
			var idx = (start_idx + s) % total_samples
			var t = float(s) / rate
			var env = exp(-t * 2.8)
			var val = (sin(t * TAU * f) * 0.5 + sin(t * TAU * f * 0.5) * 0.3) * env * 0.2
			samples[idx] += val
			
	var bgm_stream = _create_wav_stream(samples, rate)
	bgm_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	bgm_stream.loop_end = total_samples
	
	music_player.stream = bgm_stream
	music_player.volume_db = -12.0
	if music_enabled:
		music_player.play()

# Public playback methods
func play_pop() -> void:
	if not sound_enabled: return
	sfx_player.stream = cached_sfx["pop"]
	sfx_player.pitch_scale = randf_range(0.95, 1.05)
	sfx_player.play()

func play_correct() -> void:
	if not sound_enabled: return
	sfx_player.stream = cached_sfx["correct"]
	sfx_player.pitch_scale = 1.0
	sfx_player.play()

func play_wrong() -> void:
	if not sound_enabled: return
	sfx_player.stream = cached_sfx["wrong"]
	sfx_player.pitch_scale = 1.0
	sfx_player.play()

func play_star() -> void:
	if not sound_enabled: return
	sfx_player.stream = cached_sfx["star"]
	sfx_player.pitch_scale = randf_range(1.0, 1.2)
	sfx_player.play()

func play_fanfare() -> void:
	if not sound_enabled: return
	sfx_player.stream = cached_sfx["fanfare"]
	sfx_player.pitch_scale = 1.0
	sfx_player.play()

func speak_text(text: String, lang_code: String = "en") -> void:
	if not voice_enabled: return
	
	# Check if native TTS is available in Godot
	var voices = DisplayServer.tts_get_voices()
	if voices.size() > 0:
		var voice_id = voices[0]["id"]
		# Look for matching language voice
		for v in voices:
			if lang_code in v.get("language", "").to_lower():
				voice_id = v["id"]
				break
		DisplayServer.tts_speak(text, voice_id, 45, 1.0, 1.0)
	else:
		# Fallback auditory notification
		play_pop()

func toggle_sound() -> bool:
	sound_enabled = !sound_enabled
	return sound_enabled

func toggle_music() -> bool:
	music_enabled = !music_enabled
	if music_enabled:
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()
	return music_enabled

func toggle_voice() -> bool:
	voice_enabled = !voice_enabled
	return voice_enabled
