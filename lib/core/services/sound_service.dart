import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

/// Provider for the SoundService
final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

/// Provider for the sound enabled setting
final soundEnabledProvider = StateNotifierProvider<SoundEnabledNotifier, bool>((ref) {
  return SoundEnabledNotifier();
});

/// Notifier for the sound enabled setting
class SoundEnabledNotifier extends StateNotifier<bool> {
  SoundEnabledNotifier() : super(true) {
    _loadSoundPreference();
  }

  /// Loads the sound preference from shared preferences
  Future<void> _loadSoundPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final soundEnabled = prefs.getBool('sound_enabled') ?? true;
      state = soundEnabled;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load sound preference: $e');
      }
    }
  }

  /// Toggles the sound enabled setting
  Future<void> toggleSound() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', state);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save sound preference: $e');
      }
    }
  }

  /// Sets the sound enabled setting
  Future<void> setSoundEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', enabled);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save sound preference: $e');
      }
    }
  }
}

/// Service for playing sound effects
class SoundService {
  // AudioPlayer instances for different sound effects
  final AudioPlayer _buttonPlayer = AudioPlayer();
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _snapPlayer = AudioPlayer();
  
  // Flag to track initialization status
  bool _initialized = false;

  /// Initialize the sound service
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Configure each player to stop after playing once
      _buttonPlayer.setReleaseMode(ReleaseMode.stop);
      _correctPlayer.setReleaseMode(ReleaseMode.stop);
      _wrongPlayer.setReleaseMode(ReleaseMode.stop);
      _snapPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Prepare sound sources
      await _buttonPlayer.setSource(AssetSource('sounds/button.mp3'));
      await _correctPlayer.setSource(AssetSource('sounds/swipe_correct.mp3'));
      await _wrongPlayer.setSource(AssetSource('sounds/swipe_wrong.mp3'));
      await _snapPlayer.setSource(AssetSource('sounds/snap.mp3'));
      
      _initialized = true;
      
      if (kDebugMode) {
        print('Sound service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize sound service: $e');
      }
    }
  }

  /// Dispose of resources when service is no longer needed
  Future<void> dispose() async {
    await _buttonPlayer.dispose();
    await _correctPlayer.dispose();
    await _wrongPlayer.dispose();
    await _snapPlayer.dispose();
  }

  /// Play a sound effect if sound is enabled
  Future<void> playSound(String name, bool soundEnabled) async {
    if (!soundEnabled) return;
    if (!_initialized) await initialize();

    try {
      switch (name) {
        case 'button':
          await _buttonPlayer.resume();
          break;
        case 'swipe_correct':
          await _correctPlayer.resume();
          break;
        case 'swipe_wrong':
          await _wrongPlayer.resume();
          break;
        case 'snap':
          await _snapPlayer.resume();
          break;
        default:
          if (kDebugMode) {
            print('Unknown sound effect: $name');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play sound $name: $e');
      }
    }
  }

  /// Play button click sound
  Future<void> playButtonSound(bool soundEnabled) async {
    await playSound('button', soundEnabled);
  }

  /// Play correct swipe sound
  Future<void> playCorrectSwipeSound(bool soundEnabled) async {
    await playSound('swipe_correct', soundEnabled);
  }

  /// Play wrong swipe sound
  Future<void> playWrongSwipeSound(bool soundEnabled) async {
    await playSound('swipe_wrong', soundEnabled);
  }

  /// Play snap sound
  Future<void> playSnapSound(bool soundEnabled) async {
    await playSound('snap', soundEnabled);
  }
}
